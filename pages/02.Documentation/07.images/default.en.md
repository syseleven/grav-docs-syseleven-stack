---
title: Images
published: true
date: '08-08-2018 11:06'
taxonomy:
    category:
        - docu
---

## Overview

SysEleven provides and maintains a set of images in the SysEleven Stack.  
The SysEleven Stack also offers the possibility to upload custom images.

You can view and manage images both via the OpenStack API, as well as using the [Dashboard (GUI)](https://dashboard.cloud.syseleven.net).

## Provided Images

Images with the description **sys11 optimized** are built, optimized, tested and fully supported by SysEleven.  
Standard cloud images from their original source are supported with best effort only.

Distro           | Name                             | Description                               | Supported   |
-----------------|----------------------------------|-------------------------------------------|-------------|
Ubuntu 18.04 LTS | Ubuntu 18.04 LTS                 | Unmodified, directly from Canonical       | best-effort |
Ubuntu 18.04 LTS | Ubuntu 18.04 LTS sys11 optimized | Modified, optimized for SysEleven Stack   | yes         |
Ubuntu 16.04 LTS | Ubuntu 16.04 LTS                 | Unmodified, directly from Canonical       | best-effort |
Ubuntu 16.04 LTS | Ubuntu 16.04 LTS sys11 optimized | Modified, optimized for SysEleven Stack   | yes         |
Ubuntu 14.04 LTS | Ubuntu 14.04 LTS                 | Unmodified, directly from Canonical       | best-effort |
Ubuntu 14.04 LTS | Ubuntu 14.04 LTS sys11 optimized | Modified, optimized for SysEleven Stack   | yes         |
CentOS 7         | CentOS 7                         | Unmodified, directly from CentOS sources. | best-effort |
Debian 9         | Debian 9                         | Unmodified, directly from Debian sources. | best-effort |
Ubuntu 16.04 LTS | Rescue Ubuntu 16.04 sys11        | Modified, optimized for SysEleven Stack   | yes         |
Ubuntu 18.04 LTS | Rescue Ubuntu 18.04 sys11        | Modified, optimized for SysEleven Stack   | yes         |

## Distros

### Recommendation

SysEleven currently recommends to run **Ubuntu 18.04 LTS sys11 optimized** in the SysEleven Stack.

### Other distros

Basically it is possible to run any kind of operating system within the SysEleven Stack as long as it supports running in [KVM](https://www.linux-kvm.org/page/Main_Page).

Though Windows can be hosted in the SysEleven Stack we do not provide support for instances running Windows.

The following distros are reported to be working in SysEleven Stack:

* Debian
* CentOS
* CoreOS

## Uploading custom images

[This tutorial](../../03.Tutorials/10.upload-custom-images/default.en.md) shows how to upload custom images.