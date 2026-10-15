### 1 - Konfigurasi Jaringan Dasar Jujutsu High

> Ketika Curtain menutup Shibuya, jalur komunikasi antar zona Jujutsu High terputus. Pulihkan konektivitas dasar dengan mengonfigurasi jichi: eth0 memperoleh WAN dari NAT, sedangkan eth1–eth4 menjadi gateway Network 1–4 sesuai tabel pemetaan. Aktifkan IPv4 forwarding dan source NAT, lalu tetapkan IP statis host infrastruktur sesuai tabel spesifikasi. Buktikan konektivitas setiap host ke gateway dan akses eksternal dari host yang relevan.

Soal 1 meminta konfigurasi fondasi jaringan Jujutsu High secara menyeluruh. `jichi` sebagai router utama harus mampu menghubungkan keempat jaringan internal sekaligus membuka akses ke internet melalui NAT. Selain itu, seluruh host infrastruktur di Network 1 dan Network 4 harus memiliki alamat IP statis yang tetap agar layanan-layanan berikutnya seperti DNS, DHCP, load balancer, dan database dapat ditemukan di alamat yang tidak berubah. Konektivitas dibuktikan melalui ping dari setiap host ke gateway masing-masing serta ke internet publik, memastikan bahwa forwarding dan NAT di `jichi` berjalan sebelum soal-soal selanjutnya dikerjakan.

Sebagai router utama yang menghubungkan seluruh zona jaringan Jujutsu High, `jichi` dikonfigurasi dengan lima antarmuka. `eth0` memperoleh alamat WAN secara dinamis dari NAT, sedangkan `eth1` hingga `eth4` masing-masing menjadi gateway untuk Network 1 hingga Network 4.

![alt text](image-100.png)

Gambar di atas merupakan gambaran topologi jaringan Jujutsu High.

Berikut adalah konfigurasi antarmuka pada `jichi` yang disimpan di `/etc/network/interfaces`:

#### jichi (Router Utama)

```
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
    post-up echo "nameserver 192.168.122.1" > /etc/resolv.conf
    post-up sysctl -w net.ipv4.ip_forward=1
    post-up iptables -t nat -C POSTROUTING -o eth0 -s 192.214.0.0/16 -j MASQUERADE || iptables -t nat -A POSTROUTING -o eth0 -s 192.214.0.0/16 -j MASQUERADE

auto eth1
iface eth1 inet static
    address 192.214.1.1
    netmask 255.255.255.0

auto eth2
iface eth2 inet static
    address 192.214.2.1
    netmask 255.255.255.0

auto eth3
iface eth3 inet static
    address 192.214.3.1
    netmask 255.255.255.0

auto eth4
iface eth4 inet static
    address 192.214.4.1
    netmask 255.255.255.0
```

IPv4 forwarding diaktifkan agar `jichi` bersedia meneruskan paket antar jaringan. Aturan Source NAT (MASQUERADE) ditambahkan pada `eth0` sehingga seluruh alamat internal `192.214.0.0/16` dapat menjangkau internet publik menggunakan IP WAN `jichi`. Kedua konfigurasi ini ditulis sebagai `post-up` pada blok `eth0` agar otomatis aktif setiap kali node dinyalakan.

![alt text](image-101.png)

Selanjutnya, seluruh host infrastruktur di Network 1 (DMZ) dan Network 4 (Data Center) dikonfigurasi dengan alamat IP statis. Berikut konfigurasi masing-masing node:

#### Utahime

```
auto eth0
iface eth0 inet static
    address 192.214.1.2
    netmask 255.255.255.0
    gateway 192.214.1.1
    post-up echo "nameserver 192.168.122.1" > /etc/resolv.conf
```

#### Shoko

```
auto eth0
iface eth0 inet static
    address 192.214.1.3
    netmask 255.255.255.0
    gateway 192.214.1.1
    post-up echo "nameserver 192.168.122.1" > /etc/resolv.conf
```

#### Gojo

```
auto eth0
iface eth0 inet static
    address 192.214.1.4
    netmask 255.255.255.0
    gateway 192.214.1.1
    post-up echo "nameserver 192.168.122.1" > /etc/resolv.conf
```

#### Tengen

```
auto eth0
iface eth0 inet static
    address 192.214.4.10
    netmask 255.255.255.0
    gateway 192.214.4.1
    post-up echo "nameserver 192.168.122.1" > /etc/resolv.conf
```

#### Geto

```
auto eth0
iface eth0 inet static
    address 192.214.4.11
    netmask 255.255.255.0
    gateway 192.214.4.1
    post-up echo "nameserver 192.168.122.1" > /etc/resolv.conf
```

#### Maki

```
auto eth0
iface eth0 inet static
    address 192.214.4.21
    netmask 255.255.255.0
    gateway 192.214.4.1
    post-up echo "nameserver 192.168.122.1" > /etc/resolv.conf
```

#### Panda

```
auto eth0
iface eth0 inet static
    address 192.214.4.22
    netmask 255.255.255.0
    gateway 192.214.4.1
    post-up echo "nameserver 192.168.122.1" > /etc/resolv.conf
```

#### Nanami

```
auto eth0
iface eth0 inet static
    address 192.214.4.31
    netmask 255.255.255.0
    gateway 192.214.4.1
    post-up echo "nameserver 192.168.122.1" > /etc/resolv.conf
```

#### Todo

