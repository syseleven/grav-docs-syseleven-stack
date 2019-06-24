---
title: 'How to set up forward and reverse DNS for a Server/Website'
date: '24-07-2019 12:00'
taxonomy:
    category:
        - docs
---

## How to set up forward and reverse DNS for a Server/Website

### Overview

This Document will show you the essential steps to create a minimal zone with a minimal recordset for a simple Server like a Website.


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

TODO


### Set a PTR Record (reverse DNS) for your floating IP address

!!! **Feature unavailable**
!!! Due to technical issues, the management of reverse DNS records is not yet implemented.

First, obtain the ID of manageable PTR Records.

```shell
$ openstack ptr record list
+------------------------------------------+----------+-------------+-----+
| id                                       | ptrdname | description | ttl |
+------------------------------------------+----------+-------------+-----+
| dbl:01234567-89ab-cdef-0123-456789abcdef |          |             |     |
+------------------------------------------+----------+-------------+-----+
```

This is the minimal command to set a reverse dns record with the desired hostname.

```shell
$ openstack ptr record set dbl:01234567-89ab-cdef-0123-456789abcdef www.domain.example.
+-------------+------------------------------------------+
| Field       | Value                                    |
+-------------+------------------------------------------+
| action      | CREATE                                   |
| address     | 123.45.67.89                             |
| description | test                                     |
| id          | dbl:01234567-89ab-cdef-0123-456789abcdef |
| ptrdname    | www.domain.example.                      |
| status      | PENDING                                  |
| ttl         | 21600                                    |
+-------------+------------------------------------------+
```


### Conclusion

We have delegated a domain registered elsewhere to the SysEleven Stack and created a basic zone for this domain with basic records for a Webserver in the SysEleven Stack.

We can verify that the dns records resolve correctly on the Nameservers of the SysEleven Stack:

```shell
$ dig +short @ns01.cloud.syseleven.net www.domain.example a
123.45.67.89
$ dig +short @ns01.cloud.syseleven.net -x 123.45.67.89 ptr
www.domain.example.
```

We can verify that the dns records resolve correctly in the public Domain Name System.

```shell
$ dig +short www.domain.example a
123.45.67.89
$ dig +short -x 123.45.67.89 ptr
www.domain.example.
```

