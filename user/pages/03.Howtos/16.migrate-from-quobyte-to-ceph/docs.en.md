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
+--------------------------------------+-----------------------+--------+------+------------------------------------------+
| ID                                   | Name                  | Status | Size | Attached to                              |
+--------------------------------------+-----------------------+--------+------+------------------------------------------+
| d9891bfe-1f9b-414e-90f3-4a0a2a454b77 | volume-qb-10-test-web | in-use |    2 | Attached to test-qb-to-ceph on /dev/vdc  |
| 51602f73-95b5-4165-9c35-8c5406ceda92 | volume-qb-10-test     | in-use |   10 | Attached to test-qb-to-ceph on /dev/vdb  |
+--------------------------------------+-----------------------+--------+------+------------------------------------------+
[~]>$
[~]>$
```

And both of them are created from Quobyte type in OpenStack

```shell
[~]>$ openstack volume type list --fit-width
+--------------------------------------+---------------------+-----------+
| ID                                   | Name                | Is Public |
+--------------------------------------+---------------------+-----------+
| d578ba45-0e46-4dcb-b886-ba882c74a8e5 | quobyte-multiattach | True      |
| 732afc9b-6b16-4b68-aa1d-fb2a273b361b | quobyte             | True      |
+--------------------------------------+---------------------+-----------+
[~]>$
```

Here you can see definition of one of them

```shell
[~]>$ openstack volume show volume-qb-10-test --fit-width
+------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Field                        | Value                                                                                                                                                       |
+------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------+
| attachments                  | [{'id': '51602f73-95b5-4165-9c35-8c5406ceda92', 'attachment_id': 'a60acf6a-2b6b-4026-9c24-9391162fe888', 'volume_id':                                       |
|                              | '51602f73-95b5-4165-9c35-8c5406ceda92', 'server_id': 'e893ac63-2009-4fae-81c8-528b37c6d900', 'host_name': 'fes300305.fes.sys11cloud.net', 'device':         |
|                              | '/dev/vdb', 'attached_at': '2022-12-29T13:51:04.000000'}]                                                                                                   |
| availability_zone            | fes1                                                                                                                                                        |
| bootable                     | false                                                                                                                                                       |
| consistencygroup_id          | None                                                                                                                                                        |
| created_at                   | 2022-12-29T13:50:09.000000                                                                                                                                  |
| description                  | for QB                                                                                                                                                      |
| encrypted                    | False                                                                                                                                                       |
| id                           | 51602f73-95b5-4165-9c35-8c5406ceda92                                                                                                                        |
| multiattach                  | False                                                                                                                                                       |
| name                         | volume-qb-10-test                                                                                                                                           |
| os-vol-tenant-attr:tenant_id | 32e93511038d4c01941d54ff94669250                                                                                                                            |
| properties                   |                                                                                                                                                             |
| replication_status           | None                                                                                                                                                        |
| size                         | 10                                                                                                                                                          |
| snapshot_id                  | None                                                                                                                                                        |
| source_volid                 | None                                                                                                                                                        |
| status                       | in-use                                                                                                                                                      |
| type                         | quobyte                                                                                                                                                     |
| updated_at                   | 2022-12-29T13:51:05.000000                                                                                                                                  |
| user_id                      | 48b65c881b8f4ae2a83979dbd3d83b5c                                                                                                                            |
+------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------+
[~]>$
```

So for a block storage we may use our block devices for different goals, and now we want to talk about these different approaches for using a block device.


##### Static Files

