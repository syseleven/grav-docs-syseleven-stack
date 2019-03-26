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

* You should be able to use simple heat templates, like shown in the [first steps tutorial](../../02.Tutorials/02.firststeps/docs.en.md).
* You know the basics of using the [OpenStack CLI-Tools](../../03.Howtos/openstack-cli/docs.en.md).
* Environment variables are set, like shown in the [API-Access-Tutorial](../04.api-access/docs.en.md).

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
neutron port-update <PORT ID> --allowed_address_pairs list=true type=dict ip_address=<IP Address or IP Subnet/Mask>
```

```shell
neutron port-update 5fc7ed94-754e-427a-a6d2-9b0f67f9eebd --allowed_address_pairs list=true type=dict ip_address=10.0.0.0/24
```

### Step Three: Check if packets can be sent/received

```shell
ssh user@10.0.0.2

ping 192.168.2.14

64 bytes from 192.168.2.14: icmp_seq=348 ttl=64 time=2.19 ms
64 bytes from 192.168.2.14: icmp_seq=349 ttl=64 time=1.83 ms
```

## Conclusion

You allowed your VPN subnet to talk via the host port.
