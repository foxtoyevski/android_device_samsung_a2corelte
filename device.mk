#
# device.mk for Samsung Galaxy A2 Core (SM-A260F/G)
# LineageOS 17.1 (Android 10)
#
# Yontem: A10 platform + stok Oreo (API 27) 32-bit vendor blob'lari.
# A9 (LOS16) agacindaki cihaz-spesifik baglanti (RIL, OMC/PLMN, VINTF,
# bt privapp) aynen tasindi; grafik/HAL kumu A10'un 7870 aile yapisina gore
# eklendi. Ramdisk init scriptleri A10'da /vendor/etc/init altina gider,
# cbd/sswap/watchdogd /vendor/bin'e, ueventd /vendor/ueventd.rc'ye.
#

# Inherit from the common product configuration
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)
$(call inherit-product, device/samsung/a2corelte/sounds.mk)

# AOSP kaynak RIL'ini devre disi birak:
# base_vendor.mk A10'da PRODUCT_PACKAGES'a "libreference-ril" ekliyor; o da
# kapali tutulan AOSP "libril" modulune bagimli (BOARD_PROVIDES_LIBRIL=true,
# stok Oreo libril.so.so kullaniliyor). Stok libreference-ril.so/librilutils.so
# PRODUCT_COPY_FILES ile geldigi icin AOSP kaynak surumu gereksiz ve kiri
# build'ini tetikleyen bagimliligi yapiyor.
PRODUCT_PACKAGES := $(filter-out libreference-ril,$(PRODUCT_PACKAGES))

LOCAL_PATH := device/samsung/a2corelte
DEVICE_PATH := $(LOCAL_PATH)

# Audio policy must use the XML configuration (stock /vendor has no legacy
# audio_policy.conf; 48k-only audmixer backend needs the XML policy).
USE_XML_AUDIO_POLICY_CONF := 1

# Stok vendor API 27 (Oreo); A10 vendor'es target-level=1.
PRODUCT_SHIPPING_API_LEVEL := 27

# Screen (td4101 540x960)
TARGET_SCREEN_HEIGHT := 960
TARGET_SCREEN_WIDTH := 540

# Boot animation density
PRODUCT_AAPT_CONFIG := normal
PRODUCT_AAPT_PREF_CONFIG := mdpi
PRODUCT_AAPT_PREBUILT_DPI := mdpi hdpi

# Build characteristics
PRODUCT_CHARACTERISTICS := phone

# --- Boot ramdisk -----------------------------------------------------------
# fstab: SYSTEM/VENDOR kernel tarafindan erken baglanir (Exynos DT yolu);
# ramdiskteki fstab /data, /cache, /efs baglarini yonetir.
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/fstab.samsungexynos7870:root/fstab.samsungexynos7870

# --- Exynos legacy HAL'leri -------------------------------------------------
# hw_get_module("memtrack") su sirayi deniyor:
#   1) ro.hardware.memtrack property'si -> /vendor/lib/hw/memtrack.<prop>.so
#   2) ro.hardware / ro.product.board varyantlari
#   3) varsayilan: /vendor/lib/hw/memtrack.default.so
# Stok Oreo HAL'i "memtrack.exynos5.so" adiyla geliyor ve A10'da hicbir
# varyant key'i "exynos5" degere sahip olmadigi icin bulunamiyordu:
#   E android.hardware.memtrack@1.0-impl: hw_get_module memtrack failed: -2
# Bu HAL olmadan HIDL passthrough servisi null donuyor, servis init tarafindan
# restart edilip duruyor ve sistem/core/libmemtrack IMemtrack::getService()'i
# sonsuza kadar bekliyor. Cikti: system_server ana thread'i Debug.getMemoryInfo
# icinde kilitleniyor, Watchdog olduruyor, boot hicbir zaman tamamlanmiyor.
# Cozum: HAL'i /vendor/lib/hw altina koy + ro.hardware.memtrack=exynos5.
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/prebuilt/vendor/memtrack.exynos5.so:$(TARGET_COPY_OUT_VENDOR)/lib/hw/memtrack.exynos5.so \
    $(DEVICE_PATH)/prebuilt/vendor/power.universal7870_go.so:$(TARGET_COPY_OUT_VENDOR)/lib/hw/power.universal7870_go.so \
    $(DEVICE_PATH)/prebuilt/vendor/lights.exynos5.so:$(TARGET_COPY_OUT_VENDOR)/lib/hw/lights.exynos5.so \
    $(DEVICE_PATH)/prebuilt/vendor/sensors.universal7870_go.so:$(TARGET_COPY_OUT_VENDOR)/lib/hw/sensors.universal7870_go.so

# --- Kamera zinciri --------------------------------------------------------
# provider@2.5-service SIGSEGV veriyordu:
#   #00 CameraModule::notifyDeviceStateChange(uint64_t)+8   (fault addr 0x8)
#   #01 LegacyCameraProviderImpl_2_5::notifyDeviceStateChange
#   #03 BnHwCameraProvider::_hidl_notifyDeviceStateChange
# fault addr 0x8 = hardware_module yapisinda notify_device_state_change alaninin
# ofseti -> demek ki CameraModule::mModule NULL. Sebep: vendor'da Exynos kamera
# HAL modulu YOKTU; sadece A10'un bos VTS stub'lari vardi
# (camera.device@1.0/3.2/3.3-impl.so). hw_get_module("camera") null donuyor.
# Cozum: stok Oreo kamera HAL'i + transitif bagimliliklari kurmak ve
# ro.hardware.camera=universal7870_go ile secmek (memtrack/power/light/sensors
# ile ayni desen).
# VINTF camera.provider surumu 2.5 oldugu icin A10 legacy provider ile
# birlikte calisir; 12 kutuphanenin hicbiri agacta tanimli KAYNAK modul
# olmadigi icin "overriding commands for target" catismasi olmaz.
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/prebuilt/vendor/camera.universal7870_go.so:$(TARGET_COPY_OUT_VENDOR)/lib/hw/camera.universal7870_go.so \
    $(DEVICE_PATH)/prebuilt/vendor/libexynoscamera3.so:$(TARGET_COPY_OUT_VENDOR)/lib/libexynoscamera3.so \
    $(DEVICE_PATH)/prebuilt/vendor/libexynoscamera.so:$(TARGET_COPY_OUT_VENDOR)/lib/libexynoscamera.so \
    $(DEVICE_PATH)/prebuilt/vendor/libexynosutils.so:$(TARGET_COPY_OUT_VENDOR)/lib/libexynosutils.so \
    $(DEVICE_PATH)/prebuilt/vendor/libexynosgscaler.so:$(TARGET_COPY_OUT_VENDOR)/lib/libexynosgscaler.so \
    $(DEVICE_PATH)/prebuilt/vendor/libexynosscaler.so:$(TARGET_COPY_OUT_VENDOR)/lib/libexynosscaler.so \
    $(DEVICE_PATH)/prebuilt/vendor/libhwjpeg.so:$(TARGET_COPY_OUT_VENDOR)/lib/libhwjpeg.so \
    $(DEVICE_PATH)/prebuilt/vendor/libcsc.so:$(TARGET_COPY_OUT_VENDOR)/lib/libcsc.so \
    $(DEVICE_PATH)/prebuilt/vendor/libion_exynos.so:$(TARGET_COPY_OUT_VENDOR)/lib/libion_exynos.so \
    $(DEVICE_PATH)/prebuilt/vendor/libstainkiller.so:$(TARGET_COPY_OUT_VENDOR)/lib/libstainkiller.so \
    $(DEVICE_PATH)/prebuilt/vendor/libuniapi.so:$(TARGET_COPY_OUT_VENDOR)/lib/libuniapi.so \
    $(DEVICE_PATH)/prebuilt/vendor/libuniplugin.so:$(TARGET_COPY_OUT_VENDOR)/lib/libuniplugin.so

