---
title: 'LoadBalancer as a Service (LBaaS)'
published: true
date: '2019-02-28 17:30'
taxonomy:
    category:
        - docs
---

## Overview

The SysEleven Stack LBaaS is a TCP-based loadbalancer using round robin as balancing mechanism.
It also offers health monitoring.

Unfortunately it is currently not possible to forward the client IP to the instances behind the loadbalancer. The IP of the LBaaS will show up as the client IP

We prepared a simple tutorial that shows [basic usage of LBaaS](../../../02.Tutorials/05.lbaas/docs.en.md).

---

## Questions & Answers

### What features does the SysEleven Stack LBaaS offer?

The SysEleven Stack LBaaS is a TCP-based load balancer using round robin as balancing mechanism.
It also offers health monitoring.
The following modes are supported:

- Listener protocol: TCP
- Pool protocol: TCP
- Distribution strategy: ROUND_ROBIN
- Health monitoring protocols: TCP, HTTP, HTTPS

### Is it possible to see the client IP behind the LBaaS?

No. Unfortunately that is currently not possible. The IP of the LBaaS will show up as the client IP.

### How do I use the SysEleven Stack LBaaS?

We prepared a simple tutorial that shows [basic usage of LBaaS](../../../02.Tutorials/05.lbaas/docs.en.md).
