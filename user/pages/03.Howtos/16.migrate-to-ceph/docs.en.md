---
title: 'How to migrate your storage to Ceph'
date: '29-12-2022 13:47'
taxonomy:
    category:
        - docs
---

## How to migrate your storage to a different storage type

### Overview

This document is a guide to help you to migrate your storage to a different type e.g. between Local SSD storage, Distributed storage based on Quobyte or Ceph or change between different Local SSD Storage flavors, which is otherwise not supported. For this purpose, let's define a realistic scenario.


## Prerequisites

* You should be able to use simple heat templates, like shown in the [first steps tutorial](../../02.Tutorials/01.firststeps/docs.en.md).
* You know the basics of using the [OpenStack CLI-Tools](../../03.Howtos/02.openstack-cli/docs.en.md).
* Environment variables are set, like shown in the [API-Access-Tutorial](../../02.Tutorials/02.api-access/docs.en.md).


## How to do, with an example

Imagine you have a Virtual Machine (VM) which has a simple website and a database on it. You operating system is installed on the Nova ephemeral root device `/dev/vda`, your database files are supposed to be stored on a separate Cinder volume `/dev/vdc` mounted to `/var/lib/mysql` and your web documents are supposed to be on a Cinder volume `/dev/vdb` mounted to `/srv/www`.

```shell
[~]># lsblk
NAME  MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
vda  254:0    0  50G  0 disk
└─vda1 254:1  0  50G  0 part /
vdb  254:16   0  10G  0 disk /var/lib/mysql
vdc  254:32   0   2G  0 disk /srv/www
[~]>#
```

The storage type of Nova ephemeral root storage is determined by the flavor. Per convention, all flavors whose names start with `m*` refer to distributed storage and flavors with names starting with `l*` refer to local storage. The storage type of cinder volumes is directly specified and currently defaults to `quobyte` in all three regions, in our new region `fes` we alternatively offer `ceph`. Likewise, only in our new `fes` region you can choose between `m1*`-flavors using quobyte as storage backend and `m2*`-flavors using `ceph` instead as the storage backend.

Quobyte also is able to give you storage as a block device same as your local devices and this is completely transparent from the point of view of the Operating System

In this example, I have two volumes created with QB and attached to my Instance

```shell
[~]>$ openstack volume list --fit-width 
+--------------------------------------+----------------------+-----------+------+-------------+
| ID                                   | Name                 | Status    | Size | Attached to |
+--------------------------------------+----------------------+-----------+------+-------------+
| 8b1a1c5a-bcfc-4c8f-bb91-be5dc09251e8 | test-volume-qb-2-db  | available |   10 |             |
| 47d2af74-9aa4-4b20-86bf-b658351a91db | test-volume-qb-2-web | available |    2 |             |
+--------------------------------------+----------------------+-----------+------+-------------+
[~]>$
```

```shell
[~]>$ openstack volume type list --fit-width
+--------------------------------------+---------------------+-----------+
| ID                                   | Name                | Is Public |
+--------------------------------------+---------------------+-----------+
| ebacc66b-fd02-4b9a-ae10-64de5a595053 | ceph                | False     |
| 1b291a48-c8ba-4275-a22a-619f65b807ee | quobyte-multiattach | True      |
| e2ebd226-2504-4159-a0ea-7a5e30e2e4b0 | quobyte             | True      |
+--------------------------------------+---------------------+-----------+
[~]>$
```

As a real example, I have installed MariaDB (Database) and Nginx (Web server) on this VM on these mounted volumes from Quobyte and would like to migrate to Ceph. Lets to take a look briefly at what we have at this VM.

There is a demo WordPress website installed on this VM, with a database. The web server is Nginx and use php-fpm as PHP engine in backend. The database is served by MariaDB.

The mount points state

```shell
root@test-qb-to-ceph:~# df -h
Filesystem    Size  Used Avail Use% Mounted on
udev          3.9G  0  3.9G   0% /dev
tmpfs         799M  8.4M  790M   2% /run
/dev/vda1     50G  1.4G   46G   3% /
tmpfs         3.9G  0  3.9G   0% /dev/shm
tmpfs         5.0M  0  5.0M   0% /run/lock
tmpfs         3.9G  0  3.9G   0% /sys/fs/cgroup
/dev/vdb      9.8G  124M  9.2G   2% /var/lib/mysql
/dev/vdc      2.0G   71M  1.8G   4% /srv/www
tmpfs         799M  0  799M   0% /run/user/1000
root@test-qb-to-ceph:~#
```

The fstab file

