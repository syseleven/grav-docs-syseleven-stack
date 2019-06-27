---
title: 'How to set up DNS for a Server/Website'
date: '24-07-2019 12:00'
taxonomy:
    category:
        - docs
---

## How to set up DNS for a Server/Website

### Overview

This Document will show you the essential steps to create a minimal zone with a minimal recordset for a simple Server like a Website.
For a complete overview see the [reference guide](../../04.Reference/07.dns/docs.en.md).

!! The SysEleven Stack DNS service is currently in a test period. The test period ends in September 2019. Until then you can use all features free of charge.


### Prerequisites

* You know the basics of using the [OpenStack CLI-Tools](../../03.Howtos/02.openstack-cli/docs.en.md).
* Environment variables are set, like shown in the [API-Access-Tutorial](../../02.Tutorials/02.api-access/docs.en.md).

If your CLI-Tools or Kickstart Server have been installed prior to the feature release, you may need to install the designate client (plugin).

```shell
(sudo) pip install python-openstackclient python-designateclient
```


### Create your Webserver

This is not the main focus of this document, but you can work through [this howto](../../02.Tutorials/03.single-lamp-server/docs.en.md) first if you don't already have one.


### Prepare the Zone and Records in OpenStack/Designate

Create a dns zone with the following command:

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
| id             | 01234567-89ab-cdef-0123-456789abcdef |
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
| created_at  | 2019-06-21T15:39:36.000000           |
| description | None                                 |
| id          | 01234567-89ab-cdef-0123-456789abcdef |
| name        | www.domain.example.                  |
| project_id  | 0123456789abcdef0123456789abcdef     |
| records     | 123.45.67.89                         |
| status      | PENDING                              |
| ttl         | None                                 |
| type        | A                                    |
| updated_at  | None                                 |
| version     | 1                                    |
| zone_id     | 01234567-89ab-cdef-0123-456789abcdef |
| zone_name   | domain.example.                      |
+-------------+--------------------------------------+
```


### Delegate your Domain to SysEleven Stack Nameservers

The delegation of a zone will be done by the appropriate registry for the toplevel domain where the registered domain belongs to, e.g. DeNIC for `*.de`-Domains. Most likely it will be triggered via your registrar or reseller. They need to know the nameservers that the domain shall be delegated to. You can obtain that list with the following command

```shell
$ openstack recordset list domain.example. --type ns
+--------------------------------------+-----------------+------+---------------------------+--------+--------+
| id                                   | name            | type | records                   | status | action |
+--------------------------------------+-----------------+------+---------------------------+--------+--------+
| 01234567-89ab-cdef-0123-456789abcdef | domain.example. | NS   | ns02.cloud.syseleven.net. | ACTIVE | NONE   |
|                                      |                 |      | ns04.cloud.syseleven.net. |        |        |
|                                      |                 |      | ns03.cloud.syseleven.net. |        |        |
|                                      |                 |      | ns01.cloud.syseleven.net. |        |        |
+--------------------------------------+-----------------+------+---------------------------+--------+--------+
```

In this case you will have to give the nameserver names `ns01.cloud.syseleven.net` thru `ns04.cloud.syseleven.net` to your registrar. They will then arrange for the delegation. Some registries perform sanity checks on the nameservers before executing a delegation. If you encounter problems with the registry, please contact our support.


### Set a PTR Record (reverse DNS) for your floating IP address

!!! **Feature unavailable**
!!! While generally possible in OpenStacks Designate component, this is unfortunately not yet implemented in SysEleven Stack due to technical restrictions. We are working on removing these obstacles.


### Conclusion

We have delegated a domain registered elsewhere to the SysEleven Stack and created a zone for this domain with the minimum necessary records for a Webserver in the SysEleven Stack.

We can verify that the dns records resolve correctly on the Nameservers of the SysEleven Stack:

```shell
$ dig +short @ns01.cloud.syseleven.net www.domain.example a
123.45.67.89
```

We can verify that the dns records resolve correctly in the public Domain Name System.

```shell
$ dig +short www.domain.example a
123.45.67.89
```

