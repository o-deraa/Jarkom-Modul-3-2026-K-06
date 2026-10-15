# ============================================================
# SOAL 11 - Konfigurasi DNS Master dan Slave
# Dokumentasi langkah (BUKAN untuk dieksekusi langsung).
# Tiap blok menandai node tempat perintah dijalankan.
# ============================================================

# ===== 1 - Instalasi BIND9 =====
# [PERINTAH/TESTING] >>> dijalankan di: utahime dan shoko
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y bind9 bind9utils bind9-doc

# ===== 2 - named.conf.local pada Utahime (Master) =====
# [KONFIGURASI] >>> dijalankan di: utahime
# File: /etc/bind/named.conf.local
zone "jujutsu.K-06.com" {
    type master;
    file "/etc/bind/zones/jujutsu.K-06.com";
    allow-transfer { 192.214.1.3; };
};

# ===== 3 - named.conf.local pada Shoko (Slave) =====
# [KONFIGURASI] >>> dijalankan di: shoko
# File: /etc/bind/named.conf.local
zone "jujutsu.K-06.com" {
    type slave;
    file "/var/cache/bind/jujutsu.K-06.com";
    masters { 192.214.1.2; };
};

# ===== 4 - named.conf.options (Utahime dan Shoko) =====
# [KONFIGURASI] >>> dijalankan di: utahime dan shoko
# File: /etc/bind/named.conf.options
options {
    directory "/var/cache/bind";
    allow-query { any; };
    recursion yes;
    forwarders {
        192.168.122.1;
    };
    dnssec-validation no;
    listen-on-v6 { any; };
};

# ===== 5 - File Zona pada Utahime =====
# [KONFIGURASI] >>> dijalankan di: utahime
# File: /etc/bind/zones/jujutsu.K-06.com
$TTL 604800
@ IN SOA utahime.jujutsu.K-06.com. root.jujutsu.K-06.com. (
    2026101501 ; Serial
    604800     ; Refresh
    86400      ; Retry
    2419200    ; Expire
    604800 )   ; Negative Cache TTL

; NS Records
@ IN NS utahime.jujutsu.K-06.com.
@ IN NS shoko.jujutsu.K-06.com.

; A Records
utahime IN A 192.214.1.2
shoko   IN A 192.214.1.3

# ===== 6 - Menjalankan BIND9 =====
# [PERINTAH/TESTING] >>> dijalankan di: utahime
# Master dijalankan lebih dulu. Nama service pada Debian adalah
# "named" (bukan bind9).
named-checkconf
named-checkzone jujutsu.K-06.com /etc/bind/zones/jujutsu.K-06.com
service named restart
service named status

# [PERINTAH/TESTING] >>> dijalankan di: shoko
named-checkconf
service named restart
service named status

# ===== 7 - Verifikasi Zone Transfer ke Shoko =====
# [PERINTAH/TESTING] >>> dijalankan di: shoko
ls -l /var/cache/bind/jujutsu.K-06.com
dig SOA jujutsu.K-06.com @192.214.1.3

# [PERINTAH/TESTING] >>> dijalankan di: utahime
dig SOA jujutsu.K-06.com @192.214.1.2

# Kedua server harus memberi status NOERROR dengan serial yang sama.

# ===== 8 - Uji Sinkronisasi dengan Kenaikan Serial =====
# [PERINTAH/TESTING] >>> dijalankan di: utahime
sed -i 's/2026101501/2026101502/' /etc/bind/zones/jujutsu.K-06.com
named-checkzone jujutsu.K-06.com /etc/bind/zones/jujutsu.K-06.com
rndc reload jujutsu.K-06.com

# [PERINTAH/TESTING] >>> dijalankan di: shoko
dig SOA jujutsu.K-06.com @192.214.1.3 +short
# Serial yang diharapkan setelah sinkronisasi: 2026101502

# ===== 9 - Bukti Query dari Client =====
# [PERINTAH/TESTING] >>> dijalankan di: salah satu klien (misalnya itadori)
# Keempat query harus mengembalikan IP yang sama dari Master maupun Slave.
dig utahime.jujutsu.K-06.com A @192.214.1.2
dig utahime.jujutsu.K-06.com A @192.214.1.3
dig shoko.jujutsu.K-06.com A @192.214.1.2
dig shoko.jujutsu.K-06.com A @192.214.1.3

# ===== Persistensi =====
# Script lengkap untuk node:
#   scripts/per-node/utahime/soal11.sh
#   scripts/per-node/shoko/soal11.sh
