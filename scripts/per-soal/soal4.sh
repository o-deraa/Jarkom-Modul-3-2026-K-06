# ============================================================
# SOAL 4 - DHCP Pool Berbasis MAC untuk Network 2
# Dokumentasi langkah (BUKAN untuk dieksekusi langsung).
# Tiap blok menandai node tempat perintah dijalankan.
# ============================================================

# ===== 1 - Deklarasi Class Berdasarkan MAC =====
# [KONFIGURASI] >>> dijalankan di: tengen
# File: /etc/dhcp/dhcpd.conf
# Prefix 1: pada subclass menandakan hardware type Ethernet.
class "pool1" {
    match hardware;
}
subclass "pool1" 1:02:42:5f:04:2c:00;  # itadori
subclass "pool1" 1:02:42:9a:a3:61:00;  # fushiguro

class "pool2" {
    match hardware;
}
subclass "pool2" 1:02:42:e3:66:69:00;  # zenin
subclass "pool2" 1:02:42:00:59:dd:00;  # okkotsu

# ===== 2 - Konfigurasi Pool pada Subnet Network 2 =====
# [KONFIGURASI] >>> dijalankan di: tengen
# File: /etc/dhcp/dhcpd.conf
# Rentang .36 sampai .69 tidak dimasukkan ke pool manapun sehingga
# tidak pernah dialokasikan.
subnet 192.214.2.0 netmask 255.255.255.0 {
    option routers 192.214.2.1;
    option broadcast-address 192.214.2.255;
    option domain-name-servers 192.214.1.2, 192.214.1.3;

    pool {
        allow members of "pool1";
        range 192.214.2.10 192.214.2.35;
    }

    pool {
        allow members of "pool2";
        range 192.214.2.70 192.214.2.95;
    }
}

# ===== 3 - Validasi dan Restart Service =====
# [PERINTAH/TESTING] >>> dijalankan di: tengen
dhcpd -t -cf /etc/dhcp/dhcpd.conf
service isc-dhcp-server restart
service isc-dhcp-server status

# ===== 4 - Bukti Lease pada Klien =====
# [PERINTAH/TESTING] >>> dijalankan di: itadori
ip addr flush dev eth0
udhcpc -i eth0
ip -4 -br addr

# [PERINTAH/TESTING] >>> dijalankan di: fushiguro
ip addr flush dev eth0
udhcpc -i eth0
ip -4 -br addr

# [PERINTAH/TESTING] >>> dijalankan di: zenin
ip addr flush dev eth0
udhcpc -i eth0
ip -4 -br addr

# [PERINTAH/TESTING] >>> dijalankan di: okkotsu
ip addr flush dev eth0
udhcpc -i eth0
ip -4 -br addr

# ===== Persistensi =====
# Script lengkap untuk node: scripts/per-node/tengen/soal4.sh
# Simpan sebagai /root/soal4.sh.
