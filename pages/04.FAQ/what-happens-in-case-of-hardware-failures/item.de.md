---
title: ' Was passiert im Fall einer Hardware-Störung?'
published: true
date: '08-08-2018 12:37'
taxonomy:
    category:
        - FAQ
    tag:
        - migration
        - OpenStack
        - localstorage
        - storage
        - SSD
        - hardware-failures
        - Hardware
---

Local SSD Storage Instanzen können nicht zwischen Hardware-Servern migriert werden. Das bedeutet, daß alle Instanzen eines betroffenen Servers ebenfalls von **unvermeidlichem Ausfall oder Datenverlust** betroffen sind.

Sie müssen darauf vorbereitet sein, eine Local SSD Storage Instanz durch eine neue zu ersetzen, deren Daten sie aus einem Backup oder den überlebenden Mitgliedern des Clusters wiederherstellen.