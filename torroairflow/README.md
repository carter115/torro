# Airflow

## 1. Prepare

### Download the file 

Please download the file to the `/opt/torroairflow/` directory.
```
$ mkdir -p /opt/torroairflow
$ cd /opt/torroairflow

[torro@Torro-VM2 torroairflow]$ ls -a
 airflow-airflow-001.tar  airflow.cfg  airflow-frontend-001.tar  data_discovery.sql  start.sh
 airflow-backend-001.tar  airflow.env  .env
```

Change the folder owner
```
$ sudo chown -R torro:torro /opt/torroairflow/
$ sudo su - torro
$ cd /opt/torroairflow
```


### Database initialization

If it's the first time, you need to create an account and a database.
```
[torro@Torro-VM2 torroairflow]$ mysql -h <HOST> -P 3306 -u mysql -p

mysql> CREATE USER 'torro-app'@'%' IDENTIFIED BY '<YOUR_PASSWORD>';
mysql> create database torro_discovery;
mysql> create database airflow_metadata;
mysql> GRANT ALL PRIVILEGES ON torro_discovery.* TO 'torro-app'@'%' WITH GRANT OPTION; 
mysql> GRANT ALL PRIVILEGES ON airflow_metadata.* TO 'torro-app'@'%' WITH GRANT OPTION; 
mysql> flush privileges;

mysql> show databases;
mysql> exit;
```

Executing init sql file

```
[torro@Torro-VM2 torroairflow]$ cd /opt/torroairflow
[torro@Torro-VM2 torroairflow]$ mysql -h <HOST> -P 3306 -u torro-app -p torro_discovery < data_discovery.sql
```


## 2. Setup

### Modify the configuration file
```
[torro@Torro-VM2 torroairflow]$ cd /opt/torroairflow
[torro@Torro-VM2 torroairflow]$ vi .env
......
DB_HOST=<HOST>
DB_PORT=3306
DB_USER=<USER>
DB_PASSWORD=<PASSWORD>
DB_NAME=torroforexcel
DB_DRIVER=pymysql
......

[torro@Torro-VM2 torroairflow]$ vi airflow.cfg
......


[torro@Torro-VM2 torroairflow]$ vi airflow.env
......
```

### Load the image

```
[torro@Torro-VM2 torroairflow]$ ./start.sh load
[INFO] Loading Docker image from tar file...
Please enter the path to the tar file: airflow-frontend-001.tar
[INFO] Loading image from airflow-frontend-001.tar...
Getting image source signatures
Copying blob 014e56e61396 skipped: already exists
Copying blob 2e4fafc9c573 skipped: already exists
Copying blob 4745102427f1 skipped: already exists
Copying blob b9b992ae23a0 skipped: already exists
Copying blob 829beb804381 done   |
Copying blob 17add5003a46 done   |
Copying blob 5d11addb94f3 done   |
Copying blob 8663f50ca910 done   |
Copying config 49b7d40c03 done   |
Writing manifest to image destination
Loaded image: torro.ai/airflow/frontend:0.0.1
[SUCCESS] Docker image loaded successfully from airflow-frontend-001.tar

[torro@Torro-VM2 torroairflow]$ ./start.sh load
[INFO] Loading Docker image from tar file...
Please enter the path to the tar file: airflow-backend-001.tar
[INFO] Loading image from airflow-backend-001.tar...
Getting image source signatures
Copying blob 1733a4cd5954 skipped: already exists
Copying blob 72cf4c3b8301 skipped: already exists
Copying blob 4d55cfecf366 skipped: already exists
Copying blob 3f0cdbca744e skipped: already exists
Copying blob 34272bedc73e done   |
Copying blob db32528cf76b done   |
Copying blob 77a629687480 done   |
Copying blob dc07d978d3c7 done   |
Copying blob 2f79cf49d940 done   |
Getting image source signatures
Writing manifest to image destination
Loaded image: torro.ai/airflow/backend:0.0.1
[SUCCESS] Docker image loaded successfully from airflow-backend-001.tar

[torro@Torro-VM2 torroairflow]$ ./start.sh load
[INFO] Loading Docker image from tar file...
Please enter the path to the tar file: airflow-airflow-001.tar
[INFO] Loading image from airflow-airflow-001.tar...
Getting image source signatures
Copying blob af107e978371 done   |
Copying blob 8ce3f2b601cc done   |
Copying blob 171d5fbe177d done   |
Copying blob 4572660747e0 done   |
Copying blob c1dbec90831e done   |
Copying config 8f42d45425 done   |
Writing manifest to image destination
Loaded image: torro.ai/airflow/airflow:0.0.1
[SUCCESS] Docker image loaded successfully from airflow-airflow-001.tar
```


Check or update the image version

```
[torro@Torro-VM2 torroairflow]$ vi start.sh
#/bin/sh
set -e
MYNAME='torro'
MYGROUP=${MYNAME}
TORRO_FRONTEND_NAME='airflow-frontend'
TORRO_BACKEND_NAME='airflow-backend'
TORRO_AIRFLOW_NAME='airflow-airflow'
TORRO_FRONTEND_IMAGE='torro.ai/airflow/frontend:0.0.1'  # change this
TORRO_BACKEND_IMAGE='torro.ai/airflow/backend:0.0.1'    # change this
TORRO_AIRFLOW_IMAGE='torro.ai/airflow/airflow:0.0.1'
TORRO_AIRFLOW_PATH='/opt/torroairflow'
......
```


### Service stopped
```
[torro@Torro-VM2 torroairflow]$ ./start.sh stop
Select service to stop:
1) airflow-frontend
2) airflow-backend
3) airflow-airflow
Enter choice (1 or 2 or 3): 1
......
......
```

### Start the service
```
torro@Torro-VM2 torroairflow]$ ./start.sh restart
Select service to restart:
1) airflow-frontend
2) airflow-backend
3) airflow-airflow
Enter choice (1 or 2 or 3): 1
......
......
```


### Check the service status
```
[torro@Torro-VM2 torroairflow]$ ./start.sh status
[INFO] Docker containers status:
e42b981de6f5  torro.ai/airflow/frontend:0.0.1     npm run dev -- --...  28 seconds ago  Up 29 seconds                                              airflow-frontend
d8aec262400c  torro.ai/airflow/backend:0.0.1      python main.py        24 seconds ago  Up 22 seconds                                              airflow-backend
b46e1f990921  torro.ai/airflow/airflow:0.0.1      bash -c airflow d...  19 seconds ago  Up 19 seconds                                              airflow-airflow
```

### Check the logs

```
# airflow
[torro@Torro-VM2 torroairflow]$ sudo podman logs airflow-airflow

# frontend
[torro@Torro-VM2 torroairflow]$ sudo podman logs airflow-frontend

# backend
[torro@Torro-VM2 torroairflow]$ sudo podman logs airflow-backend
```