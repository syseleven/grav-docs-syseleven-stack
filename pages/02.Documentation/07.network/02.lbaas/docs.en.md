---
title: 'LoadBalancer as a Service (LBaaS)'
published: true
date: '08-08-2018 11:40'
taxonomy:
    category:
        - docs
---

## Overview

The SysEleven Stack LBaaS is a TCP-based loadbalancer. It supports round robin as balancing mechanism.
It also offers a simple HealthCheck.

Unfortunately it is currently not possible to forward the client IP to the instances behind the loadbalancer. The IP of the LBaaS will show up as the client IP

We prepared a simple tutorial that shows [basic usage of LBaaS](../../03.Tutorials/07.lbaas/docs.en.md).
