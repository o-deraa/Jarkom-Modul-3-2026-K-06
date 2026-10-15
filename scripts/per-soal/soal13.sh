# ============================================================
# SOAL 13 - Konfigurasi MariaDB Master-Slave Replication
# Dokumentasi langkah (BUKAN untuk dieksekusi langsung).
# Tiap blok menandai node tempat perintah dijalankan.
# ============================================================

# ===== 1 - Konfigurasi DB-Master pada Yaga =====
# [KONFIGURASI] >>> dijalankan di: yaga
# File: /etc/mysql/mariadb.conf.d/50-server.cnf
[mysqld]
bind-address = 0.0.0.0
server-id = 41
log_bin = /var/log/mysql/mariadb-bin
binlog_format = ROW
expire_logs_days = 10

# [PERINTAH/TESTING] >>> dijalankan di: yaga
mkdir -p /var/log/mysql
chown mysql:mysql /var/log/mysql
chmod 750 /var/log/mysql
service mariadb restart
mariadb -e "SHOW GLOBAL VARIABLES LIKE 'server_id'; SHOW GLOBAL VARIABLES LIKE 'log_bin';"

# ===== 2 - Pembuatan Database dan Tabel request_logs =====
# [KONFIGURASI] >>> dijalankan di: yaga
# (jalankan lewat klien mariadb di atas node yaga)
CREATE DATABASE IF NOT EXISTS `db_shibuya_K-06`;
USE `db_shibuya_K-06`;
CREATE TABLE IF NOT EXISTS request_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    source_node VARCHAR(50) NOT NULL,
    action VARCHAR(100) NOT NULL,
    details TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

# [PERINTAH/TESTING] >>> dijalankan di: yaga
# SHOW MASTER STATUS; SHOW DATABASES LIKE 'db_shibuya_K-06'; SHOW TABLES FROM `db_shibuya_K-06`;

# ===== 3 - Akun Replikasi dan Hak Akses =====
# [KONFIGURASI] >>> dijalankan di: yaga
CREATE USER IF NOT EXISTS 'replicator'@'192.214.4.%' IDENTIFIED BY 'ReplK06_StrongPass!';
GRANT REPLICATION SLAVE ON *.* TO 'replicator'@'192.214.4.%';
FLUSH PRIVILEGES;

# [PERINTAH/TESTING] >>> dijalankan di: yaga
# SHOW GLOBAL VARIABLES LIKE 'bind_address'; SHOW GRANTS FOR 'replicator'@'192.214.4.%';

# ===== 4 - Konfigurasi DB-Slave pada Inumaki =====
# [KONFIGURASI] >>> dijalankan di: inumaki
# File: /etc/mysql/mariadb.conf.d/50-server.cnf
[mysqld]
bind-address = 0.0.0.0
server-id = 42
relay-log = /var/log/mysql/mariadb-relay-bin

# [PERINTAH/TESTING] >>> dijalankan di: inumaki
mkdir -p /var/log/mysql
chown mysql:mysql /var/log/mysql
chmod 750 /var/log/mysql
service mariadb restart

# ===== 5 - Pengujian Konektivitas Slave ke Master =====
# [PERINTAH/TESTING] >>> dijalankan di: inumaki
ping -c 4 192.214.4.41
nc -vz 192.214.4.41 3306

# ===== 6 - Konfigurasi Replikasi dengan CHANGE MASTER TO =====
# [KONFIGURASI] >>> dijalankan di: inumaki
# MASTER_LOG_FILE dan MASTER_LOG_POS mengikuti hasil SHOW MASTER STATUS pada yaga.
STOP SLAVE;
CHANGE MASTER TO
    MASTER_HOST = '192.214.4.41',
    MASTER_USER = 'replicator',
    MASTER_PASSWORD = 'ReplK06_StrongPass!',
    MASTER_PORT = 3306,
    MASTER_LOG_FILE = 'mariadb-bin.000001',
    MASTER_LOG_POS = 1323;
START SLAVE;

# [PERINTAH/TESTING] >>> dijalankan di: inumaki
# SHOW SLAVE STATUS\G

# ===== 7 - Pengujian Replikasi Data =====
# [PERINTAH/TESTING] >>> dijalankan di: yaga
# USE `db_shibuya_K-06`;
# INSERT INTO request_logs (source_node, action, details) VALUES ('Yaga','replication_test','Nomor 13 - realtime replication test');

# [PERINTAH/TESTING] >>> dijalankan di: inumaki
# SELECT * FROM `db_shibuya_K-06`.request_logs ORDER BY id DESC LIMIT 5;

# ===== Persistensi =====
# Script lengkap untuk node:
#   scripts/per-node/yaga/soal13.sh     (DB-Master)
#   scripts/per-node/inumaki/soal13.sh  (DB-Slave)
