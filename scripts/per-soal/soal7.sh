# ============================================================
# SOAL 7 - Verifikasi Konfigurasi Klien dan dhcpd.leases
# Dokumentasi langkah (BUKAN untuk dieksekusi langsung).
# Tiap blok menandai node tempat perintah dijalankan.
# ============================================================

# ===== 1 - Verifikasi IP dan Routing pada Klien =====
# [PERINTAH/TESTING] >>> dijalankan di: itadori, fushiguro, zenin, okkotsu (Network 2)
ip -4 -br addr
ip route

# [PERINTAH/TESTING] >>> dijalankan di: ino, kusakabe, miwa, kugisaki (Network 3)
ip -4 -br addr
ip route

# ===== 2 - Verifikasi dhcpd.leases pada Tengen =====
# [PERINTAH/TESTING] >>> dijalankan di: tengen
cat /var/lib/dhcp/dhcpd.leases

# ===== 3 - Tabel Kesesuaian Lease =====
# Klien     | MAC                | IP Diharapkan         | Pool
# ----------+--------------------+-----------------------+---------------------
# itadori   | 02:42:5f:04:2c:00  | 192.214.2.10 - .35    | Pool 1
# fushiguro | 02:42:9a:a3:61:00  | 192.214.2.10 - .35    | Pool 1
# zenin     | 02:42:e3:66:69:00  | 192.214.2.70 - .95    | Pool 2
# okkotsu   | 02:42:00:59:dd:00  | 192.214.2.70 - .95    | Pool 2
# ino       | 02:42:2c:e9:ee:00  | 192.214.3.10 - .89    | Short lease (1800s)
# kusakabe  | 02:42:f5:9c:59:00  | 192.214.3.10 - .89    | Short lease (1800s)
# miwa      | 02:42:0b:75:87:00  | 192.214.3.100 - .199  | Long lease (43200s)
# kugisaki  | 02:42:df:72:fc:00  | 192.214.3.99          | Fixed address
#
# Setiap entri lease di dhcpd.leases memuat: lease <IP>, hardware ethernet
# (MAC klien), starts/ends, dan binding state active.
