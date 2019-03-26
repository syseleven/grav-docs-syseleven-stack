---
title: 'Compute Service'
published: true
date: '23-10-2018 13:45'
taxonomy:
    category:
        - docs
---

## Overview

SysEleven Stacks Compute Service is built on the OpenStack Nova project.
It manages the life-cycle of compute instances in your environment. Its responsibilities include spawning, scheduling and decommissioning of virtual machines on demand.

You can manage your compute instance both via our public [OpenStack API](../../02.Tutorials/03.api-access/docs.en.md) endpoints, as well as using the [Dashboard](https://dashboard.cloud.syseleven.net).


## Flavors

### Standard instance types (M1)

Standard instances generally offer you good performance, availability and storage durability.
Disk data will be distributed across multiple servers (SysEleven Distributed Storage).

We recommend these instance types for most workloads and applications.

Name        | API Name    | Memory | vCPUs | Storage* |
------------|-------------|--------|-------|----------|
M1 Micro    |  m1.micro   |  2GB   |   1   |   50GB   |
M1 Tiny     |  m1.tiny    |  4GB   |   1   |   50GB   |
M1 Small    |  m1.small   |  8GB   |   2   |   50GB   |
M1 Medium   |  m1.medium  | 16GB   |   4   |   50GB   |
M1 Large    |  m1.large   | 32GB   |   8   |   50GB   |

(*)
You can extend ephemeral storage using our durable [Block Storage Service](../03.block-storage/docs.en.md).

### Local SSD storage instance types (L1)

Local SSD storage instances offer low latency SSD storage directly on the local host.
These can be useful for special workloads like replicated databases.

! Availability and data durability are [**reduced**](../05.Background/local-storage/docs.en.md#what-happens-in-case-of-hardware-failures), because data is only stored locally on one server.

For more information, see the [local storage documentation](../05.Background/local-storage/docs.en.md).

Name        | API Name    | Memory | vCPUs | Storage* |
------------|-------------|--------|-------|----------|
L1 Tiny     | l1.tiny     |   4GB  |   1   |   25GB   |
L1 Small    | l1.small    |   8GB  |   2   |   50GB   |
L1 Medium   | l1.medium   |  16GB  |   4   |  100GB   |
L1 Large    | l1.large    |  32GB  |   8   |  200GB   |
L1 XLarge   | l1.xlarge   |  64GB  |  16   |  400GB   |
L1 2XLarge  | l1.2xlarge  | 128GB  |  32   |  800GB   |
L1 4XLarge  | l1.4xlarge  | 256GB  |  64   | 1600GB   |

(*)
You can extend local ephemeral storage using our distributed [Block Storage Service](../03.block-storage/docs.en.md),
[to place less latency critical data on it](../05.Background/local-storage/docs.en.md#can-i-combine-local-ssd-storage-with-distributed-storage).


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

---

## Questions & Answers

### What is the difference between local ssd storage and distributed storage?

SysEleven Stack distributed storage distributes several copies of segments of your data over many physical ssd devices attached to different physical compute nodes connected via network. This allows for high overall performance, because several devices can work simultaneously, but introduces a latency for single operations, because data has to be transmitted via network.

SysEleven Stack local ssd storage stores your data on a local raid mirrored ssd storage directly attached to the compute node. This reduces the latency, because no network is involved, but also redundancy, because only two devices and one compute node are involved.

### Which storage flavor fits my needs best?

In general, workloads where large volumes of data are transmitted or many small chunks of data are handled in parallel benefit from the overall performance of distributed storage and of course the redundancy and availability whereas workloads with tiny requests that need to be executed serially benefits from the lower latency of local ssd storage.

### Why are instances migrated?

#### Software Updates

SysEleven regularly updates the software on the hypervisor host machines.
Sometimes those updates require restarts of services or even a reboot of the whole hypervisor.
In such cases we will live-migrate all running instances to another hypervisor host prior to applying the update.

#### Hardware Maintenance

All hardware nodes require maintenance at some point.
Sometimes the required maintenance work cannot be done while the machine is online.
In such cases we will live-migrate all running instances to another hypervisor host prior to performing the maintenance.

#### Hardware failure

Unfortunately live migrations are not possible in case of a hardware failure.
In such a situation running instances will be automatically restarted on another hardware node.
Stopped instances will also be assigned to another hypervisor but remain stopped.

### How long does a migration take?

A live migration takes usually about 500ms. In some situations migrations may take longer.

### Why are instances disconnected while migrating?

To transfer the active state of instances (incl. RAM/Memory) they need to be 'frozen' prior to the migration. During the transfer network packets can get lost. It depends on the operating system and application that is being used if connection can be reestablished.

### Can I allocate a fixed IP to a compute instance?

Normally a fixed IP shouldn't play a big role in a cloud setup, since the infrastructure might change a lot.
If you need a fixed IP, you can assign a port from our networking service as a fixed IP to our compute instance. Here is an example which shows how to use the orchestration service to fetch a fixed IP address to use in a template:

```plain
  management_port:
    type: OS::Neutron::Port
    properties:
      network_id: { get_resource: management_net }
      fixed_ips:
        - ip_address: 192.168.122.100
```

### My compute instance was created, but is e.g. not accessible via SSH/HTTP

By default all compute instances of are using the "default" security group. It's settings do not allow any other packets, except of ICMP in order to be able to ping your compute instance. Any other ports needed by a given instance need to be opened by adding a rule to the security group your instance uses (i.e., SSH or HTTPS).
Here is an example that shows how you can use a heat template to allow incoming HTTP/HTTPS traffic via your security group:

```plain
resources:
  allow_webtraffic:
    type: OS::Neutron::SecurityGroup
    properties:
      description: allow incoming webtraffic from anywhere.
      name: allow webtraffic
      rules:
        - { direction: ingress, remote_ip_prefix: 0.0.0.0/0, port_range_min: 80, port_range_max: 80, protocol: tcp }
        - { direction: ingress, remote_ip_prefix: 0.0.0.0/0, port_range_min: 443, port_range_max: 443, protocol: tcp }
```

This security group can now be connected to a port of your network:

```plain
  example_port:
    type: OS::Neutron::Port
    properties:
      security_groups: [ get_resource: allow_webtraffic, default ]
      network_id: { get_resource: example_net}
```

The security group "default" is added in this example, since this group is taking care of allowing outbound traffic.