# Oreo kamera HAL'i libcamera_client.so'ya bagli, ama A10 bu libi VNDK'den
# cikardi; vendor process /system/lib'i goremedigi icin HAL sunucu surecinde
# dlopen basarisiz oluyordu:
#   E/vndksupport: dlopen failed: library "libcamera_client.so" not found
#   E/CamPrvdr@2.4-legacy: Could not load camera HAL module: -22
# Cozum: agacin kendi urettigi A10 libcamera_client.so'yu vendor'a kopyala.
# Bagimliliklarinin tamami VNDK (libcutils/libutils/liblog/libbinder/libgui/
# libcamera_metadata/libnativewindow/libc++), yani vendor namespace'te gorunur.
# Bu yuzden TARGET_PROCESS_SDK_VERSION_OVERRIDE gerekmez (zaten API 29).
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/prebuilt/vendor/libcamera_client.so:$(TARGET_COPY_OUT_VENDOR)/lib/libcamera_client.so

# Vendor linker namespace'i /system/lib'i GORMEZ. /system/etc/ld.config.29.txt
# icindeki "vendor" bolumunde:
#   namespace.default.search.paths = /odm/${LIB} + /vendor/${LIB}
# Sistem liblerine sadece iki izin listesi uzerinden erisilir:
#   namespace.default.link.system.shared_libs  (24 lib: libEGL, liblog, libc...)
#   namespace.default.link.vndk.shared_libs    (268 lib: libbinder, libui, libion...)
# "libgui.so" bu iki listede YOK. libcamera_client.so onu DT_NEEDED olarak
# istedigi icin kamera HAL'i sunucu surecinde artik su hatayi veriyordu:
#   E/vndksupport: dlopen failed: library "libgui.so" not found
# Cozum: kamera HAL zincirinin geri kalani icin gereken 5 sistem libini
# vendor'a kurmak (toplam 1.14 MB). Bunlarin bagimliliklarinin tamami
# izin listelerinde oldugu icin baska eksik kalmaz.
# Agacin kendi A10 cikislaridir; TARGET_PROCESS_SDK_VERSION_OVERRIDE gerekmez.
# PRODUCT_COPY_FILES kullanilmaz: android.frameworks.bufferhub@1.0.so yolu
# zaten Soong'un hidl_interface modulu tarafindan sahiplenildigi icin
# "overriding commands for target" hatasi verir. Bunun yerine
# prebuilt/vendor/Android.bp icinde cc_prebuilt_library_shared olarak
# tanimlanip shared_libs ile HIDL bagimliligi Soong'a birakildi; boylece
# Soong android.frameworks.bufferhub@1.0.so'yu vendor'a da kuruyor.
PRODUCT_PACKAGES += \
    libgui.so

# libsensorndkbridge — Oreo kamera HAL'inin sensor dongusu icin gerekli.
# Samsung'in libsensorlistener.so'su bunu DT_NEEDED ile istiyor. Modul agacin
# kendi kaynagindan derlenir (vendor: true); ALooperForCameraLegacy.cpp icindeki
# shim sayesinde Oreo'nun kaldirilmis ALooper_*_forCamera API'sini de saglar.
# Once stok Oreo blob'u prebuilt olarak denenmisti ama agacin kaynak modulu de
# ayni yola kuruldugu icin:
#   error: overriding commands for target `.../vendor/lib/libsensorndkbridge.so'
PRODUCT_PACKAGES += libsensorndkbridge

PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/prebuilt/vendor/hw/gralloc.exynos5.so:$(TARGET_COPY_OUT_VENDOR)/lib/hw/gralloc.exynos5.so

# Stok Oreo blob'lari: VNDK API 29 kontrolune takilmasinlar.
TARGET_PROCESS_SDK_VERSION_OVERRIDE += \
    /vendor/lib/hw/camera.universal7870_go.so=27 \
    /vendor/lib/libexynoscamera3.so=27 \
    /vendor/lib/libexynoscamera.so=27 \
    /vendor/lib/libexynosutils.so=27 \
    /vendor/lib/libexynosgscaler.so=27 \
    /vendor/lib/libexynosscaler.so=27 \
    /vendor/lib/libhwjpeg.so=27 \
    /vendor/lib/libcsc.so=27 \
    /vendor/lib/libion_exynos.so=27 \
    /vendor/lib/libstainkiller.so=27 \
    /vendor/lib/libuniapi.so=27 \
    /vendor/lib/libuniplugin.so=27

# --- Ses zinciri -----------------------------------------------------------
# GERCEK KOK NEDEN (audioserver SIGSEGV -> media.audio_policy hic kaydedilmiyor
# -> AudioService.<init> sonsuza kadar bekliyor -> Watchdog):
#
#   #00 VolumeGroup::addSupportedStream()+16   (fault addr 0x68)
#   #01 EngineBase::loadAudioPolicyEngineConfig()+936
#   #02 Engine::Engine()  #04 AudioPolicyManager::initialize()
#   #06 AudioPolicyService::onFirstRef()  #07 BinderService::publish()
#
# EngineBase.cpp:105-110'daki find_if, strategyGroups icindeki volumeGroup
# adini volumeGroups'ta arar; ALOG_ASSERT derlenmis oldugu icin bulunamazsa
# sessizce end() uzerinden null dereference olur.
#
# Agacta HICBIR audio policy config kurulmuyordu:
# frameworks/av/services/audiopolicy/config/ icinde Android.mk/Android.bp
# YOK, o yuzden /system/etc/audio_policy_configuration.xml hic olusmuyor ve
# engineConfig::parse() surec sonrasi "libxml failed to resolve XIncludes"
# ile nullptr donuyor. EngineBase o zaman bozuk fallback'e dusuyor:
#   config = gDefaultEngineConfig  (EngineDefaultConfig.h)
# gOrderedStrategies'taki STRATEGY_ENFORCED_AUDIBLE / _ACCESSIBILITY /
# _SONIFICATION_RESPECTFUL gruplari volumeGroup "" referansi tasiyor, ancak
# gDefaultEngineConfig.volumeGroups yalnizca phone/sco/ring/alarm/music/system
# iceriyor -> isim tutmaz -> crash.
#
# COZUM: XInclude'larinin tamami cozulebilen A10 config setini /system/etc'e
# kur. Ana dosya cihza ailesinin kendi A10 config'i; parcalar framework'in
# kendi config dizininden (a2dp_in/bluetooth/usb/r_submix/audio_policy_volumes/
# default_volume_tables). Boylece parse() basarili olur ve fallback'e hic
# girilmez.
A10_CFG := frameworks/av/services/audiopolicy/config
COMMON_CFG := device/samsung/universal7870-common/configs/audio
PRODUCT_COPY_FILES += \
    $(COMMON_CFG)/audio_policy_configuration.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/audio_policy_configuration.xml \
    $(COMMON_CFG)/audio_effects.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/audio_effects.xml \
    $(COMMON_CFG)/audio_effects.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_effects.xml \
    $(A10_CFG)/a2dp_in_audio_policy_configuration.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/a2dp_in_audio_policy_configuration.xml \
    $(A10_CFG)/bluetooth_audio_policy_configuration.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/bluetooth_audio_policy_configuration.xml \
    $(A10_CFG)/usb_audio_policy_configuration.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/usb_audio_policy_configuration.xml \
    $(A10_CFG)/r_submix_audio_policy_configuration.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/r_submix_audio_policy_configuration.xml \
    $(A10_CFG)/audio_policy_volumes.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/audio_policy_volumes.xml \
    $(A10_CFG)/default_volume_tables.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/default_volume_tables.xml
# audio_effects.xml ayni zamanda vendor'a da kopyalanir: efekt config'i
# ses HAL'i (hal_audio_default) EffectsConfig ile okuyor ve SELinux
# hal_audio_default'a /system/etc dosyasi (system_file) read izni vermiyor
# (avc: denied { read } name="audio_effects.xml"). Dosya /vendor/etc'ye
# konursa file_contexts 338. kural (vendor/etc -> vendor_configs_file)
# devreye girer; domain.te'deki domain-wide vendor_configs_file read izniyle
# HAL rahatca okur (DEFAULT_LOCATIONS: /odm/etc, /vendor/etc, /system/etc).

