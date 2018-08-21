---
title: 'Can I resize local SSD storage instances?'
published: true
date: '08-08-2018 12:35'
taxonomy:
    category:
        - FAQ
    tag:
        - migration
        - OpenStack
        - flavor
        - localstorage
        - storage
        - SSD
        - Size
        - Resize
---

No, local storage instances cannot be resized, you have to recreate them with a different size and migrate your data.

You can, however, attach a volume, move your data onto it, then detach it and attach it to another system where you move your data to the local SSD storage.

Depending on your application, there are likely smarter ways to bring new nodes into the cluster and seed them, e.g. promoting a replication slave.