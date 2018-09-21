---
title: 'Compute Service'
published: true
date: '21-09-2018 11:45'
taxonomy:
    category:
        - docs
---

## Übersicht

SysEleven Stacks Compute Service basiert auf dem OpenStack Nova Projekt.
Der Service verwaltet den Lebenszyklus einer Compute Instanz. Seine Zuständigkeit umfasst das erstellen, planen und  ausmustern von Compute Instanzen.

Sowohl via unserer öffentlichen [OpenStack API](../../03.Tutorials/04.api-access/docs.en.md), als auch durch das [SysEleven Stack Dashboard](https://dashboard.cloud.syseleven.net) können Compute Instanzen verwaltet werden.

## Flavors

### Standard Instanz-Typen (M1)

Standard Instanz-Typen sind mit einem verteiltem Root-Speichermedium einer festen Größe ausgestattet.
Sie bieten ein ausgewogenes Verhältnis zwischen Leistung, Verfügbarkeit und Sicherheit.
Wir empfehlen diese Instanz-Typen für die meisten Anwendungen und Nutzungsfälle.

Name        | API Name    | Memory | vCPUs | Storage* |
------------|-------------|--------|-------|----------|
M1 Micro    |  m1.micro   |  2GB   |   1   |   50GB   |
M1 Tiny     |  m1.tiny    |  4GB   |   1   |   50GB   |
M1 Small    |  m1.small   |  8GB   |   2   |   50GB   |
M1 Medium   |  m1.medium  | 16GB   |   4   |   50GB   |
M1 Large    |  m1.large   | 32GB   |   8   |   50GB   |

(*)
Sie können den Root-Speicher durch unseren ebenfalls verteilten Block-Speicher ergänzen.

### Local SSD Storage Instanz-Typen (L1)

Local SSD Storage Instanz-Typen sind mit einem lokalen Root-Speichermedium in unterschiedlichen Größen ausgestattet.
Die Rechenleistung ist mit der der Standard Instanzen vergleichbar, aber die Speicherlatenz ist geringer, dadurch steigt der Durchsatz an sequentiellen, synchronen Operationen, obwohl der Gesamthöchstdurchsatz etwas geringer ist.
Diese Instanzen können für bestimmte Anwendungsfälle, wie verteilte Datenbanken, vorteilhaft sein.

Name        | API Name    | Memory | vCPUs | Storage |
------------|-------------|--------|-------|---------|
L1 Tiny     | l1.tiny     |   4GB  |   1   |   25GB  |
L1 Small    | l1.small    |   8GB  |   2   |   50GB  |
L1 Medium   | l1.medium   |  16GB  |   4   |  100GB  |
L1 Large    | l1.large    |  32GB  |   8   |  200GB  |
L1 XLarge   | l1.xlarge   |  64GB  |  16   |  400GB  |
L1 2XLarge  | l1.2xlarge  | 128GB  |  32   |  800GB  |
L1 4XLarge  | l1.4xlarge  | 256GB  |  64   | 1600GB  |

Für mehr Informationen lesen Sie bitte die [Dokumentation des Local SSD Storage](../04.local-storage/docs.de.md).

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

## Fragen & Antworten

### Was ist der Unterschied zwischen Local SSD Storage und Distributed Storage?

Auf unserem Distributed Storage werden mehrere Kopien der Datensegmente auf mehrere physische SSDs verteilt, die an unterschiedlichen physischen Servern angeschlossen und durch das Netzwerk verbunden sind. Dadurch können wir generell eine hohe Performance bieten, da Daten auf mehreren SSDs gleichzeitig verarbeitet werden können – jedoch entsteht dadurch eine zusätzliche Latenz für einzelne Operationen, da Daten über das Netzwerk übertragen werden müssen.

Auf unserem Local SSD Storage, werden die Daten auf einem lokalen gespiegelten RAID gespeichert. Die Latenz reduziert sich, denn Daten müssen dafür nicht über das Netzwerk übertragen werden. Verfügbarkeit und Datenbeständigkeit sind jedoch bei diesen Instanztypen reduziert, da die Daten nur lokal auf einem Server vorgehalten werden.

### Which storage flavor fits my needs best?

In general, workloads where large volumes of data are transmitted or many small chunks of data are handled in parallel benefit from the overall performance of distributed storage and of course the redundancy and availability whereas workloads with tiny requests that need to be executed serially benefits from the lower latency of local ssd storage.

### Why are instances migrated?

#### Software Updates

SysEleven regularly updates the software on the hypervisor host machines.
To apply certain updates a reboot is required and running instances are therefore moved to another
hypervisor host.

#### Hardware Maintenance

All hardware nodes require maintenance at some point. Sometimes the required maintenance work cannot be done
while the machine is online. Therefore instances are moved to another hardware node prior to the planned maintenance work.

#### Hardware failure

Unfortunately life migrations are not possible in case of a hardware failure, therefor running instances will be automatically restarted on another hardware node. Stopped instances will be moved but remain in their stopped state.

### How long does a migration take?

A live migration takes usually about 500ms. In some situations migrations may take longer.

### Why are instances disconnected while migrating?

To transfer the active state of instances (incl. RAM/Memory) they need to be 'frozen' prior to the migration. During the transfer network packets can get lost. It depends on the operating system and application that is being used if connection can be reestablished.

### Kann ich einer Compute Instanz eine feste interne IP zuweisen?

Normalerweise spielen in einer Cloudumgebung feste IPs keine Rolle, da sich die Infrastruktur häufig ändert.
Ist das nicht gewünscht, kann ich z.B. mit folgendem Heat-Template via unserem SysEleven Stack Orchestration Service einer Maschine eine statische IP zuweisen:

```plain
  management_port:
    type: OS::Neutron::Port
    properties:
      network_id: { get_resource: management_net }
      fixed_ips:
        - ip_address: 192.168.122.100
```

Die Konsistenz der Netzwerkarchitektur muss ich dann allerdings selbst sicherstellen.

### Meine virtuelle Maschine wurde erstellt, ist aber z.B. nicht per SSH/ HTTP usw. erreichbar

Grundsätzlich sind alle Compute Instanzen im SysEleven Stack mit einer Default-Security-Group gesichert, die außer ICMP-Paketen keinen Traffic auf die VMs akzeptiert. Für jeden Service, der erreichbar sein soll, muss also eine Security-Group-Regel erstellt werden, die den Zugriff ermöglicht. Hier ein Beispiel wie HTTP(S)-Traffic mit einem Heat-Template unseres Orchestration Service zu ihrer Instanz erlaubt werden kann:

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

Diese so gebaute Security-Group muss noch an einen Port gebunden werden:

```plain
  example_port:
    type: OS::Neutron::Port
    properties:
      security_groups: [ get_resource: allow_webtraffic, default ]
      network_id: { get_resource: example_net}
```

Die Security-Group "default" ist in diesem Beispiel hinzugefügt, da diese Gruppe im SysEleven Stack dafür sorgt, dass Traffic, der ausgehend erlaubt ist, auch eingehend erlaubt wird.
