#!/bin/bash
# +---------------------------------------------------------------------------------------------------------------------------------+
# | Hazırlayan : Faruk TOY                                                                                                          |
# | Öğrenci No : 2420171018                                                                                                         |
# | Siber Güvenlikte Linux İşletim Sistemleri: https://www.btkakademi.gov.tr/portal/certificate/validate?certificateId=OKMhw1B2vj   |
# | Docker Temelleri: https://www.btkakademi.gov.tr/portal/certificate/validate?certificateId=zXztnNLp1n                            |
# | Linux Bash Script Eğitimi: https://credsverse.com/credentials/60b1a0f8-04fd-4951-80c5-7a14d196255a                              |
# +---------------------------------------------------------------------------------------------------------------------------------+

KAYIT="report.log"
# Dosya oluşturuluyor (touch yerine > ile sıfırlama)
> "$KAYIT"

# ISO Tarih değişkenini alıp dosyaya aktarma
ANLIK_ZAMAN=$(date +"%Y-%m-%dT%H:%M:%S%z")
echo "$ANLIK_ZAMAN" >> "$KAYIT"

# Sistem donanım bilgilerinin toplanması
echo "         SİSTEM DONANIM RAPORU            " >> "$KAYIT"
echo "==========================================" >> "$KAYIT"
echo "==========================================" >> "$KAYIT"
echo ">>>İŞLEMCİ (CPU) BİLGİLERİ" >> "$KAYIT"
wmic cpu get name, ProcessorId >> "$KAYIT"
echo "==========================================" >> "$KAYIT"
echo ">>>BELLEK (RAM) BİLGİLERİ" >> "$KAYIT"
wmic memorychip get DeviceLocator, Capacity >> "$KAYIT"
echo "==========================================" >> "$KAYIT"
echo ">>>EKRAN KARTI BİLGİLERİ" >> "$KAYIT"
wmic path win32_VideoController get name >> "$KAYIT"
echo "==========================================" >> "$KAYIT"
echo ">>>ANAKART BİLGİLERİ" >> "$KAYIT"
wmic baseboard get Product, SerialNumber >> "$KAYIT"
echo "==========================================" >> "$KAYIT"
echo ">>>SİSTEM UUID (EVRENSEL KİMLİK)" >> "$KAYIT"
wmic csproduct get UUID >> "$KAYIT"
echo "==========================================" >> "$KAYIT"
echo ">>>DİSK SÜRÜCÜSÜ BİLGİLERİ" >> "$KAYIT"
wmic diskdrive get Model, SerialNumber >> "$KAYIT"
echo "==========================================" >> "$KAYIT"
echo ">>>MAC ADRESİ" >> "$KAYIT"
getmac >> "$KAYIT"
echo "==========================================" >> "$KAYIT"
echo "==========================================" >> "$KAYIT"
echo "             RAPOR SONU                   " >> "$KAYIT"

# Kullanıcı şifre alanı
echo -e "Sistemi kilitlemek için şifre girin: \c"
read PAROLA
echo ""

# Kriptolama komutu
gpg --cipher-algo AES256 --symmetric --batch --yes --passphrase "$PAROLA" -o "${KAYIT}.gpg" "$KAYIT"

# Kalıntıları silme
rm -f "$KAYIT"
echo "[OK] Dosya şifrelendi: ${KAYIT}.gpg oluşturuldu."