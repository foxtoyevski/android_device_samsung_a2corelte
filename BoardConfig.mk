#
# BoardConfig.mk for Samsung Galaxy A2 Core (SM-A260F/G)
# LineageOS 17.1 (Android 10)
#
# Port yontemi: Android 10, stok Oreo (API 27) vendor + in-tree A10 HAL'leri
# (samsungexynos7870 ailesinin lineage-17.1 yapisi). Platform arm64, vendor
# 32-bit stok bloblar.
#

# Bootloader
TARGET_NO_BOOTLOADER := true

# Platform
TARGET_BOARD_PLATFORM := exynos5
TARGET_BOARD_PLATFORM_GPU := mali-t830mp2
TARGET_BOOTLOADER_BOARD_NAME := universal7870_go

# Architecture (A2 = ARM/32-bit cihaz; Go 2GB. Platform arm32.)
# Not: 2nd arch YOK - stok Oreo vendor 32-bit, framework 32-bit.
TARGET_ARCH := arm
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi
TARGET_CPU_VARIANT := cortex-a53
TARGET_CPU_SMP := true

# Kernel (stock prebuilt, arm64 Image + Samsung DTBs)
TARGET_NO_KERNEL := false
TARGET_PREBUILT_KERNEL := device/samsung/a2corelte/prebuilt/kernel
BOARD_KERNEL_IMAGE_NAME := Image
TARGET_PREBUILT_DTB := device/samsung/a2corelte/prebuilt/dtb.img

# Soong kernel variables (prebuilt; only needed for lineageVarsPlugin export)
KERNEL_ARCH := arm64
KERNEL_CROSS_COMPILE :=
KERNEL_MAKE_FLAGS := -j4

# VNDK
BOARD_VNDK_VERSION := current

# VINTF device manifest (a3y17lte gibi): DEVICE_MANIFEST_FILE kullanilir; build
# sistemi (build/make/target/board/Android.mk) bu dosyadan assemble_vintf ile
# /vendor/etc/vintf/manifest.xml uretir ve BOARD_SEPOLICY_VERS
# (=PLATFORM_SEPOLICY_VERSION=29.0) sepolicy surumunu manifest'e enjekte eder.
# Boylece A10 isBuildConsistent() -> VintfObject.verifyWithoutAvb() sepolicy
# kontrolu gecer ve acilista "There's an internal problem with your device"
# diyalogu cikmaz (raw PRODUCT_COPY_FILES enjeksiyonu atliyordu -> sepolicy 0.0).
DEVICE_MANIFEST_FILE := device/samsung/a2corelte/vintf/manifest.xml

# RIL: stok Oreo seti (rild-a260f + stok libril.so + stok libsec-ril.so).
# Bu iki bayrak olmadan AOSP kaynak libril+librilutils ve AOSP rild
# derlenir, /vendor/lib/libril.so, /vendor/lib/librilutils.so ve
# /vendor/bin/hw/rild'de stok kopyalarla cakisan kurulum yapar.
# BOARD_PROVIDES_LIBRIL := true -> AOSP libril kapali (stok libril.so sahibi biziz)
# ENABLE_VENDOR_RIL_SERVICE  := true -> AOSP rild kapali (rild-a260f sahibi biziz)
BOARD_PROVIDES_LIBRIL := true
ENABLE_VENDOR_RIL_SERVICE := true

# HWComposer: A10 composer@2.x, stock HWC1.5 vendor libhwcomposer.so
# hwc2on1adapter ile kullanilir
BOARD_USES_EXYNOS5_COMMON_GRALLOC := true
BOARD_USES_HWC_SERVICES := true
TARGET_ADDITIONAL_GRALLOC_10_USAGE_BITS := 0x2000
TARGET_FORCE_HWC_FOR_VIRTUAL_DISPLAYS := true
TARGET_USES_GRALLOC1 := true
TARGET_USES_HWC2 := true

# Kernel config (prebuilt: bos gecici degere ayarlandi, derleme yok)
TARGET_KERNEL_CONFIG :=
TARGET_KERNEL_SOURCE := kernel/samsung/exynos7870

