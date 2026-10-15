#!/bin/sh
# /root/soal11.sh - utahime (DNS Master BIND9)
# Zona jujutsu.K-06.com sebagai master dengan allow-transfer ke shoko
# (192.214.1.3). Forwarder diarahkan ke gateway internet 192.168.122.1.

# Lewati kalau zona sudah terkonfigurasi.
grep -q 'jujutsu.K-06.com' /etc/bind/named.conf.local 2>/dev/null && exit 0

# Tunggu koneksi internet siap (untuk apt-get).
i=0
while [ $i -lt 30 ]; do
    ping -c1 -W1 192.168.122.1 >/dev/null 2>&1 && break
    i=$((i+1))
    sleep 1
done

# 1. Install BIND9.
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y bind9 bind9utils bind9-doc

# 2. Deklarasi zona master.
cat > /etc/bind/named.conf.local <<'EOF'
zone "jujutsu.K-06.com" {
    type master;
    file "/etc/bind/zones/jujutsu.K-06.com";
    allow-transfer { 192.214.1.3; };
};
EOF

# 3. Opsi BIND9 + forwarder.
cat > /etc/bind/named.conf.options <<'EOF'
options {
    directory "/var/cache/bind";
    allow-query { any; };
    recursion yes;
    forwarders {
        192.168.122.1;
    };
    dnssec-validation no;
    listen-on-v6 { any; };
};
EOF

# 4. File zona.
mkdir -p /etc/bind/zones
cat > /etc/bind/zones/jujutsu.K-06.com <<'EOF'
$TTL 604800
@ IN SOA utahime.jujutsu.K-06.com. root.jujutsu.K-06.com. (
    2026101501 ; Serial
    604800     ; Refresh
    86400      ; Retry
    2419200    ; Expire
    604800 )   ; Negative Cache TTL

; NS Records
@ IN NS utahime.jujutsu.K-06.com.
@ IN NS shoko.jujutsu.K-06.com.

; A Records
utahime IN A 192.214.1.2
shoko   IN A 192.214.1.3
EOF

# 5. Validasi dan start service.
named-checkconf
named-checkzone jujutsu.K-06.com /etc/bind/zones/jujutsu.K-06.com
service named restart
service named status
