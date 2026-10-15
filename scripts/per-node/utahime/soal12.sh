#!/bin/sh
# /root/soal12.sh - utahime (DNS record, reverse DNS, dan forwarder)
# Menambahkan A record gojo, CNAME www, zona reverse dengan PTR, dan
# mengaktifkan DNS Forwarder ke 192.168.122.1.

# Lewati kalau zona reverse sudah terkonfigurasi.
grep -q 'in-addr.arpa' /etc/bind/named.conf.local 2>/dev/null && exit 0

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

# 2. Deklarasi zona forward (master) dan zona reverse.
cat > /etc/bind/named.conf.local <<'EOF'
zone "jujutsu.K-06.com" {
    type master;
    file "/etc/bind/db.jujutsu.K-06.com";
    allow-transfer { 192.214.1.3; };
};

zone "1.214.192.in-addr.arpa" {
    type master;
    file "/etc/bind/db.reverse.192.214.1";
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

# 4. Forward zone (A record gojo + CNAME www).
cat > /etc/bind/db.jujutsu.K-06.com <<'EOF'
$TTL 604800
@ IN SOA utahime.jujutsu.K-06.com. root.jujutsu.K-06.com. (
    2026101502 ; Serial
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
gojo    IN A 192.214.1.4
@       IN A 192.214.1.4

; CNAME Record
www IN CNAME jujutsu.K-06.com.
EOF

# 5. Reverse zone (PTR gojo).
cat > /etc/bind/db.reverse.192.214.1 <<'EOF'
$TTL 604800
@ IN SOA utahime.jujutsu.K-06.com. root.jujutsu.K-06.com. (
    2026101502 ; Serial
    604800     ; Refresh
    86400      ; Retry
    2419200    ; Expire
    604800 )   ; Negative Cache TTL

@ IN NS utahime.jujutsu.K-06.com.

; PTR Record
4 IN PTR gojo.jujutsu.K-06.com.
EOF

# 6. Validasi dan start service.
named-checkconf
named-checkzone jujutsu.K-06.com /etc/bind/db.jujutsu.K-06.com
named-checkzone 1.214.192.in-addr.arpa /etc/bind/db.reverse.192.214.1
service named restart
service named status
