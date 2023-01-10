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

You can manage your compute instance both via our public [OpenStack API](../../02.Tutorials/02.api-access/docs.en.md) endpoints, as well as using the [Dashboard](https://cloud.syseleven.de/).


## Flavors

### Standard instance types (M1 & M2)

Standard instances generally offer you good performance, availability and storage durability.
Disk data will be distributed across multiple servers (SysEleven Distributed Storage).

We recommend these instance types for most workloads and applications.

#### Balanced

Name        | API Name    | Memory | vCPUs | Storage* | Region availability  |
------------|-------------|--------|-------|----------|----------------------|
M1 Tiny     |  m1.tiny    |  4GiB  |   1   |   50GiB  | dbl, cbk, fes        |
M2 Tiny     |  m2.tiny    |  4GiB  |   1   |   50GiB  | fes                  |
M1 Small    |  m1.small   |  8GiB  |   2   |   50GiB  | dbl, cbk, fes        |
M2 Small    |  m2.small   |  8GiB  |   2   |   50GiB  | fes                  |
M1 Medium   |  m1.medium  | 16GiB  |   4   |   50GiB  | dbl, cbk, fes        |
M2 Medium   |  m2.medium  | 16GiB  |   4   |   50GiB  | fes                  |
M1 Large    |  m1.large   | 32GiB  |   8   |   50GiB  | dbl, cbk, fes        |
M2 Large    |  m2.large   | 32GiB  |   8   |   50GiB  | fes                  |
(M1 XLarge)\*\*   |  (m1.xlarge)\*\* | 64GiB   |   16   |   50GiB   | dbl, cbk, fes |
(M2 XLarge)\*\*   |  (m2.xlarge)\*\* | 64GiB   |   16   |   50GiB   | fes           |
(M1 XXLarge)\*\*  |  (m1.xxlarge)\*\* | 128GiB|   32   |   50GiB   | dbl, cbk, fes |
(M2 XXLarge)\*\*  |  (m1.xxlarge)\*\* | 128GiB|   32   |   50GiB   | fes           |

#### CPU optimized

Name            | API Name     | Memory  | vCPUs | Storage*  | Region availability  |
----------------|--------------|---------|-------|-----------|----------------------|
M1 CPU Tiny     |  m1c.tiny    |  2GiB   |   1   |   50GiB   | dbl, cbk, fes        |
M2 CPU Tiny     |  m2c.tiny    |  2GiB   |   1   |   50GiB   | fes                  |
M1 CPU Small    |  m1c.small   |  4GiB   |   2   |   50GiB   | dbl, cbk, fes        |
M2 CPU Small    |  m2c.small   |  4GiB   |   2   |   50GiB   | fes                  |
M1 CPU Medium   |  m1c.medium  | 8GiB    |   4   |   50GiB   | dbl, cbk, fes        |
M2 CPU Medium   |  m2c.medium  | 8GiB    |   4   |   50GiB   | fes                  |
M1 CPU Large    |  m1c.large   | 16GiB   |   8   |   50GiB   | dbl, cbk, fes        |
M2 CPU Large    |  m2c.large   | 16GiB   |   8   |   50GiB   | fes                  |
M1 CPU XLarge   |  m1c.xlarge  | 32GiB   |   16  |   50GiB   | dbl, cbk, fes        |
M2 CPU XLarge   |  m2c.xlarge  | 32GiB   |   16  |   50GiB   | fes                  |
(M1 CPU XXLarge)\*\* |  (m1c.xxlarge)\*\* | 64GiB   |   32   |   50GiB   | dbl, cbk, fes |
(M2 CPU XXLarge)\*\* |  (m2c.xxlarge)\*\* | 64GiB   |   32   |   50GiB   | fes           |

#### RAM optimized

Name            | API Name     | Memory  | vCPUs | Storage* | Region availability  |
----------------|--------------|---------|-------|----------|----------------------|
M1 RAM Tiny     |  m1r.tiny    |  8GiB   |   1   |   50GiB  | dbl, cbk, fes        |
M2 RAM Tiny     |  m2r.tiny    |  8GiB   |   1   |   50GiB  | fes                  |
M1 RAM Small    |  m1r.small   | 16GiB   |   2   |   50GiB  | dbl, cbk, fes        |
M2 RAM Small    |  m2r.small   | 16GiB   |   2   |   50GiB  | fes                  |
M1 RAM Medium   |  m1r.medium  | 32GiB   |   4   |   50GiB  | dbl, cbk, fes        |
M2 RAM Medium   |  m2r.medium  | 32GiB   |   4   |   50GiB  | fes                  |
(M1 RAM Large)\*\*  |  (m1r.large)\*\* | 64GiB   |   8   |   50GiB   | dbl, cbk, fes |
(M2 RAM Large)\*\*  |  (m2r.large)\*\* | 64GiB   |   8   |   50GiB   | fes             |
(M1 RAM XLarge)\*\* |  (m1r.xlarge)\*\* | 128GiB  |   16   |   50GiB   | dbl, cbk, fes |
(M2 RAM XLarge)\*\* |  (m2r.xlarge)\*\* | 128GiB  |   16   |   50GiB   | fes           |

(*)
You can extend ephemeral storage using our durable [Block Storage Service](../04.block-storage/docs.en.md).

(\*\*)
Only available upon request. We would first like to get in touch with you to clarify expectations and implications when using these flavors.

### Local SSD storage instance types (L1)

Local SSD storage instances offer low latency SSD storage directly on the local host.
These can be useful for special workloads like replicated databases.

! Availability and data durability are [**reduced**](../../05.Background/02.local-storage/docs.en.md#what-happens-in-case-of-hardware-failures), because data is only stored locally on one server.

For more information, see the [local storage documentation](../../05.Background/02.local-storage/docs.en.md).

#### Balanced

Name        | API Name    | Memory | vCPUs | Storage* |
------------|-------------|--------|-------|----------|
L1 Tiny     | l1.tiny     |   4GiB  |   1   |   25GiB   |
L1 Small    | l1.small    |   8GiB  |   2   |   50GiB   |
L1 Medium   | l1.medium   |  16GiB  |   4   |  100GiB   |
L1 Large    | l1.large    |  32GiB  |   8   |  200GiB   |
L1 XLarge   | l1.xlarge   |  64GiB  |  16   |  400GiB   |
L1 2XLarge  | l1.2xlarge  | 128GiB  |  32   |  800GiB   |
L1 4XLarge  | l1.4xlarge  | 256GiB  |  64   | 1600GiB   |

#### CPU optimized

Name          | API Name    | Memory | vCPUs | Storage* |
--------------|-------------|--------|-------|----------|
L1 CPU Tiny   | l1c.tiny     |   2GiB  |   1   |   25GiB   |
L1 CPU Small  | l1c.small    |   4GiB  |   2   |   50GiB   |
L1 CPU Medium | l1c.medium   |   8GiB  |   4   |  100GiB   |
L1 CPU Large    | l1c.large    |  16GiB  |   8   |  200GiB   |
L1 CPU XLarge   | l1c.xlarge   |  32GiB  |  16   |  400GiB   |
L1 CPU 2XLarge  | l1c.2xlarge  |  64GiB  |  32   |  800GiB   |
(L1 CPU 4XLarge)\*\*  | (l1c.4xlarge)\*\*  | 128GiB  |  64   | 1600GiB   |

#### RAM optimized

Name          | API Name    | Memory | vCPUs | Storage* |
--------------|-------------|--------|-------|----------|
L1 RAM Tiny   | l1r.tiny     |   8GiB  |   1   |   25GiB   |
L1 RAM Small  | l1r.small    |  16GiB  |   2   |   50GiB   |
L1 RAM Medium | l1r.medium   |  32GiB  |   4   |  100GiB   |
L1 RAM Large    | l1r.large  |  64GiB  |   8   |  200GiB   |
(L1 RAM XLarge)\*\*   | (l1r.xlarge)\*\*  | 128GiB  |  16   |  400GiB   |
(L1 RAM 2XLarge)\*\*  | (l1r.2xlarge)\*\* | 256GiB  |  32   |  800GiB   |

(*)
You can extend local ephemeral storage using our distributed [Block Storage Service](../04.block-storage/docs.en.md),
[to place less latency critical data on it](../../05.Background/02.local-storage/docs.en.md#can-i-combine-local-ssd-storage-with-distributed-storage).

(\*\*)
Only available upon request. We would first like to get in touch with you to clarify expectations and implications when using these flavors.

## Flavor change (resizing)

!!! After the initial resize request was placed, additional confirmation is required before the system will resize the instance when resizing via GUI/CLI.

### M1 flavors

It is possible to resize all M1 flavors since they use the same base storage backend.

### L1 flavors

Resizing local storage flavors is currently **not** possible.

### Flavor change to different storage type

If more resources are required for an instance, the fastest solution is to build a new instance and migrate the required data (if any) via network or an attached volume.

If a conversion of an existing instance seems inevitable, a similar result can be achieved by creating an image from that instance and using it as a boot source for a new instance with another flavor. Please keep in mind that hardware specifications and CPU flags may change with change of flavor.

## Instance Snapshots

Instance snapshots can be created from instances, if they are not booted from a cinder volume.

!! WARNING: Creating instance snapshots of your server will make it unresponsive for a period of time (depending on the disk size).

```shell
openstack server image create --name <MyInstanceSnapshotName> <MyInstanceName>
```

### Data consistency

For best results, we recommend to shut off the instance before creating a snapshot. Otherwise there might be data inconsistencies and file system corruption.

Another variant to avoid data inconsistencies is to use the QEMU Guest Agent. Unfortunately it's not sufficient to install the Guest Agent in your virtual machine.
You have to start with a Glance image where the QEMU Guest Agent is already properly installed and configured. This image must have the property `hw_qemu_guest_agent=yes`.
Only if the virtual machine was created from such an image the compute service learns that the Guest Agent is available.

## Launch instances from snapshots

Snapshots can be used as templates for new instances.

[This heat example](https://github.com/syseleven/heat-examples/tree/master/single-server-from-snapshot) shows
how to use snapshots to launch new instances using the ephemeral or volume storage.

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
