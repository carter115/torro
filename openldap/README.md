# OpenLDAP

## 1. Prepare

### Download the file 

Please download the file to the `/opt/openldap/` directory.
```
$ mkdir -p /opt/openldap
$ ls -a /opt/openldap/
openldap-001.tar openldap-admin-001.tar
```

Change the folder owner
```
$ sudo chown -R torro:torro /opt/openldap/
$ sudo su - torro
$ cd /opt/openldap
```

## 2. Setup


### Load the image
```
[torro@Torro-VM2 openldap]$ sudo podman load -i openldap-001.tar
Getting image source signatures
Copying blob 45b42c59be33 skipped: already exists
Copying blob ae7fb8f59730 skipped: already exists
Copying blob 55443d9da5d5 skipped: already exists
Copying blob 062b29194b6e skipped: already exists
Copying blob 613ba832a7d4 skipped: already exists
Copying blob 48562e0b854d skipped: already exists
Copying blob 3731e12f1fa4 skipped: already exists
Copying blob b1feb4016881 skipped: already exists
Copying blob d2744e887776 skipped: already exists
Copying config 2da3cf6648 done   |
Writing manifest to image destination
Loaded image: docker.io/osixia/openldap:1.5.0

[torro@Torro-VM2 openldap]$ sudo podman load -i openldap-admin-001.tar
Getting image source signatures
Copying blob 1ab2bdfe9778 skipped: already exists
Copying blob 0abcaf321aa9 skipped: already exists
Copying blob 6d688c3d4e02 skipped: already exists
Copying blob 454331b99b9a skipped: already exists
Copying blob 5cada7c8cb4e skipped: already exists
Copying blob 52cfed5e8eb6 skipped: already exists
Copying blob 456a8fa39791 skipped: already exists
Copying blob 81141b2b97de skipped: already exists
Copying blob 2a35330382a7 skipped: already exists
Copying config 78148b61fd done   |
Writing manifest to image destination
Loaded image: docker.io/osixia/phpldapadmin:0.9.0
```

### Start openldap

Use the default value
```
[torro@Torro-VM2 openldap]$ sudo podman run \
-p 389:389 \
-p 636:636 \
--name openldap \
--network host \
--env LDAP_ORGANISATION="Torro Company" \
--env LDAP_DOMAIN="torro.com" \
--env LDAP_ADMIN_PASSWORD="123456" \
--detach osixia/openldap:1.5.0
```

### Start openldap-admin

Set the **VM's IP address**
```
[torro@Torro-VM2 openldap]$ sudo podman run \
-d \
--privileged \
-p 9090:80 \
--name ldapadmin \
--env PHPLDAPADMIN_HTTPS=false \
--env PHPLDAPADMIN_LDAP_HOSTS=10.127.134.11 \
--detach osixia/phpldapadmin:0.9.0
```

### Stop openldap
```
[torro@Torro-VM2 openldap]$ sudo podman stop openldap ldapadmin
[torro@Torro-VM2 openldap]$ sudo podman rm openldap ldapadmin
```

### Check the logs

```
[torro@Torro-VM2 openldap]$ sudo podman logs openldap
[torro@Torro-VM2 openldap]$ sudo podman logs ldapadmin
```