```
auto eth0
iface eth0 inet static
    address 192.214.4.32
    netmask 255.255.255.0
    gateway 192.214.4.1
    post-up echo "nameserver 192.168.122.1" > /etc/resolv.conf
```

#### Kirara

```
auto eth0
iface eth0 inet static
    address 192.214.4.33
    netmask 255.255.255.0
    gateway 192.214.4.1
    post-up echo "nameserver 192.168.122.1" > /etc/resolv.conf
```

#### Yaga

```
auto eth0
iface eth0 inet static
    address 192.214.4.41
    netmask 255.255.255.0
    gateway 192.214.4.1
    post-up echo "nameserver 192.168.122.1" > /etc/resolv.conf
```

#### Inumaki

```
auto eth0
iface eth0 inet static
    address 192.214.4.42
    netmask 255.255.255.0
    gateway 192.214.4.1
    post-up echo "nameserver 192.168.122.1" > /etc/resolv.conf
```

Konfigurasi di atas ditulis langsung melalui fitur **Edit config** di GNS3 sehingga persisten dan diterapkan otomatis setiap kali node dinyalakan tanpa perlu menjalankan script secara manual.

Selanjutnya dilakukan pengujian konektivitas dari beberapa host ke gateway masing-masing serta ke internet publik.

![alt text](image-102.png)

![alt text](image-103.png)


Dari hasil pengujian di atas, seluruh host infrastruktur berhasil menjangkau gateway dan internet publik, membuktikan bahwa konfigurasi IP statis, IPv4 forwarding, serta Source NAT pada `jichi` telah berjalan sesuai rancangan.


### 2 - Konfigurasi DHCP Server pada Tengen

Soal 2 meminta `tengen` difungsikan sebagai DHCP Server terpusat bagi seluruh jaringan yang membutuhkan alokasi alamat dinamis. Karena `tengen` berada di Network 4, subnet tersebut harus dideklarasikan di konfigurasi tanpa pool dinamis agar service tidak mengeluarkan error `No subnet declaration` saat pertama kali dijalankan. Selain itu, dua scope DHCP disiapkan untuk Network 2 dan Network 3 sebagai fondasi yang akan dilengkapi dengan pool, lease time, dan aturan alokasi pada soal-soal berikutnya.

#### Instalasi isc-dhcp-server

Paket `isc-dhcp-server` diinstal terlebih dahulu pada `tengen`:

```bash
apt-get update
apt-get install -y isc-dhcp-server
```

#### Konfigurasi Interface Listener

`isc-dhcp-server` perlu diarahkan untuk mendengarkan pada `eth0`, yaitu antarmuka `tengen` yang terhubung ke Network 4:

```bash
cat > /etc/default/isc-dhcp-server << EOF
INTERFACESv4="eth0"
INTERFACESv6=""
EOF
```

#### Konfigurasi dhcpd.conf

File `/etc/dhcp/dhcpd.conf` dikonfigurasi dengan tiga deklarasi subnet. Network 4 dideklarasikan tanpa pool agar service aktif. Network 2 dan Network 3 disiapkan dengan opsi dasar sebagai fondasi konfigurasi pool di soal berikutnya:

```bash
cat > /etc/dhcp/dhcpd.conf << EOF
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
```

#### Validasi dan Start Service

Konfigurasi divalidasi lalu service dijalankan:

```bash
dhcpd -t -cf /etc/dhcp/dhcpd.conf
service isc-dhcp-server restart
service isc-dhcp-server status
```

![alt text](image-104.png)

Dari hasil di atas, service `isc-dhcp-server` berjalan tanpa error `No subnet declaration` karena Network 4 sudah dideklarasikan sebagai subnet lokal meskipun tanpa pool dinamis.

#### Script Lengkap (tengen.sh)

Berikut script lengkap yang dapat dijalankan langsung di `tengen`:

```bash
#!/bin/bash
# Soal 2 - DHCP Server. 

apt-get update
apt-get install -y isc-dhcp-server

cat > /etc/default/isc-dhcp-server << EOF
INTERFACESv4="eth0"
INTERFACESv6=""
EOF

cat > /etc/dhcp/dhcpd.conf << EOF
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

dhcpd -t -cf /etc/dhcp/dhcpd.conf
service isc-dhcp-server restart
service isc-dhcp-server status
```

### 3 - Konfigurasi DHCP Relay pada Jichi

Karena `tengen` berada di Network 4 sementara klien berada di Network 2 dan Network 3, paket DHCP Discover dari klien tidak dapat mencapai `tengen` secara langsung karena router tidak meneruskan broadcast antar subnet. Soal 3 meminta `jichi` difungsikan sebagai DHCP Relay yang bertugas menangkap broadcast DHCP dari kedua subnet klien dan meneruskannya sebagai unicast ke `tengen` di `192.214.4.10`. `jichi` mendengarkan pada `eth2` untuk Network 2 dan `eth3` untuk Network 3, sehingga proses DORA dapat terjadi melewati batas subnet.

#### Instalasi isc-dhcp-relay

Paket `isc-dhcp-relay` diinstal pada `jichi`:

```bash
apt-get update
apt-get install -y isc-dhcp-relay
```

Saat instalasi, wizard interaktif akan muncul. Tekan Enter saja untuk melewatinya karena konfigurasi akan ditulis manual.

#### Konfigurasi DHCP Relay

