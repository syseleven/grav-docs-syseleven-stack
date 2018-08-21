---
title: 'How is maintenance carried out for local SSD storage nodes?'
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

Affected instances will receive an ACPI shutdown event that gives the operating system one minute grace period to shut down orderly. After the maintenance it will we brought up again. Expect up to half an hour (30min) of downtime. There will be **no further annoucement** aside from the ACPI shutdown event.