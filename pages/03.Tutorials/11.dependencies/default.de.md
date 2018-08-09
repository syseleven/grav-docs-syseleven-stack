---
title: 'Stack-Ressourcen logisch aufeinander aufbauen '
published: true
date: '08-08-2018 10:05'
taxonomy:
    category:
        - tutorial
---

## Ziel

* In diesem Tutorial wird gezeigt, wie einzelne Resourcen in einem Stack aufeinander aufbauend organisiert werden können.
* Damit ist es möglich, beispielsweise erst die Netzwerk-Infrastruktur aufzubauen, bevor dort Server gestartet werden.

## Vorraussetzungen

* Der Umgang mit einfachen Heat-Templates, wie [in den ersten Schritten](../02.firststeps/default.en.md) gezeigt, wird vorausgesetzt.
* Grundlagen zur Bedienung des [OpenStack CLI-Tools](../03.openstack-cli/default.de.md).
* Umgebungsvariablen gesetzt, wie im [API-Access-Tutorial](../04.api-access/default.en.md) beschrieben.

## Das Problem: Der Aufbau von Ressourcen scheitert

Wenn die Reihenfolge bestimmter Ressourcen nicht vorgegeben wird, werden die Ressourcen willkürlich angelegt. Der Aufbau eines Stack schlägt dann nach folgendem Muster fehl:

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

## Die Lösung: saubere Definition der Reihenfolge

In einem Heat-Template werden Dependencies mittels `depends_on` definiert.

```plain
resources:
  syseleven_net:
    type: OS::Neutron::Net
    properties:
      name: syseleven-net

  syseleven_subnet:
    type: OS::Neutron::Subnet
    depends_on: [ syseleven_net ] # <-- hiermit wird die Reihenfolge beim Anlegen und Löschen von Ressourcen sortiert.

```

Über den openstack CLI Client gestartet lässt sich das mit der Option `--wait` gut beobachten:

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

## Beispiel-Ressourcen

Das auf Github veröffentlichte Beispiel [examplesetup](https://github.com/syseleven/heat-examples/tree/master/example-setup) setzt Dependencies ein.