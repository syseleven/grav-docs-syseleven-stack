---
title: 'Port Security'
published: true
date: '26-07-2021 16:25'
taxonomy:
    category:
        - docs
---

## Overview

OpenStack uses ports to connect cloud instances to networks and corresponding (virtual) network devices like routers.
By default SysEleven Stack port security will be enforced, which means that:

* Incoming traffic that does not originate from your project is not allowed (the default security group)
* Only traffic from and to the IP addresses known by OpenStack will be allowed

It is possible to change these restrictions using security groups and the port security settings.  
For more information about security groups have a look [here](https://wiki.openstack.org/wiki/Neutron/SecurityGroups).

[This tutorial](../../../03.Howtos/06.allowing-an-additional-subnet-to-talk-to-or-via-a-port/docs.en.md) shows how to allow an additional subnet to talk to/via a port to be able to communicate via a VPN for example.
