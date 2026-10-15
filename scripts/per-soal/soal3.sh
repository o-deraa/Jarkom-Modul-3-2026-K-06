# ============================================================
# SOAL 3 - Konfigurasi DHCP Relay pada Jichi
# Dokumentasi langkah (BUKAN untuk dieksekusi langsung).
# Tiap blok menandai node tempat perintah dijalankan.
# ============================================================

# ===== 1 - Instalasi isc-dhcp-relay =====
# [PERINTAH/TESTING] >>> dijalankan di: jichi
# Instalasi memakai DEBIAN_FRONTEND=noninteractive agar wizard debconf
# (yang muncul saat instalasi manual) dilewati.
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y isc-dhcp-relay

# ===== 2 - Konfigurasi Relay =====
# [KONFIGURASI] >>> dijalankan di: jichi
# File: /etc/default/isc-dhcp-relay
SERVERS="192.214.4.10"
INTERFACES="eth2 eth3"
OPTIONS=""

# ===== 3 - Menjalankan Relay =====
# [PERINTAH/TESTING] >>> dijalankan di: jichi
dhcrelay -d -iu eth4 -id eth2 -id eth3 192.214.4.10

# Catatan: flag -d dipakai saat pengujian interaktif agar log tampil di
# terminal. Versi autostart (soal 10) menghapus -d supaya dhcrelay
# self-daemonize dan tidak memblokir proses boot.

# ===== 4 - Bukti Lease pada Klien =====
# [PERINTAH/TESTING] >>> dijalankan di: klien Network 2 (itadori, fushiguro, zenin, okkotsu)
ip addr flush dev eth0
udhcpc -i eth0
ip -4 -br addr

# [PERINTAH/TESTING] >>> dijalankan di: klien Network 3 (ino, kusakabe, miwa, kugisaki)
ip addr flush dev eth0
udhcpc -i eth0
ip -4 -br addr

# ===== Persistensi =====
# Script lengkap untuk node: scripts/per-node/jichi/soal3.sh
# Simpan sebagai /root/soal3.sh (versi final tanpa -d, dipakai saat
# autostart soal 10).
