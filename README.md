
# Torro Deployment

## 1. Prepare

Please download the files `deploy-torro-1207.tgz`, `torro-core-001.tar`, and `torro-web-001.tar`.
```
$ ls /mnt
deploy-torro-1207.tgz  torro-core-001.tar  torro-web-001.tar
```

Create a new user with root, please make sure you are able to access to Bank's Virtual Machine and able to get the root access. Then follow below instruction to create local user torro to run the apps.

Execute it as root

```
useradd -m torro
chmod +w /etc/sudoers
echo 'torro ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
chmod -w /etc/sudoers
```

### Extract the `.tgz` file

```
sudo tar -xvf /mnt/deploy-torro-1207.tgz
sudo mv torro/ /opt/torro
```

### Copy the image

```
sudo chmod +r torro-core-001.tar torro-web-001.tar
sudo cp /mnt/torro-core-001.tar /opt/torro/images/
sudo cp /mnt/torro-web-001.tar /opt/torro/images/
```

### Modify the owner

```
sudo chown torro:torro -R /opt/torro
```

### Directory structure

this is just the structure, no action for this one

```
/opt/torro
├── core
│   ├── config.ini
│   └── log.conf
├── images
│   ├── torro-core-001.tar
│   └── torro-web-001.tar
├── mysql
│   ├── el8
│   │   ├── mysql-community-client-8.0.43-1.el8.x86_64.rpm
│   │   ├── mysql-community-client-plugins-8.0.43-1.el8.x86_64.rpm
│   │   ├── mysql-community-common-8.0.43-1.el8.x86_64.rpm
│   │   └── mysql-community-libs-8.0.43-1.el8.x86_64.rpm
│   └── sql
│       ├── authview.sql
│       ├── data_api.sql
│       ├── form_api.sql
│       ├── org_api.sql
│       ├── terraform.sql
│       ├── user_api.sql
│       └── workflow_api.sql
├── redis
│   ├── redis-cli
│   └── redis-server
├── setup.sh
├── torro.sh
└── web
    ├── certs
    │   ├── server.crt
    │   └── server.key
    ├── logs
    │   ├── access.log
    │   └── error.log
    └── nginx.conf
```

## 2. Setup

### 2.1 Initialization
Initialize the system environment with required configurations:

```
[root@torro-demo torro]# su - torro
[torro@torro-demo ~]$ cd /opt/torro/
[torro@dev-server01 torro]$ ./setup.sh init
[INFO] Current user: torro, group: torro
[INFO] Starting initialization...
[INFO] Configuring Redis...
[SUCCESS] Redis configuration completed
[INFO] Checking and installing MySQL Client...
[SUCCESS] MySQL Client is already installed
[SUCCESS] Initialization completed
```

### 2.2 System Check

Verify that all system dependencies and services are properly configured:

```
[root@torro-demo docker-rpms]# su - torro
Last login: Sun Dec  7 08:15:03 UTC 2025 on pts/0
[torro@torro-demo ~]$ cd /opt/torro
[torro@dev-server01 torro]$ ./setup.sh check
[INFO] Current user: torro, group: torro
[INFO] Starting system environment check...
[SUCCESS] Docker check passed
[SUCCESS] MySQL Client check passed
[SUCCESS] Redis service check passed
[SUCCESS] All checks passed
```

### 2.3 Load Docker Images
Load Docker images from tar files located in the images directory:

```
[torro@torro-demo torro]$ ./setup.sh load
[INFO] Loading Docker image from tar file...
Please enter the path to the tar file: torro-core-001.tar        
[INFO] Loading image from images/torro-core-001.tar...
Loaded image: torro.ai/torro/core:0.0.1
[SUCCESS] Docker image loaded successfully from images/torro-core-001.tar

[torro@torro-demo torro]$ ./setup.sh load
[INFO] Loading Docker image from tar file...
Please enter the path to the tar file: torro-web-001.tar        
[INFO] Loading image from images/torro-web-001.tar...
Loaded image: torro.ai/torro/web:0.0.1
[SUCCESS] Docker image loaded successfully from images/torro-web-001.tar
```

### 2.4 Database initialization

