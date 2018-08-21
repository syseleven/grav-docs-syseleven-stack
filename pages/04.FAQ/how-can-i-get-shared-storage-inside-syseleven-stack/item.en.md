---
title: 'How can I get shared storage inside SysEleven Stack?'
published: true
date: '08-08-2018 12:51'
taxonomy:
    category:
        - FAQ
    tag:
        - OpenStack
        - storage
        - VolumeStorage
        - Volumes
        - SharedVolume
        - SharedStorage
---

There are multiple options, for instance:

 * S3 (SEOS) - provided as part of the SysEleven Stack
 * NFS, GlusterFS, Ceph - interim solution for legacy applications

For the NFS case, we provide a [shared volume](https://github.com/syseleven/heat-examples/tree/master/shared-volume) template with multiple automatically connecting NFS clients, which you can use with our orchestration service.