---
title: '7. Using logically structured Stack Resources'
published: true
date: '08-08-2018 10:05'
taxonomy:
    category:
        - docs
---

## Goal

* In this tutorial you will learn how to organise stack resources that depend on each other in a structured way.
* One example use case is to create your network before you create and add servers to it.

## Prerequisites

* You should be able to use simple heat templates, like shown in the [first steps tutorial](../01.firststeps/docs.en.md).
* You know the basics of using the [OpenStack CLI-Tools](../../03.Howtos/02.openstack-cli/docs.en.md).
* Environment variables are set, like shown in the [API-Access-Tutorial](../02.api-access/docs.en.md).

## The Problem: Creating Resources fails

If Resources are not created in a defined order, they will be created randomly. This can cause stack creation to fail:

```shell
syselevenstack@kickstart:~/failingDemo$ openstack stack create -t clustersetup.yaml -e clustersetup-env.yaml noDependencies --wait
2016-10-18 13:50:48 [noDependencies]: CREATE_IN_PROGRESS  Stack CREATE started
2016-10-18 13:50:48 [syseleven_net]: CREATE_IN_PROGRESS  state changed
2016-10-18 13:50:48 [syseleven_router]: CREATE_IN_PROGRESS  state changed
2016-10-18 13:50:50 [syseleven_net]: CREATE_COMPLETE  state changed
2016-10-18 13:50:50 [syseleven_router]: CREATE_COMPLETE  state changed
2016-10-18 13:50:50 [dbserver_group]: CREATE_IN_PROGRESS  state changed
2016-10-18 13:50:51 [servicehost_group]: CREATE_IN_PROGRESS  state changed
2016-10-18 13:50:53 [lb_group]: CREATE_IN_PROGRESS  state changed
2016-10-18 13:50:55 [appserver_group]: CREATE_IN_PROGRESS  state changed
2016-10-18 13:50:58 [syseleven_subnet]: CREATE_IN_PROGRESS  state changed
2016-10-18 13:51:00 [syseleven_subnet]: CREATE_COMPLETE  state changed
2016-10-18 13:51:00 [router_subnet_connect]: CREATE_IN_PROGRESS  state changed
2016-10-18 13:51:02 [router_subnet_connect]: CREATE_COMPLETE  state changed
2016-10-18 13:51:02 [dbserver_group]: CREATE_FAILED  BadRequest: resources.dbserver_group.resources[0].resources.dbserver: Port de3404ba-3b43-4123-bf1d-1a1809ea434a requires a FixedIP in order to be used. (HTTP 400) (Request-ID: req-bcd57a8b-7290-4311-8800-46fc78fb0f8d)
2016-10-18 13:51:10 [lb_group]: CREATE_COMPLETE  state changed
2016-10-18 13:51:11 [servicehost_group]: CREATE_COMPLETE  state changed
2016-10-18 13:51:17 [appserver_group]: CREATE_COMPLETE  state changed
2016-10-18 13:51:17 [noDependencies]: CREATE_FAILED  Resource CREATE failed: BadRequest: resources.dbserver_group.resources[0].resources.dbserver: Port de3404ba-3b43-4123-bf1d-1a1809ea434a requires a FixedIP in order to be used. (HTTP 400) (Request-ID: req-bcd57a8b-7290-4311-8800-46fc78fb0f8d)

 Stack noDependencies CREATE_FAILED

syselevenstack@kickstart:~/failingDemo$
```

## The Solution: Define the Order of Resource Creation

In a Heat template you can define dependencies using the keyword `depends_on`:

```plain
resources:
  syseleven_net:
    type: OS::Neutron::Net
    properties:
      name: syseleven-net

  syseleven_subnet:
    type: OS::Neutron::Subnet
    depends_on: [ syseleven_net ] # <-- Here the order while creating and deleting resourcces is defined.

```

You can observe this using the option `--wait` when using the OpenStack command line tools to create a stack:

```shell
syselevenstack@kickstart:~/heat-examples/example-setup$ openstack stack create -t clustersetup.yaml -e clustersetup-env.yaml depTest --wait
2016-10-19 11:42:17 [depTest]: CREATE_IN_PROGRESS  Stack CREATE started
2016-10-19 11:42:17 [syseleven_net]: CREATE_IN_PROGRESS  state changed
2016-10-19 11:42:18 [syseleven_net]: CREATE_COMPLETE  state changed
2016-10-19 11:42:18 [syseleven_subnet]: CREATE_IN_PROGRESS  state changed
2016-10-19 11:42:20 [syseleven_subnet]: CREATE_COMPLETE  state changed
2016-10-19 11:42:20 [syseleven_router]: CREATE_IN_PROGRESS  state changed
2016-10-19 11:42:22 [syseleven_router]: CREATE_COMPLETE  state changed
2016-10-19 11:42:22 [router_subnet_connect]: CREATE_IN_PROGRESS  state changed
2016-10-19 11:42:25 [router_subnet_connect]: CREATE_COMPLETE  state changed
2016-10-19 11:42:25 [servicehost_group]: CREATE_IN_PROGRESS  state changed
2016-10-19 11:42:26 [lb_group]: CREATE_IN_PROGRESS  state changed
2016-10-19 11:42:27 [appserver_group]: CREATE_IN_PROGRESS  state changed
2016-10-19 11:42:31 [dbserver_group]: CREATE_IN_PROGRESS  state changed
2016-10-19 11:42:43 [servicehost_group]: CREATE_COMPLETE  state changed
2016-10-19 11:42:44 [dbserver_group]: CREATE_COMPLETE  state changed
2016-10-19 11:42:45 [lb_group]: CREATE_COMPLETE  state changed
2016-10-19 11:42:50 [appserver_group]: CREATE_COMPLETE  state changed
2016-10-19 11:42:50 [depTest]: CREATE_COMPLETE  Stack CREATE completed successfully
+---------------------+-----------------------------------------------------------------+
| Field               | Value                                                           |
+---------------------+-----------------------------------------------------------------+
| id                  | cc2dd31a-feb0-4026-8693-29926c8b1191                            |
| stack_name          | depTest                                                         |
| description         | A template to deploy and configure a loadbalanced server setup. |
| creation_time       | 2016-10-19T11:42:17                                             |
| updated_time        | None                                                            |
| stack_status        | CREATE_COMPLETE                                                 |
| stack_status_reason | Stack CREATE completed successfully                             |
+---------------------+-----------------------------------------------------------------+
```

## Examples

We provided an [example setup](https://github.com/syseleven/heat-examples/tree/master/example-setup) on github which uses dependencies.