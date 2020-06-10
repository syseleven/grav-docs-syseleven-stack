---
title: 'LoadBalancer as a Service (LBaaS)'
published: true
date: '2019-02-28 17:30'
taxonomy:
    category:
        - docs
---

## Overview

The SysEleven Stack offers LBaaS via two different generations of APIs: Neutron LBaaSv2 (deprecated API) and Octavia (current API).

Looking at the API definition both services are similar.
But there are differences in the feature set provided by the SysEleven Stack.
With Neutron LBaaS only simple TCP-based load balancers are supported, with Octavia on the other hand also HTTP and HTTPS. With both services it is optionally possible to set up health monitoring.

The client IP address can only be made visible to the backend servers if
an Octavia load balancer is used, in case of Neutron the backends will only
see the IP address of the load balancer.

We prepared a simple tutorial that shows [basic usage of LBaaS](../../../02.Tutorials/05.lbaas/docs.en.md).

---

## Questions & Answers

### What features does the SysEleven Stack LBaaS offer?

The following table lists the supported features of the two LBaaS services:

Function             | Neutron LBaaSv2 | Octavia LBaaS
---------------------|-----------------|--------------
Listener protocols  | TCP             | TCP, HTTP, HTTPS
Pool protocols      | TCP             | TCP, HTTP, HTTPS
Distribution strategies | ROUND_ROBIN     | ROUND_ROBIN
Health Monitoring protocols | TCP, HTTP, HTTPS | TCP, HTTP, HTTPS
Original client IP visible on backend servers? | no | yes
Available in dashboard | yes | no (planned)

### How do I use the SysEleven Stack LBaaS?

We prepared a simple tutorial that shows [basic usage of LBaaS](../../../02.Tutorials/05.lbaas/docs.en.md).