File `/etc/default/isc-dhcp-relay` dikonfigurasi agar relay meneruskan ke `tengen` dan mendengarkan pada `eth2` serta `eth3`:

```bash
cat > /etc/default/isc-dhcp-relay << EOF
SERVERS="192.214.4.10"
INTERFACES="eth2 eth3"
OPTIONS=""
EOF
```

#### Start Service

```bash
dhcrelay -d -iu eth4 -id eth2 -id eth3 192.214.4.10
```

![alt text](image-105.png)

#### Bukti Lease pada Klien

Pengujian dilakukan dari klien di kedua subnet dengan meminta IP melalui DHCP:

```bash
ip addr flush dev eth0
udhcpc -i eth0
ip -4 -br addr
```

![alt text](image-106.png)

![alt text](image-111.png)

Klien dari Network 2 dan Network 3 berhasil memperoleh lease dari `tengen` melalui relay di `jichi`, dibuktikan dengan alamat IP yang terdapat pada rentang subnet masing-masing.

#### Script Lengkap (relay.sh)

Berikut script lengkap yang dapat dijalankan langsung di `jichi`:

```bash
#!/bin/bash
# Soal 3 - DHCP Relay. Simpan di /root/relay.sh

apt-get update
apt-get install -y isc-dhcp-relay

cat > /etc/default/isc-dhcp-relay << EOF
SERVERS="192.214.4.10"
INTERFACES="eth2 eth3"
OPTIONS=""
EOF

dhcrelay -d -iu eth4 -id eth2 -id eth3 192.214.4.10
```

### 4 - DHCP Pool Berbasis MAC untuk Network 2

Soal 4 meminta alokasi alamat di Network 2 dikendalikan berdasarkan identitas hardware klien. Itadori dan Fushiguro harus selalu memperoleh alamat dari Pool 1 (`192.214.2.10–192.214.2.35`), sedangkan Zenin dan Okkotsu dari Pool 2 (`192.214.2.70–192.214.2.95`). Rentang 192.214.2.36–192.214.2.69 tidak termasuk dalam pool DHCP yang dikonfigurasi pada Soal 4, sehingga server tidak mengalokasikan alamat dari rentang tersebut melalui kedua pool ini. Mekanisme ini diimplementasikan menggunakan `class` dan `subclass` pada `isc-dhcp-server` yang mencocokkan paket DHCP berdasarkan MAC address hardware klien, sehingga meskipun relay meneruskan request dari subnet yang sama, server tetap dapat membedakan klien dan memberikan pool yang tepat.

#### Deklarasi Class Berdasarkan MAC

> **Node: `tengen` (`192.214.4.10`)**
> File: `/etc/dhcp/dhcpd.conf`

Dua class dibuat: `pool1` untuk itadori dan fushiguro, serta `pool2` untuk zenin dan okkotsu. Prefix `1:` pada subclass menandakan hardware type Ethernet:

```
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
```

#### Konfigurasi Pool pada Subnet Network 2

> **Node: `tengen` (`192.214.4.10`)**
> File: `/etc/dhcp/dhcpd.conf`

Subnet Network 2 diperbarui dengan dua pool yang masing-masing hanya mengizinkan member dari class yang sesuai. Rentang `.36–.69` tidak dimasukkan ke pool manapun sehingga tidak pernah dialokasikan:

```
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
```

#### Validasi dan Restart Service

> **Node: `tengen` (`192.214.4.10`)**

```bash
dhcpd -t -cf /etc/dhcp/dhcpd.conf
service isc-dhcp-server restart
service isc-dhcp-server status
```

#### Bukti Lease pada Klien

> **Node: `itadori`, `fushiguro`, `zenin`, `okkotsu`** (masing-masing dijalankan di terminalnya sendiri)

```bash
ip addr flush dev eth0
udhcpc -i eth0
ip -4 -br addr
```

![alt text](image-112.png)

![alt text](image-115.png)

![alt text](image-113.png)

![alt text](image-114.png)

Itadori dan Fushiguro memperoleh alamat dari Pool 1, sedangkan Zenin dan Okkotsu dari Pool 2, membuktikan bahwa seleksi pool berbasis MAC berjalan sesuai rancangan.

#### Script Lengkap (dhcp-pool.sh)

> **Node: `tengen` (`192.214.4.10`)**
> Simpan di `/root/dhcp-pool.sh`, jalankan dengan `bash /root/dhcp-pool.sh`
> Script ini menimpa `/etc/dhcp/dhcpd.conf` dengan konfigurasi lengkap soal 2 dan 4 sekaligus.

```bash
#!/bin/bash
# Soal 4 

cat > /etc/dhcp/dhcpd.conf << EOF
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
```
### 5 - DHCP Pool dengan Lease Time Berbeda untuk Network 3

Soal 5 meminta Network 3 memiliki dua pool dengan lease time yang berbeda sesuai kebutuhan tiap klien. Ino dan Kusakabe masuk ke pool short lease (`192.214.3.10–192.214.3.89`) dengan waktu sewa 1800 detik, sedangkan Miwa masuk ke pool long lease (`192.214.3.100–192.214.3.199`) dengan waktu sewa 43200 detik. Pemisahan ini dilakukan menggunakan class berbasis MAC seperti soal 4, sehingga tiap klien selalu diarahkan ke pool yang sesuai. Kugisaki tidak dimasukkan ke class manapun karena akan mendapat fixed address di soal 6. Selain itu, seluruh klien Network 3 menerima opsi `domain-search` menuju `<K-06>.com`.

