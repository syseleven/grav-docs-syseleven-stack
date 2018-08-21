---
title: 'Can I use a block storage volume across multiple VMs simultaneously?'
published: true
date: '08-08-2018 12:48'
taxonomy:
    category:
        - FAQ
    tag:
        - OpenStack
        - storage
        - flavor
        - VolumeStorage
        - Volumes
        - SharedVolume
        - SharedStorage
---

Unfortunately this is not possible. Think of a block storage volume like a virtual hard disk - just as you cannot connect a hard disk to multiple computers at the same time, you cannnot connect a block storage volume to multiple compute instances at the same time.