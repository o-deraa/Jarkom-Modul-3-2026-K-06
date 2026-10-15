# ============================================================
# SOAL 2 - Konfigurasi DHCP Server pada Tengen
# Dokumentasi langkah (BUKAN untuk dieksekusi langsung).
# Tiap blok menandai node tempat perintah dijalankan.
# ============================================================

# ===== 1 - Instalasi isc-dhcp-server =====
# [PERINTAH/TESTING] >>> dijalankan di: tengen
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y isc-dhcp-server

# ===== 2 - Konfigurasi Interface Listener =====
# [KONFIGURASI] >>> dijalankan di: tengen
# File: /etc/default/isc-dhcp-server
INTERFACESv4="eth0"
INTERFACESv6=""

# ===== 3 - Konfigurasi dhcpd.conf =====
# [KONFIGURASI] >>> dijalankan di: tengen
# File: /etc/dhcp/dhcpd.conf
# Network 4 dideklarasikan tanpa pool agar service aktif (tidak error
# "No subnet declaration"), sedangkan Network 2 dan 3 disiapkan dengan
# opsi dasar sebagai fondasi pool di soal berikutnya.

# Global
option domain-name-servers 192.214.1.2, 192.214.1.3;
default-lease-time 600;
max-lease-time 7200;
authoritative;

# Network 4 - subnet lokal tengen, tanpa pool dinamis
subnet 192.214.4.0 netmask 255.255.255.0 {
}

# Network 2 - Divisi A (pool dan class dikonfigurasi di soal 4)
subnet 192.214.2.0 netmask 255.255.255.0 {
    option routers 192.214.2.1;
    option broadcast-address 192.214.2.255;
    option domain-name-servers 192.214.1.2, 192.214.1.3;
}

# Network 3 - Divisi B (pool dan lease time dikonfigurasi di soal 5)
subnet 192.214.3.0 netmask 255.255.255.0 {
    option routers 192.214.3.1;
    option broadcast-address 192.214.3.255;
    option domain-name-servers 192.214.1.2, 192.214.1.3;
}

# ===== 4 - Validasi dan Start Service =====
# [PERINTAH/TESTING] >>> dijalankan di: tengen
dhcpd -t -cf /etc/dhcp/dhcpd.conf
service isc-dhcp-server restart
service isc-dhcp-server status

# ===== Persistensi =====
# Script lengkap untuk node: scripts/per-node/tengen/soal2.sh
# Simpan sebagai /root/soal2.sh (dijalankan otomatis via post-up soal 10).