```shell
root@test-qb-to-ceph:~# cat /etc/fstab
# /etc/fstab: static file system information.
UUID=919e4355-3134-483f-a80c-51f4516f2f3a    /    ext4    errors=remount-ro    0    1
UUID=a3ed0420-88ba-45a5-82e1-4bd120cdd3e6    /var/lib/mysql    ext4    errors=remount-ro    0    1
UUID=5ba23dfb-c1e2-404d-8eb6-10f39e859bac    /home/www    ext4    errors=remount-ro    0    1
root@test-qb-to-ceph:~#
```

The block devices by UUID

```shell
root@test-qb-to-ceph:~# blkid
/dev/vda1: UUID="919e4355-3134-483f-a80c-51f4516f2f3a" TYPE="ext4" PARTUUID="4ed79ac7-01"
/dev/vdb: UUID="a3ed0420-88ba-45a5-82e1-4bd120cdd3e6" TYPE="ext4"
/dev/vdc: UUID="5ba23dfb-c1e2-404d-8eb6-10f39e859bac" TYPE="ext4"
root@test-qb-to-ceph:~#
```

So there are two partitions which we want to migrate to Ceph. I have created two other Ceph volumes and attached them to the VM.


```shell
[~]>$ openstack volume list --fit-width
+--------------------------------------+------------------------+--------+------+------------------------------------------+
| ID                                | Name                | Status | Size | Attached to                           |
+--------------------------------------+------------------------+--------+------+------------------------------------------+
| 9e2bf021-4af8-49e9-abe0-4c614e017cda | test-volume-ceph-2-web | in-use |  2 | Attached to test-qb-to-ceph on /dev/vde  |
| 44630ab7-c4dd-4f93-9ff3-cdf54a58d089 | test-volume-ceph-2-db  | in-use |   15 | Attached to test-qb-to-ceph on /dev/vdd  |
| 8b1a1c5a-bcfc-4c8f-bb91-be5dc09251e8 | test-volume-qb-2-db  | in-use |   10 | Attached to test-qb-to-ceph on /dev/vdb  |
| 47d2af74-9aa4-4b20-86bf-b658351a91db | test-volume-qb-2-web   | in-use |  2 | Attached to test-qb-to-ceph on /dev/vdc  |
+--------------------------------------+------------------------+--------+------+------------------------------------------+
[~]>$

```

### Steps

We imagine that it is OK for you to stop your services for a while (It depends on many factors) and start them after migration. Here, you can see the steps to take this

#### 1. Stop Your Services

In our example, we have two services, Nginx and MariaDB

```shell
root@test-qb-to-ceph:~# systemctl stop nginx.service mariadb.service
root@test-qb-to-ceph:~# systemctl status nginx.service mariadb.service
● nginx.service - A high performance web server and a reverse proxy server
   Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
   Active: inactive (dead) since Mon 2023-01-02 10:25:20 UTC; 6s ago
  Docs: man:nginx(8)
  Process: 2459 ExecStop=/sbin/start-stop-daemon --quiet --stop --retry QUIT/5 --pidfile /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 1231 (code=exited, status=0/SUCCESS)

Jan 02 09:00:43 test-qb-to-ceph systemd[1]: Starting A high performance web server and a reverse proxy server...
Jan 02 09:00:43 test-qb-to-ceph systemd[1]: Started A high performance web server and a reverse proxy server.
Jan 02 10:25:20 test-qb-to-ceph systemd[1]: Stopping A high performance web server and a reverse proxy server...
Jan 02 10:25:20 test-qb-to-ceph systemd[1]: nginx.service: Succeeded.
Jan 02 10:25:20 test-qb-to-ceph systemd[1]: Stopped A high performance web server and a reverse proxy server.

● mariadb.service - MariaDB 10.3.36 database server
   Loaded: loaded (/lib/systemd/system/mariadb.service; enabled; vendor preset: enabled)
   Active: inactive (dead) since Mon 2023-01-02 10:25:22 UTC; 4s ago
  Docs: man:mysqld(8)
        https://mariadb.com/kb/en/library/systemd/
  Process: 654 ExecStart=/usr/sbin/mysqld $MYSQLD_OPTS $_WSREP_NEW_CLUSTER $_WSREP_START_POSITION (code=exited, status=0/SUCCESS)
 Main PID: 654 (code=exited, status=0/SUCCESS)
   Status: "MariaDB server is down"

Jan 02 08:47:01 test-qb-to-ceph systemd[1]: Starting MariaDB 10.3.36 database server...
Jan 02 08:47:01 test-qb-to-ceph mysqld[654]: 2023-01-02  8:47:01 0 [Note] /usr/sbin/mysqld (mysqld 10.3.36-MariaDB-0+deb10u2) starting as process 654 ...
Jan 02 08:47:02 test-qb-to-ceph systemd[1]: Started MariaDB 10.3.36 database server.
Jan 02 10:25:20 test-qb-to-ceph systemd[1]: Stopping MariaDB 10.3.36 database server...
Jan 02 10:25:22 test-qb-to-ceph systemd[1]: mariadb.service: Succeeded.
Jan 02 10:25:22 test-qb-to-ceph systemd[1]: Stopped MariaDB 10.3.36 database server.
root@test-qb-to-ceph:~#
```

