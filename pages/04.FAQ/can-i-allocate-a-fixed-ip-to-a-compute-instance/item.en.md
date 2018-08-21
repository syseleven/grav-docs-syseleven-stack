---
title: 'Can I allocate a fixed IP to a compute instance?'
published: true
date: '08-08-2018 12:57'
taxonomy:
    category:
        - FAQ
    tag:
        - OpenStack
        - Network
        - IP
        - PrivateIP
        - LocalIP
        - AllocateIP
        - FixedIP
---

Normally a fixed IP shouldn't play a big role in a cloud setup, since the infrastructure might change a lot.
If you need a fixed IP, you can assign a port from our networking service as a fixed IP to our compute instance. Here is an example which shows how to use the orchestration service to fetch a fixed IP address to use in a template:

```plain
  management_port:
    type: OS::Neutron::Port
    properties:
      network_id: { get_resource: management_net }
      fixed_ips:
        - ip_address: 192.168.122.100
```