#!/bin/bash
# +---------------------------------------------------------------------------------------------------------------------------------+
# | Hazirlayan : Faruk TOY                                                                                                          |
# | Öğrenci No : 2420171018                                                                                                         |
# | Siber Güvenlikte Linux İşletim Sistemleri: https://www.btkakademi.gov.tr/portal/certificate/validate?certificateId=OKMhw1B2vj   |
# | Docker Temelleri: https://www.btkakademi.gov.tr/portal/certificate/validate?certificateId=zXztnNLp1n                            |
# | Linux Bash Script Eğitimi: https://credsverse.com/credentials/60b1a0f8-04fd-4951-80c5-7a14d196255a                              |
# +---------------------------------------------------------------------------------------------------------------------------------+

KAYIT="report.log"
# Dosya oluşturuluyor (touch yerine > ile sifirlama)
> "$KAYIT"

# ISO Tarih değişkenini alip dosyaya aktarma
ANLIK_ZAMAN=$(date +"%Y-%m-%dT%H:%M:%S%z")
echo "$ANLIK_ZAMAN" >> "$KAYIT"

# Sistem donanim bilgilerinin toplanmasi
echo "        SİSTEM DONANIM RAPORU            " >> "$KAYIT"
echo "==========================================" >> "$KAYIT"
echo "==========================================" >> "$KAYIT"
echo ">>>İŞLEMCİ (CPU) BİLGİLERİ" >> "$KAYIT"
wmic cpu get Manufacturer, Name, ProcessorId >> "$KAYIT"

echo "==========================================" >> "$KAYIT"
echo ">>> BELLEK (RAM) BİLGİLERİ" >> "$KAYIT"
printf "%-15s %-30s %-20s\n" "Vendor" "PartNumber" "Capacity" >> "$KAYIT"
# Sadece harf, rakam, tire ve boşlukları ayıklıyoruz.
wmic memorychip get Capacity, PartNumber | tail -n +2 | grep -oE "[A-Za-z0-9_ \.-]+" | awk '
NF>=2 {
    RAM_MARKA="Unknown"
    cap_mib = ($1 / 1024 / 1024 ) " MiB"
    
    # Awk ile Örüntü Eşleştirme (Pattern Matching) kurali
    if ($2 ~ /^CM/ || $2 ~ /^VS/) RAM_MARKA="Corsair"
    else if ($2 ~ /^F[345]-/) RAM_MARKA="G.Skill"
    else if ($2 ~ /^K[FH]/ || $2 ~ /^99/) RAM_MARKA="Kingston"
    else if ($2 ~ /^CT/) RAM_MARKA="Crucial"
    else if ($2 ~ /^M3/) RAM_MARKA="Samsung"
    else if ($2 ~ /^HMA/ || $2 ~ /^HMC/) RAM_MARKA="SK Hynix"    

    # Printf ile verileri yazdir
    printf "%-15s %-30s %-20s\n", RAM_MARKA, $2, cap_mib
}' >> "$KAYIT"

echo "==========================================" >> "$KAYIT"
echo ">>> EKRAN KARTI BİLGİLERİ" >> "$KAYIT"
# Ekran kartı adını sadece geçerli karakterleri çekerek alıyoruz ve awk ile boşlukları tıraşlıyoruz.
GPU_AD=$(wmic path win32_VideoController get Name | tail -n +2 | grep -oE "[A-Za-z0-9_ \.-]+" | awk '{$1=$1; print $0}')
# Uzun ID'yi okumak yerine grep -o ile doğrudan aradığımız marka ID'lerini (1462, 1043) cımbızlıyoruz.
GPU_MARKA_KODU=$(wmic path win32_VideoController get PNPDeviceID | grep -oE "1462|1043|1458")
# Elde ettiğimiz temiz koda göre markayı atıyoruz
if [ "$GPU_MARKA_KODU" == "1462" ]; then
    GPU_MARKA="Micro-Star International Co., Ltd."
elif [ "$GPU_MARKA_KODU" == "1043" ]; then
    GPU_MARKA="ASUSTeK Computer Inc."
elif [ "$GPU_MARKA_KODU" == "1458" ]; then
    GPU_MARKA="GIGA-BYTE Technology Co., Ltd."
else
    GPU_MARKA="Unknown"
fi
# Printf ile Sola Dayali Tablo Oluşturma
printf "%-35s %-45s\n" "Vendor" "Model (Chip Name)" >> "$KAYIT"
printf "%-35s %-45s\n" "$GPU_MARKA" "$GPU_AD" >> "$KAYIT"

echo "==========================================" >> "$KAYIT"
echo ">>>ANAKART BİLGİLERİ" >> "$KAYIT"
wmic baseboard get Manufacturer, Product, SerialNumber >> "$KAYIT"

echo "==========================================" >> "$KAYIT"
echo ">>>SİSTEM UUID (EVRENSEL KİMLİK)" >> "$KAYIT"
wmic csproduct get UUID >> "$KAYIT"

echo "==========================================" >> "$KAYIT"
echo ">>>DİSK SÜRÜCÜSÜ BİLGİLERİ" >> "$KAYIT"
wmic diskdrive get Model, SerialNumber, Size >> "$KAYIT"

echo "==========================================" >> "$KAYIT"
echo ">>>MAC ADRESİ" >> "$KAYIT"
getmac >> "$KAYIT"

echo "==========================================" >> "$KAYIT"
echo "==========================================" >> "$KAYIT"
echo "            RAPOR SONU                    " >> "$KAYIT"

# Kullanici şifre alanina yönlendirilir
echo -n "Sistemi kilitlemek için şifre girin: "
read PAROLA
echo ""

# Parola bos degilse isleme basla
if [ "$PAROLA" != "" ]; then
    
    gpg --pinentry-mode loopback --cipher-algo AES256 --symmetric --batch --yes --passphrase "$PAROLA" -o "${KAYIT}.gpg" "$KAYIT"

    # "Dosya Var mi?" (-f) Kontrolu
    if [ -f "${KAYIT}.gpg" ]; then
        # Eger gpg dosyasi gercekten diskte olustuysa, orijinal dosyayi sil
        rm -f "$KAYIT"
        echo "[OK] Dosya sifrelendi: ${KAYIT}.gpg olusturuldu."
    else
        # Eger dosya olusamadiysa (sifreleme basarisizsa)
        echo "[ERROR] Sifreleme sirasinda bir sorun olustu!"
        echo "Guvenlik amaciyla orijinal dosya (${KAYIT}) silinmedi."
    fi

else
    # Eger parola hic girilmediyse
    echo "[ERROR] Sifre bos girildi! Sifreleme islemi iptal edildi."
fi