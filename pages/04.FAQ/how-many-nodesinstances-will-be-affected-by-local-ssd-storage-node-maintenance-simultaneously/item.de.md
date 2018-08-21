---
title: 'Wieviele Instancen sind gleichzeitig von Hardware-Wartungen der local SSD storage nodes betroffen?'
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

Geplante Hardware-Wartungen betreffen immer nur einen Hardware-Server zu einer Zeit und zwischen zwei Hardware-Wartungen wird eine halbe Stunde gewartet, damit die betroffenen Instanzen sich wieder in ihren Cluster oder Wasauchimmer integrieren können. Es werden jedoch alle Local SSD Storage Instanzen auf der selben Serverhardware gleichzeitig vom Ausfall betroffen sein. Damit redundante System nicht gleichzeitig ausfallen, müssen sie diese unbedingt in eine [anti-affinity-groups](/../../../syseleven-stack/tutorials/affinity/) aufnehmen.