---
title: 'What happens in case of hardware failures?'
published: true
date: '08-08-2018 12:37'
taxonomy:
    category:
        - FAQ
    tag:
        - OpenStack
        - localstorage
        - storage
        - SSD
        - migration
        - hardware-failures
        - Hardware
---

Local SSD storage instances cannot be moved between hypervisors. That means in case of a hardware failure, **data loss is inevitable**.

You need to replace them with a new system from scratch and data restored from one of your backups or surviving members of the cluster.