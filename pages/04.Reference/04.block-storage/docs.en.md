---
title: 'Block Storage'
published: true
date: '04-29-2020 10:40'
taxonomy:
    category:
        - docs
---

## Overview

SysEleven Stack Block Storage Service is built on the OpenStack Cinder project.

With the Block Storage Service it is possible to add additional persistent block storage to your compute instances.

You can manage your block storage volumes and make them available to your compute instances both via our public OpenStack API endpoints, as well as using the [Dashboard](https://dashboard.cloud.syseleven.net) and the [OpenStack CLI](../../02.Tutorials/02.api-access/docs.en.md).

## Available volume types

| Volume type                             |   CBK region   |   DBL region
| ----------------------------------------|----------------|-------------
| quobyte                                 | yes (default)  | yes (default)
| quobyte-multiattach                     | yes            | yes

### quobyte

The data will be stored on SSDs in the SysEleven Stack distributed storage cluster based on Quobyte. The data will be replicated and stored on three different storage nodes and SSDs.

The volumes can only be attached to a single virtual machine at a time.

### quobyte-multiattach

This volume type is the same as the `quobyte` volume type, except that the volumes can be attached to multiple VMs at the same time.

The performance of `quobyte-multiattach` is slightly reduced because some caching strategies are not possible with multi-attach volumes. There is also a performance penalty using ocfs2 (or any other cluster file system, like gfs2) compared to ext4, because the file system must coordinate with the other nodes over the network.

Please refer to our multi-attach volume tutorial. It explains [how to use multi-attach volumes with the cluster file system ocfs2](../../02.Tutorials/10.cinder-multiattach/docs.en.md).

!! WARNING: This mode of operation requires special cluster file systems like ocfs2 or gfs2. Otherwise it can lead to the loss of data and / or file system and data corruption.

## Available functionality

| OpenStack Cinder Feature                |   CBK region   |   DBL region
| ----------------------------------------|----------------|-------------
| Block storage volumes                   | yes | yes
| Volume transfer                         | yes | yes
| Volume snapshots                        | yes (offline*) | yes (offline*)
| Save volume as glance image             | yes (offline*) | yes (offline*)
| Multi-attach volumes                    | yes | yes
| Volume resizing                         | yes (offline*) | yes (offline*)
| Volume backups                          | no | no

* offline means, that this functionality is only supported for volumes that are not attached to a virtual machine.

### Block storage volumes

The OpenStack Cinder service allows end users to manage virtual block storage
devices. Via a self service API it provides the functionality to create volumes
for persistent storage and attach them to virtual machines.
A volume can be moved from one VM to another by detaching it and re-attaching
it somewhere else. Also you may delete or rebuild a VM without losing its data
that is kept on a Cinder volume.

Inside the virtual machine the volume will be available as a block device (e.g. on Linux operating systems as `/dev/vdX`). It might be necessary to format the device with the file system of your choice.

### Volume transfer

Volume transfers allow you to transfer ownership of a volume to a different [OpenStack project](../01.identity-and-access/docs.en.md).

The transfer can be initiated in one project using `openstack volume transfer request create`, and then completed using `openstack volume transfer request accept`.

### Volume snapshots

A snapshot saves a point-in-time copy of a block storage volume.

```shell
openstack volume snapshot create --volume volume_name_or_id snapshot_name
```

Snapshots can only be created while the volume is detached. The option `--force` to create a snapshot from an attached volume is currently not supported and may lead to a snapshot in ERROR state.

You may use the snapshot as a source when creating a new volume:

```shell
openstack volume create --snapshot snapshot_id name_of_new_volume
```

### Save volume as glance image

It is possible to copy the contents of a cinder volume to the [glance image store](../06.images/docs.en.md), e.g. using the [OpenStack CLI](../../02.Tutorials/02.api-access/docs.en.md):

```shell
openstack image create --volume volume_name_or_id name_of_new_image
```

The cinder volume must be detached for the operation to succeed.

### Multi-attach volumes

When you create a volume with a multi-attach volume type (See <a href="#available-volume-types">available volume types</a>), it is possible to attach it to multiple virtual machines at the same time.

This is useful, for example, to make app servers more scalable or to reduce single points of failure: If your application relies on a file system to store information, for example pictures, you can use multi-attach volumes to share the file system across a number of app servers, without the need for network storage solutions like NFS.

Please refer to our multi-attach volume tutorial. It explains [how to use multi-attach volumes with the cluster file system ocfs2](../../02.Tutorials/10.cinder-multiattach/docs.en.md).

!! WARNING: This mode of operation requires special cluster file systems like ocfs2 or gfs2. Otherwise it can lead to the loss of data and / or file system and data corruption.

### Volume resizing

Sometimes it is necessary to change the size of your volume.

Cinder volumes can be extended in size using the API or the OpenStack CLI:

```shell
openstack volume set --size XX volume_name_or_id
```

Following the volume size change it might be necessary to grow the filesystem. If you are using ext4 you may need to run this command on the VM where the volume is attached:

```shell
resize2fs /dev/vdX
```

### Current limitations

* Online resizing is not supported. A volume must be detached, before it can be resized.
* Shrinking volumes is not supported. If you need to reduce the size of your volume, create a new one and copy the data.
