---
title: 'Why are instances disconnected while migrating?'
published: true
date: '02-08-2018 16:59'
taxonomy:
    category:
        - FAQ
    tag:
        - migration
        - OpenStack
        - Network
---

To transfer the active state of instances (incl. RAM/Memory) they need to be 'frozen' prior to the migration. During the transfer network packets can get lost. 

It depends on the operating system and application that is being used if connection can be reestablished.