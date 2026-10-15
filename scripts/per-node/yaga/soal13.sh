#!/bin/sh
# /root/soal13.sh - yaga (MariaDB DB-Master)
# Database db_shibuya_K-06 dengan tabel request_logs, binary logging
# aktif, dan akun replicator untuk Inumaki.

# Lewati kalau database dan tabel sudah tersedia.
mariadb -e "SHOW TABLES FROM \`db_shibuya_K-06\`" 2>/dev/null | grep -q request_logs && exit 0

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

# 2. Konfigurasi master (server-id unik + binary logging).
cat > /etc/mysql/mariadb.conf.d/50-server.cnf <<'EOF'
[mysqld]
bind-address = 0.0.0.0
server-id = 41
log_bin = /var/log/mysql/mariadb-bin
binlog_format = ROW
expire_logs_days = 10
EOF

# 3. Direktori binary log.
mkdir -p /var/log/mysql
chown mysql:mysql /var/log/mysql
chmod 750 /var/log/mysql
service mariadb restart

# 4. Database, tabel, akun replikasi, dan hak akses.
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

CREATE USER IF NOT EXISTS 'replicator'@'192.214.4.%' IDENTIFIED BY 'ReplK06_StrongPass!';
GRANT REPLICATION SLAVE ON *.* TO 'replicator'@'192.214.4.%';
FLUSH PRIVILEGES;

SHOW MASTER STATUS;
EOF
