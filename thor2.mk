# ALT AT-M140 (thor2): всё своё для GSI. Подключается из vendor/lineage-priv/keys/keys.mk (build.sh).
PRODUCT_PACKAGES += \
    ThorSubScreen \
    Thor2FrameworkOverlay \
    Thor2LineageOverlay

# Приложения NineTailsFlip (apps/: последние релизы с GitHub, apps/fetch.py). P9 и M9 — звонки и SMS
# по умолчанию (overlay/framework); L9 — единственный лаунчер (рабочий стол и «Недавние»,
# стоковый Launcher3QuickStep убран через overrides в apps/Android.bp).
PRODUCT_PACKAGES += \
    NineTG9 \
    NineG9 \
    NineL9 \
    NineC9 \
    NineP9 \
    NineM9 \
    NineK9

# Первая настройка в стиле Nine вместо LineageSetupWizard (apps/Android.bp: overrides). Шрифт и
# полосу подсказок, выбранные в ней, подхватывают все приложения Nine (nine-core SetupChoices);
# клавиатурой она с первого экрана делает K9 (NineK9).
PRODUCT_PACKAGES += \
    NineSetup

# Настройки в стиле Nine (settings9) открываются вместо стоковых: значок, шестерёнка в шторке и все
# android.settings.* из приложений. Стоковые Settings остаются для системных диалогов (сопряжение
# Bluetooth, FallbackHome, подтверждение PIN) и ещё не перенесённых страниц, без значка.
PRODUCT_PACKAGES += \
    NineSettings

PRODUCT_COPY_FILES += \
    vendor/thor2/keylayout/mtk-kpd.kl:$(TARGET_COPY_OUT_SYSTEM)/usr/keylayout/mtk-kpd.kl \
    vendor/thor2/keylayout/mtk-pmic-keys.kl:$(TARGET_COPY_OUT_SYSTEM)/usr/keylayout/mtk-pmic-keys.kl \
    vendor/thor2/keychars/mtk-kpd.kcm:$(TARGET_COPY_OUT_SYSTEM)/usr/keychars/mtk-kpd.kcm

# Крестовина доходит до панелей инструментов (ViewGroup.touchscreenBlocksFocus, патч frameworks_base 0003).
# ro.config.* читают все приложения (config_prop).
PRODUCT_SYSTEM_PROPERTIES += \
    ro.config.thor2_keypad_focus=true

# «Недавние» (долгая левая софт-клавиша) открывают экран L9 (patches/frameworks_base 0005); тот же
# компонент — config_recentsComponentName (overlay/framework).
PRODUCT_SYSTEM_PROPERTIES += \
    ro.config.thor2_recents=io.github.ninetailsflip.l9/life.furrer.l9.RecentsActivity
