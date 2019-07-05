---
title: 'How to export and import DNS zones'
date: '24-07-2019 12:00'
taxonomy:
    category:
        - docs
---

## How to export and import DNS zones

### Overview

This Document will show you the essential steps how to export and import a zone file.
For a complete overview see the [reference guide](../../04.Reference/07.dns/docs.en.md).

!! The SysEleven Stack DNS service is currently in a test period. The test period ends in September 2019. Until then you can use all features free of charge.

### Prerequisites

* You know the basics of using the [OpenStack CLI-Tools](../../03.Howtos/02.openstack-cli/docs.en.md).
* Environment variables are set, like shown in the [API-Access-Tutorial](../../02.Tutorials/02.api-access/docs.en.md).

If your CLI-Tools or Kickstart Server have been installed prior to the feature release, you may need to install the designate client (plugin).

```shell
(sudo) pip install python-openstackclient python-designateclient
```

### Create your zone

This document assumes that you already have a zone you want to export. If you want to practise with a test domain, you can create an empty zone like in the example below. Be sure to use the recommended hostmaster@<your-domain> mail address.


```shell
$ openstack zone create --email "hostmaster@domain.example" domain.example.
+----------------+--------------------------------------+
| Field          | Value                                |
+----------------+--------------------------------------+
| action         | CREATE                               |
| attributes     |                                      |
| created_at     | 2019-06-24T15:41:22.000000           |
| description    | None                                 |
| email          | hostmaster@domain.example.de         |
| id             | 456d37fd-7e0e-4cd1-ac3e-e44fde0f82b7 |
| masters        |                                      |
| name           | domain.example.                      |
| pool_id        | 14234f0f-1234-4444-6789-758006f43802 |
| project_id     | 0123456789abcdef0123456789abcdef     |
| serial         | 1561390882                           |
| status         | PENDING                              |
| transferred_at | None                                 |
| ttl            | 21600                                |
| type           | PRIMARY                              |
| updated_at     | None                                 |
| version        | 1                                    |
+----------------+--------------------------------------+
```

Create a dns record with the following command:

```shell
$ openstack recordset create --type A --record 123.45.67.89 domain.example. www.domain.example.
+-------------+--------------------------------------+
| Field       | Value                                |
+-------------+--------------------------------------+
| action      | CREATE                               |
| created_at  | 2019-06-24T15:42:22.000000           |
| description | None                                 |
| id          | ec63302d-2666-4a44-ae60-5e8bd9ab3955 |
| name        | www.domain.example.                  |
| project_id  | 0123456789abcdef0123456789abcdef     |
| records     | 123.45.67.89                         |
| status      | PENDING                              |
| ttl         | None                                 |
| type        | A                                    |
| updated_at  | None                                 |
| version     | 1                                    |
| zone_id     | 456d37fd-7e0e-4cd1-ac3e-e44fde0f82b7 |
| zone_name   | domain.example.                      |
+-------------+--------------------------------------+
```

### Export your zone

To export a zone, we can issue an zone export with the information of the zone id or name.

```shell
$ openstack zone export create domain.example.
+------------+--------------------------------------+
| Field      | Value                                |
+------------+--------------------------------------+
| created_at | 2019-06-24T15:43:37.000000           |
| id         | 35c0d8a0-31d6-4342-8266-00982a2673f1 |
| location   | None                                 |
| message    | None                                 |
| project_id | 0123456789abcdef0123456789abcdef     |
| status     | PENDING                              |
| updated_at | None                                 |
| version    | 1                                    |
| zone_id    | 456d37fd-7e0e-4cd1-ac3e-e44fde0f82b7 |
+------------+--------------------------------------+
```

You can also list all zone exports which have been made.

```shell
$ openstack zone export list
+--------------------------------------+--------------------------------------+----------------------------+----------+
| id                                   | zone_id                              | created_at                 | status   |
+--------------------------------------+--------------------------------------+----------------------------+----------+
| 35c0d8a0-31d6-4342-8266-00982a2673f1 | 456d37fd-7e0e-4cd1-ac3e-e44fde0f82b7 | 2019-06-24T15:43:37.000000 | COMPLETE |
+--------------------------------------+--------------------------------------+----------------------------+----------+
```

The raw zone information can be obtained by using the zone export showfile command.

```shell
$ openstack zone export showfile 35c0d8a0-31d6-4342-8266-00982a2673f1 -f value
$ORIGIN domain.example.de.
$TTL 21600

domain.example.de.  IN NS ns04.cloud.syseleven.net.
domain.example.de.  IN NS ns02.cloud.syseleven.net.
domain.example.de.  IN NS ns03.cloud.syseleven.net.
domain.example.de.  IN NS ns01.cloud.syseleven.net.
domain.example.de.  IN SOA ns04.cloud.syseleven.net. hostmaster.domain.example.de. 1562146000 21600 3600 259200 300
www.domain.example.de.  IN A 123.45.67.89
```

The ouput of the showfile command can directly by used as zone file in bind. In the next step we will reimport the zone we just exported.

### Import your zone

To import a zone, we can issue an zone import with the filename of the zone you wish to import. For this command to work properly, the zone file needs to be in bind format.

