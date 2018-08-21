---
title: 'Wie läuft eine Hardware-Wartung für local SSD storage nodes ab?'
published: true
date: '08-08-2018 12:42'
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
        - Maintenance-Window
---

Betroffene Instanzen erhalten zunächst ein ACPI Shutdown Signal und eine Frist von einer Minute, um sich ordentlich herunterzufahren. Rechnen sie mit bis zu einer halben Stunde Ausfallzeit, bevor die Instanzen wieder hochgefahren werden. Es sind neben dem ACPI Shutdown Event **keine weiteren Ankündigungen** vorgesehen.