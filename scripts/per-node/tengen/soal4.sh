#!/bin/sh
# /root/soal4.sh - tengen (DHCP pool berbasis MAC untuk Network 2)
# Menimpa dhcpd.conf dengan konfigurasi gabungan soal 2 dan soal 4:
# class pool1 (itadori, fushiguro) dan pool2 (zenin, okkotsu).
# Rentang 192.214.2.36 - 192.214.2.69 sengaja tidak masuk pool manapun.

# Lewati kalau pool Network 2 sudah terkonfigurasi.
grep -q 'allow members of "pool1"' /etc/dhcp/dhcpd.conf 2>/dev/null && exit 0

cat > /etc/dhcp/dhcpd.conf <<'EOF'
# Global
option domain-name-servers 192.214.1.2, 192.214.1.3;
default-lease-time 600;
max-lease-time 7200;
authoritative;

# Class berdasarkan MAC - Network 2
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

# Network 4 - subnet lokal tengen, tanpa pool dinamis
subnet 192.214.4.0 netmask 255.255.255.0 {
}

# Network 2 - Divisi A
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

# Network 3 - Divisi B (pool dan lease time dikonfigurasi di soal 5)
subnet 192.214.3.0 netmask 255.255.255.0 {
    option routers 192.214.3.1;
    option broadcast-address 192.214.3.255;
    option domain-name-servers 192.214.1.2, 192.214.1.3;
}
EOF

dhcpd -t -cf /etc/dhcp/dhcpd.conf
service isc-dhcp-server restart
service isc-dhcp-server status