#### Deklarasi Class Berdasarkan MAC

> **Node: `tengen` (`192.214.4.10`)**
> File: `/etc/dhcp/dhcpd.conf`

```
class "short-lease" {
    match hardware;
}
subclass "short-lease" 1:02:42:2c:e9:ee:00;  # ino
subclass "short-lease" 1:02:42:f5:9c:59:00;  # kusakabe

class "long-lease" {
    match hardware;
}
subclass "long-lease" 1:02:42:0b:75:87:00;   # miwa
```

#### Konfigurasi Pool pada Subnet Network 3

> **Node: `tengen` (`192.214.4.10`)**
> File: `/etc/dhcp/dhcpd.conf`

Dua pool dikonfigurasi di dalam subnet Network 3. Lease time ditulis per pool agar tidak saling menimpa nilai global:

```
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
}
```

#### Validasi dan Restart Service

> **Node: `tengen` (`192.214.4.10`)**

```bash
dhcpd -t -cf /etc/dhcp/dhcpd.conf
service isc-dhcp-server restart
service isc-dhcp-server status
```


#### Bukti Lease pada Klien

> **Node: `ino`, `kusakabe`, `miwa`** (masing-masing dijalankan di terminalnya sendiri)

```bash
ip addr flush dev eth0
udhcpc -i eth0
ip -4 -br addr
```

![alt text](image-107.png)

![alt text](image-108.png)

Ino alamat dari pool short lease, sedangkan Miwa dari pool long lease. Lease time dapat diverifikasi dengan melihat isi `/var/lib/dhcp/dhcpd.leases` di `tengen`.

![alt text](image-109.png)

#### Script Lengkap (dhcp-net3.sh)

> **Node: `tengen` (`192.214.4.10`)**
> Simpan di `/root/dhcp-net3.sh`, jalankan dengan `bash /root/dhcp-net3.sh`


```bash
#!/bin/bash
# Soal 5 - DHCP Pool lease time berbeda.

cat > /etc/dhcp/dhcpd.conf << EOF
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
    option domain-search "<K-06>.com";

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
}
EOF

dhcpd -t -cf /etc/dhcp/dhcpd.conf
service isc-dhcp-server restart
service isc-dhcp-server status
```

### 6 - DHCP Fixed Address untuk Kugisaki

Soal 6 meminta Kugisaki selalu mendapatkan alamat yang sama setiap kali terhubung ke jaringan, yaitu `192.214.3.99`. Mekanisme ini diimplementasikan menggunakan deklarasi `host` pada `isc-dhcp-server` yang mengikat MAC address Kugisaki ke satu alamat tetap. Alamat `192.214.3.99` dipilih karena berada di luar seluruh pool dinamis Network 3, yaitu di antara rentang short lease (`.3.10–.3.89`) dan long lease (`.3.100–.3.199`), sehingga tidak pernah dialokasikan secara dinamis ke klien lain.

#### Deklarasi Host Fixed Address

> **Node: `tengen` (`192.214.4.10`)**
> File: `/etc/dhcp/dhcpd.conf`

Deklarasi `host` ditambahkan di dalam blok subnet Network 3, mengikat MAC Kugisaki ke alamat `192.214.3.99`:

```
host kugisaki {
    hardware ethernet 02:42:df:72:fc:00;
    fixed-address 192.214.3.99;
}
```

#### Validasi dan Restart Service

> **Node: `tengen` (`192.214.4.10`)**

```bash
dhcpd -t -cf /etc/dhcp/dhcpd.conf
service isc-dhcp-server restart
service isc-dhcp-server status
```


#### Bukti Lease pada Kugisaki

> **Node: `kugisaki`**

Lease diperbarui dengan melepas alamat lama lalu meminta ulang:

```bash
ip addr flush dev eth0
udhcpc -i eth0
ip -4 -br addr
```

![alt text](image-110.png)

Alamat yang diterima Kugisaki adalah `192.214.3.99` sesuai reservasi, membuktikan bahwa fixed address berhasil diikat berdasarkan MAC address.

#### Script Lengkap (dhcp-fixed.sh)

> **Node: `tengen` (`192.214.4.10`)**

```bash
#!/bin/bash
# Soal 6 - DHCP Fixed Address. Simpan di /root/dhcp-fixed.sh

cat > /etc/dhcp/dhcpd.conf << EOF
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
    option domain-search "<K-06>.com";

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
```

### 7 - Verifikasi Konfigurasi Klien dan dhcpd.leases

Soal 7 meminta pembuktian bahwa seluruh klien telah memperoleh alamat sesuai konfigurasi DHCP yang dirancang, dengan cara mencocokkan IP yang diterima klien terhadap entri di file `dhcpd.leases` pada `tengen`. File tersebut mencatat setiap lease yang diberikan server beserta MAC address, waktu mulai, dan waktu berakhirnya, sehingga dapat dijadikan referensi otoritatif untuk memvalidasi bahwa pool, lease time, dan fixed address bekerja sesuai rancangan.

#### Verifikasi IP pada Klien

> **Node: seluruh klien** (masing-masing di terminalnya sendiri)

```bash
ip -4 -br addr
```

**Network 2: Divisi A**

![alt text](image-116.png)

![alt text](image-123.png)

![alt text](image-117.png)