If it's the first time, you need to create an account and a database.
```
[torro@dev-server01 torro]$ mysql -h <HOST> -P 3306 -u mysql -p

mysql> CREATE USER 'torro-app'@'%' IDENTIFIED BY '<YOUR_PASSWORD>';
mysql> create database torro_api;
mysql> GRANT ALL PRIVILEGES ON torro_api.* TO 'torro-app'@'%' WITH GRANT OPTION; 
mysql> flush privileges;

mysql> show databases;
mysql> exit;
```

Executing init sql file

```
[torro@dev-server01 torro]$ cd /opt/torro
[torro@dev-server01 torro]$ mysql -h <HOST> -P 3306 -u torro-app -p torro_api < mysql/sql/authview.sql
[torro@dev-server01 torro]$ mysql -h <HOST> -P 3306 -u torro-app -p torro_api < mysql/sql/data_api.sql
[torro@dev-server01 torro]$ mysql -h <HOST> -P 3306 -u torro-app -p torro_api < mysql/sql/form_api.sql
[torro@dev-server01 torro]$ mysql -h <HOST> -P 3306 -u torro-app -p torro_api < mysql/sql/org_api.sql
[torro@dev-server01 torro]$ mysql -h <HOST> -P 3306 -u torro-app -p torro_api < mysql/sql/terraform.sql
[torro@dev-server01 torro]$ mysql -h <HOST> -P 3306 -u torro-app -p torro_api < mysql/sql/user_api.sql
[torro@dev-server01 torro]$ mysql -h <HOST> -P 3306 -u torro-app -p torro_api < mysql/sql/workflow_api.sql
```

Check the data table
```
[torro@dev-server01 torro]$ mysql -h <HOST> -P 3306 -u mysql -p
mysql> use torro_api;
mysql> show tables;
mysql> exit;
```

## 3. Service Management (torro-web and torro-core)

Modify the `config.ini` file
```
$ ls /opt/torro/core
config.ini  log.conf

$ cat /opt/torro/core/config.ini
......
[DB]
type = mysql
user = <DB_USERNAME>
pwd = <DB_PASSWORD>
host = <DB_HOST>
port = <DB_PORT>
name = <DB_NAME>
......
```

### 3.1 Manage Torro services

```
[torro@dev-server01 torro]$ ./torro.sh restart
Select service to restart:
1) torro-web
2) torro-core
Enter choice (1 or 2): 1
[INFO] Restarting torro-web...
WARNING: Published ports are discarded when using host network mode
2fd5e7deb60e775db4f4a30d2d3a5f8d698fef770869cf9697713554d059ad9d
[SUCCESS] torro-web restarted successfully

[torro@dev-server01 torro]$ ./torro.sh restart
Select service to restart:
1) torro-web
2) torro-core
Enter choice (1 or 2): 2
[INFO] Restarting torro-core...
WARNING: Published ports are discarded when using host network mode
e291d763e69a534cb89ad537be507f28868abd022803c4585186dbc39ebea102
[SUCCESS] torro-core restarted successfully
```

### 3.2 Stop Services
```
[torro@dev-server01 torro]$ ./torro.sh stop
Select service to stop:
1) torro-web
2) torro-core
Enter choice (1 or 2): 1
[INFO] Stopping torro-web...
[SUCCESS] torro-web stopped successfully
```

### 3.3 Check Service Status
```
[torro@dev-server01 torro]$ ./torro.sh status
[INFO] Docker containers status:
CONTAINER ID   IMAGE                                         COMMAND                  CREATED          STATUS          PORTS     NAMES
e291d763e69a   torro-core:0.0.3   "/app/torro"             7 seconds ago    Up 6 seconds              torro-core
2fd5e7deb60e   torro-web:0.0.1   "/docker-entrypoint.…"   14 seconds ago   Up 13 seconds             torro-web
```
### 3.4 Check the Firewall

Check the status of the firewall

```
[torro@dev-server01 torro]$ sudo systemctl status firewalld
[torro@dev-server01 torro]$ sudo firewall-cmd --state
```

**If the firewall is enabled, We need to open firewall port 80 and 443 for 0.0.0.0/0 (Internal network)**

