---
title: 'Allowing an additional subnet to talk to/via a port'
published: true
date: '08-08-2018 11:48'
taxonomy:
    category:
        - docs
---

Allowing e.g. VPN Network communication in and out via the VPN Gateway port requires adjustment of the port security.

## Prerequisites

* You should be able to use simple heat templates, like shown in the [first steps tutorial](../../02.Tutorials/01.firststeps/docs.en.md).
* You know the basics of using the [OpenStack CLI-Tools](../../03.Howtos/02.openstack-cli/docs.en.md).
* Environment variables are set, like shown in the [API-Access-Tutorial](../../02.Tutorials/02.api-access/docs.en.md).

### Step One: List available ports

```shell
$ openstack port list
+--------------+------------------+-------------------+-----------------------------------------------------+--------+
| ID           | Name             | MAC Address       | Fixed IP Addresses                                  | Status |
+--------------+------------------+-------------------+-----------------------------------------------------+--------+
| 5fc7ed94-... | vpngateway1 port | fa:16:3e:6a:24:b3 | ip_address='192.168.2.14', subnet_id='f776dcf3-...' | ACTIVE |
+--------------+------------------+-------------------+-----------------------------------------------------+--------+
```

### Step Two: Update port security for target port and allow additional subnet

```shell
openstack port set --allowed-address ip-address=<IP Address or IP Subnet/Mask> <PORT ID>
```

```shell
openstack port set --allowed-address ip-address=10.0.0.0/24 5fc7ed94-754e-427a-a6d2-9b0f67f9eebd
```

Note that `openstack port set` returns no output. You can verify the change with `openstack port show <PORT ID>`.

### Step Three: Check if packets can be sent/received

```shell
ssh user@10.0.0.2

ping 192.168.2.14

64 bytes from 192.168.2.14: icmp_seq=348 ttl=64 time=2.19 ms
64 bytes from 192.168.2.14: icmp_seq=349 ttl=64 time=1.83 ms
```

## Conclusion

You allowed your VPN subnet to talk via the host port.
