---
title: 'I cannot delete my stack anymore – What can I do now?'
published: true
date: '08-08-2018 13:08'
taxonomy:
    category:
        - FAQ
    tag:
        - OpenStack
        - Stack
        - Heat
        - Delete
        - Dependencies
---

A heat stack follows a chain of dependencies on creation, to bring a certain order into the creation of objects. It will also respect this order on removing the stack. By specifying specific dependencies you can work around the failure. If you forgot to specify dependencies, deletion often fails with an error message similar to this one:

```
Resource DELETE failed: Conflict: resources.router_subnet_connect: Router interface for subnet eaa5a91f-3f45-43cf-8714-95118aabc64c on router 487a984c-692c-4d45-80d2-2e0ee92b505d cannot be deleted, as it is required by one or more floating IPs. 
```

In this case a clean solution is to delete the dependencies by hand - for example first delete the floating IP that is attached to the router, then delete the router and then the whole stack. Oftentimes you can also just call ``heat stack-delete <stackName>`` multiple times.
Again, by specifying ``depends_on: <myOtherResourceID>`` you can avoid this class of problem entirely.