![alt text](image-118.png)

**Network 3: Divisi B**

![alt text](image-119.png)

![alt text](image-120.png)

![alt text](image-121.png)

![alt text](image-122.png)

#### Verifikasi dhcpd.leases pada Tengen

> **Node: `tengen` (`192.214.4.10`)**

```bash
cat /var/lib/dhcp/dhcpd.leases
```

![alt text](image-124.png)

Setiap entri lease di file tersebut memuat informasi berikut yang dicocokkan dengan data klien:

| Field | Keterangan |
|---|---|
| `lease <IP>` | Alamat yang diberikan ke klien |
| `hardware ethernet` | MAC address klien penerima lease |
| `starts` / `ends` | Waktu mulai dan berakhirnya lease |
| `binding state active` | Lease sedang aktif digunakan |

Tabel berikut merangkum kesesuaian antara konfigurasi yang dirancang dengan hasil aktual:

| Klien | MAC Address | IP yang Diharapkan | Pool / Keterangan |
|---|---|---|---|
| itadori | `02:42:5f:04:2c:00` | `192.214.2.10–.35` | Pool 1 |
| fushiguro | `02:42:9a:a3:61:00` | `192.214.2.10–.35` | Pool 1 |
| zenin | `02:42:e3:66:69:00` | `192.214.2.70–.95` | Pool 2 |
| okkotsu | `02:42:00:59:dd:00` | `192.214.2.70–.95` | Pool 2 |
| ino | `02:42:2c:e9:ee:00` | `192.214.3.10–.89` | Short lease (1800s) |
| kusakabe | `02:42:f5:9c:59:00` | `192.214.3.10–.89` | Short lease (1800s) |
| miwa | `02:42:0b:75:87:00` | `192.214.3.100–.199` | Long lease (43200s) |
| kugisaki | `02:42:df:72:fc:00` | `192.214.3.99` | Fixed address |

Seluruh entri di `dhcpd.leases` menunjukkan MAC address yang sesuai dengan klien yang bersangkutan dan alamat IP yang berada di rentang pool yang benar, membuktikan bahwa konfigurasi DHCP berjalan sesuai rancangan.

### 8 - Packet Capture DORA dan Field giaddr

Soal 8 meminta pembuktian alur DORA (Discover, Offer, Request, Acknowledge) melalui packet capture, sekaligus memverifikasi bahwa field `giaddr` pada paket DHCP terisi dengan benar. Field `giaddr` (Gateway IP Address) diisi oleh relay agent (`jichi`) saat meneruskan paket dari klien ke `tengen`, berisi IP interface `jichi` di sisi subnet klien. Dengan adanya `giaddr`, `tengen` mengetahui dari subnet mana request berasal dan ke mana Offer harus dikembalikan. Capture dilakukan di `jichi` pada interface `eth4` (arah ke `tengen`) dengan output disimpan ke file, sehingga tcpdump dapat berjalan di background dan hasilnya dibaca setelah proses DORA selesai.

#### Langkah 1: Jalankan tcpdump di Background

> **Node: `jichi`**

Jalankan tcpdump di background. Flag `-c 8` menghentikan capture otomatis setelah 8 paket tertangkap (cukup untuk satu siklus DORA bolak-balik):

```bash
tcpdump -i eth4 -v -n -c 8 port 67 > /root/dora.txt 2>&1 &
echo "tcpdump berjalan, PID: $!"
```

#### Langkah 2: Picu DORA dari Klien

> **Node: `itadori`** (terminal klien)

Lepas IP lama lalu minta lease baru:

```bash
ip addr flush dev eth0
udhcpc -i eth0
```

#### Langkah 3: Baca Hasil Capture di Jichi

> **Node: `jichi`**

Tunggu beberapa detik hingga tcpdump selesai (berhenti otomatis setelah 8 paket), lalu baca hasilnya:

```bash
cat /root/dora.txt
```

Contoh output yang diharapkan:

```
# 1. DHCP Discover (relay -> tengen, giaddr sudah terisi)
IP 192.214.2.1.67 > 192.214.4.10.67: BOOTP/DHCP, Request from 02:42:5f:04:2c:00
  giaddr 192.214.2.1
  DHCP-Message Option 53, length 1: Discover

# 2. DHCP Offer (tengen -> relay via giaddr)
IP 192.214.4.10.67 > 192.214.2.1.67: BOOTP/DHCP, Reply
  giaddr 192.214.2.1
  DHCP-Message Option 53, length 1: Offer

# 3. DHCP Request (relay -> tengen, giaddr sudah terisi)
IP 192.214.2.1.67 > 192.214.4.10.67: BOOTP/DHCP, Request from 02:42:5f:04:2c:00
  giaddr 192.214.2.1
  DHCP-Message Option 53, length 1: Request

# 4. DHCP Ack (tengen -> relay via giaddr)
IP 192.214.4.10.67 > 192.214.2.1.67: BOOTP/DHCP, Reply
  giaddr 192.214.2.1
  DHCP-Message Option 53, length 1: ACK
```

![alt text](image-125.png)

#### Penjelasan Field giaddr

Nilai `giaddr` pada seluruh paket DORA adalah `192.214.2.1`, yaitu IP `jichi` di sisi Network 2 (`eth2`). Hal ini membuktikan bahwa relay agent mengisi `giaddr` sebelum meneruskan paket ke `tengen`, dan `tengen` menggunakan nilai tersebut untuk menentukan subnet asal request, memilih pool yang sesuai, serta mengirim balasan kembali ke relay. Untuk Network 3, nilai `giaddr` yang diharapkan adalah `192.214.3.1`. Pengujian dapat diulang dari `ino` dengan prosedur yang sama.

