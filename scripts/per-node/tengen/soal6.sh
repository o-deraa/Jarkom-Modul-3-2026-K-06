#!/bin/sh
# /root/soal6.sh - tengen (DHCP fixed address untuk Kugisaki)
# Konfigurasi final yang mencakup seluruh aturan soal 2 sampai 6, termasuk
# host kugisaki dengan fixed address 192.214.3.99 (di luar semua pool dinamis).

# Lewati kalau fixed address kugisaki sudah terkonfigurasi.
grep -q 'kugisaki' /etc/dhcp/dhcpd.conf 2>/dev/null && exit 0

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

# Class berdasarkan MAC - Network 3
class "short-lease" {
    match hardware;
}
subclass "short-lease" 1:02:42:2c:e9:ee:00;  # ino
subclass "short-lease" 1:02:42:f5:9c:59:00;  # kusakabe

class "long-lease" {
    match hardware;
}
subclass "long-lease" 1:02:42:0b:75:87:00;   # miwa

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

# Network 3 - Divisi B
subnet 192.214.3.0 netmask 255.255.255.0 {
    option routers 192.214.3.1;
    option broadcast-address 192.214.3.255;
    option domain-name-servers 192.214.1.2, 192.214.1.3;
    option domain-search "K-06.com";

    pool {
        allow members of "short-lease";
        range 192.214.3.10 192.214.3.89;
        default-lease-time 1800;
        max-lease-time 1800;
    }

    pool {
        allow members of "long-lease";
        range 192.214.3.100 192.214.3.199;
        default-lease-time 43200;
        max-lease-time 43200;
    }

    host kugisaki {
        hardware ethernet 02:42:df:72:fc:00;
        fixed-address 192.214.3.99;
    }
}
EOF

dhcpd -t -cf /etc/dhcp/dhcpd.conf
service isc-dhcp-server restart
service isc-dhcp-server status