```
# Check the open ports(80 and 443)
[torro@dev-server01 torro]$ sudo firewall-cmd --list-all

# open the ports
[torro@dev-server01 torro]$ sudo firewall-cmd --zone=public --add-port=80/tcp --permanent
[torro@dev-server01 torro]$ sudo firewall-cmd --zone=public --add-port=443/tcp --permanent
[torro@dev-server01 torro]$ sudo firewall-cmd --add-service=ssh --permanent

# reload
[torro@dev-server01 torro]$ sudo firewall-cmd --reload

# recheck
[torro@dev-server01 torro]$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: eth0
  sources:
  services: cockpit dhcpv6-client ssh # check ssh
  ports: 80/tcp 443/tcp               # check 80 and 443
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

### 4.5 Update the image

Download the new image file: `torro-core-002.tar`, `torro-web-002.tar`

```
ls /mnt
torro-core-002.tar torro-web-002.tar
```

Move the file to the `/opt/torro/images` directory
```
sudo mv /mnt/torro-core-002.tar /opt/torro/images
sudo mv /mnt/torro-web-002.tar /opt/torro/images
sudo chmod +r /opt/torro/images/*.tar
```

Load the new image
```
[torro@Torro-VM2 torro]$ ./setup.sh load
[INFO] Loading Docker image from tar file...
Please enter the path to the tar file: torro-web-002.tar

[torro@Torro-VM2 torro]$ ./setup.sh load
[INFO] Loading Docker image from tar file...
Please enter the path to the tar file: torro-core-002.tar
```

Modify the startup script

```
[root@Torro-VM2 ~]$ sudo su - torro
[torro@Torro-VM2 torro]$ cd /opt/torro
[torro@Torro-VM2 torro]$ vi torro.sh
#/bin/sh
set -e
MYUSER='torro'
TORRO_WEB_NAME='torro-web'
TORRO_CORE_NAME='torro-core'
TORRO_WEB_IMAGE='torro.ai/torro/web:0.0.2'      # change this
TORRO_CORE_IMAGE='torro.ai/torro/core:0.0.2'    # change this
TORRO_WEB_PATH='/opt/torro/web'
TORRO_CORE_PATH='/opt/torro/core'
......
```

Run a new image
```
[torro@Torro-VM2 torro]$ cd /opt/torro
[torro@Torro-VM2 torro]$ ./torro.sh restart
```

### 4.6 Nginx configuration

Enter the directory
```
[root@Torro-VM2 ~]$ sudo su - torro
[torro@Torro-VM2 ~]$ cd /opt/torro/web/
```

It is recommended to back up the `nginx.conf` before modifying it.

```
[torro@Torro-VM2 web]$ sudo cp -a nginx.conf nginx.conf-$(date +%m%d%H%M)
```

#### Configure the certificate

Copy the certificate file
```
$ ls /mnt
server.crt  server.key
$ sudo cp server.crt server.key /opt/torro/web/certs
```

Replace the `server.key` and `server.crt` files in the `/opt/torro/web/certs/` directory
```
$ ls /opt/torro/web
certs  logs  nginx.conf
```

Modify the `nginx.conf` to set `server_name`

```
[torro@Torro-VM2 web]$ sudo vi nginx.conf
......

    server {
        listen       443 ssl;
        server_name  localhost;         # Change to a domain name or IP address
        ssl_certificate      ssl/server.crt;
        ssl_certificate_key  ssl/server.key;

.....

    server {
        listen 80;
        server_name localhost;          # Change to a domain name or IP address

        # HTTP redirect to HTTPS
        location / {
            return 301 https://$server_name$request_uri;
        }
    }        

......
```

#### Configure reverse proxy

```
[torro@Torro-VM2 web]$ sudo vi nginx.conf

......
        # ============== sampledata frontend/backend configuration ==============
        location /sampledata/ {
            proxy_pass http://127.0.0.1:5162/sampledata/;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            proxy_redirect http://127.0.0.1:5162/ /sampledata/;

            proxy_set_header Origin "";

            proxy_read_timeout 3600s;
            proxy_connect_timeout 3600s;

            proxy_cache off;
            proxy_buffering off;
            chunked_transfer_encoding off;
        }

        location /sampledata-api/ {
            proxy_pass http://127.0.0.1:8099/;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            proxy_redirect http://127.0.0.1:8099/ /sampledata-api/;

            add_header 'Access-Control-Allow-Origin' '*' always;
            add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
            add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range' always;

            # Handle preflight requests
            if ($request_method = 'OPTIONS') {
                add_header 'Access-Control-Allow-Origin' '*';
                add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS';
                add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range';
                add_header 'Access-Control-Max-Age' 1728000;
                add_header 'Content-Type' 'text/plain; charset=utf-8';
                add_header 'Content-Length' 0;
                return 204;
            }
        }
        # ============== sampledata frontend/backend configuration ==============
        
        # error page
        error_page 404 /404.html;
        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
            root   html;
        }

.....

```

Restart
```
[torro@Torro-VM2 torro]$ cd /opt/torro

[torro@Torro-VM2 torro]$ ./torro.sh restart
[INFO] All required variables are set and paths exist
Select service to restart:
1) torro-web
2) torro-core
Enter choice (1 or 2): 1
[INFO] Restarting torro-web...
Port mappings have been discarded as one of the Host, Container, Pod, and None network modes are in use
f471f18ac9361b4a186c592511976111ff61ed7d40673aa677f72ab2d9f77d6b
[SUCCESS] torro-web restarted successfully
```


### 4.7 Check the logs

```
# torro-web
[torro@dev-server01 opt]$ sudo podman logs -f torro-web
# or
[torro@dev-server01 opt]$ sudo podman logs torro-web

# torro-core
[torro@dev-server01 opt]$ sudo podman logs -f torro-core
# or
[torro@dev-server01 opt]$ sudo podman logs torro-core
```

## 5. Deploy-1220

### 5.1 Copy the new script `torro2.sh`

```
ls /data/deploy-torro-1218/torro2.sh
sudo cp /data/deploy-torro-1218/torro2.sh /opt/torro/torro2.sh
sudo chown torro:torro /opt/torro/torro2.sh
sudo chmod +x /opt/torro/torro2.sh
```
### 5.2 Modify the configuration file `config.ini`

Add 3 lines of LDAP configuration
```
sudo su - torro
[torro@Torro-VM2 ~]$ cd /opt/torro/core
[torro@Torro-VM2 core]$ vi config.ini
[IPCONFIG]
....

[LDAP]
caCertFile = ca_cert.pem
validNames = ["openldap","ldap.torro.com","AZLDAPS.hbctxdom.com"]

[DB]
......
```

### 5.3 CA certificate file `ca_cert.pem` must exist.

```
[torro@Torro-VM2 core]$ ls /opt/torro/core/
ca_cert.pem  config.ini  log.conf
```

### 5.4 Load the image

```
[torro@Torro-VM2 core]$ sudo cp /data/torro-core-002.tar /opt/torro/images/torro-core-002.tar
[torro@Torro-VM2 core]$ sudo chmod +r /opt/torro/images/torro-core-002.tar
[torro@Torro-VM2 core]$ cd /opt/torro

[torro@Torro-VM2 torro]$ ./torro2.sh load
[INFO] Loading Docker image from tar file...
Please enter the path to the tar file: torro-core-002.tar
[INFO] Loading image from images/torro-core-002.tar...
Getting image source signatures
Copying blob 7e49dc6156b0 skipped: already exists
Copying blob 4e63d33112bb skipped: already exists
Copying blob 85e965f6d976 skipped: already exists
Copying blob 22bf750afc0e skipped: already exists
Copying blob 4f4fb700ef54 skipped: already exists
Copying blob 35d3e3bba172 skipped: already exists
Copying config 698e66e24d done   |
Writing manifest to image destination
Loaded image: torro.ai/torro/core:0.0.2
[SUCCESS] Docker image loaded successfully from images/torro-core-002.tar
```

### 5.5 Restart the service `torro-core`

```
[torro@Torro-VM2 core]$ cd /opt/torro
[torro@Torro-VM2 torro]$ ./torro2.sh restart
[INFO] All required variables are set and paths exist
Select service to restart:
1) torro-web
2) torro-core
Enter choice (1 or 2): 2
[INFO] Restarting torro-core...
Port mappings have been discarded as one of the Host, Container, Pod, and None network modes are in use
511bb2df5d102fbbe2ae770ec03651bba129cd60f9b1a963ed29c73b1a28c750
```

### 5.6 Check the logs

```
# torro-core
[torro@dev-server01 opt]$ sudo podman logs -f torro-core
```