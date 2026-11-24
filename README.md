# vendor/thor2

Additions for a LineageOS GSI on the **ALT AT-M140 "MIVE Style Folder 2"** (codename `thor2`):
a Korean flip phone with a keypad and an external screen, MediaTek MT6765 (Helio P35).

Это всё, что нужно своей сборке LineageOS 23.2 (Android 16, `lineage_arm64_bvN4`) поверх
GSI, чтобы раскладушка работала как кнопочный телефон. Раскладывается в дерево исходников в
`vendor/thor2`.

## Что внутри

| Путь | Что это |
|---|---|
| `keylayout/mtk-kpd.kl` | Клавиатура раскладушки: цифры, `*`, `#`, крестовина и OK, софт-клавиши (левая — Меню, правая — Назад), Домой, Вызов, F1–F3, Камера, крышка (датчик Холла: SLEEP/WAKEUP). Нажатия будят экран. |
| `keylayout/mtk-pmic-keys.kl` | Красная кнопка — ENDCALL («отбой»: в разговоре завершает вызов, иначе домой/сон; долгое — меню выключения) и громкость. |
| `keychars/mtk-kpd.kcm` | Generic.kcm из AOSP, DEL с fallback на BACK. |
| `overlay/framework` | RRO для `android`: крестовина будит экран (`config_wakeOnDpadKeyPress`). |
| `overlay/lineage` | RRO для LineageOS: аппаратные кнопки Домой/Назад/Меню/громкость, долгое «Меню» — недавние приложения. |
| `thor2.mk` | Подключает всё это в сборку и выставляет `ro.config.thor2_keypad_focus=true`. |

## Подключение

В сборке `thor2.mk` подключался из `vendor/lineage-priv/keys/keys.mk`:

```make
$(call inherit-product, vendor/thor2/thor2.mk)
```

`thor2.mk` также ссылается на пакет **`ThorSubScreen`** (приложение для внешнего экрана:
часы, уведомления, плитки, курсор, действия клавиш F1–F3 и Камеры) — его исходников в этом
репозитории нет. Без него уберите `ThorSubScreen` из `PRODUCT_PACKAGES`.

Кнопки F1–F3, Камера, SOS и крышка доходят до приложения через патчи `frameworks/base`
(`PhoneWindowManager`), а D-pad до панелей инструментов — через патч `ViewGroup`
(читает `ro.config.thor2_keypad_focus`). Эти патчи тоже не входят сюда.

## Телефон

- 3 ГБ RAM, GPU PowerVR GE8320, ядро 5.10 GKI, vendor от Android 12 (VNDK 31).
- Сток — 32-битный Android Go; 64-битная система работает на vendor с 64-битными
  PowerVR-библиотеками от TECNO Spark 20C (тот же SoC и DDK).
