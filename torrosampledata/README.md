# torrosampledata


Download the file to the specified directory

```
$ ls /opt/torrosampledata/
backend.env  sampledata-backend-001.tar  sampledata-frontend-001.tar  start.sh
```

Change the folder owner
```
sudo chown -R torro:torro /opt/torrosampledata/
```

Load the image
```
[torro@Torro-VM2 torrosampledata]$ ./start.sh load
[INFO] Loading Docker image from tar file...
Please enter the path to the tar file: sampledata-backend-001.tar
[INFO] Loading image from sampledata-backend-001.tar...
Getting image source signatures
Copying blob 1733a4cd5954 skipped: already exists
Copying blob 72cf4c3b8301 skipped: already exists
Copying blob 4d55cfecf366 skipped: already exists
Copying blob 3f0cdbca744e skipped: already exists
Copying blob f70241507c00 skipped: already exists
Copying blob ee6ad0bf2532 skipped: already exists
Copying blob f5c24d6a1e30 skipped: already exists
Copying blob 964fa4b9d737 skipped: already exists
Copying blob ecfda4667d44 skipped: already exists
Copying blob 18212e46e279 skipped: already exists
Copying config c0ed342418 done   |
Writing manifest to image destination
Loaded image: torro.ai/sampledata/backend:0.0.1
[SUCCESS] Docker image loaded successfully from sampledata-backend-001.tar

[torro@Torro-VM2 torrosampledata]$ ./start.sh load
[INFO] Loading Docker image from tar file...
Please enter the path to the tar file: sampledata-frontend-001.tar
[INFO] Loading image from sampledata-frontend-001.tar...
Getting image source signatures
Copying blob 014e56e61396 skipped: already exists
Copying blob 2e4fafc9c573 skipped: already exists
Copying blob 4745102427f1 skipped: already exists
Copying blob b9b992ae23a0 skipped: already exists
Copying blob 9b5ad003d5c0 skipped: already exists
Copying blob 9210f65aa7c5 skipped: already exists
Copying blob 8aee8db7eced skipped: already exists
Copying blob dfd76b497979 skipped: already exists
Copying config eb09d4f180 done   |
Writing manifest to image destination
Loaded image: torro.ai/sampledata/frontend:0.0.1
[SUCCESS] Docker image loaded successfully from sampledata-frontend-001.tar
```

Service stopped
```
[torro@Torro-VM2 torrosampledata]$ ./start.sh stop
Select service to stop:
1) sampledata-frontend
2) sampledata-backend
Enter choice (1 or 2): 1
[INFO] Stopping sampledata-frontend...
[SUCCESS] sampledata-frontend stopped successfully

[torro@Torro-VM2 torrosampledata]$ ./start.sh stop
Select service to stop:
1) sampledata-frontend
2) sampledata-backend
Enter choice (1 or 2): 2
[INFO] Stopping sampledata-backend...
[SUCCESS] sampledata-backend stopped successfully
```

Enable the service
```
[torro@Torro-VM2 torrosampledata]$ ./start.sh restart
Select service to restart:
1) sampledata-frontend
2) sampledata-backend
Enter choice (1 or 2): 1
[INFO] Restarting sampledata-frontend...
9e1390daa59e1070534a531b7bce1a14c55fdc73aa14166b1423638c6fbe9d1f
[SUCCESS] sampledata-frontend restarted successfully

[torro@Torro-VM2 torrosampledata]$ ./start.sh restart
Select service to restart:
1) sampledata-frontend
2) sampledata-backend
Enter choice (1 or 2): 2
[INFO] Restarting sampledata-backend...
9a4362efac6f5e253bd46eb70543aad6e2be47267fdeff670023c76610a32f22
[SUCCESS] sampledata-backend restarted successfully
```

Check the service status
```
[torro@Torro-VM2 torrosampledata]$ ./start.sh status
[INFO] Docker containers status:
CONTAINER ID  IMAGE                               COMMAND               CREATED         STATUS         PORTS       NAMES
9e1390daa59e  torro.ai/sampledata/frontend:0.0.1  npm run dev -- --...  17 minutes ago  Up 17 minutes              sampledata-frontend
9a4362efac6f  torro.ai/sampledata/backend:0.0.1   python -m backend...  25 seconds ago  Up 25 seconds              sampledata-backend
```
