#!/bin/sh
# /root/soal3.sh - jichi (DHCP Relay)
# Instalasi isc-dhcp-relay dan menjalankan dhcrelay ke tengen (192.214.4.10).
# Versi final tanpa flag -d agar dhcrelay self-daemonize (dipakai autostart
# soal 10). IP interface jichi: eth4 ke Data Center, eth2 ke Network 2,
# eth3 ke Network 3.

# Berhenti kalau dhcrelay sudah jalan.
pgrep -x dhcrelay >/dev/null 2>&1 && exit 0

# Tunggu koneksi internet siap (untuk apt-get).
i=0
while [ $i -lt 30 ]; do
    ping -c1 -W1 192.168.122.1 >/dev/null 2>&1 && break
    i=$((i+1))
    sleep 1
done

# 1. Install isc-dhcp-relay tanpa wizard debconf.
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y isc-dhcp-relay

# 2. Konfigurasi relay.
cat > /etc/default/isc-dhcp-relay <<'EOF'
SERVERS="192.214.4.10"
INTERFACES="eth2 eth3"
OPTIONS=""
EOF

# 3. Tunggu tengen siap di jaringan.
until ping -c 1 192.214.4.10 > /dev/null 2>&1; do
    echo "Menunggu tengen..."; sleep 3
done

# 4. Jalankan relay (tanpa -d agar berjalan di background).
dhcrelay -iu eth4 -id eth2 -id eth3 192.214.4.10
