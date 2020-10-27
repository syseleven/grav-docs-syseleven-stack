---
title: 'How to repartition VM disk'
date: '21-10-2020 16:27'
taxonomy:
    category:
        - docs
---

## How to repartition VM disk

### Overview

This Document will show you the essential steps to repartition your VM disk. For this purpose we are using an Ubuntu 18.04 server as example with the `m1c.tiny` [flavor](../../04.Reference/03.compute/docs.en.md).


### Prerequisites

* You need to have the login data for the SysEleven Stack API (user name and passphrase)
* Knowledge how to utilise a terminal/SSH and SSH-keys.

### Start VM with custom user data

By default [cloudinit](https://cloudinit.readthedocs.io/en/latest/) will grow your VM image partition size to the complete size of the ephemeral disk (which is defined by the flavor you used for your VM). To avoid this behavior and use the spare space for a new partition we will use following snippet :

```shell
#cloud-config
growpart:
  mode: off
```

Using the OpenStack dashboard to start your VM you may provide this snippet in the `Customization Script` box located in the `Configuration` tab. If you prefer to use the CLI to bring up the VM, you can use the `--user-data` option to provide the cloud-config file containing the snippet.

### Check existing partitions

To be able to check the partitions we need to use ssh to connect to the VM. We further need to get root rights. Having done so, we can see the following :

```shell
$ root@partition-test:~# df -h
Filesystem      Size  Used Avail Use% Mounted on
udev            3.9G     0  3.9G   0% /dev
tmpfs           798M  648K  798M   1% /run
/dev/vda1       2.0G  1.1G  948M  53% /
tmpfs           3.9G     0  3.9G   0% /dev/shm
tmpfs           5.0M     0  5.0M   0% /run/lock
tmpfs           3.9G     0  3.9G   0% /sys/fs/cgroup
/dev/vda15      105M  3.6M  101M   4% /boot/efi
tmpfs           798M     0  798M   0% /run/user/1000

$ root@partition-test:~# parted /dev/vda --script "print free"
Warning: Not all of the space available to /dev/vda appears to be used, you can fix the GPT to use all of the space (an extra 100245504 blocks) or continue with the current setting?
Model: Virtio Block Device (virtblk)
Disk /dev/vda: 53.7GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags:

Number  Start   End     Size    File system  Name  Flags
        17.4kB  1049kB  1031kB  Free Space
14      1049kB  5243kB  4194kB                     bios_grub
15      5243kB  116MB   111MB   fat32              boot, esp
 1      116MB   2361MB  2245MB  ext4
        2361MB  53.7GB  51.3GB  Free Space

root@partition-test:~#
```

As we can see, our partitation /dev/vda1 did not grow and got the original size of the image itself. In consequence we have 51,3GB free space, which we may use for our new partition.

### Create new partition

In order to use the free space, we have to relocate the backup data structures to the end of the disk. We are using [gdisk](https://linux.die.net/man/8/gdisk) in expert mode to do so.

```shell
root@partition-test:~# gdisk
GPT fdisk (gdisk) version 1.0.3

Type device filename, or press <Enter> to exit: /dev/vda
Partition table scan:
  MBR: protective
  BSD: not present
  APM: not present
  GPT: present

Found valid GPT with protective MBR; using GPT.

Command (? for help): p
Disk /dev/vda: 104857600 sectors, 50.0 GiB
Sector size (logical/physical): 512/512 bytes
Disk identifier (GUID): C2EE45B5-56B2-4257-8BB5-E271FA3DD857
Partition table holds up to 128 entries
Main partition table begins at sector 2 and ends at sector 33
First usable sector is 34, last usable sector is 4612062
Partitions will be aligned on 2048-sector boundaries
Total free space is 2014 sectors (1007.0 KiB)

Number  Start (sector)    End (sector)  Size       Code  Name
   1          227328         4612062   2.1 GiB     8300
  14            2048           10239   4.0 MiB     EF02
  15           10240          227327   106.0 MiB   EF00

Command (? for help): x

Expert command (? for help): e
Relocating backup data structures to the end of the disk

Expert command (? for help): m

Command (? for help):
```

The next step is to create our new partition. We will use all the free space and create a new `/dev/vda2` partition.

```shell
Command (? for help): n
Partition number (2-128, default 2): 2
First sector (34-104857566, default = 4612096) or {+-}size{KMGTP}:
Last sector (4612096-104857566, default = 104857566) or {+-}size{KMGTP}:
Current type is 'Linux filesystem'
Hex code or GUID (L to show codes, Enter = 8300):
Changed type of partition to 'Linux filesystem'

Command (? for help): p
Disk /dev/vda: 104857600 sectors, 50.0 GiB
Sector size (logical/physical): 512/512 bytes
Disk identifier (GUID): C2EE45B5-56B2-4257-8BB5-E271FA3DD857
Partition table holds up to 128 entries
Main partition table begins at sector 2 and ends at sector 33
First usable sector is 34, last usable sector is 104857566
Partitions will be aligned on 2048-sector boundaries
Total free space is 2047 sectors (1023.5 KiB)

Number  Start (sector)    End (sector)  Size       Code  Name
   1          227328         4612062   2.1 GiB     8300
   2         4612096       104857566   47.8 GiB    8300  Linux filesystem
  14            2048           10239   4.0 MiB     EF02
  15           10240          227327   106.0 MiB   EF00

Command (? for help): w

Final checks complete. About to write GPT data. THIS WILL OVERWRITE EXISTING
PARTITIONS!!

Do you want to proceed? (Y/N): Y
OK; writing new GUID partition table (GPT) to /dev/vda.
Warning: The kernel is still using the old partition table.
The new table will be used at the next reboot or after you
run partprobe(8) or kpartx(8)
The operation has completed successfully.
```

To be able to see the new partition we need to reload the partition table.

```shell
root@partition-test:~# partprobe
root@partition-test:~# ls /dev | grep vda2
vda2
```

### Create filesystem on new partition

Now that we have our new partition, the next step is to create a filesystem on it. We will go with `ext4` in this example.

```shell
# Lets create an ext4 filesystem
root@partition-test:/home/ubuntu# mkfs.ext4 /dev/vda2
mke2fs 1.44.1 (24-Mar-2018)
Creating filesystem with 12530683 4k blocks and 3137536 inodes
Filesystem UUID: a6edfdf1-23dd-4b1d-af45-493a8d0fd986
Superblock backups stored on blocks:
 32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208,
 4096000, 7962624, 11239424

Allocating group tables: done
Writing inode tables: done
Creating journal (65536 blocks): done
Writing superblocks and filesystem accounting information:
done
```

The very last step is to mount the partition

```shell
root@partition-test:~# mount /dev/vda2 /mnt
root@partition-test:~# lsblk
NAME    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
vda     252:0    0   50G  0 disk
├─vda1  252:1    0  2.1G  0 part /
├─vda2  252:2    0 47.8G  0 part /mnt
├─vda14 252:14   0    4M  0 part
└─vda15 252:15   0  106M  0 part /boot/efi
```

If you want the mount to be persistent after a reboot you also have to adjust the fstab configuration file.

```shell
root@partition-test:~# blkid /dev/vda2
/dev/vda2: UUID="8b1aba77-feb7-4bdb-83e8-35879411059c" TYPE="ext4" PARTLABEL="Linux filesystem" PARTUUID="8adfef00-93d8-4b05-944e-cce09bb66f3a"

echo "UUID=8b1aba77-feb7-4bdb-83e8-35879411059c /mnt ext4 defaults 0 0" >> /etc/fstab
```

### Conclusion

We have started a VM using custom user data which prevents the growing of the VM root partition to the complete size of the ephemeral disk. Afterwards we have used the resulting free disk space to create a custom partition. In the end we have created a new ext4 filesystem on the new partition and mounted it so we can use it.
