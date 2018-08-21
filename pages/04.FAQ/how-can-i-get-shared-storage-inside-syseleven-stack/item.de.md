---
title: 'Wie kann ich also shared Storage innerhalb eines Stacks bereitstellen? '
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

Grundsätzlich gibt es mehrere Möglichkeiten, u.a.: 

* S3 (SEOS) - als Bestandteil des SysEleven Stacks bereitgestellt
* NFS, GlusterFS, Ceph - Übergangslösung für ältere Anwendungen

Wir haben [ein Beispiel](https://github.com/syseleven/heat-examples/tree/master/shared-volume) für einen NFS-Server mit mehreren NFS-Clients, die sich automatisch mit diesem verbinden, welcher mit unserem Orchestration Service verwendet werden kann.