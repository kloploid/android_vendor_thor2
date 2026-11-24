# ALT AT-M140 (thor2): всё своё для GSI. Подключается из vendor/lineage-priv/keys/keys.mk (build.sh).
PRODUCT_PACKAGES += \
    ThorSubScreen \
    Thor2FrameworkOverlay \
    Thor2LineageOverlay

# Приложения NineTailsFlip (apps/: последние релизы с GitHub, apps/fetch.py). P9 и M9 — звонки и SMS
# по умолчанию (overlay/framework); L9 — рабочий стол на выбор при первом нажатии «Домой».
PRODUCT_PACKAGES += \
    NineTG9 \
    NineG9 \
    NineL9 \
    NineC9 \
    NineP9 \
    NineM9

PRODUCT_COPY_FILES += \
    vendor/thor2/keylayout/mtk-kpd.kl:$(TARGET_COPY_OUT_SYSTEM)/usr/keylayout/mtk-kpd.kl \
    vendor/thor2/keylayout/mtk-pmic-keys.kl:$(TARGET_COPY_OUT_SYSTEM)/usr/keylayout/mtk-pmic-keys.kl \
    vendor/thor2/keychars/mtk-kpd.kcm:$(TARGET_COPY_OUT_SYSTEM)/usr/keychars/mtk-kpd.kcm

# Крестовина доходит до панелей инструментов (ViewGroup.touchscreenBlocksFocus, патч frameworks_base 0003).
# ro.config.* читают все приложения (config_prop).
PRODUCT_SYSTEM_PROPERTIES += \
    ro.config.thor2_keypad_focus=true
