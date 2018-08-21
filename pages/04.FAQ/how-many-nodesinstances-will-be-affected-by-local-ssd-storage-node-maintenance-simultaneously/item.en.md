---
title: 'How many nodes/instances will be affected by local SSD storage node maintenance simultaneously?'
published: true
date: '08-08-2018 12:43'
taxonomy:
    category:
        - FAQ
    tag:
        - migration
        - OpenStack
        - localstorage
        - storage
        - SSD
        - Hardware
        - Maintenance
        - Availability
---

Planned maintenances will only affect one compute node at a time and between two maintenances there will be half an hour of recreation to allow the affected systems to re-join their clusters or whatever. It will, however, affect all local ssd storage instances on the same compute node. To ensure, that redundant systems will not be affected simultaneously, you must put them into [anti-affinity-groups](/../../../syseleven-stack/tutorials/affinity/).