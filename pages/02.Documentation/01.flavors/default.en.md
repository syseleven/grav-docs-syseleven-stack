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

Name      | API Name    | Memory | VCPUs | Storage* | Network Performance
----------|-------------|--------|-------|----------|--------------------
M1 Micro  |  m1.micro   |  2GB   |   1   |   50GB   | basic
M1 Tiny   |  m1.tiny    |  4GB   |   1   |   50GB   | basic
M1 Small  |  m1.small   |  8GB   |   2   |   50GB   | basic
M1 Medium |  m1.medium  |  16GB  |   4   |   50GB   | intermediate
M1 Large  |  m1.large   |  32GB  |   8   |   50GB   | high


Note: You can extend storage using our our Block Storage Service.

## Local SSD storage instance types

Local SSD storage instances offer low latency SSD storage directly on the local host.

These can be useful for special workloads like replicated databases.

**Warning: Availability and data durability are reduced, because data is only stored locally on one server.**


Name        | API Name    | VCPUs | Memory | Storage
------------|-------------|-------|--------|----------
L1 Tiny     | l1.tiny     |   1   |  4GB   |   25GB
L1 Small    | l1.small    |   2   |  8GB   |   50GB
L1 Medium   | l1.medium   |   4   |  16GB  |  100GB
L1 Large    | l1.large    |   8   |  32GB  |  200GB
L1 XLarge   | l1.xlarge   |  16   |  64GB  |  400GB
L1 2XLarge  | l1.2xlarge  |  32   | 128GB  |  800GB
L1 4XLarge  | l1.4xlarge  |  64   | 256GB  | 1600GB

For more information, see the FAQ articles on [local storage instances](../../../faq/en/taxonomy?name=tag&val=localstorage).