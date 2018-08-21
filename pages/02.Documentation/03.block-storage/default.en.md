---
title: 'Block Storage'
published: true
date: '08-08-2018 10:40'
taxonomy:
    category:
        - docu
---

## Overview

SysEleven Stack Block Storage Service is built on the OpenStack Cinder project.

The Block Storage Service adds persistent block storage to your compute instances.

You can manage your block storage volumes and make them available to your compute instances both via our public OpenStack API endpoints, as well as using the [Dashboard](https://dashboard.cloud.syseleven.net).

You can also create snapshots from your block storages volumes, which you can use as a boot image or as a template for the creation of other block storage volumes.

### Optimal storage alignment

The alignment within images that SysEleven distributes is already configured optimally.

To boost the performance of the virtual volumes the following settings are advisable:

```shell
mkfs.ext4 -q -L myVolumeLabel -E stride=2048,stripe_width=10240
```