# Boot image (kernel + dtb; Exynos cmdline'i boot imajindan almaz)
BOARD_KERNEL_BASE := 0x10000000
BOARD_KERNEL_PAGESIZE := 2048
BOARD_KERNEL_CMDLINE :=
BOARD_MKBOOTIMG_ARGS := --kernel_offset 0x00008000 --ramdisk_offset 0x01000000 \
    --second_offset 0x00f00000 --tags_offset 0x00000100 --board SRPSB19D014KU \
    --dt device/samsung/a2corelte/prebuilt/dtb.img

# Android 10 non-SAR (calisan LOS16 duzeniyle ayni):
#   - system/core/init/Android.mk:44 -> BOARD_BUILD_SYSTEM_ROOT_IMAGE != true iken
#     "init_first_stage" (stem=init) binary'si TARGET_RAMDISK_OUT'a kurulur,
#     yani boot ramdisk'inde /init GERCEK bir binary olur.
#   - build/make/core/Makefile:955 -> SAR=false iken boot.img'ye --ramdisk eklenir.
# true iken ramdisk'te sadece "init -> /system/bin/init" symlink'i olur ve
# boot.img'ye hic ramdisk girmez => kernel /init bulamaz => panic/download modu.
# first_stage_init DT fstab'i okur: dtb.img icinde /firmware/android/fstab
# (system, vendor, odm) node'lari var, init bunlari ilk asamada mount eder.
BOARD_BUILD_SYSTEM_ROOT_IMAGE := false
BOARD_AVB_ENABLE := false

# Partitions (ayni partition boyutlari; vendor ayri imaj olarak kurulur)
BOARD_BOOTIMAGE_PARTITION_SIZE     := 0x002000000
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 0x002600000
BOARD_SYSTEMIMAGE_PARTITION_SIZE   := 1409286144 # 0x054000000, ondalik olmali (verity_utils int() ondalik bekler)
BOARD_USERDATAIMAGE_PARTITION_SIZE := 13757317120 # 0x334000000, ondalik olmali (verity_utils int() ondalik bekler)
BOARD_CACHEIMAGE_PARTITION_SIZE    := 0x002800000
BOARD_FLASH_BLOCK_SIZE             := 131072

# Vendor image
# Cihazdaki VENDOR partition: mmcblk0p19 = 180224 KB = 184549376 bayt.
# Onceki deger 276824064 (264MB) partition'dan buyuk oldugu icin OTA sirasinda
# "E2001: Failed to update vendor image" veriyordu. Gercek vendor verisi sadece
# ~23MB, bu deger rahatca sigiyor ve bosluk vermek icin tam partition kullanilir.
TARGET_COPY_OUT_VENDOR := vendor
BOARD_USES_VENDORIMAGE := true
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_VENDORIMAGE_PARTITION_SIZE   := 184549376 # 180224 KB, ondalik olmali (verity_utils int() ondalik bekler)

# Filesystem
BOARD_HAS_LARGE_FILESYSTEM := true
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true
BOARD_SUPPRESS_SECURE_ERASE := true

# Recovery
TARGET_RECOVERY_FSTAB := device/samsung/a2corelte/recovery.fstab
TARGET_RECOVERY_PIXEL_FORMAT := "ABGR_8888"

# System property file (system.prop in this directory is picked up automatically)
TARGET_SYSTEM_PROP := device/samsung/a2corelte/system.prop

# SEPolicy: A9'dan aktarilan cihaz kurallari + vendor tarafi
# A10'da vendor sepolicy dizinleri BOARD_SEPOLICY_DIRS icinde tanimlanir;
# build/make/core/soong_config.mk bu listeyi Soong tarafina
# "BoardVendorSepolicyDirs" olarak aktarir. Ayni dizini ayrica
# BOARD_VENDOR_SEPOLICY_DIRS'a eklemek vendor_file_contexts'a ayni dosyayi
# iki kez koyuyor ve m4/checkfc "Multiple same specifications" ile hata
# veriyordu. Tek kayit yeterli.
BOARD_SEPOLICY_DIRS += device/samsung/a2corelte/sepolicy

