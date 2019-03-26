---
title: 'Verfügbarkeit von redundanten Services erhöhen'
date: '08-08-2018 09:45'
taxonomy:
    category:
        - docs
---

## Redundante Services für eine höhere Verfügbarkeit besser verteilen

## Ziel

* In diesem Tutorial wird gezeigt wie man mit der Hilfe von Servergruppen Instanzen auf unterschiedliche Hosts verteilen kann
* Zusätzlich wird auch darauf eingegangen wie man Instanzen auf denselben Host zwingt

## Vorraussetzungen

* Der Umgang mit einfachen Heat-Templates, wie [in den ersten Schritten](../02.firststeps/docs.en.md) gezeigt, wird vorausgesetzt.
* Grundlagen zur Bedienung des [OpenStack CLI-Tools](../03.openstack-cli/docs.de.md).
* Umgebungsvariablen gesetzt, wie im [API-Access-Tutorial](../04.api-access/docs.en.md) beschrieben.

## Problemstellung

Standardmäßig gibt es keine Garantie, dass Instanzen auf unterschiedliche Hypervisor (Host) verteilt werden. Der Nova Compute-Scheduler entscheidet dies anhand der zur Verfügung stehenden Ressourcen.  
Dies kann dazu führen, dass redundant ausgelegte Services wie App-Server auf dem gleichen Host landen und damit bei einem Ausfall des Hosts nicht mehr erreichbar sind.  
Im umgekehrten Fall möchte man vielleicht zwei Services so nah wie möglich bei einander haben, da zwischen diesen viel Bandbreite gebraucht wird.  
Beides ist mit ServerGroups lösbar. Auf diese Weise kann man Einfluss auf die Verteilung der Instanzen nehmen.

## Prinzip

Man erstellt eine `OS::Nova::ServerGroup-Ressource` und referenziert diese als *Scheduler-Hint* in der *Server-Definition*.

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

## Beispiele

Das [ResourceGroups-Beispiel](../06.resourcegroups/docs.de.md) ist hier ergänzt um ServerGroups für die Nutzung von *Affinity* und *Anti-Affinity* `group.yaml`:

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

Die bekannte `server.yaml` ergänzt um die affinity_group Parameter:

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

## Fazit

* Erhöhte Ausfallsicherheit mit Hilfe der Anti-Affinity-Policy
* Erhöhten Datendurchsatz mit Hilfe der Affinity-Policy

Um nachvollziehen zu können, dass die Scheduler-Hints auch gewirkt haben, gibt es zwei Ansätze.  
Zum einen kann man sich die Mitglieder eine ServerGroup anzeigen lassen:

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

Zum anderen kann man die hostIds der einzelnen Instanzen vergleichen:

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

## Link Ressource/Quellen

* [Heat Template Guide](http://docs.openstack.org/developer/heat/template_guide/index.html)
* [Heat Template ServerGroup Resource](http://docs.openstack.org/developer/heat/template_guide/openstack.html#OS::Nova::ServerGroup)
* [Nova Scheduler Reference](http://docs.openstack.org/mitaka/config-reference/compute/scheduler.html)
* [Nova Scheduler Affinity Filter](http://docs.openstack.org/mitaka/config-reference/compute/scheduler.html#servergroupaffinityfilter)
* [OpenStack Client Server Create](http://docs.openstack.org/developer/python-openstackclient/command-objects/server.html#server-create)
* [OpenStack Client ServerGroup](http://docs.openstack.org/developer/python-openstackclient/command-objects/server-group.html)

## Weiterführende Links/Beispiele

Das auf Github veröffentlichte Beispiel [affinity](https://github.com/syseleven/heat-examples/tree/master/affinity) enthält ein Beispiel für *affinity* und *anti-affinity*.
