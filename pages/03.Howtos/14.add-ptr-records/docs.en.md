---
title: 'How to add PTR records'
date: '17-09-2020 18:00'
taxonomy:
    category:
        - docs
---

## How to add PTR records for an existing floating IP

### Overview

This Document will show you the essential steps to add a PTR record for an existing floating IP.

For a complete overview see the [networking reference guide](../../04.Reference/08.network/docs.en.md) and the [DNS reference guide](../../04.Reference/07.dns/docs.en.md).

### Prerequisites

* You know the basics of using the [OpenStack CLI-Tools](../../03.Howtos/02.openstack-cli/docs.en.md).
* You know the basics of the Designate DNS service as shown in the [DNSaaS tutorial](../../02.Tutorials/09.dnsaas/docs.en.md).

You may need to install the designate client (plugin).

```shell
(sudo) pip install python-openstackclient python-designateclient
```

### Create your zone

We only allow PTR records for zones that you own. You can use a zone that you already created before this how-to.

If you want to create a subzone for the purpose of delegating it to a different project, you may want to work through [this howto](../../02.Tutorials/09.dnsaas/docs.en.md) first.

If you want to practice with a test domain, you can create an empty zone like this:

```shell
$ openstack zone create --email email@domain.example ptrhowto.example.
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
| name           | ptrhowto.example.                    |
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

### Create a network and a server

You need at least one network and one server. For testing purposes, you can create a network and a server by following the tutorials "[first steps](../../02.Tutorials/01.firststeps/docs.en.md)" or "[single LAMP server](../../02.Tutorials/03.single-lamp-server/docs.en.md)".

### Assign the DNS domain to the network

For automated forward A-record and reverse PTR-record management, the network needs to be assigned to the DNS zone.

Find out the network ID with this command:

```shell
openstack network list
```

Then assign the DNS zone to the network:

```shell
openstack network set --dns-domain ptrhowto.example. <Network UUID>
```

### Assign the DNS domain and DNS name to the port

Because we did not use the DNS integration when the server was created, we must update the DNS domain and DNS name for the preexisting network port of our server. For newly created servers this will happen automatically, once we assigned the dns domain to the network.

First let's find the ID of the server we want to work with and the floating IP:

```shell
$ openstack server list
+--------------------------------------+------------+--------+--------------------------------------------------+----------------------------------+----------+
| ID                                   | Name       | Status | Networks                                         | Image                            | Flavor   |
+--------------------------------------+------------+--------+--------------------------------------------------+----------------------------------+----------+
| e4dc0ac3-7f71-4279-ba95-d686da868dae | appserver2 | ACTIVE | demo_net=192.168.2.30, 185.56.129.73  | Ubuntu Bionic 18.04 (2020-04-30) | m1c.tiny |
+--------------------------------------+------------+--------+--------------------------------------------------+----------------------------------+----------+
```

And now we need to find the network port ID:

```shell
$ openstack port list --server e4dc0ac3-7f71-4279-ba95-d686da868dae
+--------------------------------------+------+-------------------+-----------------------------------------------------------------------------+--------+
| ID                                   | Name | MAC Address       | Fixed IP Addresses                                                          | Status |
+--------------------------------------+------+-------------------+-----------------------------------------------------------------------------+--------+
| 1e1c5f3f-4b69-41d0-8e67-15911a471a42 |      | fa:16:3e:8e:29:33 | ip_address='192.168.2.30', subnet_id='81bcf2d9-f72e-4a2c-aedd-1f68e4c7f86d' | ACTIVE |
+--------------------------------------+------+-------------------+-----------------------------------------------------------------------------+--------+
```

Now we can update the DNS domain and DNS name for our port:

```shell
openstack port set 1e1c5f3f-4b69-41d0-8e67-15911a471a42 --dns-domain ptrhowto.example. --dns-name appserver2
```

### Re-assign the floating IP

Finally, to create the forward A-type records and reverse PTR-type records for our Floating IP, we need to re-assign it to the server:

!! Please be aware that this procedure will cause a downtime for your server.

In our example, the server ID is `e4dc0ac3-7f71-4279-ba95-d686da868dae` and the floating IP is `185.56.129.73`.

```shell
openstack server remove floating ip <server UUID> <server floating IP>
```

and then immediately run:

```shell
openstack server add floating ip <server UUID> <server floating IP>
```

### Conclusion

We now created the forward A-type record `appserver2.ptrhowto.example.` in our example zone. You can verify that by running:

```shell
openstack recordset list ptrhowto.example.
```

Also, a matching reverse PTR-type record is configured for the floating IP:

```shell
$ dig +short -x 185.56.129.73
appserver2.ptrhowto.example.net.
```

