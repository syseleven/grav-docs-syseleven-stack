---
title: 'How to migrate your storage from quobyte to ceph'
date: '29-12-2022 13:47'
taxonomy:
    category:
        - docs
---

## How to migrate your storage from quobyte to ceph

### Overview

This document is a guide to help you to migrate your storage from Quobyte to Ceph. Since there could be different use cases of Quobyte(QB), we will try to cover the most common use cases here in this document. For this purpose, lets to define some scenarios from real world. In real world you have two different approaches with a storage, As Block storage or As Object storage.

#### Block Storage

At this category, you will have your storage as a block device in your operating system layer, like “/dev/vdb, /dev/sdc”. You should format your block device with some partitions in specific format. For better understanding, take a look at the following example

Here you can see that there are three disks, and they are mounted in specific mount points

```shell
[~]># lsblk
NAME  MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
vda  254:0    0  50G  0 disk
└─vda1 254:1  0  50G  0 part /
vdb  254:16   0  10G  0 disk /var/lib/mysql
vdc  254:32   0   2G  0 disk /home/www
[~]>#
```

Quobyte also is able to give you storage as a block device same as your local devices and this is completely transparent from point of view of Operating System

At this example, I have two volumes created in my Instance

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

And both of them are created from Quobyte type in OpenStack

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

For getting better feeling and understanding, I have installed MariaDB (Database) and Nginx (Web server) on this VM on these mounted volumes from Quobyte and would like to migrate these services to Ceph. Lets to take a look briefly at what we have at this VM.

##### Nginx


```shell

```

So for a block storage we may use our block devices for different goals, and now we want to talk about these different approaches for using a block device.


##### Static Files

