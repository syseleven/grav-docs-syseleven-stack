---
title: 'How to transfer dns zones'
date: '28-07-2019 18:00'
taxonomy:
    category:
        - docs
---

## How to transfer a DNS zone from one project to another

### Overview

This Document will show you the essential steps to transfer a zone from one project to another project.

For a complete overview see the [reference guide](../../04.Reference/07.dns/docs.en.md).

### Prerequisites

* You know the basics of using the [OpenStack CLI-Tools](../../03.Howtos/02.openstack-cli/docs.en.md).
* Environment variables are set, like shown in the [API-Access-Tutorial](../../02.Tutorials/02.api-access/docs.en.md).

You may need to install the designate client (plugin).

```shell
(sudo) pip install python-openstackclient python-designateclient
```


### Create your zone

This document assumes that you already have the zone you want to transfer.
If you want to create a subzone for the purpose of delegating it, you may want to work through [this howto](../../02.Tutorials/09.dnsaas/docs.en.md) first.
If you want to practice with a test domain, you can create an empty zone like this:

```shell
$ openstack zone create --email email@domain.example transfer.domain.example.
+----------------+--------------------------------------+
| Field          | Value                                |
+----------------+--------------------------------------+
| action         | CREATE                               |
| attributes     |                                      |
| created_at     | 2019-06-28T15:27:00.000000           |
| description    | None                                 |
| email          | email@domain.example                 |
| id             | 01234567-89ab-cdef-0123-456789abcdef |
| masters        |                                      |
| name           | transfer.domain.example.             |
| pool_id        | 14234f0f-1234-4444-6789-758006f43802 |
| project_id     | 0123456789abcdef0123456789abcdef     |
| serial         | 1561735620                           |
| status         | PENDING                              |
| transferred_at | None                                 |
| ttl            | 21600                                |
| type           | PRIMARY                              |
| updated_at     | None                                 |
| version        | 1                                    |
+----------------+--------------------------------------+
```

### Request a transfer

As the donor, you can initiate the transfer of the zone to the intended recipient. You need to specify the project id of the intended recipient of the zone when you request a transfer.

```shell
$ openstack zone transfer request create --target-project-id 026293a28d204567bb568b1e5685459c transfer.domain.example.
+-------------------+---------------------------------------------------------------------------------------------------------------------------+
| Field             | Value                                                                                                                     |
+-------------------+---------------------------------------------------------------------------------------------------------------------------+
| created_at        | 2019-06-28T15:37:30.000000                                                                                                |
| description       | None                                                                                                                      |
| id                | ca6b190e-376b-4075-9dd6-a14d451212da                                                                                      |
| key               | S9JX5C27                                                                                                                  |
| links             | {u'self': u'https://api.infra.sys11cloud.net:9001/v2/zones/tasks/transfer_requests/ca6b190e-376b-4075-9dd6-a14d451212da'} |
| project_id        | 0123456789abcdef0123456789abcdef                                                                                          |
| status            | ACTIVE                                                                                                                    |
| target_project_id | fedcba9876543210fedcba9876543210                                                                                          |
| updated_at        | None                                                                                                                      |
| zone_id           | db1228fc-d955-4cc2-a6f8-23ad91024b20                                                                                      |
| zone_name         | transfer.domain.example.                                                                                                  |
+-------------------+---------------------------------------------------------------------------------------------------------------------------+
```

You will need to give the key of this output to the recipient. In case you missed it, you can always look it up again with

```shell
$ openstack zone transfer request list
+--------------------------------------+--------------------------------------+-------------------------+----------------------------------+----------------------------------+--------+----------+
| id                                   | zone_id                              | zone_name               | project_id                       | target_project_id                | status | key      |
+--------------------------------------+--------------------------------------+-------------------------+----------------------------------+----------------------------------+--------+----------+
| ca6b190e-376b-4075-9dd6-a14d451212da | db1228fc-d955-4cc2-a6f8-23ad91024b20 | transfer.domain.example.| 0123456789abcdef0123456789abcdef | fedcba9876543210fedcba9876543210 | ACTIVE | S9JX5C27 |
+--------------------------------------+--------------------------------------+-------------------------+----------------------------------+----------------------------------+--------+----------+
```

### Accept a transfer

As the recipient, you must accept the transfer of the zone from the donor. You need to obtain the transfer id and the key. The transfer id can be looked up.

```shell
$ openstack zone transfer accept list
+--------------------------------------+--------------------------------------+------------+--------------------------+--------+-----+
| id                                   | zone_id                              | project_id | zone_transfer_request_id | status | key |
+--------------------------------------+--------------------------------------+------------+--------------------------+--------+-----+
| ca6b190e-376b-4075-9dd6-a14d451212da | db1228fc-d955-4cc2-a6f8-23ad91024b20 |            |                          | ACTIVE |     |
+--------------------------------------+--------------------------------------+------------+--------------------------+--------+-----+
```

The key needs to be given to you by the donor. You can now accept the transfer.

```shell
$ openstack zone transfer accept request --transfer-id ca6b190e-376b-4075-9dd6-a14d451212da --key S9JX5C27
+--------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Field                    | Value                                                                                                                                                                                                                     |
+--------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| created_at               | 2019-06-28T16:01:28.000000                                                                                                                                                                                                |
| id                       | 7ade2756-f726-48a6-a1e6-57463595ff2b                                                                                                                                                                                      |
| key                      | S9JX5C27                                                                                                                                                                                                                  |
| links                    | {u'self': u'https://api.infra.sys11cloud.net:9001/v2/zones/tasks/transfer_accepts/7ade2756-f726-48a6-a1e6-57463595ff2b', u'zone': u'https://api.infra.sys11cloud.net:9001/v2/zones/db1228fc-d955-4cc2-a6f8-23ad91024b20'} |
| project_id               | fedcba9876543210fedcba9876543210                                                                                                                                                                                          |
| status                   | COMPLETE                                                                                                                                                                                                                  |
| updated_at               | 2019-06-28T16:01:28.000000                                                                                                                                                                                                |
| zone_id                  | db1228fc-d955-4cc2-a6f8-23ad91024b20                                                                                                                                                                                      |
| zone_transfer_request_id | ca6b190e-376b-4075-9dd6-a14d451212da                                                                                                                                                                                      |
+--------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
```

If everything was correct, the zone transfer is now complete and the zone has appeared in the recipients zone list and disappeared from the donors zone list.



### Conclusion

We have transferred a zone from one project to another.

```shell
$ openstack zone list
+--------------------------------------+--------------------------+---------+------------+--------+--------+
| id                                   | name                     | type    |     serial | status | action |
+--------------------------------------+--------------------------+---------+------------+--------+--------+
| db1228fc-d955-4cc2-a6f8-23ad91024b20 | transfer.domain.example. | PRIMARY | 1561735620 | ACTIVE | NONE   |
+--------------------------------------+--------------------------+---------+------------+--------+--------+
```

This can be useful to resolve a dispute peacefully, but it makes sense over deleting and recreating the zone especially if the zones recordsets shall be retained without interruption or the zones are subzones that cannot otherwise be created in another project.
Say, if you want to delegate the handling for a subsystem within your company to a team, you can create a subdomain within your domain and transfer it to the project of your team.

If you created an empty example zone for practicing, don't forget to delete it from the recipient project's list.