```bash
# Ulangi dari jichi untuk Network 3
tcpdump -i eth4 -v -n -c 8 port 67 > /root/dora_net3.txt 2>&1 &
```

```bash
# Lalu dari ino
ip addr flush dev eth0
udhcpc -i eth0
```

```bash
# Kembali ke jichi
cat /root/dora_net3.txt
```
![alt text](image-126.png)

### 9 - Simulasi Relay Mati dan Pemulihan

Soal 9 meminta pembuktian bahwa sistem DHCP bergantung penuh pada relay di `jichi`. Ketika relay dimatikan, klien di Network 2 dan Network 3 tidak dapat memperoleh lease karena paket Discover tidak pernah sampai ke `tengen`. Setelah relay dipulihkan, klien kembali dapat memperoleh alamat secara normal. Pengujian ini membuktikan peran kritis `jichi` sebagai jembatan antara subnet klien dan DHCP server.

#### Langkah 1: Catat Kondisi Awal Klien

> **Node: `itadori`**

Pastikan klien sudah memiliki lease sebelum pengujian dimulai:

```bash
ip -4 -br addr
```

![alt text](image-127.png)

#### Langkah 2: Matikan Relay di Jichi

> **Node: `jichi`**

```bash
kill $(pgrep dhcrelay)
ps aux | grep dhcrelay
```

#### Langkah 3: Coba Minta Lease dari Klien (Harus Gagal)

> **Node: `itadori`**

Lepas IP lama lalu coba minta lease baru. Karena relay mati, udhcpc akan timeout tanpa mendapat balasan:

```bash
ip addr flush dev eth0
udhcpc -i eth0
```

![alt text](image-128.png)

#### Langkah 4: Pulihkan Relay di Jichi

> **Node: `jichi`**

```bash
dhcrelay -d -iu eth4 -id eth2 -id eth3 192.214.4.10
```

![alt text](image-129.png)

#### Langkah 5: Minta Lease Ulang dari Klien (Harus Berhasil)

> **Node: `itadori`**

```bash
udhcpc -i eth0
ip -4 -br addr
```

![alt text](image-130.png)

Setelah relay dipulihkan, klien berhasil memperoleh lease dari `tengen` seperti semula, membuktikan bahwa `jichi` sebagai relay merupakan komponen kritis yang harus selalu aktif agar alokasi DHCP lintas subnet dapat berjalan.

### 10 - Autostart dan Uji Restart

Soal 10 memastikan bahwa seluruh service DHCP bangkit kembali secara otomatis ketika node di-restart tanpa intervensi manual. Karena `debinet` tidak menggunakan systemd, autostart dikonfigurasi melalui `post-up` di `/etc/network/interfaces` pada masing-masing node via GNS3 Edit config. Pada `tengen`, `post-up` menjalankan `/root/soal6.sh` agar `dhcpd.conf` selalu ditulis ulang dan service di-restart dengan konfigurasi final yang mencakup seluruh konfigurasi soal 2 hingga 6. Instalasi `isc-dhcp-server` cukup dilakukan sekali secara manual karena paket tidak hilang saat node di-restart. Pada `jichi`, `post-up` menjalankan `/root/soal3.sh` agar `isc-dhcp-relay` terinstall dan `dhcrelay` berjalan otomatis. Flag `-d` dihilangkan dari `soal3.sh` agar `dhcrelay` melakukan self-daemonize dan tidak memblokir proses boot.


#### Update soal3.sh di Jichi

> **Node: `jichi`**
> File: `/root/soal3.sh`

Hapus flag `-d` agar `dhcrelay` self-daemonize dan tidak memblokir `post-up`:

```bash
#!/bin/bash

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y isc-dhcp-relay

cat > /etc/default/isc-dhcp-relay << EOF
SERVERS="192.214.4.10"
INTERFACES="eth2 eth3"
OPTIONS=""
EOF

# Tunggu tengen siap
until ping -c 1 192.214.4.10 > /dev/null 2>&1; do
    echo "Menunggu tengen..."; sleep 3
done

dhcrelay -iu eth4 -id eth2 -id eth3 192.214.4.10
```

dhcrelay baru akan aktif setelah node Tengen sudah tersetup.

#### Konfigurasi Autostart pada Tengen

> **Node: `tengen` (`192.214.4.10`)**
> File: `/etc/network/interfaces` (Edit config di GNS3)

```
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.214.4.10
    netmask 255.255.255.0
    gateway 192.214.4.1
    post-up echo "nameserver 192.168.122.1" > /etc/resolv.conf
post-up /bin/sh -c '/bin/bash /root/soal2.sh; sleep 5; /bin/bash /root/soal6.sh'
```

Tengen akan menjalankan soal2.sh terlebih dahulu dan menunggu 5 detik sebelum menjalankan soal6.sh.

#### Konfigurasi Autostart pada Jichi

> **Node: `jichi`**
> File: `/etc/network/interfaces` (Edit config di GNS3)

