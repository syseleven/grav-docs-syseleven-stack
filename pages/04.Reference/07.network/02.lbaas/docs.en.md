---
title: 'LoadBalancer as a Service (LBaaS)'
published: true
date: '2019-02-28 17:30'
taxonomy:
    category:
        - docs
---

## Overview

The SysEleven Stack LBaaS is a TCP-based loadbalancer. It supports round robin as balancing mechanism.
It also offers a simple HealthCheck.

Unfortunately it is currently not possible to forward the client IP to the instances behind the loadbalancer. The IP of the LBaaS will show up as the client IP

We prepared a simple tutorial that shows [basic usage of LBaaS](../../../02.Tutorials/07.lbaas/docs.en.md).

!!! **Feature availability**
!!! LBaaS was previously only available in region 'dbl'. It has become also available in region 'cbk' in February 2019.

---

## Questions & Answers

### What features does the SysEleven Stack LBaaS offer?

The SysEleven Stack LBaaS is a TCP-based LoadBalancer. It supports round robin as balancing mechanism.
It also offers a simple HealthCheck.

### Is it possible to see the client IP behind the LBaaS?

No. Unfortunately that is currently not possible. The IP of the LBaaS will show up as the client IP.

### How do I use the SysEleven Stack LBaaS?

We prepared a simple tutorial that shows [basic usage of LBaaS](../../../02.Tutorials/07.lbaas/docs.en.md).
