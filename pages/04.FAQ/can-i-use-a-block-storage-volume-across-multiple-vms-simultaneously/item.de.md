---
title: 'Ist es möglich ein Cinder Volume auf mehreren VMs gleichzeitig zu verwenden? '
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

Nein, das geht aus technischen Gründen nicht. Ein Cinder Gerät ist ein virtuelles Block Gerät und kann daher nicht gleichzeitig auf mehreren VMs verwendet werden.  