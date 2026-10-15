# ============================================================
# SOAL 9 - Simulasi Relay Mati dan Pemulihan
# Dokumentasi langkah (BUKAN untuk dieksekusi langsung).
# Tiap blok menandai node tempat perintah dijalankan.
# ============================================================

# ===== 1 - Catat Kondisi Awal Klien =====
# [PERINTAH/TESTING] >>> dijalankan di: itadori
ip -4 -br addr

# ===== 2 - Matikan Relay di Jichi =====
# [PERINTAH/TESTING] >>> dijalankan di: jichi
kill $(pgrep dhcrelay)
ps aux | grep dhcrelay

# ===== 3 - Klien Minta Lease Baru (Harus Gagal) =====
# [PERINTAH/TESTING] >>> dijalankan di: itadori
# Karena relay mati, DHCP Discover tidak sampai ke tengen dan udhcpc
# akan timeout tanpa mendapat balasan.
ip addr flush dev eth0
udhcpc -i eth0

# ===== 4 - Pulihkan Relay di Jichi =====
# [PERINTAH/TESTING] >>> dijalankan di: jichi
dhcrelay -d -iu eth4 -id eth2 -id eth3 192.214.4.10

# ===== 5 - Klien Minta Lease Ulang (Harus Berhasil) =====
# [PERINTAH/TESTING] >>> dijalankan di: itadori
udhcpc -i eth0
ip -4 -br addr

# Catatan: klien harus kembali memperoleh alamat dari pool yang benar
# dengan gateway semula, membuktikan relay adalah komponen kritis.