# Exynos primary ses HAL'i ve vendor'a ait mimari kutuphaneler.
# Secim ro.hardware.audio.primary=universal7870_go ile yapilir; hw_get_module
# once bu property'ye, sonra ro.hardware/ro.product.board varyantlarina bakar.
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/prebuilt/vendor/audio.primary.universal7870_go.so:$(TARGET_COPY_OUT_VENDOR)/lib/hw/audio.primary.universal7870_go.so \
    $(DEVICE_PATH)/prebuilt/vendor/libsecaudioinfo.so:$(TARGET_COPY_OUT_VENDOR)/lib/libsecaudioinfo.so \
    $(DEVICE_PATH)/prebuilt/vendor/libstagefrighthw.so:$(TARGET_COPY_OUT_VENDOR)/lib/libstagefrighthw.so \
    $(DEVICE_PATH)/prebuilt/vendor/libexynosv4l2.so:$(TARGET_COPY_OUT_VENDOR)/lib/libexynosv4l2.so \
    $(DEVICE_PATH)/prebuilt/vendor/hw/hwcomposer.exynos5.so:$(TARGET_COPY_OUT_VENDOR)/lib/hw/hwcomposer.exynos5.so \
    $(DEVICE_PATH)/prebuilt/vendor/libhwcutils.so:$(TARGET_COPY_OUT_VENDOR)/lib/libhwcutils.so \
    $(DEVICE_PATH)/prebuilt/vendor/libexynosdisplay.so:$(TARGET_COPY_OUT_VENDOR)/lib/libexynosdisplay.so \
    $(DEVICE_PATH)/prebuilt/vendor/libhdmi.so:$(TARGET_COPY_OUT_VENDOR)/lib/libhdmi.so \
    $(DEVICE_PATH)/prebuilt/vendor/libmpp.so:$(TARGET_COPY_OUT_VENDOR)/lib/libmpp.so \
    $(DEVICE_PATH)/prebuilt/vendor/libExynosHWCService.so:$(TARGET_COPY_OUT_VENDOR)/lib/libExynosHWCService.so \
    $(DEVICE_PATH)/prebuilt/vendor/libvirtualdisplay.so:$(TARGET_COPY_OUT_VENDOR)/lib/libvirtualdisplay.so \
    $(DEVICE_PATH)/prebuilt/vendor/libaudioroute.so:$(TARGET_COPY_OUT_VENDOR)/lib/libaudioroute.so \
    $(DEVICE_PATH)/prebuilt/vendor/libtinyalsa.so:$(TARGET_COPY_OUT_VENDOR)/lib/libtinyalsa.so

# --- Exynos donanim video codec'leri (OMX) -----------------------------------
# media_codecs.xml bu decoder'lari (OMX.Exynos.avc/hevc/mpeg4/vp8.dec) ilan
# ediyordu ama ilgili .so'lar build'e HIC konmamis oldugu icin framework
# OMX.google.* yazilim decoder'larina dusuyordu -> video/Reels oynatmada
# yazilim decode (asiri CPU + kasma). Zincir: libstagefrighthw.so
# (ExynosOMXPlugin) -> libExynosOMX_Core.so -> component'leri SABIT
# "/vendor/lib/omx/" yolundan dlopen eder (core icindeki string ile sabit).
# Vendor process'in linker namespace'i "permitted.paths += /vendor" oldugu
# icin bu mutlak yol izinlidir (/system/etc/ld.config.29.txt, [vendor]
# namespace.default.permitted.paths).
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/prebuilt/vendor/lib/libExynosOMX_Core.so:$(TARGET_COPY_OUT_VENDOR)/lib/libExynosOMX_Core.so \
    $(DEVICE_PATH)/prebuilt/vendor/lib/libExynosOMX_Resourcemanager.so:$(TARGET_COPY_OUT_VENDOR)/lib/libExynosOMX_Resourcemanager.so \
    $(DEVICE_PATH)/prebuilt/vendor/lib/omx/libOMX.Exynos.AVC.Decoder.so:$(TARGET_COPY_OUT_VENDOR)/lib/omx/libOMX.Exynos.AVC.Decoder.so \
    $(DEVICE_PATH)/prebuilt/vendor/lib/omx/libOMX.Exynos.HEVC.Decoder.so:$(TARGET_COPY_OUT_VENDOR)/lib/omx/libOMX.Exynos.HEVC.Decoder.so \
    $(DEVICE_PATH)/prebuilt/vendor/lib/omx/libOMX.Exynos.MPEG4.Decoder.so:$(TARGET_COPY_OUT_VENDOR)/lib/omx/libOMX.Exynos.MPEG4.Decoder.so \
    $(DEVICE_PATH)/prebuilt/vendor/lib/omx/libOMX.Exynos.VP8.Decoder.so:$(TARGET_COPY_OUT_VENDOR)/lib/omx/libOMX.Exynos.VP8.Decoder.so \
    $(DEVICE_PATH)/prebuilt/vendor/lib/omx/libOMX.Exynos.WMV.Decoder.so:$(TARGET_COPY_OUT_VENDOR)/lib/omx/libOMX.Exynos.WMV.Decoder.so \
    $(DEVICE_PATH)/prebuilt/vendor/lib/omx/libOMX.Exynos.AVC.Encoder.so:$(TARGET_COPY_OUT_VENDOR)/lib/omx/libOMX.Exynos.AVC.Encoder.so \
    $(DEVICE_PATH)/prebuilt/vendor/lib/omx/libOMX.Exynos.HEVC.Encoder.so:$(TARGET_COPY_OUT_VENDOR)/lib/omx/libOMX.Exynos.HEVC.Encoder.so \
    $(DEVICE_PATH)/prebuilt/vendor/lib/omx/libOMX.Exynos.MPEG4.Encoder.so:$(TARGET_COPY_OUT_VENDOR)/lib/omx/libOMX.Exynos.MPEG4.Encoder.so \
    $(DEVICE_PATH)/prebuilt/vendor/lib/omx/libOMX.Exynos.VP8.Encoder.so:$(TARGET_COPY_OUT_VENDOR)/lib/omx/libOMX.Exynos.VP8.Encoder.so

# NOT: libtinyalsa (external/tinyalsa) ve libwebrtc_audio_preprocessing
# (external/webrtc) agacta KAYNAK modul olarak tanimli ve /vendor/lib altina
# kuruluyor. libaudioroute ise kaynak modul olmasina ragmen PRODUCT_PACKAGES'a
# dahil edilmedigi icin /vendor/lib'e KURULMUYOR; audio.primary.universal7870_go.so
# dlopen sirasinda "cannot locate symbol audio_route_get_mixer_ctl" veriyor.
# Bu yuzle stok prebuilt'i asagidaki PRODUCT_COPY_FILES ile kuruluyor
# (cihazda runtime ile dogrulandi). Stok lib'i hedefe gondermek "overriding
# commands for target" uyarisi vermez; onceki yorum bunun tersini soyluyordu.

