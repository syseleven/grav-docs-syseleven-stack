---
title: Images
published: true
date: '20-08-2018 10:05'
taxonomy:
    category:
        - docs
---

## Overview

SysEleven provides and maintains a set of images in the SysEleven Stack.
The SysEleven Stack also offers the possibility to upload custom images.

You can view and manage images both via the OpenStack API, as well as using the [Dashboard (GUI)](https://dashboard.cloud.syseleven.net).

## Available Images

### SysEleven Images

Images with the description **sys11 optimized** are built, optimized, tested and supported by SysEleven.
Apart from building images from scratch SysEleven adjusts the file system alignment to work best with the underlying storage system.

#### Pre-installed packages in SysEleven images

```bash
# All images
cloud-init openssh-server python vim rng-tools wget curl cron psmisc man-db
logrotate apt-transport-https software-properties-common language-pack-de xz-utils

# Ubuntu 18.04 LTS only
netplan.io gnupg2
```

### Standard Images

Additionally to the self-bild images we also provide standard images from their original sources.
Standard cloud images are supported with best effort.

### Image overview

Distro           | Name                             | Description                               |
-----------------|----------------------------------|-------------------------------------------|
Ubuntu 18.04 LTS | Ubuntu 18.04 LTS                 | Unmodified, directly from Canonical       |
Ubuntu 18.04 LTS | Ubuntu 18.04 LTS sys11 optimized | Modified, optimized for SysEleven Stack   |
Ubuntu 16.04 LTS | Ubuntu 16.04 LTS                 | Unmodified, directly from Canonical       |
Ubuntu 16.04 LTS | Ubuntu 16.04 LTS sys11 optimized | Modified, optimized for SysEleven Stack   |
Ubuntu 14.04 LTS | Ubuntu 14.04 LTS                 | Unmodified, directly from Canonical       |
Ubuntu 14.04 LTS | Ubuntu 14.04 LTS sys11 optimized | Modified, optimized for SysEleven Stack   |
Ubuntu 16.04 LTS | Rescue Ubuntu 16.04 sys11        | Modified, optimized for SysEleven Stack   |
Ubuntu 18.04 LTS | Rescue Ubuntu 18.04 sys11        | Modified, optimized for SysEleven Stack   |

## Distros

SysEleven currently recommends to use the **Ubuntu 18.04 LTS sys11 optimized** image in the SysEleven Stack.

Basically it is possible to run any kind of operating system within the SysEleven Stack as long as it supports running in [KVM](https://www.linux-kvm.org/page/Main_Page).
Though Windows can be hosted in the SysEleven Stack we do not provide support for instances running Windows.

The following distros are reported to be working in SysEleven Stack:

* Debian
* CentOS
* CoreOS

## Uploading images

### Image sources

This table shows sources for commonly used images suitable for OpenStack.

Distro                    | URL |
--------------------------|-----|
Ubuntu 18.04 LTS (Bionic) | `http://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img` |
Ubuntu 16.04 LTS (Xenial) | `http://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-disk1.img` |
Ubuntu 14.04 LTS (Trusty) | `http://cloud-images.ubuntu.com/trusty/current/trusty-server-cloudimg-amd64-disk1.img` |
Debian 9 (Stretch)        | `https://cdimage.debian.org/cdimage/openstack/current-9/debian-9-openstack-amd64.qcow2` |
CentOS 7                  | `https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2` |
CoreOS                    | `https://stable.release.core-os.net/amd64-usr/current/coreos_production_openstack_image.img.bz2` |

!!! The CoreOS image has to be decompressed before it can be imported
!!! `bunzip2 coreos_production_openstack_image.img.bz2`

### How to upload images?

[This tutorial](../../03.Howtos/upload-images/docs.en.md) shows how to upload images via CLI and GUI.

