---
title: 'How to export and import DNS zones'
date: '24-07-2019 12:00'
taxonomy:
    category:
        - docs
---

## How export and import DNS zones

### Overview

This Document will show you the essential steps to export and import a zone file.
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

This document assumes that you already have a zone you want to export. If you want to practise with a test domain, you can create an empty zone like this:

```shell
$ openstack zone create --email "email@domain.example" domain.example.
+----------------+--------------------------------------+
| Field          | Value                                |
+----------------+--------------------------------------+
| action         | CREATE                               |
| attributes     |                                      |
| created_at     | 2019-06-24T15:41:22.000000           |
| description    | None                                 |
| email          | email@example.de                     |
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

The raw zone information can be obtained by using the zone export showfile.

```shell
$ openstack zone export showfile 35c0d8a0-31d6-4342-8266-00982a2673f1 -f value
$ORIGIN lgrebe.invaliddomain2.de.
$TTL 21600

domain.example.de.  IN NS ns04.cloud.syseleven.net.
domain.example.de.  IN NS ns02.cloud.syseleven.net.
domain.example.de.  IN NS ns03.cloud.syseleven.net.
domain.example.de.  IN NS ns01.cloud.syseleven.net.
domain.example.de.  IN SOA ns04.cloud.syseleven.net. email.example.de. 1562146000 21600 3600 259200 300
www.domain.example.de.  IN A 123.45.67.89
```

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

You can also list all zone exports which have been made

```shell
$ openstack zone import list
+--------------------------------------+--------------------------------------+----------------------------+----------+-----------------------------+
| id                                   | zone_id                              | created_at                 | status   | message                     |
+--------------------------------------+--------------------------------------+----------------------------+----------+-----------------------------+
| 4067eae9-b3e6-4b65-bf7b-d5c039d35586 | 2e1db03e-4d9c-4116-b023-4f3a82e1f7d7 | 2019-06-24T15:48:46.000000 | COMPLETE | domain.example.de. imported |
+--------------------------------------+--------------------------------------+----------------------------+----------+-----------------------------+
```

To confirm your zone has been imported successfully you can check the list of zones

```shell
openstack zone list
+--------------------------------------+--------------------+---------+------------+--------+--------+
| id                                   | name               | type    |     serial | status | action |
+--------------------------------------+--------------------+---------+------------+--------+--------+
| 2e1db03e-4d9c-4116-b023-4f3a82e1f7d7 | domain.example.de. | PRIMARY | 1562146000 | ACTIVE | NONE   |
+--------------------------------------+--------------------+---------+------------+--------+--------+
```

### Conclusion

We have exported and re-imported a zone.