```
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
    post-up echo "nameserver 192.168.122.1" > /etc/resolv.conf
    post-up sysctl -w net.ipv4.ip_forward=1
    post-up iptables -t nat -C POSTROUTING -o eth0 -s 192.214.0.0/16 -j MASQUERADE || iptables -t nat -A POSTROUTING -o eth0 -s 192.214.0.0/16 -j MASQUERADE

auto eth1
iface eth1 inet static
    address 192.214.1.1
    netmask 255.255.255.0

auto eth2
iface eth2 inet static
    address 192.214.2.1
    netmask 255.255.255.0

auto eth3
iface eth3 inet static
    address 192.214.3.1
    netmask 255.255.255.0

auto eth4
iface eth4 inet static
    address 192.214.4.1
    netmask 255.255.255.0
    post-up bash /root/soal3.sh
```

#### Urutan Start yang Benar

Karena `tengen` membutuhkan internet dari `jichi` untuk instalasi paket, urutan start node harus diperhatikan:

| Urutan | Node | Alasan |
|---|---|---|
| 1 | `jichi` | Gateway semua jaringan, NAT, dan relay harus aktif lebih dulu |
| 2 | `tengen` | Butuh `jichi` untuk internet saat `soal6.sh` berjalan |
| 3 | Server lain | Butuh `jichi` sebagai gateway |
| 4 | Klien | Butuh `tengen` untuk DHCP dan `jichi` sebagai relay |

#### Uji Restart Tengen

> **Node: `tengen`**

Stop lalu Start node `tengen` dari GNS3. Setelah node kembali aktif, verifikasi service berjalan otomatis:

```bash
service isc-dhcp-server status
```

![alt text](image-131.png)

#### Uji Restart Jichi

> **Node: `jichi`**

Stop lalu Start node `jichi` dari GNS3. Setelah node kembali aktif, verifikasi `dhcrelay` berjalan otomatis:

```bash
ps aux | grep dhcrelay
```

![alt text](image-132.png)

#### Uji Akhir: Klien Masih Bisa Mendapat Lease

> **Node: `itadori`**

Setelah kedua node di-restart, pastikan klien masih bisa memperoleh lease:

```bash
ip addr flush dev eth0
udhcpc -i eth0
ip -4 -br addr
```

![alt text](image-133.png)

Seluruh service bangkit kembali secara otomatis setelah restart tanpa intervensi manual, membuktikan konfigurasi autostart pada `tengen` dan `jichi` berjalan sesuai rancangan.



### 11 - Konfigurasi DNS Master dan Slave

Soal 11 meminta sistem penamaan domain dibangun agar node dapat berkomunikasi menggunakan nama alih-alih alamat IP mentah. `utahime` dikonfigurasi sebagai DNS Master yang memegang otoritas atas zona `jujutsu.K-06.com`, sedangkan `shoko` sebagai DNS Slave yang menerima salinan zona secara otomatis dari Master melalui mekanisme *zone transfer*. SOA record mendefinisikan metadata zona, termasuk serial number sebagai penanda versi, sementara NS record menetapkan server DNS yang berwenang atas zona. Sinkronisasi dibuktikan dengan menaikkan serial pada Utahime dan memverifikasi bahwa Shoko menerima zona terbaru tanpa konfigurasi ulang.

#### Instalasi BIND9

**Node: `utahime` dan `shoko`** (jalankan pada masing-masing node).

```bash
apt-get update
apt-get install -y bind9 bind9utils bind9-doc
```

#### Konfigurasi `named.conf.local` pada Utahime

**Node: `utahime` (`192.214.1.2`)**

File: `/etc/bind/named.conf.local`

```bash
cat > /etc/bind/named.conf.local << 'EOF'
zone "jujutsu.K-06.com" {
    type master;
    file "/etc/bind/zones/jujutsu.K-06.com";
    allow-transfer { 192.214.1.3; };
};
EOF
```

Konfigurasi tersebut menetapkan Utahime sebagai DNS Master dan mengizinkan Shoko mengambil salinan zona melalui mekanisme *zone transfer*.

#### Konfigurasi `named.conf.local` pada Shoko

**Node: `shoko` (`192.214.1.3`)**

File: `/etc/bind/named.conf.local`

```bash
cat > /etc/bind/named.conf.local << 'EOF'
zone "jujutsu.K-06.com" {
    type slave;
    file "/var/cache/bind/jujutsu.K-06.com";
    masters { 192.214.1.2; };
};
EOF
```

Konfigurasi tersebut menetapkan Shoko sebagai DNS Slave dengan Utahime sebagai sumber zona.

#### Konfigurasi `named.conf.options`

**Node: `utahime` dan `shoko`** (jalankan pada masing-masing node).

File: `/etc/bind/named.conf.options`

```bash
cat > /etc/bind/named.conf.options << 'EOF'
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
```

Konfigurasi ini mengatur direktori kerja BIND9, mengizinkan permintaan DNS, mengaktifkan pencarian rekursif, dan menetapkan DNS forwarder `192.168.122.1`.

#### Pembuatan File Zona pada Utahime

**Node: `utahime` (`192.214.1.2`)**

Buat direktori zona dan file zona DNS.

```bash
mkdir -p /etc/bind/zones
cat > /etc/bind/zones/jujutsu.K-06.com << 'EOF'
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
```

File zona tersebut mendefinisikan SOA record, NS record untuk kedua server DNS, serta A record untuk Utahime dan Shoko.

#### Menjalankan BIND9

**Node: `utahime`**. Jalankan Master terlebih dahulu.