# Oreo ses HAL'inin dlopen zinciri icin zorunlu olan Samsung kutuphaneleri ve
# stok mixer yapilandirmalari. Runtime'da push edilerek dogrulandi; temiz
# build'de de kurulmazsa:
#   - libsamsungDiamondVoice/libSamsungPostProcessConvertor/librecordalive/
#     libpreprocessing_nxp/lib_soundaliveresampler/lib_SoundAlive_SRC384_ver300
#     yoksa audio.primary dlopen hatasi
#   - mixer_gains.xml yoksa mixer_paths <include> parse edilemez
# Media: universal7870-common/device-common.mk "Media" bolumunde kurallar var
# ama o dosya bu hedeften hic inherit edilmiyor (yalnizca a3y17lte ediyor);
# dolayisiyla degerlendirilmiyor. Stok medya XML'leri (cihazda md5 ile
# dogrulanmis, /vendor/etc uzerinde vboot sonrasi calismasi ispatlanmis)
# prebuilt olarak buradan kuruluyor. Yoksa OmxInfoBuilder parsing error ->
# vorbis decoder bulunamaz -> zil/alarm sesi yok, sadece titresim.
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/prebuilt/vendor/media/media_codecs.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs.xml \
    $(DEVICE_PATH)/prebuilt/vendor/media/media_codecs_performance.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_performance.xml \
    $(DEVICE_PATH)/prebuilt/vendor/media/media_profiles_V1_0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_profiles_V1_0.xml \
    $(DEVICE_PATH)/prebuilt/vendor/media/media_codecs_google_audio.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_audio.xml \
    $(DEVICE_PATH)/prebuilt/vendor/media/media_codecs_google_telephony.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_telephony.xml \
    $(DEVICE_PATH)/prebuilt/vendor/media/media_codecs_google_video.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_video.xml \
    $(DEVICE_PATH)/prebuilt/vendor/media/media_codecs_google_video_le.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_video_le.xml \
    $(DEVICE_PATH)/prebuilt/vendor/mixer_paths.xml:$(TARGET_COPY_OUT_VENDOR)/etc/mixer_paths.xml \
    $(DEVICE_PATH)/prebuilt/vendor/mixer_gains.xml:$(TARGET_COPY_OUT_VENDOR)/etc/mixer_gains.xml \
    $(DEVICE_PATH)/prebuilt/vendor/audio_effects_common.conf:$(TARGET_COPY_OUT_VENDOR)/etc/audio_effects_common.conf \
    $(DEVICE_PATH)/prebuilt/vendor/lib/libsamsungDiamondVoice.so:$(TARGET_COPY_OUT_VENDOR)/lib/libsamsungDiamondVoice.so \
    $(DEVICE_PATH)/prebuilt/vendor/lib/libSamsungPostProcessConvertor.so:$(TARGET_COPY_OUT_VENDOR)/lib/libSamsungPostProcessConvertor.so \
    $(DEVICE_PATH)/prebuilt/vendor/lib/librecordalive.so:$(TARGET_COPY_OUT_VENDOR)/lib/librecordalive.so \
    $(DEVICE_PATH)/prebuilt/vendor/lib/libpreprocessing_nxp.so:$(TARGET_COPY_OUT_VENDOR)/lib/libpreprocessing_nxp.so \
    $(DEVICE_PATH)/prebuilt/vendor/lib/lib_soundaliveresampler.so:$(TARGET_COPY_OUT_VENDOR)/lib/lib_soundaliveresampler.so \
    $(DEVICE_PATH)/prebuilt/vendor/lib/lib_SoundAlive_SRC384_ver300.so:$(TARGET_COPY_OUT_VENDOR)/lib/lib_SoundAlive_SRC384_ver300.so \
    $(DEVICE_PATH)/prebuilt/vendor/lib/lib_SamsungRec_06006.so:$(TARGET_COPY_OUT_VENDOR)/lib/lib_SamsungRec_06006.so \
    $(DEVICE_PATH)/prebuilt/vendor/lib/libLifevibes_lvverx.so:$(TARGET_COPY_OUT_VENDOR)/lib/libLifevibes_lvverx.so \
    $(DEVICE_PATH)/prebuilt/vendor/lib/libLifevibes_lvvetx.so:$(TARGET_COPY_OUT_VENDOR)/lib/libLifevibes_lvvetx.so \
    $(DEVICE_PATH)/prebuilt/vendor/lib/libunwind.so:$(TARGET_COPY_OUT_VENDOR)/lib/libunwind.so

# audio.primary'in NEEDED'si libstdc++.so. bionic/libc/Android.bp'deki libstdc++
# modulu vendor_available oldugu icin agac "libstdc++.vendor" vendor varyantini
# kendisi uretiyor (hedef: $(TARGET_COPY_OUT_VENDOR)/lib/libstdc++.so). Ayri bir
# PRODUCT_COPY_FILES kurali ayni hedefe ikinci komut yazdigi icin "overriding
# commands for target" hatasi veriyor; bu yuzden prebuilt degil modul kuruluyor.
PRODUCT_PACKAGES += libstdc++.vendor

# --- HIDL servis binary'leri ------------------------------------------------
# VINTF manifest bu HAL'lari beyan ediyor ama A10 agacindaki servis
# moduleri PRODUCT_PACKAGES'a hic eklenmemisti; bu yuzden /vendor/bin/hw
# altinda hic "power" veya "light" servisi olmuyordu. Sonuc:
#   W ServiceManagement: Waited one second for
#       android.hardware.power@1.0::IPower/default
# IPower::getService() sonsuz retry ediyor ve PowerManagerService.nativeInit
# icinde ana thread'i bloklayip Watchdog'u tetikliyor (boot dongusu).
PRODUCT_PACKAGES += \
    android.hardware.power@1.0-service \
    android.hardware.light@2.0-service

# --- HIDL passthrough impl kutuphaneleri -------------------------------------
# Servis binary'si tek basina yetmez: registerPassthroughServiceImplementation
# once getService(name, getStub=true) ile /vendor/lib/hw altindaki
# android.hardware.<x>@<ver>-impl.so kutuphanesini yukleyip HIDL_FETCH_<IF>
# sembolunu arar. Impl yoksa servis EXIT_FAILURE ile cikip init onu
# "restarting" durumunda sonsuz donguye sokar:
#   E android.hardware.power@1.0-service: Could not get passthrough
#       implementation for android.hardware.power@1.0::IPower/default.
#   E android.hardware.light@2.0-service: Could not get passthrough ...
#   E android.hardware.sensors@1.0-service: Could not get passthrough ...
# Not: sensors icin agacta ayrica Samsung varyanti
# (android.hardware.sensors@1.0-impl.samsung.so) var; passthrough tam olarak
# "android.hardware.sensors@1.0-impl.so" adini aradigi icin A10 surumu de
# ekleniyor. Impl'ler kendi icinde legacy HAL'i hw_get_component ile
# buluyor: sensors -> sensors.universal7870_go.so (ro.hardware.sensors).
PRODUCT_PACKAGES += \
    android.hardware.power@1.0-impl \
    android.hardware.light@2.0-impl \
    android.hardware.sensors@1.0-impl

# --- Vendor init / ueventd / native binaries -------------------------------
# init rc'leri + cbd (cpboot), sswap, watchdogd /vendor altinda durur;
# ueventd.rc /vendor/ueventd.rc olarak birlesir.
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/root/init.samsungexynos7870.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.samsungexynos7870.rc \
    $(DEVICE_PATH)/root/init.samsungexynos7870.usb.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.samsungexynos7870.usb.rc \
    $(DEVICE_PATH)/root/init.baseband.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.baseband.rc \
    $(DEVICE_PATH)/root/init.wifi.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.wifi.rc \
    $(DEVICE_PATH)/root/init.vendor.rilchip.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.vendor.rilchip.rc \
    $(DEVICE_PATH)/root/init.vendor.rilcommon.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.vendor.rilcommon.rc \
    $(DEVICE_PATH)/root/init.lineage.ril.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.lineage.ril.rc \
    $(DEVICE_PATH)/root/rild-watchdog.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/rild-watchdog.rc \
    $(DEVICE_PATH)/rild-watchdog.sh:$(TARGET_COPY_OUT_VENDOR)/bin/rild-watchdog.sh \
    $(DEVICE_PATH)/root/ueventd.samsungexynos7870.rc:$(TARGET_COPY_OUT_VENDOR)/ueventd.rc \
    $(DEVICE_PATH)/root/sbin/cbd:$(TARGET_COPY_OUT_VENDOR)/bin/cbd \
    $(DEVICE_PATH)/root/sbin/sswap:$(TARGET_COPY_OUT_VENDOR)/bin/sswap \
    $(DEVICE_PATH)/root/sbin/watchdogd:$(TARGET_COPY_OUT_VENDOR)/bin/watchdogd

# --- VINTF device manifest (vendor) -----------------------------------------
# Manifest artik BoardConfig.mk'deki DEVICE_MANIFEST_FILE ile uretilir:
# assemble_vintf bu dosyadan /vendor/etc/vintf/manifest.xml olusturur ve
# BOARD_SEPOLICY_VERS (=PLATFORM_SEPOLICY_VERSION=29.0) sepolicy surumunu
# enjekte eder. Raw PRODUCT_COPY_FILES enjeksiyonu atliyordu (sepolicy 0.0),
# bu da acilista "There's an internal problem with your device" diyaloguna yol
# aciyordu. Bu yuzden burada ayrica KOPYALANMAZ.

