---
title: 'Port Security'
published: true
date: '08-08-2018 11:45'
taxonomy:
    category:
        - docu
---

OpenStack uses ports to connect cloud instances to networks and corresponding (virtual) network devices like routers, firewalls. 
By default SysEleven Stack port security will be enforced, which means that:

* Incoming traffic that does not originate from your project is not allowed (the default security group)
* Only traffic from and to the IP addresses known by OpenStack will be allowed

It is possible to change these restrictions using security groups and the port security settings.  
In this article we will focus on the port security settings; for more information about security groups have a look [here](https://wiki.openstack.org/wiki/Neutron/SecurityGroups).

[This tutorial](tutorials/allowing-an-additional-subnet-to-talk-to-or-via-a-port) shows how to allow an additional subnet to talk to/via a port to be able to communicate via a VPN for example.