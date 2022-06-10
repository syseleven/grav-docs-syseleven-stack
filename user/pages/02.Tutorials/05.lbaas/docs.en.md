---
title: 'Create a Load Balancer (using LBaaS)'
date: '2022-06-10 14:30'
taxonomy:
    category:
        - docs
---

## Overview

SysEleven Stack provides load balancing through Load Balancer as a Service (LBaaS).

Currently the SysEleven Stack provides two APIs/services for Load Balancers: Octavia LBaaS and Neutron LBaaSv2. With the Neutron variant the SysEleven Stack only supports TCP-based load balancers, whereas with Octavia also HTTP and HTTPS are supported.

Please refer to our reference documentation for a more [detailed comparison between Octavia LBaaS and Neutron LBaaS](../../04.Reference/08.network/02.lbaas/docs.en.md).

Below you will find two tutorials in two variants: how to set up an HTTP load balancer (using Octavia load balancers) and how to set up a simple TCP load balancer (this time with Neutron load balancers).

- [Tutorials with Heat](01.heat/docs.en.md)
- [Tutorials with Terraform](02.terraform/docs.en.md)