# --- GPU user-space (EGL/GLES) ----------------------------------------------
# Stok Oreo vendor'daki Mali-T830 unified surucusu (ELF32 ARM) framework ile
# ayni bitness. Android 10'un EGL loader'i (frameworks/native/opengl/libs/EGL/
# Loader.cpp:697 attempt_to_load_system_driver) ro.hardware.egl degerine gore
# /vendor/lib/egl/libGLES_${prop}.so arar ve basarili olursa EGL+GLESv1_CM+
# GLESv2'yi TEK kutuphaneden baslatir (initialize_api(dso, EGL|GLESv1_CM|
# GLESv2)). Mali unified surucusu tam olarak bu sekilde derlenmis oldugu icin
# ayri libEGL_/libGLESv2_ kopyalari gerekmez.
#
# Bu dosya build'te hic kurulmuyordu -> /vendor/lib/egl hic olusmadi ->
# surfaceflinger "couldn't find an OpenGL ES implementation" ile SIGABRT ->
# system_server/zygote zinciri olum -> watchdog hard lockup -> panic -> download
# mode. LOS16 loglarindaki crash_dump64/surfaceflighter crash'i tam olarak
# buydu.
# Stok Pie (vstage) libGLES_mali.so, Samsung Pie'nin OZEL libgralloc/private_handle
# yapisina gore derlenmis; A10 tarafinda gralloc HIDL'si
# (gralloc.exynos5 + android.hardware.graphics.mapper@2.0) kullanildigi icin
# buffer'larda su uyarilar donuyor:
#   E : invalid gralloc handle (at 0x...)
#   E : Runtime and build version of gralloc private structure does not match
# Bunlar zorlayici DEGIL: surfaceflinger ayakta kaliyor ve sistem
# boot_progress_preload_end'e kadar geliyor. Bu blob OLMADIGI zaman ise
# A10'un sistem tarafinda EGL surucusu fallback'i yoktur; loader
# libGLES_exynos5.so'yu arar, bulamaz ve surfaceflinger 5 saniyede bir
# SIGABRT ile dongu yaratir. Bu yuzden dosya gonderilmek zorunda.
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/prebuilt/egl/libGLES_mali.so:$(TARGET_COPY_OUT_VENDOR)/lib/egl/libGLES_mali.so

# Stok Pie (vstage) Mali blob'u: VNDK API 29 kontrollerine takilmamasi icin
# TARGET_PROCESS_SDK_VERSION override ile 27'ye sabitlendi (override olmadan
# A10 derleyici "requires API 29" hatasi veriyor).
TARGET_PROCESS_SDK_VERSION_OVERRIDE += \
    /vendor/lib/egl/libGLES_mali.so=27

# --- Graphics (A10 composer@2.2 + HWC1.5->2 shim) --------------------------
PRODUCT_PACKAGES += \
    android.hardware.graphics.allocator@2.0-impl \
    android.hardware.graphics.allocator@2.0-service \
    android.hardware.graphics.composer@2.1-impl \
    android.hardware.graphics.composer@2.2-service \
    android.hardware.graphics.mapper@2.0-impl \
    android.hardware.memtrack@1.0-impl \
    android.hardware.memtrack@1.0-service \
    android.hardware.renderscript@1.0-impl \
    libhwc2on1adapter \
    libhwc2onfbadapter \
    libtinyxml

# !!! gralloc.default BILINCLI OLARAK YUKLENMIYOR !!!
# Bu agacta /vendor/lib/hw altinda iki FARKLI private_handle_t ABI'sine sahip
# gralloc modulu bulunuyordu:
#   * gralloc.exynos5.so -> stok Pie (vstage) Exynos gralloc, Samsung'in
#                           private_handle_t yapisi (stok Mali ile uyumlu)
#   * gralloc.default.so -> A10 agacinin kendi gralloc'i, FARKLI private_handle_t
# ro.hardware.gralloc=exyos5 oldugu icin loader once exynos5'i dener; ancak
# gralloc.default.so dosyasi durdugu surece herhangi bir surec duserken yanlis
# gralloc'i yukleyip farkli ABI ile handle uretebiliyordu. Sonuc:
#   E : invalid gralloc handle (at 0x...)
#   W : GraphicBufferMapper: importBuffer(...) failed: 2
#   E : GraphicBufferAllocator: Failed to allocate (1 x 1) ... : 2   (ENOENT)
# Yani 1x1 piksel bile tahsis edilemiyor, tum uygulamalara "dequeueBuffer failed,
# error = 2" + GL OOM veriliyor ve ekran gosunmuyordu.
# Cozum: /vendor/lib/hw icinde SADECE stok exynos5 gralloc birak -> tek ABI.
# NOT: ro.hardware.gralloc=exynos5 sistem.prop'da KORUNMALIDIR; bos birakilirsa
# loader gralloc.default.so arar, bulamaz ve tum buffer tahsisi cokuler.

# EGL loader surucu adini ro.hardware.egl property'sinden turetir
# (Loader.cpp:181 DRIVER_SUFFIX_PROPERTY). Bos birakilirsa loader
# ro.board.platform ("exynos5") ile "libGLES_exynos5.so" arar, bulamaz.
# DIKKAT: bu deger PRODUCT_PROPERTY_OVERRIDES ile VERILMEZ; A10'da o degisken
# hem system hem vendor build.prop'a yazildigi icin deger /vendor/build.prop'a
# duser ve Treble'da vendor "ro.*" property'leri property_service tarafindan
# (sadece izinli vendor_ro_properties listesinde olanlar) okunamaz -> deger
# yine bos kalir. Bu yuzden cihazin kendi system.prop dosyasina yazilir; o dosya
# TARGET_SYSTEM_PROP ile SADECE system/build.prop'a girer.

# --- Health / Light / Power / Thermal / Sensors / Vibrator / USB -----------
PRODUCT_PACKAGES += \
    android.hardware.health@2.0-impl \
    android.hardware.health@2.0-service \
    chargeonlymode \
    android.hardware.light@2.0-service.samsung \
    android.hardware.power@1.0-service.exynos \
    android.hardware.thermal@2.0-service.samsung \
    android.hardware.sensors@1.0-impl.samsung \
    android.hardware.sensors@1.0-service \
    android.hardware.vibrator@1.0-impl \
    android.hardware.vibrator@1.0-service \
    android.hardware.usb@1.0-service.basic

# --- USB feature: UsbService baslatabilmesi icin gerekli. Android 10
# SystemServer UsbService'i yalnizca FEATURE_USB_HOST|FEATURE_USB_ACCESSORY
# varken kurgular; yoksa UsbManager.getPorts() null doner ve Settings'in
# "Bagli cihazlar" ekrani NPE ile kapanir (UsbBackend.updatePorts).
# A2 Core (Exynos7870) mikro-USB OTG destekler -> host feature dogru etikettir.
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.usb.host.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/android.hardware.usb.host.xml \
    frameworks/native/data/etc/android.hardware.usb.accessory.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/android.hardware.usb.accessory.xml

# --- Camera flash feature: SystemUI hizli ayar panelindeki Fener (flashlight)
# kutucugu yalnizca FEATURE_CAMERA_FLASH oldugunda gosterilir
# (FlashlightTile -> FlashlightController.isAvailable). Bu xml disinda sistemde
# flash feature'ini declare eden paket yok; eklenmezse kutupane hic gozukmez.
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.camera.flash-autofocus.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/android.hardware.camera.flash-autofocus.xml

# --- DRM / CAS / Gatekeeper / Keymaster -------------------------------------
PRODUCT_PACKAGES += \
    android.hardware.drm@1.0-impl \
    android.hardware.drm@1.0-service \
    android.hardware.drm@1.2-service.clearkey \
    android.hardware.cas@1.1-service \
    android.hardware.gatekeeper@1.0-impl \
    android.hardware.keymaster@4.0-impl \
    android.hardware.keymaster@4.0-service

# --- Audio (in-tree HAL'ler stok vendor altyapisini kullanir) ----------------
PRODUCT_PACKAGES += \
    android.hardware.audio@2.0-service \
    android.hardware.audio@5.0-impl \
    android.hardware.audio.effect@5.0-impl \
    android.hardware.soundtrigger@2.2-impl \
    audio.a2dp.default \
    audio.usb.default \
    audio.r_submix.default \
    libtinycompress

