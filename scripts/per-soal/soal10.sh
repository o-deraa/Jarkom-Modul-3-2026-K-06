# ============================================================
# SOAL 10 - Autostart dan Uji Restart
# Dokumentasi langkah (BUKAN untuk dieksekusi langsung).
# Tiap blok menandai node tempat perintah dijalankan.
# ============================================================

# ===== 1 - Update soal3.sh di Jichi =====
# [KONFIGURASI] >>> dijalankan di: jichi
# File: /root/soal3.sh (versi final)
# Flag -d dihapus agar dhcrelay self-daemonize dan tidak memblokir
# proses boot. Script lengkap: scripts/per-node/jichi/soal3.sh

# ===== 2 - Autostart pada Tengen =====
# [KONFIGURASI] >>> dijalankan di: tengen
# File: /etc/network/interfaces (Edit config di GNS3)
# soal2.sh dijalankan lebih dulu, tunggu 5 detik, lalu soal6.sh
# (konfigurasi final mencakup seluruh soal 2 sampai 6).
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.214.4.10
    netmask 255.255.255.0
    gateway 192.214.4.1
    post-up echo "nameserver 192.168.122.1" > /etc/resolv.conf
post-up /bin/sh -c '/bin/bash /root/soal2.sh; sleep 5; /bin/bash /root/soal6.sh'

# ===== 3 - Autostart pada Jichi =====
# [KONFIGURASI] >>> dijalankan di: jichi
# File: /etc/network/interfaces (Edit config di GNS3)
# post-up soal3.sh dijalankan pada blok eth4.
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
    post-up bash /root/soal3.sh

# ===== 4 - Urutan Start Node =====
# 1. jichi       : gateway semua jaringan, NAT, dan relay harus aktif lebih dulu.
# 2. tengen      : butuh jichi untuk internet saat soal6.sh berjalan.
# 3. Server lain : butuh jichi sebagai gateway.
# 4. Klien       : butuh tengen untuk DHCP dan jichi sebagai relay.

# ===== 5 - Uji Restart Tengen =====
# [PERINTAH/TESTING] >>> dijalankan di: GNS3 (stop lalu start node tengen)
# [PERINTAH/TESTING] >>> dijalankan di: tengen
service isc-dhcp-server status

# ===== 6 - Uji Restart Jichi =====
# [PERINTAH/TESTING] >>> dijalankan di: GNS3 (stop lalu start node jichi)
# [PERINTAH/TESTING] >>> dijalankan di: jichi
ps aux | grep dhcrelay

# ===== 7 - Uji Akhir Klien =====
# [PERINTAH/TESTING] >>> dijalankan di: itadori
ip addr flush dev eth0
udhcpc -i eth0
ip -4 -br addr

# Catatan: instalasi paket (isc-dhcp-server, isc-dhcp-relay) cukup
# dilakukan sekali karena paket tidak hilang saat node di-restart.
