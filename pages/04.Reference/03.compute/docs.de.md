---
title: 'Compute Service'
published: true
date: '23-10-2018 13:45'
taxonomy:
    category:
        - docs
---

## Übersicht

SysEleven Stacks Compute Service basiert auf dem OpenStack Nova Projekt.
Der Service verwaltet den Lebenszyklus einer Compute Instanz. Seine Zuständigkeit umfasst das erstellen, planen und  ausmustern von Compute Instanzen.

Sowohl via unserer öffentlichen [OpenStack API](../../02.Tutorials/02.api-access/docs.en.md), als auch durch das [SysEleven Stack Dashboard](https://dashboard.cloud.syseleven.net) können Compute Instanzen verwaltet werden.

## Flavors

### Standard Instanz-Typen (M1)

Standard Instanz-Typen bieten gute Leistung, Verfügbarkeit und Datenbeständigkeit in einem ausgewogenen Verhältnis.
Der Datenspeicher wird auf mehrere Server verteilt (SysEleven Distributed Storage).

Wir empfehlen diese Instanz-Typen für die meisten Anwendungen und Nutzungsfälle.

#### Ausgeglichen

Name        | API Name    | Memory | vCPUs | Storage* |
------------|-------------|--------|-------|----------|
M1 Tiny     |  m1.tiny    |  4GB   |   1   |   50GB   |
M1 Small    |  m1.small   |  8GB   |   2   |   50GB   |
M1 Medium   |  m1.medium  | 16GB   |   4   |   50GB   |
M1 Large    |  m1.large   | 32GB   |   8   |   50GB   |
(M1 XLarge**)   |  (m1.xlarge)** | 64GB   |   16   |   50GB   |
(M1 XXLarge**)  |  (m1.xxlarge)** | 128GB|   32   |   50GB   |

#### CPU-Optimiert

Name            | API Name     | Memory | vCPUs | Storage* |
----------------|--------------|--------|-------|----------|
M1 CPU Tiny     |  m1c.tiny    |  2GB   |   1   |   50GB   |
M1 CPU Small    |  m1c.small   |  4GB   |   2   |   50GB   |
M1 CPU Medium   |  m1c.medium  | 8GB    |   4   |   50GB   |
M1 CPU Large    |  m1c.large   | 16GB   |   8   |   50GB   |
M1 CPU XLarge   |  m1c.xlarge  | 32GB   |   16   |   50GB   |
(M1 CPU XXLarge)** |  (m1c.xxlarge)** | 64GB   |   32   |   50GB   |

#### RAM-Optimiert

Name            | API Name     | Memory | vCPUs | Storage* |
----------------|--------------|--------|-------|----------|
M1 RAM Tiny     |  m1r.tiny    |  8GB   |   1   |   50GB   |
M1 RAM Small    |  m1r.small   | 16GB   |   2   |   50GB   |
M1 RAM Medium   |  m1r.medium  | 32GB   |   4   |   50GB   |
(M1 RAM Large)**  |  m1r.large | 64GB   |   8   |   50GB   |
(M1 RAM XLarge)** |  m1r.xlarge| 128GB  |   16   |   50GB   |

(*)
Der kurzlebige Festspeicher kann durch unseren ebenfalls verteilten, langlebigen [Block-Speicher](../04.block-storage/docs.de.md) ergänzt werden.

(**)
Nur auf Anfrage erhältlich

### Local SSD Storage Instanz-Typen (L1)

Local SSD Storage Instanz-Typen sind mit lokal angeschlossenem SSD Speicher mit geringer Latenz ausgestattet.
Diese Instanzen können für bestimmte Anwendungsfälle, wie verteilte Datenbanken, vorteilhaft sein.

! Verfügbarkeit und Datenbeständigkeit sind bei diesem Instanz-Typ [**verringert**](../../05.Background/02.local-storage/docs.de.md#was-passiert-im-fall-einer-hardware-stoerung), weil die Daten nur lokal auf einem Server gespeichert werden.

Für mehr Informationen lesen Sie bitte die [Dokumentation des Local SSD Storage](../../05.Background/02.local-storage/docs.de.md).

#### Ausgeglichen

Name        | API Name    | Memory | vCPUs | Storage* |
------------|-------------|--------|-------|----------|
L1 Tiny     | l1.tiny     |   4GB  |   1   |   25GB   |
L1 Small    | l1.small    |   8GB  |   2   |   50GB   |
L1 Medium   | l1.medium   |  16GB  |   4   |  100GB   |
L1 Large    | l1.large    |  32GB  |   8   |  200GB   |
L1 XLarge   | l1.xlarge   |  64GB  |  16   |  400GB   |
L1 2XLarge  | l1.2xlarge  | 128GB  |  32   |  800GB   |
L1 4XLarge  | l1.4xlarge  | 256GB  |  64   | 1600GB   |

#### CPU-Optimiert

Name          | API Name    | Memory | vCPUs | Storage* |
--------------|-------------|--------|-------|----------|
L1 CPU Tiny   | l1c.tiny     |   2GB  |   1   |   25GB   |
L1 CPU Small  | l1c.small    |   4GB  |   2   |   50GB   |
L1 CPU Medium | l1c.medium   |   8GB  |   4   |  100GB   |
L1 CPU Large    | l1c.large    |  16GB  |   8   |  200GB   |
L1 CPU XLarge   | l1c.xlarge   |  32GB  |  16   |  400GB   |
L1 CPU 2XLarge  | l1c.2xlarge  |  64GB  |  32   |  800GB   |
L1 CPU 4XLarge  | l1c.4xlarge  | 128GB  |  64   | 1600GB   |

#### RAM-Optimiert

Name          | API Name    | Memory | vCPUs | Storage* |
--------------|-------------|--------|-------|----------|
L1 RAM Tiny   | l1r.tiny     |   8GB  |   1   |   25GB   |
L1 RAM Small  | l1r.small    |  16GB  |   2   |   50GB   |
L1 RAM Medium | l1r.medium   |  32GB  |   4   |  100GB   |
L1 RAM Large    | l1r.large  |  64GB  |   8   |  200GB   |
L1 RAM XLarge   | l1r.xlarge | 128GB  |  16   |  400GB   |
L1 RAM 2XLarge  | l1r.2xlarge| 256GB  |  32   |  800GB   |


(*)
Der lokal angeschlossene Festspeicher kann ebenfalls durch unseren verteilten, langlebigen [Block-Speicher](../04.block-storage/docs.de.md) ergänzt werden,
[um weniger latenzkritische Daten dort zu speichern](../../05.Background/02.local-storage/docs.de.md#kann-local-ssd-storage-mit-distributed-storage-kombiniert-werden).

## Flavor wechseln (resizing)

!!! Nach der initialen Anforderung zum Wechseln des Flavors ist eine explizite Bestätigung erforderlich, bevor das System den Wechsel umsetzt, wenn der Wechsel über die GUI oder das CLI angefordert wird.

### M1 Instanz-Typen

Es ist möglich, die Größe zwischen allen M1 Instanz-Typen zu wechseln, weil sie den selben verteilten Speichertyp verwenden.

### L1 Instanz-Typen

Es wird zurzeit nicht unterstützt, die Größe von Local Storage Instanz-Typen zu wechseln.

### Wechseln zwischen Instance-Typen

Wenn mehr Ressourcen für eine Instanz erforderlich sind, ist die schnellste Lösung, eine neue Instanz zu bauen und ggf. die Daten über das Netzwerk oder ein angeschlossenes Volume zu migrieren.

Wenn eine Umwandlung einer vorhandenen Instanz unausweichlich erscheint, kann ein ähnliches Ergebnis erreicht werden, indem man ein Abbild der Instanz erstellt und es als Vorlage für eine neue Instanz mit einem anderen Flavor benutzt. Bitte beachten Sie, dass die Hardwarespezifikationen und CPU-Flags sich dabei ändern können.

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