# audio_effects.xml'deki AOSP efekt kutuphaneleri agacta hic uretilmiyordu;
# fabrika xml'i "XML effect configuration failed to load" ile yuklenemiyordu
# (AudioFX/equalizer/bassboost olumdu). Moduller: lvm/wrapper (bundle+reverb),
# visualizer, downmix, loudness, dynamicsproc.
PRODUCT_PACKAGES += \
    libbundlewrapper \
    libreverbwrapper \
    libvisualizer \
    libdownmix \
    libldnhncr \
    libdynproc

# --- Camera (stok vendor kamera blob'lari uzerinde) --------------------------
PRODUCT_PACKAGES += \
    android.hardware.camera.common@1.0-helper \
    android.hardware.camera.provider@2.5-impl \
    android.hardware.camera.provider@2.5-service \
    libion_exynos \
    Snap

# --- Wifi (bcmdhd BCM43436L) -------------------------------------------------
# A2 Core wifi cipi Broadcom BCM43436L, driver kernel'da dhd olarak gomulu.
# Kernel firmware'i su yollardan bekliyor:
#   /vendor/etc/wifi/bcmdhd_sta.bin_36   (kernel strings'inde "_36" suffixli)
#   /vendor/etc/wifi/bcmdhd_clm.blob
#   /vendor/etc/wifi/nvram_net.txt
# dmesg (kernel: bcmdhd_1_77):
#   dhdsdio_download_firmware: firmware path=/vendor/etc/wifi/bcmdhd_sta.bin_36
# Firmware dosya adi "_36" suffixsiz kuruluyordu; dongle indirme basarisiz
# oluyordu (dhdsdio_download_firmware: dongle image file download failed,
# -35) ve wlan0 UP edilemiyordu. _36 adli kopya da kurulur.
# Stock Pie (vstage) fw dosyalari prebuilt/wifi/ altina alindi.
# NOT: Hotspot (hostapd AP mode) icin AYRICA bcmdhd_apsta.bin_36 gerekir:
# driver firmware_path'i "_36" suffix ile arar; apsta_36 yoksa AP beacon
# "Link up didn't come for AP interface / ADD-SET beacon failed" ile patlar
# (hostapd: "Failed to set beacon parameters").
# Ayrica WifiService'in system_server'de baslamasi icin
# android.hardware.wifi.xml permission'i zorunlu (yokken FEATURE_WIFI
# gelmedigi icin WifiManager null kaliyordu).
PRODUCT_PACKAGES += \
    android.hardware.wifi@1.0-service \
    android.hardware.wifi@1.3 \
    hostapd \
    libcld80211 \
    libwpa_client \
    macloader \
    wificond \
    wpa_supplicant \
    wpa_supplicant.conf

PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/prebuilt/wifi/etc/bcmdhd_sta.bin:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/bcmdhd_sta.bin \
    $(DEVICE_PATH)/prebuilt/wifi/etc/bcmdhd_apsta.bin_36:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/bcmdhd_sta.bin_36 \
    $(DEVICE_PATH)/prebuilt/wifi/etc/bcmdhd_apsta.bin:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/bcmdhd_apsta.bin \
    $(DEVICE_PATH)/prebuilt/wifi/etc/bcmdhd_apsta.bin_36:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/bcmdhd_apsta.bin_36 \
    $(DEVICE_PATH)/prebuilt/wifi/etc/bcmdhd_clm.blob:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/bcmdhd_clm.blob \
    $(DEVICE_PATH)/prebuilt/wifi/etc/nvram_net.txt:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/nvram_net.txt \
    $(DEVICE_PATH)/prebuilt/wifi/etc/nvram.txt_36:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/nvram.txt_36 \
    $(DEVICE_PATH)/prebuilt/wifi/etc/indoorchannel.info:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/indoorchannel.info \
    $(DEVICE_PATH)/prebuilt/wifi/etc/wpa_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/wpa_supplicant_overlay.conf \
    $(DEVICE_PATH)/prebuilt/wifi/etc/p2p_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/p2p_supplicant_overlay.conf \
    $(DEVICE_PATH)/prebuilt/wifi/firmware/bcm43436B0_V0086.0141.hcd:$(TARGET_COPY_OUT_VENDOR)/firmware/bcm43436B0_V0086.0141.hcd \
    $(DEVICE_PATH)/prebuilt/wifi/firmware/bcm43436B0_V0096.0154.hcd:$(TARGET_COPY_OUT_VENDOR)/firmware/bcm43436B0_V0096.0154.hcd \
    frameworks/native/data/etc/android.hardware.wifi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.xml \
    frameworks/native/data/etc/android.hardware.wifi.direct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.direct.xml \
    frameworks/native/data/etc/android.hardware.wifi.passpoint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.passpoint.xml

# FIMC-IS kamera ISP firmware (yoksa startPreview: VIDIOC_S_INPUT -38 / FLITE create fail)
# + MFC video codec firmware.
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/prebuilt/camera/firmware/fimc_is_lib.bin:$(TARGET_COPY_OUT_VENDOR)/firmware/fimc_is_lib.bin \
    $(DEVICE_PATH)/prebuilt/camera/firmware/setfile_gc5035.bin:$(TARGET_COPY_OUT_VENDOR)/firmware/setfile_gc5035.bin \
    $(DEVICE_PATH)/prebuilt/camera/firmware/setfile_5e9.bin:$(TARGET_COPY_OUT_VENDOR)/firmware/setfile_5e9.bin \
    $(DEVICE_PATH)/prebuilt/camera/firmware/mfc_fw.bin:$(TARGET_COPY_OUT_VENDOR)/firmware/mfc_fw.bin

# libwifi-hal, BOARD_WLAN_DEVICE=bcmdhd iken android.mk tarafindan
# libwifi-hal-bcm kaynagindan derlenir (fallback emulator stub yerine).
PRODUCT_PACKAGES += libwifi-hal

# --- Bluetooth ---------------------------------------------------------------
PRODUCT_PACKAGES += \
    Bluetooth \
    android.hardware.bluetooth@1.0 \
    android.hardware.bluetooth@1.0-impl \
    android.hardware.bluetooth@1.0-service \
    android.hardware.bluetooth.audio@2.0-impl \
    audio.bluetooth.default

# Bluetooth privileged app whitelist
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/privapp-permissions-bluetooth.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/privapp-permissions-bluetooth.xml

# Samsung BlueZ bt vendor kutuphanesi: android.hardware.bluetooth@1.0-impl
# bu kutuphaneyi dlopen ile acar (VendorInterface); stock'tan alindi.
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/prebuilt/vendor-lib/libbt-vendor.so:$(TARGET_COPY_OUT_VENDOR)/lib/libbt-vendor.so

# --- Lineage HALS -----------------------------------------------------------
PRODUCT_PACKAGES += \
    AdvancedDisplay \
    SamsungDoze \
    vendor.lineage.livedisplay@2.0-service.samsung-exynos \
    vendor.lineage.touch@1.0-service.samsung \
    vendor.lineage.trust@1.0-service

# --- Keylayout / IDC ---------------------------------------------------------
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/configs/keylayout/gpio-keys.kl:$(TARGET_COPY_OUT_VENDOR)/usr/keylayout/gpio-keys.kl \
    $(DEVICE_PATH)/configs/keylayout/sec_touchscreen.kl:$(TARGET_COPY_OUT_VENDOR)/usr/keylayout/sec_touchscreen.kl \
    $(DEVICE_PATH)/configs/idc/AVRCP.idc:$(TARGET_COPY_OUT_VENDOR)/usr/idc/AVRCP.idc \
    $(DEVICE_PATH)/configs/idc/qwerty.idc:$(TARGET_COPY_OUT_VENDOR)/usr/idc/qwerty.idc \
    $(DEVICE_PATH)/configs/idc/qwerty2.idc:$(TARGET_COPY_OUT_VENDOR)/usr/idc/qwerty2.idc

# --- Net / misc --------------------------------------------------------------
PRODUCT_PACKAGES += \
    ebtables \
    ethertypes \
    libebtc \
    libgui_vendor \
    libnl \
    netutils-wrapper-1.0 \
    android.hidl.base@1.0 \
    android.hidl.base@1.0.vendor

