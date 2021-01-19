---
title: 'Cinder multi-attach'
published: true
date: '04-27-2020 10:11'
taxonomy:
    category:
        - docs
---

## Cinder multi-attach

### Overview

In this tutorial we will create a [block storage volume](../../04.Reference/04.block-storage/docs.en.md) and attach it to 3 different instances simultaneously in Read/Write mode using the OCFS2 file system.

### Prerequisites

* 3 running instances using Ubuntu sharing one network
* You know the basics of using the [OpenStack CLI-Tools](../../03.Howtos/02.openstack-cli/docs.en.md).
* Environment variables are set, like shown in the [API-Access-Tutorial](../02.api-access/docs.en.md).

### Create a cinder multi-attach volume

Multi-attach volumes are created by choosing the type `quobyte-multiattach`.

```shell
openstack volume create --size 50 --type quobyte-multiattach  testvolume
+---------------------+--------------------------------------+
| Field               | Value                                |
+---------------------+--------------------------------------+
| attachments         | []                                   |
| availability_zone   | cbk1                                 |
| bootable            | false                                |
| consistencygroup_id | None                                 |
| created_at          | 2020-04-23T08:46:24.000000           |
| description         | None                                 |
| encrypted           | False                                |
| id                  | 28d230fa-7070-4698-a801-475ad29275d4 |
| multiattach         | True                                 |
| name                | testvolume                           |
| properties          |                                      |
| replication_status  | None                                 |
| size                | 50                                   |
| snapshot_id         | None                                 |
| source_volid        | None                                 |
| status              | creating                             |
| type                | quobyte-multiattach                  |
| updated_at          | None                                 |
| user_id             | 8e9e69c9d85e4b4a82382b9e9e0f59c1     |
+---------------------+--------------------------------------+
```

### Attach the new volume to the instances

For this tutorial the following 3 instances are used:

```shell
openstack server list
+--------------------------------------+----------------+--------+----------------------------------------+----------------------------------+
| ID                                   | Name           | Status | Networks                               | Image Name                       |
+--------------------------------------+----------------+--------+----------------------------------------+----------------------------------+
| 2befeba0-70f1-4049-97d8-98a71a3b6d72 | App Instance 1 | ACTIVE | net_demo=192.168.1.14                | Ubuntu Xenial 16.04 (2020-03-30) |
| 6e607706-13e2-4433-8665-3617835865c0 | App Instance 2 | ACTIVE | net_demo=192.168.1.2                 | Ubuntu Xenial 16.04 (2020-03-30) |
| a6d64bf4-d2da-4d17-ada0-9b5c10942bc9 | App Instance 3 | ACTIVE | net_demo=192.168.1.6                 | Ubuntu Xenial 16.04 (2020-03-30) |
+--------------------------------------+----------------+--------+----------------------------------------+----------------------------------+

openstack --os-compute-api-version 2.60 server add volume "App Instance 1" testvolume
openstack --os-compute-api-version 2.60 server add volume "App Instance 2" testvolume
openstack --os-compute-api-version 2.60 server add volume "App Instance 3" testvolume

```

If you get an error message like
>versions supported by client: 2.1 - 2.41

you need to update your openstack client. Working with multi-attach volumes is supported from nova API version 2.60.


### Setup OCFS2

Multi-attach volumes require a [cluster file system](https://en.wikipedia.org/wiki/Clustered_file_system#SHARED-DISK) like OCFS2 or GFS2 to coordinate concurrent file system access.

**Warning: We do not recommend to use a file system like Ext4 or XFS for multi-attach volumes. Concurrent write access will destroy the file system and the data on that volume.**

For this tutorial we use OCFS2.
To setup OCFS2 we need to install the ocfs2 management tools and kernel modules for the running kernel version on every VM:

```shell
uname -a
Linux app-instance-1 4.4.0-177-generic #207-Ubuntu SMP Mon Mar 16 01:16:10 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux

apt install ocfs2-tools linux-modules-extra-4.4.0-177-generic
```

OCFS2 is configurend in /etc/default/o2cb and /etc/ocfs/cluster.conf.
Set `O2CB_ENABLED=true` in /etc/default/o2cb. All other settings can be left unchanged.

```shell
# O2CB_ENABLED: 'true' means to load the driver on boot.
O2CB_ENABLED=true

[ ... ]
```

Define all 3 VMs in /etc/ocfs2/cluster.conf to tell o2cb which nodes are part of the cluster and how to reach them. Make sure that the `name` setting for every node matches the hostname and that the `number` is unique in the cluster.
This file is identical on all 3 VMs:

```shell
# /etc/ocfs2/cluster.conf
node:
        ip_port = 7777
        ip_address = 192.168.1.14
        number = 1
        name = app-instance-1
        cluster = ocfs2
node:
        ip_port = 7777
        ip_address = 192.168.1.2
        number = 2
        name = app-instance-2
        cluster = ocfs2
node:
        ip_port = 7777
        ip_address = 192.168.1.6
        number = 3
        name = app-instance-3
        cluster = ocfs2

cluster:
    node_count = 3
    name = ocfs2
```

Start the o2cb service on all 3 VMs and check the status:

```shell
systemctl start o2cb
systemctl status o2cb
systemctl enable o2cb
```

### Create a file system on the volume

In this example there is only one cinder volume attached to the VMs. The device name on all VMs is `/dev/vdb`.
The next step is only necessary on one VM:

```shell
mkfs.ocfs2 /dev/vdb
```

### Mount the file system

Mount the file system on all 3 VMs:

```shell
mount.ocfs2 /dev/vdb /mnt
```

Now it is possible to read and write files on the volume from all VMs.

## References

* [SysEleven Stack block storage reference guide](../../04.Reference/04.block-storage/docs.en.md)
* [OCFS2 best practices guide](http://www.oracle.com/us/technologies/linux/ocfs2-best-practices-2133130.pdf)
