# Inherit from the common LineageOS product configuration
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# Inherit from our device configuration
$(call inherit-product, device/samsung/a2corelte/device.mk)

# Overlays
DEVICE_PACKAGE_OVERLAYS += \
    device/samsung/a2corelte/overlay

# VINTF: device manifest BoardConfig.mk'deki DEVICE_MANIFEST_FILE ile verilir
# (assemble_vintf -> /vendor/etc/vintf/manifest.xml, sepolicy surumu enjekte
# edilir). BOARD_VINTF_FRAGMENTS A10'da tuketilmiyor (no-op), kullanilmaz.

# Device identifiers
PRODUCT_DEVICE := a2corelte
PRODUCT_NAME := lineage_a2corelte
PRODUCT_BRAND := Samsung
PRODUCT_MODEL := Galaxy A2 Core
PRODUCT_MANUFACTURER := samsung

# Release name
PRODUCT_RELEASE_NAME := a2corelte



# Inherit from common tree



