#!/bin/sh
# /root/soal2.sh - tengen (DHCP Server)
# Instalasi isc-dhcp-server dan konfigurasi awal scope Network 2, 3, dan 4.
# Network 4 dideklarasikan tanpa pool agar service aktif tanpa error
# "No subnet declaration".

# Berhenti kalau dhcpd sudah jalan.
pgrep -x dhcpd >/dev/null 2>&1 && exit 0

# Tunggu koneksi internet siap (untuk apt-get).
i=0
while [ $i -lt 30 ]; do
    ping -c1 -W1 192.168.122.1 >/dev/null 2>&1 && break
    i=$((i+1))
    sleep 1
done

# 1. Install isc-dhcp-server.
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y isc-dhcp-server

# 2. Interface listener (eth0 = Network 4).
cat > /etc/default/isc-dhcp-server <<'EOF'
INTERFACESv4="eth0"
INTERFACESv6=""
EOF

# 3. dhcpd.conf (scope dasar, belum ada pool).
cat > /etc/dhcp/dhcpd.conf <<'EOF'
# Global
option domain-name-servers 192.214.1.2, 192.214.1.3;
default-lease-time 600;
max-lease-time 7200;
authoritative;

# Network 4 - subnet lokal tengen, tanpa pool dinamis
subnet 192.214.4.0 netmask 255.255.255.0 {
}

# Network 2 - Divisi A (pool dan class dikonfigurasi di soal 4)
subnet 192.214.2.0 netmask 255.255.255.0 {
    option routers 192.214.2.1;
    option broadcast-address 192.214.2.255;
    option domain-name-servers 192.214.1.2, 192.214.1.3;
}

# Network 3 - Divisi B (pool dan lease time dikonfigurasi di soal 5)
subnet 192.214.3.0 netmask 255.255.255.0 {
    option routers 192.214.3.1;
    option broadcast-address 192.214.3.255;
    option domain-name-servers 192.214.1.2, 192.214.1.3;
}
EOF

# 4. Validasi dan start service.
dhcpd -t -cf /etc/dhcp/dhcpd.conf
service isc-dhcp-server restart
service isc-dhcp-server status
