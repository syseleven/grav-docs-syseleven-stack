---
title: 'Compute Service'
published: true
date: '08-08-2018 10:46'
taxonomy:
    category:
        - docs
    tag:
        - flavor
        - compute
        - nova
        - localstorage
        - ssdstorage
        - networkstorage
        - quobyte
---

## Übersicht

SysEleven Stacks Compute Service basiert auf dem OpenStack Nova Projekt.

Der Service verwaltet den Lebenszyklus einer Compute Instanz. Seine Zuständigkeit umfasst das erstellen, planen und  ausmustern von Compute Instanzen.

Sowohl via unserer öffentlichen [OpenStack API](../../03.Tutorials/04.api-access/default.en.md), als auch durch das [SysEleven Stack Dashboard](https://dashboard.cloud.syseleven.net) können Compute Instanzen verwaltet werden.

## Flavors

### Standard network storage instance types (M1)

Standard instances generally offer you good performance, availability and storage durability. Disk data will be distributed across multiple servers (SysEleven Distributed Storage).

We recommend these instance types for most workloads and applications.

Name        | API Name    | Memory | vCPUs | Storage* |
------------|-------------|--------|-------|----------|
M1 Micro    |  m1.micro   |  2GB   |   1   |   50GB   |
M1 Tiny     |  m1.tiny    |  4GB   |   1   |   50GB   |
M1 Small    |  m1.small   |  8GB   |   2   |   50GB   |
M1 Medium   |  m1.medium  | 16GB   |   4   |   50GB   |
M1 Large    |  m1.large   | 32GB   |   8   |   50GB   |

(*)
You can extend storage using our our Block Storage Service.

### Local SSD storage instance types (L1)

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

## Flavor change (resizing)

!!! After the initial resize request was placed, additional confirmation is required before the system will resize the instance when resizing via GUI/CLI.

### M1 flavors

It is possible to resize all M1 flavors since they have the same base storage.

### L1 flavors

Resizing local storage flavors is currently **not** possible.

### Flavor change to different storage type

! We do **not** recommend to change flavors to different storage types.
! If more resources are required for an instance the fastest solution is to build a new instance and migrate the required data (if any) via network or an attached volume.

#### M1 to L1 migration

Migrating M1 to L1 flavors is generally possible with the following exception:

M1 flavors **cannot** be migrated to the L1 flavor `l1.tiny` because the target disk (25GB) is smaller than the source disk (50GB).

#### L1 to M1 migration

It is currently **not** possible to migrate any L1 flavor to M1 flavors.