```shell
$ openstack zone import create ~/domain.example.de.zone
+------------+--------------------------------------+
| Field      | Value                                |
+------------+--------------------------------------+
| created_at | 2019-06-24T15:48:46.000000           |
| id         | 4067eae9-b3e6-4b65-bf7b-d5c039d35586 |
| message    | None                                 |
| project_id | 0123456789abcdef0123456789abcdef     |
| status     | PENDING                              |
| updated_at | None                                 |
| version    | 1                                    |
| zone_id    | None                                 |
+------------+--------------------------------------+
```

If the zone you want to import already exists, you will see an error. This may be the case in our example, because we tried to import the same zone we just exported.

```shell
openstack zone import list
+--------------------------------------+---------+----------------------------+--------+-----------------+
| id                                   | zone_id | created_at                 | status | message         |
+--------------------------------------+---------+----------------------------+--------+-----------------+
| d7b3a9de-0b5f-43a3-a3b3-f16d0cc92f8a |         | 2019-06-24T15:47:35.000000 | ERROR  | Duplicate zone. |
+--------------------------------------+---------+----------------------------+--------+-----------------+
```

If there is no zone file using the same domain, because we removed it before or it was deleted on accident, the zone import request will succeed.


```shell
$ openstack zone import list
+--------------------------------------+--------------------------------------+----------------------------+----------+-----------------------------+
| id                                   | zone_id                              | created_at                 | status   | message                     |
+--------------------------------------+--------------------------------------+----------------------------+----------+-----------------------------+
| 4067eae9-b3e6-4b65-bf7b-d5c039d35586 | 2e1db03e-4d9c-4116-b023-4f3a82e1f7d7 | 2019-06-24T15:48:46.000000 | COMPLETE | domain.example.de. imported |
+--------------------------------------+--------------------------------------+----------------------------+----------+-----------------------------+
```

To confirm your zone has been imported successfully you can check the list of zones and the related recordset.

```shell
$ openstack zone list
+--------------------------------------+--------------------+---------+------------+--------+--------+
| id                                   | name               | type    |     serial | status | action |
+--------------------------------------+--------------------+---------+------------+--------+--------+
| 2e1db03e-4d9c-4116-b023-4f3a82e1f7d7 | domain.example.de. | PRIMARY | 1562146000 | ACTIVE | NONE   |
+--------------------------------------+--------------------+---------+------------+--------+--------+

$ openstack recordset list 2e1db03e-4d9c-4116-b023-4f3a82e1f7d7
+--------------------------------------+-------------------------------+------+-------------------------------------------------------------------------------------------------+--------+--------+
| id                                   | name                          | type | records                                                                                         | status | action |
+--------------------------------------+-------------------------------+------+-------------------------------------------------------------------------------------------------+--------+--------+
| 3e615366-bdb6-4b05-9235-8a14b1dad046 | domain.example.de.            | NS   | ns03.cloud.syseleven.net.                                                                       | ACTIVE | NONE   |
|                                      |                               |      | ns04.cloud.syseleven.net.                                                                       |        |        |
|                                      |                               |      | ns02.cloud.syseleven.net.                                                                       |        |        |
|                                      |                               |      | ns01.cloud.syseleven.net.                                                                       |        |        |
| 46f77bbd-3e5f-4276-9c10-54bf003d49b3 | domain.example.de.            | SOA  | ns04.cloud.syseleven.net. hostmaster.domain.example.de. 1562146000 21600 3600 259200 300        | ACTIVE | NONE   |
| d50a2d59-424b-4919-b51e-cb0588e414ae | www.domain.example.de.        | A    | 123.45.67.89                                                                                    | ACTIVE | NONE   |
+--------------------------------------+-------------------------------+------+-------------------------------------------------------------------------------------------------+--------+--------+
```

### Conclusion

We have exported and re-imported a zone using OpenStack DNS.

```shell
$ openstack zone export list
+--------------------------------------+--------------------------------------+----------------------------+----------+
| id                                   | zone_id                              | created_at                 | status   |
+--------------------------------------+--------------------------------------+----------------------------+----------+
| 35c0d8a0-31d6-4342-8266-00982a2673f1 | 456d37fd-7e0e-4cd1-ac3e-e44fde0f82b7 | 2019-06-24T15:43:37.000000 | COMPLETE |
+--------------------------------------+--------------------------------------+----------------------------+----------+

$ openstack zone import list
+--------------------------------------+--------------------------------------+----------------------------+----------+-----------------------------+
| id                                   | zone_id                              | created_at                 | status   | message                     |
+--------------------------------------+--------------------------------------+----------------------------+----------+-----------------------------+
| 4067eae9-b3e6-4b65-bf7b-d5c039d35586 | 2e1db03e-4d9c-4116-b023-4f3a82e1f7d7 | 2019-06-24T15:48:46.000000 | COMPLETE | domain.example.de. imported |
+--------------------------------------+--------------------------------------+----------------------------+----------+-----------------------------+
```

This can be useful to backup and restore zone files as part of disaster recovery or to move a zone from one service provider to another.


### Cleanup

The zone exports and imports can be cleaned up afterwards

```shell
openstack zone export delete 35c0d8a0-31d6-4342-8266-00982a2673f1
openstack zone import delete 4067eae9-b3e6-4b65-bf7b-d5c039d35586
```