# Single-SIM (ssss): stok vendor tek radyo. SIM_COUNT=1, framework tek slot.
SIM_COUNT := 1

# WiFi BCM43436L: libwifi-hal'i libwifi-hal-bcm (gercek bcmdhd HAL) kaynagindan
# derletir. WPA_SUPPLICANT_VERSION bcmdhd config/Android.mk include'u icin
# gerekli (VER_0_8_X = modern yol). BOARD_WPA_SUPPLICANT_DRIVER=NL80211,
# wpa_supplicant Android.mk satir 11-12'de CONFIG_DRIVER_NL80211=y uretir;
# yoksa "No drivers enabled" ile cikar.
BOARD_WLAN_DEVICE := bcmdhd
WPA_SUPPLICANT_VERSION := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER := NL80211
# hostapd/Android.mk satir 10'da `WPA_BUILD_HOSTAPD := false` ile baslar; sadece
# BOARD_HOSTAPD_DRIVER set edilirse true olur (ve CONFIG_DRIVER_NL80211=y uretir).
# Yoksa hostapd modulu hic tanimlanmaz (hotspot icin zorunlu).
BOARD_HOSTAPD_DRIVER := NL80211
# iptables CT helper extension (CT --helper ftp/pptp) bu cihazin iptables
# build'inde YOK; netd TetherController CT satirlarini yollarsa iptables-restore
# patlar -> TetherController::setForwardRules -ENODEV -> IpServer
# IFACE_IP_MODE_CONFIGURATION_ERROR -> WifiServiceImpl.stopSoftAp ->
# hotspot 1 sn'de kendiliginden kapanir. Lineage product variable'i bu satirlari
# derlemeden cikarir (system/netd/server/Android.bp:120-121).
TARGET_IGNORES_FTP_PPTP_CONNTRACK_FAILURE := true

# --- Build kimligi (foxtoyevski) ---
# Default BUILD_NUMBER user adini sinirlar (BUILD_USERNAME:0:6). Nick ile
# tam eslesen fingerprint icin BUILD_NUMBER -> system/vendor/bootimage ucude
# ayni BUILD_NUMBER uzerinden fingerprint urettigi icin ucunu birden esitler:
#   ro.build.fingerprint / ro.vendor.build.fingerprint / ro.bootimage.build.fingerprint.
# A10 isBuildConsistent() bu ucunu karsilastirip uyumsuzlukta
# "internal problem" toast cikarir.
# BUILD_NUMBER kati .KATI_READONLY'dir: burada set edilemez, "cant assign
# to readonly variable" ile lunch'i kirar. Agacin kendi build kimligi
# build/make/core/version_defaults.mk:315'e 'eng.foxtoyevski.date' olarak
# sabitlendi.
# Vendor build.prop -> ro.vendor.build.security_patch (Ayarlar: "Uretici guvenlik yamasi
# duzeyi: Bilinmiyor" gosterimini duzeltir; make/core/Makefile:510 bu degiskene bakar).
VENDOR_SECURITY_PATCH := 2023-02-05

# ---------------------------------------------------------------------------
# Play / cihaz kimligi: stok A260F fingerprint'i (tum partition'larda tutarli).
# BUILD_FINGERPRINT onceden set edilirse build/make/core/Makefile:317-323 onu
# kullanir; ro.system.build.fingerprint / ro.vendor.build.fingerprint /
# ro.bootimage.build.fingerprint'in HEPSI bu tek degerden uretilir. Boylece
# isBuildConsistent() gecer ("internal problem" toast'i yok) ve Play ile
# uygulamalar cihazi SM-A260F (samsung/a2coreltejx) olarak tanir. Deger stok
# firmware'den (vstage/build.prop) birebir alindi. BUILD_THUMBPRINT ayni
# kimligi tamamlar (varsayilani yerine stok).
# ---------------------------------------------------------------------------
BUILD_FINGERPRINT := samsung/a2coreltejx/a2corelte:8.1.0/OPR6/A260FXXSEAUJ1:user/release-keys
BUILD_THUMBPRINT := 8.1.0/OPR6/A260FXXSEAUJ1:user/release-keys
