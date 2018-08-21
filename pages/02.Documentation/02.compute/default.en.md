---
title: 'Compute Service'
published: true
date: '21-08-2018 17:15'
taxonomy:
    category:
        - docu
    tag:
        - flavor
        - compute
        - nova
        - localstorage
        - ssdstorage
        - networkstorage
        - quobyte
---

## Overview

SysEleven Stacks Compute Service is built on the OpenStack Nova project.
It manages the life-cycle of compute instances in your environment. Its responsibilities include spawning, scheduling and decommissioning of virtual machines on demand.

You can manage your compute instance both via our public [OpenStack API](../../03.Tutorials/04.api-access/default.en.md) endpoints, as well as using the [Dashboard](https://dashboard.cloud.syseleven.net).

## Flavors

### Standard network storage instance types

Standard instances generally offer you good performance, availability and storage durability. Disk data will be distributed across multiple servers (SysEleven Distributed Storage).

We recommend these instance types for most workloads and applications.

Name        | API Name    | Memory | vCPUs | Storage* |
------------|-------------|--------|-------|----------|
M1 Micro    |  m1.micro   |  2GB   |   1   |   50GB   |
M1 Tiny     |  m1.tiny    |  4GB   |   1   |   50GB   |
M1 Small    |  m1.small   |  8GB   |   2   |   50GB   |
M1 Medium   |  m1.medium  | 16GB   |   4   |   50GB   |
M1 Large    |  m1.large   | 32GB   |   8   |   50GB   |

!!! **(*)**  
!!! You can extend storage using our our Block Storage Service.

### Local SSD storage instance types

Local SSD storage instances offer low latency SSD storage directly on the local host.
These can be useful for special workloads like replicated databases.

! Availability and data durability are reduced, because data is only stored locally on one server.

Name        | API Name    | Memory | vCPUs | Storage |
------------|-------------|--------|-------|---------|
L1 Tiny     | l1.tiny     |   4GB  |   1   |   25GB  |
L1 Small    | l1.small    |   8GB  |   2   |   50GB  |
L1 Medium   | l1.medium   |  16GB  |   4   |  100GB  |
L1 Large    | l1.large    |  32GB  |   8   |  200GB  |
L1 XLarge   | l1.xlarge   |  64GB  |  16   |  400GB  |
L1 2XLarge  | l1.2xlarge  | 128GB  |  32   |  800GB  |
L1 4XLarge  | l1.4xlarge  | 256GB  |  64   | 1600GB  |

For more information, see the FAQ articles on [local storage instances](https://docs.syseleven.de/helpcenter/en/taxonomy?name=tag&val=localstorage).

## Flavor resizing

!!! After the initial resize request was placed, additional confirmation is required before the system will resize the instance when resizing via GUI/CLI.

### M1 flavors

It is possible to resize all M1 flavors since they have the same base storage.

### L1 flavors

Resizing local storage flavors is currently **not** possible since the base storage differs in size.

## Flavor migration

### M1 to L1 migration

Migrating M1 to L1 flavors is generally possible with the following exception:

!! M1 flavors **cannot** be migrated to the L1 flavor `l1.tiny`
!! **Why?** The target disk (25GB) is smaller than the source disk (50GB).

### L1 to M1 migration

It is currently **not** possible to migrate any L1 flavor to M1 flavors.
This is a limitation caused by OpenStack in regards to LVM which is used for local storage.

If you require a resize the fastest solution is to build a new instance and migrate the required data (if any) via network.