# --- RIL (stok Oreo 32-bit set + A10 hwservicemanager restart) -------------
# libsec-ril.so (2.374.044 B, dogru A260F), libril.so (315.464 B stok Oreo)
# rild-a260f (20.404 B). A9'da dogrulanan yigin ayni kalir.
PRODUCT_PACKAGES += \
    librilutils \
    libsec-ril.so \
    libsec-ril-dsds.so \
    libvndsecril-client.so \
    libsecnativefeature.so \
    libsecaudioinfo.so \
    libaudio-ril.so \
    libfloatingfeature.so \
    libsensorlistener.so \
    vendor.samsung.hardware.radio.channel@1.0_vendor.so \
    vendor.samsung.hardware.radio.secoemhook@1.0_vendor.so

# stok Oreo android.hardware.radio@1.0/1.1/deprecated@1.0 vendor/lib'de
# linker tarafindan vndk-29 (system) kopyasindan once bulunup rild'in
# UND sembol (toString/vendor) sorununu cozumlemesi icin birebir gonderiliyor.
# vendor.samsung.hardware.radio@1.1_vendor.so da stok A260F HAL kutuphanesidir.
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/prebuilt/ril/rild-a260f:$(TARGET_COPY_OUT_VENDOR)/bin/hw/rild \
    $(DEVICE_PATH)/prebuilt/ril/libril.so:$(TARGET_COPY_OUT_VENDOR)/lib/libril.so \
    $(DEVICE_PATH)/prebuilt/ril/android.hardware.radio@1.0.so:$(TARGET_COPY_OUT_VENDOR)/lib/android.hardware.radio@1.0.so \
    $(DEVICE_PATH)/prebuilt/ril/android.hardware.radio@1.1.so:$(TARGET_COPY_OUT_VENDOR)/lib/android.hardware.radio@1.1.so \
    $(DEVICE_PATH)/prebuilt/ril/android.hardware.radio.deprecated@1.0.so:$(TARGET_COPY_OUT_VENDOR)/lib/android.hardware.radio.deprecated@1.0.so \
    $(DEVICE_PATH)/prebuilt/ril/vendor.samsung.hardware.radio@1.1_vendor.so:$(TARGET_COPY_OUT_VENDOR)/lib/vendor.samsung.hardware.radio@1.1_vendor.so

# librilutils.so ve libreference-ril.so durumu (RIL kalici kurulum):
# hardware/ril/librilutils/Android.bp "librilutils" adli KAYNAK modul tanimliyor
# ve PRODUCT_PACKAGES'a girmedigi icin hic derlenmiyor; boylece /vendor/lib
# hedefi bos kaliyor ve rild linker hatasi veriyordu. Cozum: stok Oreo
# kopyalari (prebuilt/ril altinda) PRODUCT_COPY_FILES ile gonderiliyor.
# libreference-ril.so A10'da base_vendor.mk'den PRODUCT_PACKAGES'a girip derleme
# hedefi uretiyordu; device.mk en ustdaki $(filter-out libreference-ril) ile
# listeden dusuruldugu icin hedef bos ve stok kopyasi PCF ile sorunsuz geliyor.

# rild 32-bit set: A10'da da API 27 (Oreo) uyumlu calissin
TARGET_PROCESS_SDK_VERSION_OVERRIDE += \
    /vendor/bin/hw/rild=27 \
    /vendor/lib/libsec-ril.so=27 \
    /vendor/lib/libsec-ril-dsds.so=27

# RIL paths
# ONEMLI: bu agacda PRODUCT_VENDOR_PROPERTIES ve PRODUCT_SYSTEM_PROPERTIES
# degiskenleri build/make tarafinda HIC okunmuyor (build/make/core/main.mk
# yalnizca ADDITIONAL_BUILD_PROPERTIES <- PRODUCT_PROPERTY_OVERRIDES yolunu
# kullanir, Makefile:239 ise FINAL_DEFAULT_PROPERTIES icin
# PRODUCT_SYSTEM_DEFAULT_PROPERTIES'i kullanir). Onceki surumde RIL/CSC
# property'leri bu iki desteklenmeyen degiskene yazildigi icin hic
# uretilmiyordu; sonuc: init "property 'vendor.sec.rild.libpath' doesn't exist
# while expanding" + "cannot expand" ile ril-daemon'i hic baslatamiyordu.
# Bu yuzden:
#   * init.vendor.rilchip.rc icindeki ${vendor.sec.rild.libpath} ifadeleri
#     dogrudan yola sabitlendi (property genisletmesine bagli kalmamasi icin),
#   * kalan RIL property'leri init rc ile erken asamada setprop ile birakiliyor
#     (bkz. root/init.vendor.rilchip.rc),
#   * ro.* CSC/OMC/low_ram degerleri PRODUCT_PROPERTY_OVERRIDES ile
#     build.prop'a yaziliyor.
PRODUCT_PROPERTY_OVERRIDES += \
    rild.libpath=/vendor/lib/libsec-ril.so \
    rild.libargs=-d \
    exynos.ril.modempath=/dev/block/mmcblk0p5 \
    exynos.ril.nvpath=/efs/

# --- CSC / OMC ---------------------------------------------------------------
PRODUCT_PROPERTY_OVERRIDES += \
    ro.csc.sales_code=TUR \
    ro.csc.omcnw_code=TUR \
    ro.omc.region=TUR

# cscfeature.xml ve cscfeature_network.xml Samsung OMC tarafindan SIFRELENMIS
# dosyalar (ilk 4 bayt 2f 27 29 b7); gercek XML degiller. Build, kaynak
# uzantisina .xml gorurse xmllint ile dogrulamaya calisiyor ve
# "parser error : Start tag expected" ile basarisiz oluyor. Dosyalar .bin
# uzantisiyla duruyor, hedef yine .xml. A9'da xmllint dogrulamasi yoktu.
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/omc/SW_Configuration.xml:$(TARGET_COPY_OUT_SYSTEM)/omc/SW_Configuration.xml \
    $(DEVICE_PATH)/omc/CSCVersion.txt:$(TARGET_COPY_OUT_SYSTEM)/omc/CSCVersion.txt \
    $(DEVICE_PATH)/omc/sales_code.dat:$(TARGET_COPY_OUT_SYSTEM)/omc/sales_code.dat \
    $(DEVICE_PATH)/omc/sales_code_list.dat:$(TARGET_COPY_OUT_SYSTEM)/omc/sales_code_list.dat \
    $(DEVICE_PATH)/omc/omc_b2b_list:$(TARGET_COPY_OUT_SYSTEM)/omc/omc_b2b_list \
    $(DEVICE_PATH)/omc/TUR/etc/TUR_keystrings.dat:$(TARGET_COPY_OUT_SYSTEM)/omc/TUR/etc/TUR_keystrings.dat \
    $(DEVICE_PATH)/omc/TUR/etc/contents.db:$(TARGET_COPY_OUT_SYSTEM)/omc/TUR/etc/contents.db \
    $(DEVICE_PATH)/omc/TUR/etc/enforceskippingpackages.txt:$(TARGET_COPY_OUT_SYSTEM)/omc/TUR/etc/enforceskippingpackages.txt \
    $(DEVICE_PATH)/omc/TUR/etc/hidden_apks_list.txt:$(TARGET_COPY_OUT_SYSTEM)/omc/TUR/etc/hidden_apks_list.txt \
    $(DEVICE_PATH)/omc/TUR/etc/sales_code.dat:$(TARGET_COPY_OUT_SYSTEM)/omc/TUR/etc/sales_code.dat \
    $(DEVICE_PATH)/omc/TUR/conf/customer.xml:$(TARGET_COPY_OUT_SYSTEM)/omc/TUR/conf/customer.xml \
    $(DEVICE_PATH)/omc/TUR/conf/imsupdate.json:$(TARGET_COPY_OUT_SYSTEM)/omc/TUR/conf/imsupdate.json \
    $(DEVICE_PATH)/omc/TUR/conf/omc.info:$(TARGET_COPY_OUT_SYSTEM)/omc/TUR/conf/omc.info

