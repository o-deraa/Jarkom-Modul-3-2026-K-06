# ============================================================
# SOAL 6 - DHCP Fixed Address untuk Kugisaki
# Dokumentasi langkah (BUKAN untuk dieksekusi langsung).
# Tiap blok menandai node tempat perintah dijalankan.
# ============================================================

# ===== 1 - Deklarasi Host Fixed Address =====
# [KONFIGURASI] >>> dijalankan di: tengen
# File: /etc/dhcp/dhcpd.conf (di dalam blok subnet 192.214.3.0)
# Alamat .3.99 dipilih karena berada di luar seluruh pool dinamis
# Network 3 (short lease .3.10 sampai .3.89 dan long lease .3.100
# sampai .3.199) sehingga tidak pernah dialokasikan ke klien lain.
host kugisaki {
    hardware ethernet 02:42:df:72:fc:00;
    fixed-address 192.214.3.99;
}

# ===== 2 - Validasi dan Restart Service =====
# [PERINTAH/TESTING] >>> dijalankan di: tengen
dhcpd -t -cf /etc/dhcp/dhcpd.conf
service isc-dhcp-server restart
service isc-dhcp-server status

# ===== 3 - Bukti Lease pada Kugisaki =====
# [PERINTAH/TESTING] >>> dijalankan di: kugisaki
ip addr flush dev eth0
udhcpc -i eth0
ip -4 -br addr

# ===== Persistensi =====
# Script lengkap untuk node: scripts/per-node/tengen/soal6.sh
# Simpan sebagai /root/soal6.sh (dijalankan otomatis via post-up soal 10).
