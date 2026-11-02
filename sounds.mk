#
# Ses volume'u duzeltmesi.
#
# Lineage build'inde (LINEAGE_BUILD) kanser /product/media altina sesler
# "AudioPackage14.mk" ile kurulur. Ancak bu cihazda MediaProvider yalnizca
# /system/media volume'unu taramaktadir (dogrulandi: /product/media dolu ama
# MediaStore internal/audio/media 0 kayit; ringtone listesi bos "none").
#
# Cozum: ayni Lineage ses kumesini /system/media altina da kopyala.
#
LOCAL_PATH := frameworks/base/data/sounds

ALARM_FILES_EXTRA := Argon Carbon Helium Krypton Neon Oxygen Osmium Platinum Timer
NOTIFICATION_FILES_EXTRA := Ariel Ceres Carme Elara Europa Iapetus Io Rhea Salacia Titan Tethys
RINGTONE_FILES_EXTRA := Atria Callisto Dione Ganymede Luna Oberon Phobos Pyxis Sedna Titania Triton Umbriel
EFFECT_FILES_EXTRA := Effect_Tick KeypressReturn KeypressInvalid KeypressDelete KeypressSpacebar KeypressStandard \
	camera_focus Dock Undock Lock Unlock Trusted ChargingStarted InCallNotification \
	NFCFailure NFCInitiated NFCSuccess NFCTransferComplete NFCTransferInitiated
MATERIAL_EFFECT_FILES_EXTRA := camera_click VideoRecord WirelessChargingStarted LowBattery VideoStop

PRODUCT_COPY_FILES += $(foreach fn,$(ALARM_FILES_EXTRA),\
	$(LOCAL_PATH)/alarms/material/ogg/$(fn).ogg:$(TARGET_COPY_OUT_SYSTEM)/media/audio/alarms/$(fn).ogg)

PRODUCT_COPY_FILES += $(foreach fn,$(NOTIFICATION_FILES_EXTRA),\
	$(LOCAL_PATH)/notifications/material/ogg/$(fn).ogg:$(TARGET_COPY_OUT_SYSTEM)/media/audio/notifications/$(fn).ogg)

PRODUCT_COPY_FILES += $(foreach fn,$(RINGTONE_FILES_EXTRA),\
	$(LOCAL_PATH)/ringtones/material/ogg/$(fn).ogg:$(TARGET_COPY_OUT_SYSTEM)/media/audio/ringtones/$(fn).ogg)

PRODUCT_COPY_FILES += $(foreach fn,$(EFFECT_FILES_EXTRA),\
	$(LOCAL_PATH)/effects/ogg/$(fn).ogg:$(TARGET_COPY_OUT_SYSTEM)/media/audio/ui/$(fn).ogg)

PRODUCT_COPY_FILES += $(foreach fn,$(MATERIAL_EFFECT_FILES_EXTRA),\
	$(LOCAL_PATH)/effects/material/ogg/$(fn).ogg:$(TARGET_COPY_OUT_SYSTEM)/media/audio/ui/$(fn).ogg)