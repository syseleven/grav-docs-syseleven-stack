---
title: 'What is the difference between local ssd storage and distributed storage?'
published: true
date: '08-08-2018 12:53'
taxonomy:
    category:
        - FAQ
    tag:
        - OpenStack
        - localstorage
        - storage
        - SSD
        - DistributedStorage
---

SysEleven Stack distributed storage distributes several copies of segments of your data over many physical ssd devices attached to different physical compute nodes connected via network. This allows for high overall performance, because several devices can work simultaneously, but introduces a latency for single operations, because data has to be transmitted via network.

SysEleven Stack local ssd storage stores your data on a local raid mirrored ssd storage directly attached to the compute node. This reduces the latency, because no network is involved, but also redundancy, because only two devices and one compute node are involved.