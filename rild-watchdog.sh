#!/system/bin/sh
# RIL boot-race watchdog v3.
# Detay/gecmis: /vendor/etc/init/rild-watchdog.rc
#
# v3 (2026-10-12), v2'ye gore degisiklikler:
#  * DEBOUNCE: "IN_SERVICE" ust uste 2 ornekte gorulmeden saglikli sayilmaz.
#    Tek bir gecici (transient) IN_SERVICE blip'ine aldanmaz.
#  * "boot_completed+120s'de ses yok -> reboot" KURALI KALDIRILDI. Ilk-boot
#    LTE attach (ro.telephony.default_network=9 yuzunden) birkac dakika
#    surdugu icin bu kural YANLIS/erken reboot tetikliyordu; kapsama disi
#    (sebeke yok) durumda da gereksiz reboot yapiyordu. v3 SADECE kesin ve
#    kurtarilamaz hata modunda reboot eder: SIM UNKNOWN (libsec-ril CP shmem
#    session'unu yalnizca boot penceresinde kurabildigi icin rild restart
#    bunu kurtarmaz; tek care reboot).
#  * "Servis yok" tek basina reboot NEDENI DEGILDIR (yavas attach veya
#    kapsama olabilir) -> yanlis-pozitif ortadan kalkar.
#  * Pes etme: denemeler bitince cihazi izleyicisiz birakmaz; yavas tempoda
#    SIM olumu / servis donusu izlemeye devam eder.
#
# Kisit: pipe $( ) YOK; cikti dosyaya yonlendirilir (init domain sh toybox
# pipe yazisini AVC ile reddeder). Ara dosyalar /data/local/tmp.
# Bayrak: /data/misc/rild-reboot-attempt (varsa bir reboot denemesi yapildi).

FLAG=/data/misc/rild-reboot-attempt
TMP=/data/local/tmp/rilwd.txt

sim_unknown() {
    getprop gsm.sim.state > $TMP 2>/dev/null
    grep -q UNKNOWN $TMP
}

voice_in_service() {
    dumpsys -t 10 telephony.registry 2>/dev/null > $TMP
    grep -q "mVoiceRegState=0(IN_SERVICE)" $TMP
}

do_reboot() {
    if grep -qs r $FLAG 2>/dev/null; then
        return 1
    fi
    echo r > $FLAG
    setprop sys.powerctl reboot
    return 0
}

# --- Faz 1: erken SIM olumu -> hizli reboot --------------------------------
sleep 45
if sim_unknown; then
    do_reboot
fi

# --- Faz 2: saglik penceresi (~5 dk, 20 sn aralik) --------------------------
in_svc=0
i=0
while [ $i -lt 15 ]; do
    sleep 20
    i=$((i+1))

    if sim_unknown; then
        do_reboot
        exit 1
    fi

    if voice_in_service; then
        in_svc=$((in_svc+1))
        if [ $in_svc -ge 2 ]; then
            rm -f $FLAG
            exit 0
        fi
    else
        in_svc=0
    fi
done

# --- Faz 3: pencere bitti --------------------------------------------------
# "Servis yok" tek basina reboot nedeni DEGIL. Yalnizca SIM hala UNKNOWN ise.
if sim_unknown; then
    do_reboot
    exit 1
fi

# --- Faz 4: devamli yavas izleme (cihazi izleyicisiz birakma) ---------------
while true; do
    sleep 60
    if sim_unknown; then
        do_reboot
        exit 1
    fi
    if voice_in_service; then
        rm -f $FLAG
        exit 0
    fi
done