#### 2. Mount the new Ceph disks

It is up to you where you would like to create temporary mount points. In this example, two directories are created in ***/opt/db*** and ***/opt/web*** and disks are mounted


```shell
root@test-qb-to-ceph:~# df -h
Filesystem    Size  Used Avail Use% Mounted on
udev          3.9G  0  3.9G   0% /dev
tmpfs         799M  8.4M  790M   2% /run
/dev/vda1     50G  1.4G   46G   3% /
tmpfs         3.9G  0  3.9G   0% /dev/shm
tmpfs         5.0M  0  5.0M   0% /run/lock
tmpfs         3.9G  0  3.9G   0% /sys/fs/cgroup
/dev/vdb      9.8G  112M  9.2G   2% /var/lib/mysql
/dev/vdc      2.0G   71M  1.8G   4% /home/www
tmpfs         799M  0  799M   0% /run/user/1000
/dev/vdd      15G   24K   14G   1% /opt/db
/dev/vde      2.0G   24K  1.8G   1% /opt/web
root@test-qb-to-ceph:~#
```

#### 3. Copy over your data

You can use rsync to do it very simple to copy your data from old QB partitions into new Ceph partitions

```shell
root@test-qb-to-ceph:~# rsync -avh /home/www/ /opt/web/
sending incremental file list

sent 78.67K bytes  received 358 bytes  158.06K bytes/sec
total size is 65.09M  speedup is 823.56
root@test-qb-to-ceph:~# rsync -avh /var/lib/mysql/ /opt/db/
sending incremental file list

sent 3.69K bytes  received 16 bytes  7.42K bytes/sec
total size is 116.17M  speedup is 31,329.73
root@test-qb-to-ceph:~#
```

#### 4. Unmount the old partitions

You can use simply ```umount``` command to do it

```shell
root@test-qb-to-ceph:~# umount /var/lib/mysql
root@test-qb-to-ceph:~# umount /home/www
root@test-qb-to-ceph:~# df -h
Filesystem    Size  Used Avail Use% Mounted on
udev          3.9G  0  3.9G   0% /dev
tmpfs         799M  8.4M  790M   2% /run
/dev/vda1     50G  1.4G   46G   3% /
tmpfs         3.9G  0  3.9G   0% /dev/shm
tmpfs         5.0M  0  5.0M   0% /run/lock
tmpfs         3.9G  0  3.9G   0% /sys/fs/cgroup
tmpfs         799M  0  799M   0% /run/user/1000
/dev/vdd      15G  111M   14G   1% /opt/db
/dev/vde      2.0G   71M  1.8G   4% /opt/web
root@test-qb-to-ceph:~#
```

#### 5. Replace mount points

All will be done in fstab, or you prefer to do it manually. And this is good idea to comment (not to delete) the old lines in fstab until you are sure about it. Then you'll need to mount the 2 mountpoints manually here, or reboot.

```shell
root@test-qb-to-ceph:~# cat /etc/fstab
# /etc/fstab: static file system information.
UUID=919e4355-3134-483f-a80c-51f4516f2f3a    /    ext4    errors=remount-ro    0    1
#UUID=a3ed0420-88ba-45a5-82e1-4bd120cdd3e6    /var/lib/mysql    ext4    errors=remount-ro    0    1
UUID=7da89885-7d87-4a8b-a14d-4c6fa87cd2c6    /var/lib/mysql    ext4    errors=remount-ro    0    1
#UUID=5ba23dfb-c1e2-404d-8eb6-10f39e859bac    /home/www    ext4    errors=remount-ro    0    1
UUID=a7f03a6d-17a4-4b57-88d8-ea10b92b93fc    /home/www    ext4    errors=remount-ro    0    1
root@test-qb-to-ceph:~#

```


#### 6. Check if it works

Start services and check the functionality

