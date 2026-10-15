# ============================================================
# SOAL 1 - Konfigurasi Jaringan Dasar Jujutsu High
# Dokumentasi langkah (BUKAN untuk dieksekusi langsung).
# Tiap blok menandai node tempat perintah dijalankan.
# ============================================================

# ===== 1 - Konfigurasi Router Utama (jichi) =====
# [KONFIGURASI] >>> dijalankan di: jichi
# File: /etc/network/interfaces (Edit config di GNS3)
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
    post-up echo "nameserver 192.168.122.1" > /etc/resolv.conf
    post-up sysctl -w net.ipv4.ip_forward=1
    post-up iptables -t nat -C POSTROUTING -o eth0 -s 192.214.0.0/16 -j MASQUERADE || iptables -t nat -A POSTROUTING -o eth0 -s 192.214.0.0/16 -j MASQUERADE

auto eth1
iface eth1 inet static
    address 192.214.1.1
    netmask 255.255.255.0

auto eth2
iface eth2 inet static
    address 192.214.2.1
    netmask 255.255.255.0

auto eth3
iface eth3 inet static
    address 192.214.3.1
    netmask 255.255.255.0

auto eth4
iface eth4 inet static
    address 192.214.4.1
    netmask 255.255.255.0

# ===== 2 - IP Statis Network 1 (DMZ) =====
# [KONFIGURASI] >>> dijalankan di: utahime
# File: /etc/network/interfaces (Edit config di GNS3)
auto eth0
iface eth0 inet static
    address 192.214.1.2
    netmask 255.255.255.0
    gateway 192.214.1.1
    post-up echo "nameserver 192.168.122.1" > /etc/resolv.conf

# [KONFIGURASI] >>> dijalankan di: shoko
# File: /etc/network/interfaces (Edit config di GNS3)
auto eth0
iface eth0 inet static
    address 192.214.1.3
    netmask 255.255.255.0
    gateway 192.214.1.1
    post-up echo "nameserver 192.168.122.1" > /etc/resolv.conf

# [KONFIGURASI] >>> dijalankan di: gojo
# File: /etc/network/interfaces (Edit config di GNS3)
auto eth0
iface eth0 inet static
    address 192.214.1.4
    netmask 255.255.255.0
    gateway 192.214.1.1
    post-up echo "nameserver 192.168.122.1" > /etc/resolv.conf

# ===== 3 - IP Statis Network 4 (Data Center) =====
# [KONFIGURASI] >>> dijalankan di: tengen
# File: /etc/network/interfaces (Edit config di GNS3)
auto eth0
iface eth0 inet static
    address 192.214.4.10
    netmask 255.255.255.0
    gateway 192.214.4.1
    post-up echo "nameserver 192.168.122.1" > /etc/resolv.conf

# [KONFIGURASI] >>> dijalankan di: geto
# File: /etc/network/interfaces (Edit config di GNS3)
auto eth0
iface eth0 inet static
    address 192.214.4.11
    netmask 255.255.255.0
    gateway 192.214.4.1
    post-up echo "nameserver 192.168.122.1" > /etc/resolv.conf

# [KONFIGURASI] >>> dijalankan di: maki
# File: /etc/network/interfaces (Edit config di GNS3)
auto eth0
iface eth0 inet static
    address 192.214.4.21
    netmask 255.255.255.0
    gateway 192.214.4.1
    post-up echo "nameserver 192.168.122.1" > /etc/resolv.conf

# [KONFIGURASI] >>> dijalankan di: panda
# File: /etc/network/interfaces (Edit config di GNS3)
auto eth0
iface eth0 inet static
    address 192.214.4.22
    netmask 255.255.255.0
    gateway 192.214.4.1
    post-up echo "nameserver 192.168.122.1" > /etc/resolv.conf

# [KONFIGURASI] >>> dijalankan di: nanami
# File: /etc/network/interfaces (Edit config di GNS3)
auto eth0
iface eth0 inet static
    address 192.214.4.31
    netmask 255.255.255.0
    gateway 192.214.4.1
    post-up echo "nameserver 192.168.122.1" > /etc/resolv.conf

# [KONFIGURASI] >>> dijalankan di: todo
# File: /etc/network/interfaces (Edit config di GNS3)
auto eth0
iface eth0 inet static
    address 192.214.4.32
    netmask 255.255.255.0
    gateway 192.214.4.1
    post-up echo "nameserver 192.168.122.1" > /etc/resolv.conf

# [KONFIGURASI] >>> dijalankan di: kirara
# File: /etc/network/interfaces (Edit config di GNS3)
auto eth0
iface eth0 inet static
    address 192.214.4.33
    netmask 255.255.255.0
    gateway 192.214.4.1
    post-up echo "nameserver 192.168.122.1" > /etc/resolv.conf

# [KONFIGURASI] >>> dijalankan di: yaga
# File: /etc/network/interfaces (Edit config di GNS3)
auto eth0
iface eth0 inet static
    address 192.214.4.41
    netmask 255.255.255.0
    gateway 192.214.4.1
    post-up echo "nameserver 192.168.122.1" > /etc/resolv.conf

# [KONFIGURASI] >>> dijalankan di: inumaki
# File: /etc/network/interfaces (Edit config di GNS3)
auto eth0
iface eth0 inet static
    address 192.214.4.42
    netmask 255.255.255.0
    gateway 192.214.4.1
    post-up echo "nameserver 192.168.122.1" > /etc/resolv.conf

# ===== 4 - Pengujian Konektivitas =====
# [PERINTAH/TESTING] >>> dijalankan di: host Network 1 (utahime, shoko, gojo)
ping -c 3 192.214.1.1
ping -c 3 google.com

# [PERINTAH/TESTING] >>> dijalankan di: host Network 4 (tengen, geto, maki, dll.)
ping -c 3 192.214.4.1
ping -c 3 google.com
