---
title: 'How to Migrate From Quobyte to Ceph Storage'
date: '28-11-2024 02:48'
taxonomy:
    category:
        - docs
---

## Overview

In this guide we will provide a way to migrate your VMs with ephemeral storage, block storage, and object storage.

## Compute Workloads (VM flavor and ephemeral storage)

Migrating a VM from Quobyte to Ceph storage means moving from *m1* to *m2* flavor. To do that, you need to create an image of the VM with ephemeral storage and then create a new VM based on the that image.

!! WARNING: Creating instance image of your server will make it unresponsive for a period of time (depending on the disk size).

Create an image:

```shell
openstack server image create <server> --name <target-image-name>
```

Wait until the image reaches an active state:

```shell
openstack image show <target-image> -c status
```

Create a new VM with an *m2* flavor based on the created image:

```shell
openstack server create <server-name> --image <image> --flavor m2.<size>
```

If the old and new VMs are not in the same region, you will need to download the created image and upload it to the new region:

```shell
openstack --os-region <source-region> image save <image> --file <filename>
openstack --os-region <target-region> image create <image-name> --file <filename>

```


## Block Storage Volumes

Block storage volumes can also be migrated by creating an image of the existing one and then creating a new volume based on that image.

!! WARNING: Volume snapshots can only be created while the volume is detached.

Create an image:

```shell
openstack image create <target-image-name> --volume <volume>

```

Wait until the image reaches an active state:

```shell
openstack image show <target-image> -c status

```

Create a new volume based on the created image and make sure you specify the volume type as `ceph`:

```shell
openstack volume create <name> --image <image> --type ceph --size <size>
```

If the old and new volumes are not in the same region, you will need to download the created image and upload it to the new region:

```shell
openstack --os-region <source-region> image save <image> --file <filename>
openstack --os-region <target-region> image create <image-name> --file <filename>

```


## Object Storage

For Quobyte-based object storage (s3.*REGION*.cloud.syseleven.net) and ceph-based (objectstorage.fes.cloud.syseleven.net) the same access/secret key pair can be used.

There are no special tools available to move/copy buckets or partial content internally between two object storage clusters. You will need to download the content and upload it again with your choice of tools.
