---
title: 'I am using Ubuntu from 15.xx and the default route is missing'
published: true
date: '08-08-2018 13:05'
taxonomy:
    category:
        - FAQ
    tag:
        - OpenStack
        - Network
        - Access
        - DHCP
        - ICMP
        - DefaultRoute
        - DefaultGateway
        - Gateway
---

Since `15.04`, Ubuntu uses an RFC conform implementation of DHCP. The software defined network does not send a default route by default, therefore it must be explicitly set using `host_routes`. We are currently working with the manufacturer on a solution. Using the following configuration you can work around this problem. Following is an example for the subnet `10.0.0.0/24` with `10.0.0.1` as the default gateway.

```plain
  subnet:
    type: OS::Neutron::Subnet
    properties:
      name: kickstart-subnet
      dns_nameservers:
        - 8.8.8.8
        - 8.8.4.4
      network_id: {get_resource: net}
      ip_version: 4
      host_routes:
        - { destination: 0.0.0.0/0, nexthop: 10.0.0.1 }
      gateway_ip: 10.0.0.1
      cidr: 10.0.0.0/24
      allocation_pools:
      - {start: 10.0.0.10, end: 10.0.0.250}
```