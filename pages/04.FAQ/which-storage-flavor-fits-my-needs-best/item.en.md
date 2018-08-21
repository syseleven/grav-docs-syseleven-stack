---
title: 'Which storage flavor fits my needs best?'
published: true
date: '08-08-2018 12:55'
taxonomy:
    category:
        - FAQ
    tag:
        - OpenStack
        - localstorage
        - storage
        - SSD
        - DistributedStorage
        - VolumeStorage
        - flavor
---

In general, workloads where large volumes of data are transmitted or many small chunks of data are handled in parallel benefit from the overall performance of distributed storage and of course the redundancy and availability whereas workloads with tiny requests that need to be executed serially benefits from the lower latency of local ssd storage.