```shell
root@test-qb-to-ceph:~# systemctl start nginx.service mariadb.service
root@test-qb-to-ceph:~# systemctl status nginx.service mariadb.service
● nginx.service - A high performance web server and a reverse proxy server
   Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
   Active: active (running) since Mon 2023-01-02 10:55:50 UTC; 5s ago
  Docs: man:nginx(8)
  Process: 2809 ExecStartPre=/usr/sbin/nginx -t -q -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
  Process: 2816 ExecStart=/usr/sbin/nginx -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
 Main PID: 2818 (nginx)
  Tasks: 5 (limit: 4915)
   Memory: 5.2M
   CGroup: /system.slice/nginx.service
        ├─2818 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
        ├─2819 nginx: worker process
        ├─2820 nginx: worker process
        ├─2823 nginx: worker process
        └─2824 nginx: worker process

Jan 02 10:55:50 test-qb-to-ceph systemd[1]: Starting A high performance web server and a reverse proxy server...
Jan 02 10:55:50 test-qb-to-ceph systemd[1]: Started A high performance web server and a reverse proxy server.

● mariadb.service - MariaDB 10.3.36 database server
   Loaded: loaded (/lib/systemd/system/mariadb.service; enabled; vendor preset: enabled)
   Active: active (running) since Mon 2023-01-02 10:55:50 UTC; 4s ago
  Docs: man:mysqld(8)
        https://mariadb.com/kb/en/library/systemd/
  Process: 2810 ExecStartPre=/usr/bin/install -m 755 -o mysql -g root -d /var/run/mysqld (code=exited, status=0/SUCCESS)
  Process: 2817 ExecStartPre=/bin/sh -c systemctl unset-environment _WSREP_START_POSITION (code=exited, status=0/SUCCESS)
  Process: 2825 ExecStartPre=/bin/sh -c [ ! -e /usr/bin/galera_recovery ] && VAR= ||   VAR=`cd /usr/bin/..; /usr/bin/galera_recovery`; [ $? -eq 0 ]   && systemctl set-environment _WSREP_STAR
  Process: 2904 ExecStartPost=/bin/sh -c systemctl unset-environment _WSREP_START_POSITION (code=exited, status=0/SUCCESS)
  Process: 2906 ExecStartPost=/etc/mysql/debian-start (code=exited, status=0/SUCCESS)
 Main PID: 2873 (mysqld)
   Status: "Taking your SQL requests now..."
  Tasks: 31 (limit: 4915)
   Memory: 74.7M
   CGroup: /system.slice/mariadb.service
        └─2873 /usr/sbin/mysqld

Jan 02 10:55:50 test-qb-to-ceph systemd[1]: Starting MariaDB 10.3.36 database server...
Jan 02 10:55:50 test-qb-to-ceph mysqld[2873]: 2023-01-02 10:55:50 0 [Note] /usr/sbin/mysqld (mysqld 10.3.36-MariaDB-0+deb10u2) starting as process 2873 ...
Jan 02 10:55:50 test-qb-to-ceph systemd[1]: Started MariaDB 10.3.36 database server.
Jan 02 10:55:50 test-qb-to-ceph /etc/mysql/debian-start[2908]: Upgrading MySQL tables if necessary.
Jan 02 10:55:50 test-qb-to-ceph /etc/mysql/debian-start[2923]: Triggering myisam-recover for all MyISAM tables and aria-recover for all Aria tables
lines 1-41/41 (END)

```

#### 7. Release the old resource

You can keep the old volumes for a while to make sure that everything works fine and then release and delete them. After you were sure about everything, it is reasonable to release the old and unused resources


```shell
[~]>$ openstack server remove volume test-qb-to-ceph test-volume-qb-2-db
[~]>$ openstack server remove volume test-qb-to-ceph test-volume-qb-2-web
[~]>$ openstack volume delete test-volume-qb-2-db 
[~]>$ openstack volume delete test-volume-qb-2-web
[~]>$ openstack volume list --fit-width 
+--------------------------------------+------------------------+--------+------+------------------------------------------+
| ID                                   | Name                   | Status | Size | Attached to                              |
+--------------------------------------+------------------------+--------+------+------------------------------------------+
| 9e2bf021-4af8-49e9-abe0-4c614e017cda | test-volume-ceph-2-web | in-use |    2 | Attached to test-qb-to-ceph on /dev/vde  |
| 44630ab7-c4dd-4f93-9ff3-cdf54a58d089 | test-volume-ceph-2-db  | in-use |   15 | Attached to test-qb-to-ceph on /dev/vdd  |
+--------------------------------------+------------------------+--------+------+------------------------------------------+
[~]>$
```

