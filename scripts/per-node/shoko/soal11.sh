#!/bin/sh
# /root/soal11.sh - shoko (DNS Slave BIND9)
# Zona jujutsu.K-06.com sebagai slave yang menarik salinan zona dari
# master utahime (192.214.1.2). Jalankan setelah master siap.

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

# 2. Deklarasi zona slave.
cat > /etc/bind/named.conf.local <<'EOF'
zone "jujutsu.K-06.com" {
    type slave;
    file "/var/cache/bind/jujutsu.K-06.com";
    masters { 192.214.1.2; };
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

# 4. Tunggu master utahime siap di jaringan.
i=0
while [ $i -lt 30 ]; do
    ping -c1 -W1 192.214.1.2 >/dev/null 2>&1 && break
    i=$((i+1))
    sleep 1
done

# 5. Validasi dan start service.
named-checkconf
service named restart
service named status
