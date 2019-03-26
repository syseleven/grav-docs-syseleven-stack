---
title: 'Enhance availability for redundant services'
date: '08-08-2018 09:45'
taxonomy:
    category:
        - docs
---

## Better distributing redundant services for higher availability

## Goal

* This tutorial shows howto distribute instances to different hosts using servergroups
* It is also shown how to force instances on the same host

## Prerequisites

* You should be able to use simple heat templates, like shown in the [first steps tutorial](../02.firststeps/docs.en.md).
* You know the basics of using the [OpenStack CLI-Tools](../03.openstack-cli/docs.en.md).
* Environment variables are set, like shown in the [API-Access-Tutorial](../04.api-access/docs.en.md).

## Problem

By default, there is no guarantees wether servers will be distributed across different hypervisors. The Nova compute scheduler makes that decision based on available resources.  
This can lead to services that are meant to be highly available to share a common host and thus share a single point of failure.  
Inversely it might be desired to have two services to be located as close as possible, because they will need high bandwidth between each other.  
Both cases are solvable using ServerGroups. That way you can influence the distribution of instances.

## Principle

Create a OS::Nova::ServerGroup resource and reference it as scheduler hint in the server definition.

```plain
resources:
  anti-affinity_group:
   type: OS::Nova::ServerGroup
   properties:
    name: hosts on separate compute nodes
    policies:
     - anti-affinity

  my_instance:
    type: OS::Nova::Server
    properties:
      user_data_format: RAW
      image: Ubuntu 16.04 sys11-cloudimg amd64
      flavor: m1.small
      name: server app 1
      scheduler_hints:
        group: { get_resource: anti-affinity_group }
```

## Example

Here the [ResourceGroups example](../06.resourcegroups/docs.en.md) is extended using ServerGroups for *affinity* and *anti-affinity* `group.yaml`:

```plain
heat_template_version: 2014-10-16

#
# you can start this stack using the following command:
# 'openstack stack create -t group.yaml <stackName>'
#

description: deploys a group of servers with only internal network.

resources:
  same_hosts:
    type: OS::Heat::ResourceGroup
    depends_on: example_subnet
    properties:
      count: 2
      resource_def:
        type: server.yaml
        properties:
          network_id: { get_resource: example_net}
          server_name: server_%index%
          affinity_group: { get_resource: affinity_group }

  separate_hosts:
    type: OS::Heat::ResourceGroup
    depends_on: example_subnet
    properties:
      count: 2
      resource_def:
        type: server.yaml
        properties:
          network_id: { get_resource: example_net}
          server_name: antiserver_%index%
          affinity_group: { get_resource: anti-affinity_group }


  anti-affinity_group:
   type: OS::Nova::ServerGroup
   properties:
    name: hosts on separate compute nodes
    policies:
     - anti-affinity

  affinity_group:
   type: OS::Nova::ServerGroup
   properties:
    name: hosts on one compute-node
    policies:
     - affinity

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

The already known `server.yaml` extended by affinity_group parameter:

```plain
heat_template_version: 2014-10-16

description: single server resource used by resource groups.

parameters:
  network_id:
    type: string
  server_name:
    type: string
  affinity_group:
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
      scheduler_hints:
        group: { get_param: affinity_group }

  example_port:
    type: OS::Neutron::Port
    properties:
      network_id: { get_param: network_id }
```

## Conclusion

* increased availability when using anti-affinity policy
* increased data throughput when using affinity policy

There are two options to check whether the scheduler hints were fully considered.
For one you can list the members of a ServerGroup:

```plain
openstack server group show "hosts on one compute-node"
+----------+----------------------------------------------------------------------------+
| Field    | Value                                                                      |
+----------+----------------------------------------------------------------------------+
| id       | 0d6a2b32-0cef-419b-9e58-23d0894f9a04                                       |
| members  | c3719d43-a3c4-4359-b2d1-8a4626ccf8d6, cf89eb84-1fb5-4dd8-bb88-2ebac4c64273 |
| name     | hosts on one compute-node                                                  |
| policies | affinity                                                                   |
+----------+----------------------------------------------------------------------------+
```

Also you can compare the hostIds of the individual instances:

```plain
openstack server show server_0 -c name -c hostId
+--------+----------------------------------------------------------+
| Field  | Value                                                    |
+--------+----------------------------------------------------------+
| hostId | eda910fefd0756ea0d88b7c84ba01ddc0f350332e351348a33e0132f |
| name   | server_0                                                 |
+--------+----------------------------------------------------------+
openstack server show server_1 -c name -c hostId
+--------+----------------------------------------------------------+
| Field  | Value                                                    |
+--------+----------------------------------------------------------+
| hostId | eda910fefd0756ea0d88b7c84ba01ddc0f350332e351348a33e0132f |
| name   | server_1                                                 |
+--------+----------------------------------------------------------+
```

## Link Ressources/Sources

* [Heat Template Guide](http://docs.openstack.org/developer/heat/template_guide/index.html)
* [Heat Template ServerGroup Resource](http://docs.openstack.org/developer/heat/template_guide/openstack.html#OS::Nova::ServerGroup)
* [Nova Scheduler Reference](http://docs.openstack.org/mitaka/config-reference/compute/scheduler.html)
* [Nova Scheduler Affinity Filter](http://docs.openstack.org/mitaka/config-reference/compute/scheduler.html#servergroupaffinityfilter)
* [OpenStack Client Server Create](http://docs.openstack.org/developer/python-openstackclient/command-objects/server.html#server-create)
* [OpenStack Client ServerGroup](http://docs.openstack.org/developer/python-openstackclient/command-objects/server-group.html)

## Links/Examples

The templates published on github [affinity](https://github.com/syseleven/heat-examples/tree/master/affinity) contain examples for *affinity* und *anti-affinity*.
