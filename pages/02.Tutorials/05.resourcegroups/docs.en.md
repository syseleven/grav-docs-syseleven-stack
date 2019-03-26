---
title: '5. Organising instances in group'
published: true
date: '08-08-2018 09:55'
taxonomy:
    category:
        - docs
---

## Resource Groups: From Single Server to Distributed Setup

## Goal

* This tutorial shows how you can group servers. That way you can control the
* amount of identical servers via parameters.

## Prerequisites

* You should be able to use simple heat templates, like shown in the [first steps tutorial](../02.firststeps/docs.en.md).
* You know the basics of using the [OpenStack CLI-Tools](../../03.Howtos/05.openstack-cli/docs.en.md).
* Environment variables are set, like shown in the [API-Access-Tutorial](../03.api-access/docs.en.md).

## The How *not* To: Redundant Code

A template used to start more than a single server could look like this (excerpt):

```plain
heat_template_version: 2014-10-16
.
.
.
resources:
  instance_one:
    type: OS::Nova::Server
    depends_on: example_subnet
    properties:
      image: Ubuntu 16.04 sys11-cloudimg amd64
      flavor: m1.small
      name: server01
      user_data_format: RAW
      networks:
        - port: { get_resource: example_port1 }

  example_port1:
    type: OS::Neutron::Port
    properties:
      network_id: { get_resource: example_net}

  instance_two:
    type: OS::Nova::Server
    depends_on: example_subnet
    properties:
      image: Ubuntu 16.04 sys11-cloudimg amd64
      flavor: m1.small
      name: server02
      user_data_format: RAW
      networks:
        - port: { get_resource: example_port2 }

  example_port2:
    type: OS::Neutron::Port
    properties:
      network_id: { get_resource: example_net}

  example_net:
    type: OS::Neutron::Net
    properties:
      name: example-net

  example_subnet:
    type: OS::Neutron::Subnet
    properties:
      name: example_subnet
      dns_nameservers:
        - 8.8.8.8
        - 8.8.4.4
      network_id: {get_resource: example_net}
      ip_version: 4
      cidr: 10.0.0.0/24
      allocation_pools:
      - {start: 10.0.0.10, end: 10.0.0.250}
```

As you can see, servers and ports are defined twice. That will turn cumbersome with setups that have several dozen identically configured servers. It is more convenient if you organize servers in groups and keep their definition in a separate file.

## The Elegant Way: Grouping Servers

Simplifying Infrastructure Templates with `Resource Groups`.

A simple servers with several identical servers is split between two files: A `setup.yaml that describes everything except the servers:

```plain
heat_template_version: 2014-10-16

#
# you can start this stack using the following command:
# 'openstack stack create -t group.yaml <stackName>'
#

description: deploys a group of servers

parameters:
 server_count:
  type: string
  default: 2

resources:
  multiple_hosts:
    type: OS::Heat::ResourceGroup
    depends_on: example_subnet
    properties:
      count: { get_param: server_count }
      resource_def:
        type: server.yaml
        properties:
          network_id: { get_resource: example_net}
          server_name: server_%index%

  example_net:
    type: OS::Neutron::Net
    properties:
      name: example-net

  example_subnet:
    type: OS::Neutron::Subnet
    properties:
      name: example_subnet
      dns_nameservers:
        - 8.8.8.8
        - 8.8.4.4
      network_id: {get_resource: example_net}
      ip_version: 4
      cidr: 10.0.0.0/24
      allocation_pools:
      - {start: 10.0.0.10, end: 10.0.0.250}
```

This is accompanied by `server.yaml`, where the actual virtual machine definition is kept:

```plain
heat_template_version: 2014-10-16

description: single server resource used by resource groups.

parameters:
  network_id:
    type: string
  server_name:
    type: string

resources:
  my_instance:
    type: OS::Nova::Server
    properties:
      user_data_format: RAW
      image: Ubuntu 16.04 sys11-cloudimg amd64
      flavor: m1.small
      name: { get_param: server_name }
      networks:
        - port: { get_resource: example_port }

  example_port:
    type: OS::Neutron::Port
    properties:
      network_id: { get_param: network_id }
```

## Conclusion: Modular Code

This method has several advantages:

* Modular code is easier to re-use.
* You avoid redundancies and repetition.
* You get an automatically managed index you can use (in this example for the server name).
* The number of resources in a group is controlled by a simple parameter, so you can generate differently scaled setups from the same code base.

## An Example

We published an [example setup](https://github.com/syseleven/heat-examples/tree/master/example-setup) using Resource Groups for modularization and simplification.