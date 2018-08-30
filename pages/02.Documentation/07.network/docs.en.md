---
title: 'Networking Service'
published: true
date: '08-08-2018 11:08'
taxonomy:
    category:
        - docs
---

## Overview

The SysEleven Stack Networking Service is built on the OpenStack Neutron project.
It enables Network-Connectivity-as-a-Service for other SysEleven Stack services, such as the Compute Service. It provides an API for users to define networks and the attachments into them.

You can manage your network both via our public OpenStack API endpoints, as well as using the [Dashboard](https://dashboard.cloud.syseleven.net).

---

## Questions & Answers

### How do I use the SysEleven Stack LBaaS?

We prepared a simple tutorial that shows [basic usage of LBaaS](/syseleven-stack/tutorials/lbaas/).

### Is it possible to see the client IP behind the LBaaS?

No. Unfortunately that is currently not possible. The IP of the LBaaS will show up as the client IP.

### What features does the SysEleven Stack LBaaS offer?

The SysEleven Stack LBaaS is a TCP-based LoadBalancer. It supports round robin as balancing mechanism.
It also offers a simple HealthCheck.