```bash
named-checkconf
named-checkzone jujutsu.K-06.com /etc/bind/zones/jujutsu.K-06.com
service named restart
service named status
```

Pastikan validasi zona menghasilkan `OK` dan layanan DNS berjalan.

**Node: `shoko`**. Jalankan Slave setelah Master siap.

```bash
named-checkconf
service named restart
service named status
```

Pada lingkungan Debian 13 yang digunakan, nama layanan yang benar adalah `named`, sehingga perintah yang digunakan ialah `service named`, bukan `service bind9`.

![alt text](image-134.png)

![alt text](image-135.png)

#### Verifikasi Zone Transfer ke Shoko

**Node: `shoko`**

Periksa apakah file zona telah tersedia pada direktori cache.

```bash
ls -l /var/cache/bind/jujutsu.K-06.com
```

Keberadaan file zona menjadi salah satu bukti bahwa salinan zona tersimpan pada Slave. Verifikasi berikutnya dilakukan dengan memeriksa SOA record dan serial zona.

![alt text](image-136.png)

#### Verifikasi SOA pada Master dan Slave

**Node: `utahime`**

```bash
dig SOA jujutsu.K-06.com @192.214.1.2
```

**Node: `shoko`**

```bash
dig SOA jujutsu.K-06.com @192.214.1.3
```

Periksa status respons dan serial pada bagian `ANSWER SECTION`. Jika kedua server memberikan status `NOERROR` dengan serial yang sama, keduanya menyajikan versi zona yang sama.

![alt text](image-137.png)

![alt text](image-138.png)

#### Uji Sinkronisasi dengan Kenaikan Serial

**Node: `utahime`**

Ubah serial zona dari `2026101501` menjadi `2026101502`, lalu validasi dan muat ulang zona.

```bash
sed -i 's/2026101501/2026101502/' /etc/bind/zones/jujutsu.K-06.com
named-checkzone jujutsu.K-06.com /etc/bind/zones/jujutsu.K-06.com
rndc reload jujutsu.K-06.com
```

Pastikan validasi zona menghasilkan `OK` dan perintah reload berhasil diproses.

**Node: `shoko`**

Periksa serial zona setelah proses sinkronisasi.

```bash
dig SOA jujutsu.K-06.com @192.214.1.3 +short
```

Serial yang diharapkan setelah sinkronisasi adalah `2026101502`.

![alt text](image-139.png)

Jika serial pada Shoko telah berubah menjadi `2026101502`, perubahan zona pada Master telah diterapkan pada Slave.

#### Bukti Query dari Client

**Node: salah satu klien, misalnya `itadori`**

Uji resolusi nama host melalui DNS Master dan DNS Slave.

##### Query nama Utahime melalui Master

```bash
dig utahime.jujutsu.K-06.com A @192.214.1.2
```

Alamat IP yang diharapkan adalah `192.214.1.2`.

##### Query nama Utahime melalui Slave

```bash
dig utahime.jujutsu.K-06.com A @192.214.1.3
```

Alamat IP yang diharapkan adalah `192.214.1.2`.

##### Query nama Shoko melalui Master

```bash
dig shoko.jujutsu.K-06.com A @192.214.1.2
```

Alamat IP yang diharapkan adalah `192.214.1.3`.

##### Query nama Shoko melalui Slave

```bash
dig shoko.jujutsu.K-06.com A @192.214.1.3
```

Alamat IP yang diharapkan adalah `192.214.1.3`.

![alt text](image-140.png)

![alt text](image-141.png)

![alt text](image-142.png)

![alt text](image-143.png)

Keempat pengujian tersebut membuktikan bahwa DNS Master dan Slave dapat menjawab permintaan resolusi untuk nama host yang telah didefinisikan dalam zona. Query menggunakan nama host dipilih karena zona saat ini belum memiliki A record untuk nama domain `jujutsu.K-06.com` itu sendiri.

#### Script Lengkap

##### Script DNS Master pada Utahime

**Node: `utahime` (`192.214.1.2`)**

Simpan sebagai `/root/soal11-utahime.sh`.

```bash
#!/bin/bash
set -e

apt-get update
apt-get install -y bind9 bind9utils bind9-doc

cat > /etc/bind/named.conf.local << 'EOF'
zone "jujutsu.K-06.com" {
    type master;
    file "/etc/bind/zones/jujutsu.K-06.com";
    allow-transfer { 192.214.1.3; };
};
EOF

cat > /etc/bind/named.conf.options << 'EOF'
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

mkdir -p /etc/bind/zones

cat > /etc/bind/zones/jujutsu.K-06.com << 'EOF'
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

named-checkconf
named-checkzone jujutsu.K-06.com /etc/bind/zones/jujutsu.K-06.com
service named restart
service named status
```

##### Script DNS Slave pada Shoko

**Node: `shoko` (`192.214.1.3`)**

Simpan sebagai `/root/soal11-shoko.sh`.

```bash
#!/bin/bash
set -e

apt-get update
apt-get install -y bind9 bind9utils bind9-doc

cat > /etc/bind/named.conf.local << 'EOF'
zone "jujutsu.K-06.com" {
    type slave;
    file "/var/cache/bind/jujutsu.K-06.com";
    masters { 192.214.1.2; };
};
EOF

cat > /etc/bind/named.conf.options << 'EOF'
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

named-checkconf
service named restart
service named status
```


