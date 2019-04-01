---
title: 'Manual data recovery'
published: true
date: '08-08-2018 10:17'
taxonomy:
    category:
        - docs
---

## Goal

* Downloading a snapshot of an instance
* Repairing the filesystem and mount it to extract data

## Prerequisites

* You should be able to use simple heat templates, like shown in the [first steps tutorial](../../02.Tutorials/01.firststeps/docs.en.md).
* You know the basics of using the [OpenStack CLI-Tools](../../03.Howtos/02.openstack-cli/docs.en.md).
* Environment variables are set, like shown in the [API-Access-Tutorial](../../02.Tutorials/02.api-access/docs.en.md).

## Optional: temporary work environment

<details/>
<summary>Click here to show details</summary>

### Temporary work environment

For this tutorial, we need a *Linux* environment and the OpenStack client. If you do not have that yet, you can create it with the following commands:

```shell
wget https://raw.githubusercontent.com/syseleven/heat-examples/master/kickstart/kickstart.yaml
...
openstack stack create -t kickstart.yaml --parameter key_name=<ssh key name> <stack name> --wait
...
```

Now we need to connect to the created instance.

```shell
ssh syseleven@<server-ip>
```

The following commands need to be executed in the ssh session.

We also need the OpenStack credentials (openrc-file).
You can download the file [here](https://dashboard.cloud.syseleven.net/horizon/project/access_and_security/api_access/openrc/).

```shell
source openrc
```

</details>

## Create a snapshot

To recover data from an existing instance, we have to create a snapshot first.

Attention: The server will be unavailable for a few minutes.

```shell
openstack server image create <server uuid> --name <snapshot name> --wait
```

We can download the snapshot now. This can take a while.

```shell
openstack image save --file snapshot.qcow2 <snapshot name>
```

We can access the snapshot's contents via nbd.

```shell
sudo apt-get install -y qemu-utils
sudo modprobe nbd
sudo qemu-nbd --connect /dev/nbd0 snapshot.qcow2
```

Let's list the partitions.

```shell
$ sudo fdisk -l /dev/nbd0
Disk /dev/nbd0: 50 GiB, 53687091200 bytes, 104857600 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x974bb19a

Device      Boot Start       End   Sectors Size Id Type
/dev/nbd0p1 *     2048 104857566 104855519  50G 83 Linux
```

To repair the filesystem, use fsck.

```shell
# Using the option -y, fsck will repair without asking.
sudo fsck -f /dev/nbd0p1
[...]
```

Now we can mount the filesystem.

```shell
sudo mount /dev/nbd0p1 /mnt/
```

# Conclusion

Now the data is accessible on `/mnt/`.  
If it's an ext filesystem you should have a look in `/mnt/lost+found`.