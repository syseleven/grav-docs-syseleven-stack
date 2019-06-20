---
title: 'Use DNS (as a Service)'
date: '24-07-2019 12:00'
taxonomy:
    category:
        - docs
---

## DNS as a Service

### Overview

OpenStack's Designate provides a Domain Name Service as a Service (DNSaaS).
This means that zones and records can be configured within OpenStack.
No dedicated virtual machines are required to use this service.

!!! **Feature availability**
!!! DNSaaS gets released 07/2019. Reliability and performance may not immediately be fully established.

## Prerequisites

* You know the basics of using the [OpenStack CLI-Tools](../../03.Howtos/02.openstack-cli/docs.en.md).
* Environment variables are set, like shown in the [API-Access-Tutorial](../../02.Tutorials/02.api-access/docs.en.md).

If your CLI-Tools or Kickstart Server have been installed prior to the feature release, you may need to install the designate client (plugin).

```shell
(sudo) pip install python-openstackclient python-designateclient
```

## How to create a DNS Zone and manage its Records

### Create a zone

First you create a dns zone with the following command:

```shell
$ openstack zone create --email "email@domain.example" sub.domain.example.
```

To indicate a valid email adress is a requirement by the relevant DNS Standards (RFC) and thus also mandatory for OpenStack Designate. 

The zone name can be any publicly available domain name or subdomain name. Top level domain names are not allowed.

### Have the zone delegated to the SysEleven Stack Nameservers

### Create records within that zone

### Update records within that zone

### Frequent problems and their solutions

| Problem | Solution |
|---|---|
| Duplicate Zone| Zone has already been created, either by you or by another user. Contact us if you believe, someone else is illegitimately blocking your domain. |
| Invalid TLD | Zone names must be within a known toplevel domain. Contact us if you believe the top level domain is valid. |
| More than one label is required | It is not allowed to create a zone for a top level domain. |
| Zone name cannot be the same as a TLD | It is not allowed to create a zone for a known top level domain. |
| u'invaliddomain.de' is not a 'domainname'| Domain names must be fully qualified, i.e. end with a dot. |
Please delete any subzones before deleting this zone|
Unable to createsubzone in another tenants zone|
Unable to create zone because another tenant owns a subzone of the zone|

## How to manage PTR Records (reverse DNS) of floating IP-Adresses

First, obtain a list of manageable PTR Records.

```shell
$ openstack ptr record list
+------------------------------------------+----------+-------------+-----+
| id                                       | ptrdname | description | ttl |
+------------------------------------------+----------+-------------+-----+
| dbl:01234567-89ab-cdef-0123-456789abcdef |          |             |     |
+------------------------------------------+----------+-------------+-----+
```

There is one entry for every floating ip associated with the current project in any region, i.e. it basically corresponds to the output of `openstack floating ip list` issued for all available regions.

Now we can display details for the not yet set record.

```shell
$ openstack ptr record show dbl:01234567-89ab-cdef-0123-456789abcdef
+-------------+------------------------------------------+
| Field       | Value                                    |
+-------------+------------------------------------------+
| action      | None                                     |
| address     | 123.45.67.89                             |
| description | None                                     |
| id          | dbl:01234567-89ab-cdef-0123-456789abcdef |
| ptrdname    | None                                     |
| status      | ACTIVE                                   |
| ttl         | None                                     |
+-------------+------------------------------------------+
```

This is the minimal command to set a reverse dns record with the desired hostname.

```shell
$ openstack ptr record set dbl:01234567-89ab-cdef-0123-456789abcdef hostname.domain.example.
+-------------+------------------------------------------+
| Field       | Value                                    |
+-------------+------------------------------------------+
| action      | CREATE                                   |
| address     | 123.45.67.89                             |
| description | test                                     |
| id          | dbl:01234567-89ab-cdef-0123-456789abcdef |
| ptrdname    | mbernhardt.invaliddomain.de.             |
| status      | PENDING                                  |
| ttl         | 21600                                    |
+-------------+------------------------------------------+
```

<a name="edit-ptr"></a>Changes to a record require unsetting it and setting it again with complete corrected parameters.

```shell
$ openstack ptr record unset dbl:01234567-89ab-cdef-0123-456789abcdef
$ openstack ptr record set dbl:01234567-89ab-cdef-0123-456789abcdef --description Test --ttl 86400 hostname.domain.example.
+-------------+------------------------------------------+
| Field       | Value                                    |
+-------------+------------------------------------------+
| action      | CREATE                                   |
| address     | 123.45.67.89                             |
| description | Test                                     |
| id          | dbl:01234567-89ab-cdef-0123-456789abcdef |
| ptrdname    | hostname.domain.example.                 |
| status      | PENDING                                  |
| ttl         | 86400                                    |
+-------------+------------------------------------------+
```

This how a populated record looks like:

```shell
$ openstack ptr record show dbl:01234567-89ab-cdef-0123-456789abcdef
+-------------+------------------------------------------+
| Field       | Value                                    |
+-------------+------------------------------------------+
| action      | NONE                                     |
| address     | 123.45.67.89                             |
| description | Test                                     |
| id          | dbl:01234567-89ab-cdef-0123-456789abcdef |
| ptrdname    | hostname.domain.example.                 |
| status      | ACTIVE                                   |
| ttl         | 86400                                    |
+-------------+------------------------------------------+
$ openstack ptr record list
+------------------------------------------+--------------------------+-------------+-------+
| id                                       | ptrdname                 | description | ttl   |
+------------------------------------------+--------------------------+-------------+-------+
| dbl:01234567-89ab-cdef-0123-456789abcdef | hostname.domain.example. | Test        | 86400 |
+------------------------------------------+--------------------------+-------------+-------+
```

The reverse DNS record can now be looked up with your preferred utility.

```shell
$ dig +short @ns01.cloud.syseleven.net -x 195.192.129.177 ptr
hostname.domain.example.
```

For reverse DNS records you do not need to take care about the zone creation and delegation, this is up to SysEleven. OpenStack Designate takes care that each user of the SysEleven Stack has only control over records corresponding to his/her floating ip addresses.

### Frequent problems and their solutions

| Problem | Solution |
|---|---|
| Duplicate Record | see [changing an entry](#edit-ptr). |

## Import/Export of Zones

## Collisions

Each domain name can only be registered once within the SysEleven Stack. If a domain name is already taken you cannot register this domain or a subdomain within. You can, however, create subzones within your already registered zone and transfer them to other users. Creation of a zone does not require actual control over the domain, it is legit to prepare zones for future use, e.g. in preparation of the registration. If you have the feeling that a zone is blocked illegitimately by another user, please contact our support.

## Transfer of Zones

Zones can be transferred to other users.