# Samsung vendor RIL PLMN tablosu: libsec-ril OperatorName::LoadOpnameDb su
# yollari dener (libsec-ril.so string'leri):
#   /vendor/carrier/%s/plmn_se13.bin  (yil/region kodu ile, orn. TUR)
#   /vendor/etc/plmn_se13.bin
#   /system/omc/%s/etc/plmn_delta.bin (omc kodu ile, orn. TUR)
# Eski /system/etc kopyalari RIL tarafindan ARTIK okunmuyor; operator adi
# "28602" gibi sayisal donuyordu. Her iki konuma da yaziliyor.
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/etc/plmn_se13.bin:$(TARGET_COPY_OUT_VENDOR)/etc/plmn_se13.bin \
    $(DEVICE_PATH)/etc/plmn_se13.bin:$(TARGET_COPY_OUT_VENDOR)/carrier/TUR/plmn_se13.bin \
    $(DEVICE_PATH)/etc/plmn_delta.bin:$(TARGET_COPY_OUT_SYSTEM)/omc/TUR/etc/plmn_delta.bin \
    $(DEVICE_PATH)/etc/plmn_delta.bin:$(TARGET_COPY_OUT_SYSTEM)/etc/plmn_delta.bin \
    $(DEVICE_PATH)/etc/plmn_delta_attaio.bin:$(TARGET_COPY_OUT_SYSTEM)/etc/plmn_delta_attaio.bin \
    $(DEVICE_PATH)/etc/plmn_delta_usacdma.bin:$(TARGET_COPY_OUT_SYSTEM)/etc/plmn_delta_usacdma.bin \
    $(DEVICE_PATH)/etc/plmn_delta_usagsm.bin:$(TARGET_COPY_OUT_SYSTEM)/etc/plmn_delta_usagsm.bin

# --- System properties -------------------------------------------------------
PRODUCT_PROPERTY_OVERRIDES += \
    ro.config.low_ram=true

# Telephony framework (package adlari LOS17 adlandirmasina uygun)
PRODUCT_PACKAGES += \
    telephony-ext \
    telephony-common

# --- Sifreli OMC dosyalari (xmllint dogrulamasini atlayarak kopyalanir) -------
# Asagidaki 3 dosya OMC tarafindan SIFRELENMIS, XML degil:
#   cscfeature.xml            (ilk 4 bayt 2f 27 29 b7)
#   cscfeature_network.xml    (ayni imza)
#   default_application_order.xml  ("null" yazisi, XML etiketi icermez)
# build/make/core/Makefile PRODUCT_COPY_FILES girdisinin HEDEF ucu .xml
# oldugu icin (build/make/core/Makefile:37 -> copy-xml-file-checked)
# hepsini xmllint ile dogrulamaya calisiyor ve parser error ile build'i
# durduruyor. Kaynak ucu .xml uzantisi degil olsa da bu bir etkilenmez.
# Bu yuzden PRODUCT_COPY_FILES'tan cikarildi; asagida copy-one-file
# kuraliyla dogrulamasiz kopyalaniyorlar. Cihazda cscfeature/CSC ile
# ilgili Samsung servisleri bu dosyalari kendi cozebildigi icin
# sifreli icerik oldugu gibi korunur.
# Samsung OMC tarafindan SIFRELENMIS, gercek XML olmayan dosyalar:
#   cscfeature.xml / cscfeature_network.xml  (ilk 4 bayt 2f 27 29 b7)
#   default_application_order.xml            (icerigi yalnizca "null")
# PRODUCT_COPY_FILES bunlarin HEDEF ucu .xml oldugu icin
# copy-xml-file-checked kuralina giriyor ve xmllint parser error veriyor
# (build/make/core/Makefile:37). Bu yuzden prebuilt modulu olarak
# tanimlanip PRODUCT_PACKAGES ile kuruluyor; boylece xmllint hic devreye
# girmez. Cihazdaki Samsung servisleri bu dosyalari kendi cozebildigi
# icin sifreli icerik oldugu gibi korunur.
PRODUCT_PACKAGES += \
    a2c-omc-cscfeature \
    a2c-omc-cscfeature-network \
    a2c-omc-default-application-order

PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/omc/TUR/conf/customer.xml:$(TARGET_COPY_OUT_SYSTEM)/omc/TUR/conf/customer.xml

# --- Non-SAR boot ramdisk: monolithic SELinux policy ------------------------
# system/sepolicy/Android.mk:950'deki "sepolicy" modulu LOCAL_MODULE_PATH olarak
# $(TARGET_ROOT_OUT) (= boot ramdisk koku) kullanir ve TAGS=optional oldugu icin
# yalnizca PRODUCT_PACKAGES icinde istenirse kurulur. Bu cihazda
# system/core/init/selinux.cpp:IsSplitPolicyDevice() false donup (/sepolicy
# okunamadigi icin) init monolithic yola dustugu halde ramdiskte /sepolicy
# yoktu: "Could not open /sepolicy" -> LOG(FATAL) -> rebootTarget: bootloader.
PRODUCT_PACKAGES += sepolicy

# --- ADB: ekransiz (siyah ekran) boot'ta onay diyalogu acilamiyor -----------
# prop.default icindeki ro.adb.secure=1, adbd'nin "Allow USB debugging?" istemesine
# yol aciyor; ekran acmadigi icinden de onaylanamaz ve cihaz 'unauthorized'
# kaliyor (logcat/shell alinamaz). ro.adb.secure=0 ile adbd dogrudan root/shell
# moduna geciyor. Bu bir bring-up ayaridir, build/make/core/Makefile:239'daki
# FINAL_DEFAULT_PROPERTIES listesine PRODUCT_SYSTEM_DEFAULT_PROPERTIES uzerinden
# eklenir.
# NOT: ro.adb.secure=0 vendor/lineage/config/common.mk icinde ayarlanmistir.
# FINAL_DEFAULT_PROPERTIES "uniq-pairs-by-first-component" ile sadestirildigi
# icin ilk deger kazanir; device.mk common.mk'ten sonra include edildigi icin
# buraya yazilan deger prop.default'da etkisiz kalirdi.

# libsensorndkbridge.so - Oreo kamera HAL zincirinin son eksigi.
# camera.universal7870_go.so -> libexynoscamera3.so -> libsensorlistener.so
# -> libsensorndkbridge.so
# Vendor process /system/lib'i gormedigi icin:
#   E/vndksupport: dlopen failed: library "libsensorndkbridge.so" not found
# Artik kaynak modul DEGIL: ALooperForCameraLegacy.cpp shim'i ile agacin
# kendi modulu kullaniliyor
# cc_library_shared olarak tanimlidir ve oradan kurulur.


# libbinder.so (tam surum) + libbinderthreadstate.so — vendor'a kopyalanir.
# Gerekce: prebuilt/vendor/Android.bp icindeki yorumlarda ayrintili.
PRODUCT_PACKAGES += \
    libbinder.so \
    libbinderthreadstate.so

# --- Tek gralloc: A10 gralloc.default'i /vendor/lib/hw'den tamamen cikar -----
# gralloc.default, build/make/target/product/base_vendor.mk icinde
# PRODUCT_PACKAGES'a eklenir. Bizim stok Exynos gralloc'umuz
# (gralloc.exynos5.so, PRODUCT_COPY_FILES ile gelir) Samsung private_handle_t
# ABI'sine sahip; A10'nin gralloc.default'i ise FARKLI bir yapiya sahip.
# Ikisi ayni /vendor/lib/hw icinde durdugu surece farkli surecler farkli ABI
# ile handle uretiyor ve tum buffer tahsisi cokuyor:
#   E : invalid gralloc handle
#   E : GraphicBufferAllocator: Failed to allocate (1 x 1) ... : 2 (ENOENT)
# Bu yuzden burada ek bir savunma hatti olarak kaydi ayrica filtreliyoruz.
# Asil kaldirma build/make/target/product/base_vendor.mk icinde yapildi (orada
# gralloc.default PRODUCT_PACKAGES'a ekleniyordu). Bu filtre, ileride base_vendor.mk
# ya da baska bir ortak mk dosyasi listede yeniden eklenirse sessizce geri
# gelmesini engeller.
# DIKKAT: base_vendor.mk "inherit-product" ile EN SON include edildigi icin
# buradaki PRODUCT_PACKAGES -= degil, $(filter-out ...) kullanilmali.
PRODUCT_PACKAGES := $(filter-out gralloc.default,$(PRODUCT_PACKAGES))
