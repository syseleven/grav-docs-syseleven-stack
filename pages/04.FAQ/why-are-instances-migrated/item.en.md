---
title: 'Why are instances migrated?'
published: true
taxonomy:
    category:
        - FAQ
    tag:
        - migration
        - instances
        - OpenStack
---

**Software Updates**

SysEleven regularly updates the software on the hypervisor host machines.
To apply certain updates a reboot is required and running instances are therefore moved to another 
hypervisor host. 

**Hardware Maintenance**

All hardware nodes require maintenance at some point. Sometimes the required maintenance work cannot be done
while the machine is online. Therefore instances are moved to another hardware node prior to the planned maintenance work.

**Hardware failure**

Unfortunately life migrations are not possible in case of a hardware failure, therefor running instances will be automatically restarted on another hardware node. Stopped instances will be moved but remain in their stopped state.