---
title: 'DNS as a Service (DNSaaS) Tutorial'
date: '24-07-2019 12:00'
taxonomy:
    category:
        - docs
---

## DNS as a service (DNSaaS) tutorial

### Overview

OpenStack's Designate provides a Domain Name Service as a Service (DNSaaS).
This means that zones and records can be configured within OpenStack.
No dedicated virtual machines are required to use this service.

!!! **Feature availability**
!!! DNSaaS gets released 07/2019. Reliability and performance may not immediately be fully established.

### Prerequisites

* You know the basics of using the [OpenStack CLI-Tools](../../03.Howtos/02.openstack-cli/docs.en.md).
* Environment variables are set, like shown in the [API-Access-Tutorial](../../02.Tutorials/02.api-access/docs.en.md).

If your CLI-Tools or kickstart server have been installed prior to the feature release, you may need to install the designate client (plugin).

```shell
(sudo) pip install python-openstackclient python-designateclient
```

### How to create a DNS zone and manage its records

#### Create a (primary) zone

First you create a dns zone with the following command:

```shell
$ openstack zone create --email "email@domain.example" domain.example.
```

You can also create subzones with the following command:

```shell
$ openstack zone create --email "email@domain.example" sub.domain.example.
```

To indicate a valid email address is a requirement by the relevant DNS standards (RFC) and thus also mandatory for OpenStack.

The zone name can be any publicly available domain name or subdomain name. Top level domain names are not allowed.


#### Create a secondary (slave) zone

To create a secondary or slave zone, thats content are actually managed by (and obtained from) the primary or master server, you need to specify the master server(s):

```shell
$ openstack zone create --type SECONDARY --masters 123.45.67.89 -- secondary.domain.example.
```

Attention: Because more than one master ip address can be specified, the list must either be terminated with a double dash or the whole parameter with its list be moved to the end of the command line.

```shell
$ openstack zone create secondary.domain.example. --type SECONDARY --masters 123.45.67.89
```


#### Have the zone delegated to the SysEleven Stack nameservers

The delegation of a zone will be done by the appropriate registry for the toplevel domain where the registered domain belongs to. Most likely it will be triggered via your registrar or reseller. They need to know the nameservers that the domain shall be delegated to. You can obtain that list with the following command

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

#### Create records within that zone

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

#### Update records within that zone

```shell
$ openstack recordset set --description "Webserver FIP" --ttl 600 --record 123.45.67.88 domain.example. www.domain.example.
+-------------+--------------------------------------+
| Field       | Value                                |
+-------------+--------------------------------------+
| action      | UPDATE                               |
| created_at  | 2019-06-21T15:39:36.000000           |
| description | Webserver FIP                        |
| id          | 01234567-89ab-cdef-0123-456789abcdef |
| name        | www.domain.example.                  |
| project_id  | 0123456789abcdef0123456789abcdef     |
| records     | 123.45.67.88                         |
| status      | PENDING                              |
| ttl         | 600                                  |
| type        | A                                    |
| updated_at  | 2019-06-24T10:44:33.000000           |
| version     | 2                                    |
| zone_id     | 01234567-89ab-cdef-0123-456789abcdef |
| zone_name   | domain.example.                      |
+-------------+--------------------------------------+
$ openstack recordset set --no-description --no-ttl --record 123.45.67.89 domain.example. www.domain.example.
+-------------+--------------------------------------+
| Field       | Value                                |
+-------------+--------------------------------------+
| action      | UPDATE                               |
| created_at  | 2019-06-21T15:39:36.000000           |
| description | None                                 |
| id          | 01234567-89ab-cdef-0123-456789abcdef |
| name        | www.domain.example.                  |
| project_id  | 0123456789abcdef0123456789abcdef     |
| records     | 123.45.67.89                         |
| status      | PENDING                              |
| ttl         | None                                 |
| type        | A                                    |
| updated_at  | 2019-06-24T10:46:19.000000           |
| version     | 3                                    |
| zone_id     | 01234567-89ab-cdef-0123-456789abcdef |
| zone_name   | domain.example.                      |
+-------------+--------------------------------------+
```

#### Remove records from that zone

```shell
$ openstack recordset delete domain.example. www.domain.example.
+-------------+--------------------------------------+
| Field       | Value                                |
+-------------+--------------------------------------+
| action      | DELETE                               |
| created_at  | 2019-06-21T15:39:36.000000           |
| description | None                                 |
| id          | 01234567-89ab-cdef-0123-456789abcdef |
| name        | www.domain.example.                  |
| project_id  | 0123456789abcdef0123456789abcdef     |
| records     | 123.45.67.89                         |
| status      | PENDING                              |
| ttl         | None                                 |
| type        | A                                    |
| updated_at  | 2019-06-24T10:51:43.000000           |
| version     | 3                                    |
| zone_id     | 01234567-89ab-cdef-0123-456789abcdef |
| zone_name   | domain.example.                      |
+-------------+--------------------------------------+
```

#### Frequent problems and their solutions

| Problem | Solution |
|---|---|
| Duplicate Zone| Zone has already been created, either by you or by another user. Contact us if you believe, someone else is illegitimately blocking your domain. |
| Invalid TLD | Zone names must be within a known toplevel domain. Contact us if you believe the top level domain is valid. |
| More than one label is required | It is not allowed to create a zone for a top level domain. |
| Zone name cannot be the same as a TLD | It is not allowed to create a zone for a known top level domain. |
| u'domain.example' is not a 'domainname'| Domain names must be fully qualified, i.e. end with a dot. |
| Please delete any subzones before deleting this zone | This is a security measure to prevent you from losing control over your zone after having [transferred](#transfer-of-zones) subzones. |
| Unable to create subzone in another tenants zone | The subzone must be created by the tenant owning the zone and can then be [transferred](#transfer-of-zones). |
| Unable to create zone because another tenant owns a subzone of the zone | The zone must be created by the tenant owning the subzone and can then be [transferred](#transfer-of-zones). |

### How to manage PTR Records (reverse DNS) of floating IP-Addresses

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
| ptrdname    | hostname.domain.example.                 |
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

#### Frequent problems and their solutions

| Problem | Solution |
|---|---|
| Duplicate Record | see [changing an entry](#edit-ptr). |

### Import/Export of Zones

TODO

### Collisions

Each domain name can only be registered once within the SysEleven Stack. If a domain name is already taken you cannot register this domain or a subdomain within. You can, however, create subzones within your already registered zone and transfer them to other users. Creation of a zone does not require actual control over the domain, it is legit to prepare zones for future use, e.g. in preparation of the registration. If you have the feeling that a zone is blocked illegitimately by another user, please contact our support.

TODO

### Transfer of Zones

Zones can be transferred to other users.

TODO
