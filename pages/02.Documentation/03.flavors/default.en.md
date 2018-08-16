---
title: Flavors
published: true
date: '02-08-2018 17:15'
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

## Standard network storage instance types

Standard instances generally offer you good performance, availability and storage durability. Disk data will be distributed across multiple servers (SysEleven Distributed Storage).

We recommend these instance types for most workloads and applications.

Name        | API Name    | Memory | vCPUs | Storage* |
------------|-------------|--------|-------|----------|
M1 Micro    |  m1.micro   |  2GB   |   1   |   50GB   |
M1 Tiny     |  m1.tiny    |  4GB   |   1   |   50GB   |
M1 Small    |  m1.small   |  8GB   |   2   |   50GB   |
M1 Medium   |  m1.medium  | 16GB   |   4   |   50GB   |
M1 Large    |  m1.large   | 32GB   |   8   |   50GB   |

(*) Note: You can extend storage using our our Block Storage Service.

## Local SSD storage instance types

Local SSD storage instances offer low latency SSD storage directly on the local host.

These can be useful for special workloads like replicated databases.

**Warning: Availability and data durability are reduced, because data is only stored locally on one server.**


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
