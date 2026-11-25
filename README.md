# android_vendor_thor2

LineageOS for the ALT AT-M140 "MIVE Style Folder 2" (`thor2`), a keypad flip phone with an external screen.

This repository goes in `vendor/thor2` of a LineageOS source tree. With its patches to
`frameworks/base`, it turns a generic `arm64_bvN` GSI into a keypad phone: the D-pad and the
number keys work and wake the screen, the red key ends calls, the lid sleeps and wakes the phone,
the soft keys act as Menu and Back — and everything the user touches is in the
[NineTailsFlip](https://github.com/NineTailsFlip) look, from the first-time setup to the lock
screen.

## Features

- **Keys:** key layouts for the keypad and the PMIC keys; the D-pad wakes the screen; F1–F3,
  Camera, SOS and the lid handled by [ThorSubScreen](https://github.com/kloploid/android_packages_apps_ThorSubScreen).
- **No touchscreen needed:** no on-screen navigation buttons; D-pad focus reaches toolbars that
  normally block it.
- **The Nine apps built in:** launcher and Recents (L9), phone (P9), messages (M9), calendars and
  contacts (C9), gallery (G9), Telegram (TG9), keyboard (K9).
- **The system in the Nine look:** first-time setup (Setup), Settings, the lock screen (Lock);
  dark theme, monospace font and black surfaces for what's left of AOSP.

## Device

| | |
|---|---|
| Model | ALT AT-M140, "MIVE Style Folder 2" |
| Codename | `thor2` |
| SoC | MediaTek MT6765 (Helio P35) |
| GPU | PowerVR GE8320 |
| RAM | 3 GB |
| Kernel | 5.10 GKI |
| Stock vendor | Android 12 (VNDK 31), 32-bit Android Go userspace |
| Form factor | Flip phone, 12-key keypad, D-pad, soft keys, external screen, Hall sensor on the lid |

## Status

Built with **LineageOS 23.2 (Android 16)**, target `lineage_arm64_bvN4`, using
[MisterZtr](https://github.com/MisterZtr)'s GSI manifest and patches, on a 64-bit vendor image
that carries PowerVR libraries from the TECNO Spark 20C (same SoC and GPU driver version).

| Area | State |
|---|---|
| Graphics, camera, Wi-Fi, Bluetooth, sensors, modem, keypad, lid | Working (October 2026) |
| Calls with a SIM card | Not tested yet |
| Setup and K9 | Working (November 2026) |
| L9 as Recents, no navigation bar, Settings, Lock | New in November 2026, not yet verified on the phone |

## Project structure

```
vendor/thor2/
├── thor2.mk                        # Product makefile: packages, key files, properties
├── apps/
│   ├── fetch.py                    # Downloads the NineTailsFlip apps' latest releases
│   ├── Android.bp                  # Preinstalls them (in /product)
│   ├── privapp-permissions-*.xml   # What Setup, Settings and Lock may do
│   └── nine-l9-hiddenapi.xml       # Lets L9 manage tasks as the Recents screen
├── patches/
│   ├── apply.sh                    # Applies the patches below (safe to re-run)
│   ├── frameworks_base/            # 7 patches: key handling, lid, D-pad focus, Recents, lock screen
│   └── packages_apps_Launcher3/    # 1 patch: keypad navigation in the launcher
├── keylayout/
│   ├── mtk-kpd.kl                  # Keypad (mtk-kpd driver)
│   └── mtk-pmic-keys.kl            # PMIC keys: red key, volume
├── keychars/
│   └── mtk-kpd.kcm                 # Key character map (AOSP Generic.kcm, DEL falls back to BACK)
└── overlay/
    ├── framework/                  # Thor2FrameworkOverlay (RRO for android)
    └── lineage/                    # Thor2LineageOverlay (RRO for lineageos.platform)
```

## Key map

### Keypad (`mtk-kpd.kl`)

| Scancode | Android key | Wakes the screen | Notes |
|---:|---|:---:|---|
| 2 – 11 | `1` … `9`, `0` | ✓ | Number keys |
| 522 | `STAR` | ✓ | `*` |
| 523 | `POUND` | ✓ | `#` |
| 103, 108, 105, 106 | `DPAD_UP/DOWN/LEFT/RIGHT` | ✓ | Wakes through `config_wakeOnDpadKeyPress` |
| 28 | `ENTER` | ✓ | OK, in the middle of the D-pad |
| 580 | `MENU` | | Left soft key. A long press opens recent apps |
| 158 | `BACK` | | Right soft key |
| 172 | `HOME` | | |
| 14 | `DEL` | ✓ | Clear. Falls back to `BACK` outside text fields (`.kcm`) |
| 169 | `CALL` | ✓ | Green key |
| 59, 60, 61 | `F1`, `F2`, `F3` | ✓ | Contacts, messages, and notifications (a long press on F3 turns on cursor mode). ThorSubScreen assigns these and lets you change them |
| 212 | `CAMERA` | | Short press opens the camera, a long press toggles the flashlight (ThorSubScreen) |
| 142 / 143 | `SLEEP` / `WAKEUP` | | The lid (Hall sensor) closes / opens |

### PMIC keys (`mtk-pmic-keys.kl`)

| Scancode | Android key | Notes |
|---:|---|---|
| 116 | `ENDCALL` | Red key. During a call it ends the call. Otherwise it follows `END_BUTTON_BEHAVIOR` (home, sleep, or home then sleep). A long press opens the power menu |
| 115 | `VOLUME_UP` | |

## Overlays

**`Thor2FrameworkOverlay`** (target `android`)

- `config_wakeOnDpadKeyPress = true`: the D-pad wakes the screen. The keypad sits inside the flip, so it can't be pressed by accident while the lid is closed.
- **The Nine look for what's left of AOSP:**
  - dark theme by default (`config_defaultNightMode = 2`; this applies to fresh installs only);
  - the monospace system font (`monospace`, i.e. DroidSansMono, which has Cyrillic);
  - pure black backgrounds, dialogs and surfaces, with a white accent instead of a colour taken from the wallpaper.

  The palette follows [nine-core](https://github.com/NineTailsFlip/nine-core)'s `Palette`.
- `config_defaultDialer` / `config_defaultSms`: P9 and M9 (see below) are the default phone and SMS apps.
- `config_showNavigationBar = false`: no on-screen Back/Home/Recents; the phone has them as keys.
- `config_recentsComponentName`: L9's Recents screen (see below), in place of Launcher3 Quickstep, which isn't in the image.

**`Thor2LineageOverlay`** (target `lineageos.platform`)

- `config_deviceHardwareKeys = 71`, which is Home (1) + Back (2) + Menu (4) + Volume (64). These show up in *Settings → System → Buttons*. Camera (32) is left out on purpose, because ThorSubScreen handles it.
- `config_deviceHardwareWakeKeys = 71`.
- `config_longPressOnMenuBehavior = 2`: a long press on the left soft key opens recent apps: L9's screen, which `ro.config.thor2_recents` names for the `frameworks/base` patch `0005`.

`thor2.mk` also sets `ro.config.thor2_keypad_focus=true`, which a `ViewGroup` patch reads (see below).

## Preinstalled apps

`apps/` puts [NineTailsFlip](https://github.com/NineTailsFlip)'s keypad apps into `/product`:

| App | What it is |
|---|---|
| [TG9](https://github.com/NineTailsFlip/tg9) | Telegram |
| [G9](https://github.com/NineTailsFlip/g9) | Gallery |
| [L9](https://github.com/NineTailsFlip/l9) | Launcher, the only one: the home screen and Recents (Launcher3 Quickstep is left out through `overrides`; `nine-l9-hiddenapi.xml` lets L9 open and close other apps' tasks) |
| [C9](https://github.com/NineTailsFlip/c9) | Calendars and contacts |
| [P9](https://github.com/NineTailsFlip/p9) | Phone, the default dialer |
| [M9](https://github.com/NineTailsFlip/m9) | Messages, the default SMS app |
| [K9](https://github.com/NineTailsFlip/k9) | Keyboard (Traditional T9 on nine-core), the keyboard in use from the first screen |
| [Setup](https://github.com/NineTailsFlip/setup9) | The first-time setup, in place of LineageSetupWizard: language, Wi-Fi, K9's layouts, date and time, PIN, and the look of every Nine app |
| [Lock](https://github.com/NineTailsFlip/lock9) | The lock screen in the Nine look, over the keyguard (which stays the security boundary): it checks the PIN itself and SystemUI finishes the keyguard on its signal (patch `0006`) |
| [Settings](https://github.com/NineTailsFlip/settings9) | The phone's settings in the Nine look; it answers `android.settings.*` above the stock Settings app, which stays, without its icon, for the system's own dialogs and the pages not ported yet |

`apps/fetch.py` downloads each app's latest GitHub release into `apps/prebuilt/` (git-ignored)
and checks it against the release's `update.json`. For TG9 it takes the `arm64-v8a` APK. The
APKs keep their release signature (`presigned`), so the preinstalled copies update from GitHub
through the apps' own updater, like any installed copy - all but Setup, Settings and Lock, which the build re-signs
with the platform key as privileged apps (they set the system's language, time, Wi-Fi, lock and
the rest; `privapp-permissions-nine-setup.xml`, `-nine-settings.xml` and `-nine-lock.xml` list what they may), so they update only with the image. Run `fetch.py` before building; the
build fails without the APKs.

## Building

1. Add the repository to your local manifest, e.g. `.repo/local_manifests/thor2.xml`:

   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <manifest>
     <remote name="kloploid" fetch="https://github.com/kloploid/" />
     <project path="vendor/thor2" name="android_vendor_thor2" remote="kloploid" revision="main" />
   </manifest>
   ```

2. Inherit `thor2.mk` from a makefile your GSI target already includes:

   ```make
   $(call inherit-product-if-exists, vendor/thor2/thor2.mk)
   ```

   The original build pulled it in from `vendor/lineage-priv/keys/keys.mk`, which every signed
   LineageOS build includes.

3. Apply the patches after every `repo sync`, because syncing drops them. The script skips
   patches that are already applied. Then fetch the apps:

   ```bash
   vendor/thor2/patches/apply.sh .
   vendor/thor2/apps/fetch.py
   ```

4. Build:

   ```bash
   source build/envsetup.sh
   lunch lineage_arm64_bvN4-bp4a-userdebug
   m
   ```

## Flashing

The order that works on thor2 (active slot `b`):

1. Boot to fastbootd: `adb reboot fastboot`.
2. If `super` has no room for the system image, delete the stock `product_b` (and any leftover
   `*-cow` partitions): `fastboot delete-logical-partition product_b`. The GSI has its own
   `/product` inside system, and its `skip_mount.cfg` skips mounting the partition.
3. Flash the 64-bit vendor: `fastboot flash vendor vendor_stage2.img` (the stock 32-bit vendor
   can't run an arm64 GSI). It carries another phone's proprietary GPU libraries, so it isn't in
   this repository.
4. Flash the system: `fastboot flash system <image>`.
5. Reboot to the bootloader (`fastboot reboot bootloader`), then disable verification and wipe
   there — fastbootd on this phone has no Fastboot HAL, so `-w` doesn't work in it:
   ```bash
   fastboot --disable-verity --disable-verification flash vbmeta vbmeta_b.img   # the phone's own vbmeta, from a backup
   fastboot -w
   fastboot reboot
   ```

If the phone ends up in a boot loop, the MediaTek Preloader can put it in fastboot without keys:
answer its `READY` on the USB serial port with `FASTBOOT`.

Don't use `adb root` on this build: it drops USB until the next restart.

## Patches

| Repository | Patch | What it does |
|---|---|---|
| `frameworks/base` | `0001` PhoneWindowManager: forward SOS/volume keys to thor2 | Hands the SOS and volume keys to the external-screen app |
| | `0002` PhoneWindowManager: thor2 keypad keys, lid and home long press | Handles the keypad keys, the lid (Hall sensor) and a long press on Home |
| | `0003` ViewGroup: let D-pad focus reach touchscreenBlocksFocus groups | Toolbars that block focus in touch mode become reachable with the D-pad, when `ro.config.thor2_keypad_focus` is set |
| | `0004` PhoneFallbackEventHandler: pass camera and call keys through | Camera and Call reach apps instead of being taken by the system |
| | `0005` PhoneWindowManager: open the launcher's own recents screen | The Recents key starts the activity `ro.config.thor2_recents` names (L9's), since SystemUI has no Quickstep to show them |
| | `0006` SystemUI: let the thor2 lock screen app dismiss the keyguard | KeyguardViewMediator finishes the keyguard on `org.thor2.keyguard.action.UNLOCK` from an app holding `ACCESS_KEYGUARD_SECURE_STORAGE` (signature-only): Lock, after it checked the PIN |
| | `0007` PhoneWindowManager: Home does nothing on the thor2 lock screen | With `ro.config.thor2_lockscreen`'s app focused over the keyguard, Home is ignored instead of uncovering the stock keyguard |
| `packages/apps/Launcher3` | `0001` keypad navigation for thor2 flip phone | Moving around the launcher with the keypad (kept for builds that still include Launcher3; this image uses L9) |

`patches/apply.sh` applies them with `git am`, skipping any already applied, so it's safe to re-run.

## Related repositories

- **[ThorSubScreen](https://github.com/kloploid/android_packages_apps_ThorSubScreen)**
  (`packages/apps/ThorSubScreen`): the external screen, F1–F3, Camera and SOS, and a cursor.
  `thor2.mk` lists it in `PRODUCT_PACKAGES`; without it, F1–F3, Camera and SOS have nothing to go to.
- **[NineTailsFlip](https://github.com/NineTailsFlip)**: the apps `apps/` builds in.

## Contributing

Issues and pull requests are welcome. Say which LineageOS version and GSI target you build, and
include a `logcat` for anything that misbehaves on the phone.

## Credits

- [LineageOS](https://lineageos.org) and the Android Open Source Project.
- [MisterZtr](https://github.com/MisterZtr), for the LineageOS 23.2 GSI manifest and patches.
- [TrebleDroid](https://github.com/TrebleDroid) and phh, for making GSIs work on devices like this one.

## License

No license file yet. `keychars/mtk-kpd.kcm` is derived from AOSP's `Generic.kcm` and stays
under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0), as its header says.
