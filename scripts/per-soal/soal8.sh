# ============================================================
# SOAL 8 - Packet Capture DORA dan Field giaddr
# Dokumentasi langkah (BUKAN untuk dieksekusi langsung).
# Tiap blok menandai node tempat perintah dijalankan.
# ============================================================

# ===== 1 - Jalankan tcpdump di Background (Network 2) =====
# [PERINTAH/TESTING] >>> dijalankan di: jichi
# -c 8 menghentikan capture otomatis setelah 8 paket (satu siklus
# DORA bolak-balik ditambah beberapa paket pendukung).
tcpdump -i eth4 -v -n -c 8 port 67 > /root/dora.txt 2>&1 &

# ===== 2 - Picu DORA dari Klien =====
# [PERINTAH/TESTING] >>> dijalankan di: itadori
ip addr flush dev eth0
udhcpc -i eth0

# ===== 3 - Baca Hasil Capture =====
# [PERINTAH/TESTING] >>> dijalankan di: jichi
cat /root/dora.txt

# ===== 4 - Pengujian untuk Network 3 =====
# [PERINTAH/TESTING] >>> dijalankan di: jichi
tcpdump -i eth4 -v -n -c 8 port 67 > /root/dora_net3.txt 2>&1 &

# [PERINTAH/TESTING] >>> dijalankan di: ino
ip addr flush dev eth0
udhcpc -i eth0

# [PERINTAH/TESTING] >>> dijalankan di: jichi
cat /root/dora_net3.txt

# ===== Catatan Field giaddr =====
# giaddr diisi oleh relay agent (jichi) dengan IP interface-nya di sisi
# subnet klien sebelum paket diteruskan ke tengen.
#   Network 2 -> giaddr 192.214.2.1 (eth2)
#   Network 3 -> giaddr 192.214.3.1 (eth3)
# Urutan yang diamati: DHCP Discover, DHCP Offer, DHCP Request, DHCP ACK.
