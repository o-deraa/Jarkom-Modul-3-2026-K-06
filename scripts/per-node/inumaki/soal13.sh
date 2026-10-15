#!/bin/sh
# /root/soal13.sh - inumaki (MariaDB DB-Slave)
# Slave dengan server-id 42 yang menyalin data dari yaga (192.214.4.41)
# menggunakan CHANGE MASTER TO.

# Lewati kalau replikasi sudah terkonfigurasi.
mariadb -e "SHOW SLAVE STATUS\G" 2>/dev/null | grep -q 'Master_Host: 192.214.4.41' && exit 0

# Tunggu koneksi internet siap (untuk apt-get).
i=0
while [ $i -lt 30 ]; do
    ping -c1 -W1 192.168.122.1 >/dev/null 2>&1 && break
    i=$((i+1))
    sleep 1
done

# 1. Install MariaDB.
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y mariadb-server mariadb-client

# 2. Konfigurasi slave (server-id berbeda + relay log).
cat > /etc/mysql/mariadb.conf.d/50-server.cnf <<'EOF'
[mysqld]
bind-address = 0.0.0.0
server-id = 42
relay-log = /var/log/mysql/mariadb-relay-bin
EOF

# 3. Direktori relay log.
mkdir -p /var/log/mysql
chown mysql:mysql /var/log/mysql
chmod 750 /var/log/mysql
service mariadb restart

# 4. Tunggu master yaga siap di jaringan.
until ping -c 1 192.214.4.41 >/dev/null 2>&1; do
    echo "Menunggu yaga..."; sleep 3
done

# 5. Samakan struktur tabel agar event replikasi tidak gagal
# (menghindari error "Table 'db_shibuya_K-06.request_logs' doesn't exist").
mariadb <<'EOF'
CREATE DATABASE IF NOT EXISTS `db_shibuya_K-06`;

USE `db_shibuya_K-06`;

CREATE TABLE IF NOT EXISTS request_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    source_node VARCHAR(50) NOT NULL,
    action VARCHAR(100) NOT NULL,
    details TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
EOF

# 6. Hubungkan slave ke master.
mariadb <<'EOF'
STOP SLAVE;

CHANGE MASTER TO
    MASTER_HOST = '192.214.4.41',
    MASTER_USER = 'replicator',
    MASTER_PASSWORD = 'ReplK06_StrongPass!',
    MASTER_PORT = 3306,
    MASTER_LOG_FILE = 'mariadb-bin.000001',
    MASTER_LOG_POS = 1323;

START SLAVE;
EOF

# 7. Tampilkan status replikasi.
mariadb -e "SHOW SLAVE STATUS\G" | grep -E 'Slave_IO_Running|Slave_SQL_Running|Last_IO_Error|Last_SQL_Error|Master_Host|Master_User'
