---
title: 'Local SSD Storage'
published: true
date: '08-08-2018 10:50'
taxonomy:
    category:
        - docs
---

## Overview

SysEleven Stack offers two flavors of ephemeral storage. The default storage type is a distributed storage based on Quobyte. It offers high performance, redundancy and scalability at the cost of latency. For some application workloads, where latency is a bottleneck, we offer local SSD storage.

---

## Questions & Answers

### Where can I find a list of all the local SSD storage instance types?

We provide a [tabular overview of our flavor types](../../04.Reference/03.compute/docs.en.md).

### How do I use local SSD storage?

For a quick start to evaluate or just play with local SSD storage, please see our [Tutorials](../../02.Tutorials/08.local-storage/docs.en.md).

### When should I better not use local SSD storage?

Traditional single server setups often suffer from performance penalty when run on distributed storage. While it may be tempting to build them on local storage to gain speed, we discourage to use it this way because of the lower redundancy and availability. To put it into simple words, you put your service and your data at risk, when running a single server setup on local storage.

### What can I do to make my setup suitable for local SSD storage?

Depending on your application, there are many proven ways to design either your setup or your application in a way that provides for the missing redundancy. Application servers can be multiplied and put behind a loadbalancer, databases can be set up in replication topologies or clusters. We try to provide some inspiration among our [heat templates](https://github.com/syseleven/heat-examples), please contact us if you need further assistance.

### Can I use local SSD storage for volumes?

No, local SSD storage is only available as ephemeral storage.

### Can I combine local SSD storage with distributed storage?

Yes. You can attach volumes with distributed storage to your instances and this can be very handy to seed them with data or create backups, where latency isn't such an issue as with the running service.

### Can I replace local SSD storage with a volume?

Yes, but this rarely makes sense as it isn't a local volume instance anymore. It may make sense in certain cases to setup or repair things, see our [rescue tutorial](../../03.Howtos/05.nova-rescue-mode/docs.en.md).

### Can I use local SSD storage in other sizes?

Local SSD storage is exclusively available in the sizes defined in our [flavors](../../04.Reference/03.compute/docs.en.md).

### Can I resize local SSD storage instances?

No, local storage instances cannot be resized, you have to recreate them with a different size and migrate your data.
You can, however, attach a volume, move your data onto it, then detach it and attach it to another system where you move your data to the local SSD storage.
Depending on your application, there are likely smarter ways to bring new nodes into the cluster and seed them, e.g. promoting a replication slave.

### What happens in case of hardware failures?

Local SSD storage instances cannot be moved between hypervisors. That means in case of a hardware failure, **data loss is inevitable**.
You need to replace them with a new system from scratch and data restored from one of your backups or surviving members of the cluster.

### What about hardware maintenance?

Local SSD storage instances cannot be (live) migrated, we need to regularly reboot our compute nodes for maintenance and this **inevitably affects all virtual machines with local storage** hosted on them.

### When is the local SSD storage node maintenance window?

To keep the impact predictable, we hereby announce a regular

!! maintenance window:
!! Every week in the night from Wednesday, 11pm (23h) to Thursday, 4am,

we will restart about 25% of our local SSD storage compute nodes.
Statistically, every instance **will be shut down once a month.**

### How is maintenance carried out for local SSD storage nodes?

Affected instances will receive an ACPI shutdown event that gives the operating system one minute grace period to shut down orderly. After the maintenance it will we brought up again. Expect up to half an hour (30min) of downtime. There will be **no further announcement** aside from the ACPI shutdown event.

### How many nodes/instances will be affected by local SSD storage node maintenance simultaneously?

Planned maintenances will only affect one compute node at a time and between two maintenances there will be half an hour of recreation to allow the affected systems to re-join their clusters or whatever. It will, however, affect all local SSD storage instances on the same compute node. To ensure, that redundant systems will not be affected simultaneously, you must put them into [anti-affinity-groups](../../02.Tutorials/07.affinity/docs.en.md).
