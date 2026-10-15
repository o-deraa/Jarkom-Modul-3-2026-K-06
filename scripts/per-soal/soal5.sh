# ============================================================
# SOAL 5 - DHCP Pool dengan Lease Time Berbeda untuk Network 3
# Dokumentasi langkah (BUKAN untuk dieksekusi langsung).
# Tiap blok menandai node tempat perintah dijalankan.
# ============================================================

# ===== 1 - Deklarasi Class Berdasarkan MAC =====
# [KONFIGURASI] >>> dijalankan di: tengen
# File: /etc/dhcp/dhcpd.conf
# Kugisaki sengaja tidak dimasukkan ke class manapun karena akan
# mendapat fixed address pada soal 6.
class "short-lease" {
    match hardware;
}
subclass "short-lease" 1:02:42:2c:e9:ee:00;  # ino
subclass "short-lease" 1:02:42:f5:9c:59:00;  # kusakabe

class "long-lease" {
    match hardware;
}
subclass "long-lease" 1:02:42:0b:75:87:00;   # miwa

# ===== 2 - Konfigurasi Pool pada Subnet Network 3 =====
# [KONFIGURASI] >>> dijalankan di: tengen
# File: /etc/dhcp/dhcpd.conf
# Lease time ditulis per pool agar tidak saling menimpa nilai global.
subnet 192.214.3.0 netmask 255.255.255.0 {
    option routers 192.214.3.1;
    option broadcast-address 192.214.3.255;
    option domain-name-servers 192.214.1.2, 192.214.1.3;
    option domain-search "K-06.com";

    pool {
        allow members of "short-lease";
        range 192.214.3.10 192.214.3.89;
        default-lease-time 1800;
        max-lease-time 1800;
    }

    pool {
        allow members of "long-lease";
        range 192.214.3.100 192.214.3.199;
        default-lease-time 43200;
        max-lease-time 43200;
    }
}

# ===== 3 - Validasi dan Restart Service =====
# [PERINTAH/TESTING] >>> dijalankan di: tengen
dhcpd -t -cf /etc/dhcp/dhcpd.conf
service isc-dhcp-server restart
service isc-dhcp-server status

# ===== 4 - Bukti Lease pada Klien =====
# [PERINTAH/TESTING] >>> dijalankan di: ino
ip addr flush dev eth0
udhcpc -i eth0
ip -4 -br addr

# [PERINTAH/TESTING] >>> dijalankan di: kusakabe
ip addr flush dev eth0
udhcpc -i eth0
ip -4 -br addr

# [PERINTAH/TESTING] >>> dijalankan di: miwa
ip addr flush dev eth0
udhcpc -i eth0
ip -4 -br addr

# ===== 5 - Verifikasi Lease Time =====
# [PERINTAH/TESTING] >>> dijalankan di: tengen
cat /var/lib/dhcp/dhcpd.leases

# ===== Persistensi =====
# Script lengkap untuk node: scripts/per-node/tengen/soal5.sh
# Simpan sebagai /root/soal5.sh.
