# ============================================================
# SOAL 12 - Konfigurasi DNS Record, Reverse DNS, dan DNS Forwarder
# Dokumentasi langkah (BUKAN untuk dieksekusi langsung).
# Tiap blok menandai node tempat perintah dijalankan.
# ============================================================

# ===== 1 - Konfigurasi Forward Zone pada Utahime =====
# [KONFIGURASI] >>> dijalankan di: utahime
# File: /etc/bind/db.jujutsu.K-06.com
# gojo diarahkan ke 192.214.1.4 dan www dijadikan alias domain utama.
@       IN NS    utahime.jujutsu.K-06.com.
@       IN NS    shoko.jujutsu.K-06.com.
utahime IN A     192.214.1.2
shoko   IN A     192.214.1.3
gojo    IN A     192.214.1.4
@       IN A     192.214.1.4
www     IN CNAME jujutsu.K-06.com.

# ===== 2 - Konfigurasi Reverse DNS =====
# [KONFIGURASI] >>> dijalankan di: utahime
# File: /etc/bind/db.reverse.192.214.1
# Record PTR memetakan 192.214.1.4 kembali ke nama domain gojo.
4 IN PTR gojo.jujutsu.K-06.com.

# [KONFIGURASI] >>> dijalankan di: utahime
# File: /etc/bind/named.conf.local (deklarasi zona reverse)
zone "1.214.192.in-addr.arpa" {
    type master;
    file "/etc/bind/db.reverse.192.214.1";
};

# ===== 3 - Konfigurasi DNS Forwarder =====
# [KONFIGURASI] >>> dijalankan di: utahime
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

# ===== 4 - Validasi Konfigurasi BIND9 =====
# [PERINTAH/TESTING] >>> dijalankan di: utahime
named-checkconf
named-checkzone jujutsu.K-06.com /etc/bind/db.jujutsu.K-06.com
named-checkzone 1.214.192.in-addr.arpa /etc/bind/db.reverse.192.214.1
service named restart

# ===== 5 - Pengujian A, CNAME, dan Reverse DNS =====
# [PERINTAH/TESTING] >>> dijalankan di: utahime
dig @127.0.0.1 gojo.jujutsu.K-06.com A +short
dig @127.0.0.1 www.jujutsu.K-06.com CNAME +short
dig @127.0.0.1 -x 192.214.1.2 +short

# ===== 6 - Pengujian DNS Eksternal dan Konektivitas =====
# [PERINTAH/TESTING] >>> dijalankan di: utahime
dig @127.0.0.1 google.com A +short
ping -c 4 google.com

# ===== Persistensi =====
# Script lengkap untuk node: scripts/per-node/utahime/soal12.sh
# Simpan sebagai /root/soal12.sh.
