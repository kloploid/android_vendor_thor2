# ALT AT-M140 (thor2): всё своё для GSI. Подключается из vendor/lineage-priv/keys/keys.mk (build.sh).
PRODUCT_PACKAGES += \
    ThorSubScreen \
    Thor2FrameworkOverlay \
    Thor2LineageOverlay

PRODUCT_COPY_FILES += \
    vendor/thor2/keylayout/mtk-kpd.kl:$(TARGET_COPY_OUT_SYSTEM)/usr/keylayout/mtk-kpd.kl \
    vendor/thor2/keylayout/mtk-pmic-keys.kl:$(TARGET_COPY_OUT_SYSTEM)/usr/keylayout/mtk-pmic-keys.kl \
    vendor/thor2/keychars/mtk-kpd.kcm:$(TARGET_COPY_OUT_SYSTEM)/usr/keychars/mtk-kpd.kcm

# Крестовина доходит до панелей инструментов (ViewGroup.touchscreenBlocksFocus, патч frameworks_base 0003).
# ro.config.* читают все приложения (config_prop).
PRODUCT_SYSTEM_PROPERTIES += \
    ro.config.thor2_keypad_focus=true
