---
title: 'Orchestration Service'
published: true
date: '08-08-2018 11:55'
taxonomy:
    category:
        - docs
---

Der SysEleven Stack Orchestration Service basiert auf dem OpenStack Heat Projekt.

Mit ihm können zusammengesetzte Cloud Applikation in der OpenStack nativen HOT Template-Sprache orchestriert werden.
Sie kann als Template-Spezifikation angesehen werden, welche mit Hilfe der Orchestration Service API die weiteren SysEleven Stack Services konfigurieren kann.

Sowohl via unserer öffentlichen OpenStack API, als auch durch das SysEleven Stack Dashboard können Stacks verwaltet werden.

Die Kontrolle, die der SysEleven Stack dem Nutzer bietet, geht weit über das
Starten und Stoppen einer virtuellen Maschine hinaus. Der Nutzer des SysEleven
Stacks kontrolliert das Netzwerk seiner Umgebung, die Bereitstellung von
virtuellem Speicher, die Erstellung von Sicherheitsrichtlinien innerhalb eines
Projektes und eben auch die virtuellen Maschinen selbst. Damit erfolgreich
Webservices im SysEleven Stack betrieben werden können, müssen diese einzelnen
Bestandteile bekannt sein.  

## Netzwerk

Ich kann zwar in OpenStack virtuelle Maschinen ohne Netzwerk betreiben; für das
Gros der Anwendungen werde ich allerdings Netzwerk brauchen. In OpenStack gibt
es fünf Objekte, die im Netzwerksegment wichtig sind: Netzwerke, Subnetze,
Ports und Router sowie sogenannte Floating-IPs.

Netzwerke sind vorzustellen als Container, die einen Rahmen bilden, um darin
ein- oder mehrere Subnetze zu betreiben. Subnetze sind in der
Netzwerkarchitektur von OpenStack die tatsächlich genutzten Netzwerke, über die
Traffic von der Aussenwelt in den Server geroutet wird und auch zurück. Ohne
Subnetz wird also eine virtuelle Maschine keine Verbindung zur Aussenwelt
bekommen.

Es ist wichtig, sich vor Augen zu halten, dass alles in OpenStack ein Objekt
bzw. eine Ressource ist, das über APIs verwaltet werden kann. Das heißt, dass
ich beliebige Komponenten als Heat-Stack formulieren und starten kann. Am
Beispiel Netzwerk manchen wir das kurz in der Praxis, indem wir uns eine Datei
names `net.yaml` mit folgendem Inhalt anlegen:

```plain
heat_template_version: 2014-10-16
resources:
  net:
    type: OS::Neutron::Net
    properties:
      name: example-net
  subnet:
    type: OS::Neutron::Subnet
    properties:
      name: example-subnet
      dns_nameservers:
        - 8.8.8.8
        - 8.8.4.4
      network_id: {get_resource: net}
      ip_version: 4
      cidr: 10.0.0.0/24
      allocation_pools:
      - {start: 10.0.0.10, end: 10.0.0.250}
```

Das Beispiel starten wir mit

```shell
heat stack-create -f net.yaml netexample1
```

Wenn wir nun in die Weboberfläche zurück wechseln, sehen wir, dass wir ein
Stück Infrastruktur geschaffen haben: Im Bereich Netzwerk taucht nun ein
weiteres Netzwerk und ein Subnetz auf. Den Baustein brauchen wir aktuell nicht,
also löschen wir ihn mit folgenden Befehl:

```shell
heat stack-delete netexample1
```

Neben Netzen und Subnetzen sind Router elementare Bestandteile eines
Infrastruktur-Stacks. Router sind Notwendig, um das öffentliche Netz, und damit
das Internet, mit Subnetzen zu verbinden. Das ermöglicht zum einen den Zugriff
aus der virtuellen Maschine heraus, so dass sich ein Linux-Server z.B. mit
Updates versorgen kann. Zum anderen sind Router essentiell, damit aus dem Netz
auf eine virtuelle Maschine zugegriffen werden kann. Für ausgehenden Traffic
muss Source Network Address Translation (SNAT) auf dem Router aktiviert sein,
damit IPv4-Netzwerkverkehr der korrekten Maschine zugeordnet werden kann.
Erweitern wir das Beispiel von eben um einen Router:

```plain
heat_template_version: 2014-10-16
parameters:
  public_network_id:
    type: string
resources:
  net:
    type: OS::Neutron::Net
    properties:
      name: example-net
  subnet:
    type: OS::Neutron::Subnet
    properties:
      name: example-subnet
      dns_nameservers:
        - 8.8.8.8
        - 8.8.4.4
      network_id: {get_resource: net}
      ip_version: 4
      cidr: 10.0.0.0/24
      allocation_pools:
      - {start: 10.0.0.10, end: 10.0.0.250}
  router:
    type: OS::Neutron::Router
    properties:
      external_gateway_info: {"network": { get_param: public_network_id }}
      name: example-router
```

Wir sehen am Codebeispiel, dass erstmals ein Parameter benötigt wird: Die
`public_network_id`. Die verfügbaren Netze mit öffentlichen IPs lassen wir uns
kurzerhand anzeigen:

```shell
syselevenstack@kickstart:~$ neutron net-list
+--------------------------------------+---------------+---------------------------------------------------+
| id                                   | name          | subnets                                           |
+--------------------------------------+---------------+---------------------------------------------------+
| 02fc43b8-6de5-4e26-8bc7-7e70f0f3ca1a | float2        | 6c9e0e07-f7ac-40e3-b208-febd9d8cd0b8              |
| 4f996f76-e943-4e91-bfe2-d01b00283d86 | kickstart-net | d134c951-aaa2-4c9b-9cac-ae51b96f5533 10.0.0.0/24  |
| 80ca1837-a461-4621-b58d-79507aa8b044 | float1        | d79b58c4-23f3-476b-82f2-e00e348d25d4              |
­+--------------------------------------+---------------+---------------------------------------------------+
```

Wir entscheiden uns für eines der beiden öffentlichen Netze, in diesem Fall
float1 mit der ID `80ca1837-a461-4621-b58d-79507aa8b044` Das Objekt legen wir
ähnlich an wie eben, nur dass jetzt ein Parameter mit angegeben wird.:

```shell
heat stack-create -f net2.yaml \
                  -P public_network_id=80ca1837-a461-4621-b58d-79507aa8b044 \
                  netexample2
```

Wir können wieder in der Weboberfläche unter dem Punkt "Network topology"
feststellen, dass das Objekt korrekt angelegt wurde. Was wir aber auch sehen
können ist, dass sowohl Router als auch Netzwerk eigenständige isolierte
Objekte sind. Damit beide Objekte verbunden sind, muss ein Objekt angelegt
werden, dass genau das tut: Ein Router-Subnet-Connect. Hier der Code, um diese
Infrastruktur zu starten:

```plain
parameters:
  public_network_id:
    type: string
resources:
  net:
    type: OS::Neutron::Net
    properties:
      name: example-net
  subnet:
    type: OS::Neutron::Subnet
    properties:
      name: example-subnet
      dns_nameservers:
        - 8.8.8.8
        - 8.8.4.4
      network_id: {get_resource: net}
      ip_version: 4
      cidr: 10.0.0.0/24
      allocation_pools:
      - {start: 10.0.0.10, end: 10.0.0.250}
  router:
    type: OS::Neutron::Router
    properties:
      external_gateway_info: {"network": { get_param: public_network_id }}
      name: example-router
  router_subnet_bridge:
    type: OS::Neutron::RouterInterface
    depends_on: subnet
    properties:
      router_id: { get_resource: router }
      subnet: { get_resource: subnet }
```

Wenn wir dieses Template mit folgendem Code starten:

```shell
heat stack-create -f net3.yaml \
                  -P public_network_id=80ca1837-a461-4621-b58d-79507aa8b044 \
                  netexample3
```

sehen wir in der Weboberfläche, dass nun ein privates Netzwerk enstanden ist
(example-net), das mit dem öffentlichen Netzwerk (float1) durch einen Router
verbunden ist.

Mit dieser Infrastruktur sind wir nun in der Lage, eine virtuelle Maschine zu
starten, die Netzwerkverbindung nach aussen hat. Wie allerdings ordne ich eine
VM einem bestimmten Subnetz zu? Die fehlenden Bausteine hier sind "Ports".
Ports sind die Netzwerkschnittstellen einer virtuellen Maschine; einen Port
muss also mit einem Subnetz verbunden werden, damit die Maschine sich in das
Netz integriert. Der Code, der den Port mit einem Subnetz verknüpft, sieht z.B.
so aus:

```plain
  port:
    type: OS::Neutron::Port
    properties:
      network_id: { get_resource: net}
```

Damit haben wir einen großen Teil unserer ersten virtuellen Infrastruktur
zusammen. Es ist also an der Zeit, eine virtuelle Maschine zu starten und dabei
unsere neu geschaffene Ad-Hoc Infrastruktur zu nutzen:

```plain
heat_template_version: 2014-10-16

parameters:
 key_name:
  type: string
 public_network_id:
  type: string

resources:

  host:
    type: OS::Nova::Server
    properties:
      name: example host
      image: Ubuntu-14.04-LTS from cloud-images.ubuntu.com
      key_name: { get_param: key_name }
      flavor: m1.micro
      networks:
        - port: { get_resource: port }

  port:
    type: OS::Neutron::Port
    properties:
      network_id: { get_resource: net}

  net:
    type: OS::Neutron::Net
    properties:
      name: example-net

  subnet:
    type: OS::Neutron::Subnet
    properties:
      name: example-subnet
      dns_nameservers:
        - 8.8.8.8
        - 8.8.4.4
      network_id: {get_resource: net}
      ip_version: 4
      cidr: 10.0.0.0/24
      allocation_pools:
      - {start: 10.0.0.10, end: 10.0.0.250}

  router:
    type: OS::Neutron::Router
    properties:
      external_gateway_info: {"network": { get_param: public_network_id }}
      name: example-router

  router_subnet_bridge:
    type: OS::Neutron::RouterInterface
    depends_on: subnet
    properties:
      router_id: { get_resource: router }
      subnet: { get_resource: subnet }
```

Dieses Template starten wir wie gehabt, nur dass wir mittels `-P
key_name=<PubKeyName>` unseren in OpenStack hinterlegten öffentlichen SSH-Key
per Name referenzieren. Damit sorgen wir dafür, dass für den Standard-User der
virtuellen Maschine unser SSH-Key eingespielt wird und wir Zugriff erhalten.

Wir sehen in der Weboberfläche, dass das Netzwerk gebaut wird. Wir sehen auch,
dass ein Netzwerk, ein Subnetz und ein Router angelegt werden und alle
Bausteine miteinander verknüpft werden. Verbinden können wir uns allerdings
noch nicht auf unsere virtuelle Maschine: uns fehlt eine aus dem Internet
erreichbare öffentliche IP-Adresse. Das fehlende Bindeglied ist schnell
integriert: Wir legen ein Floating-IP-Objekt an und verbinden dieses mit
unserem Netzwerk-Port. Und siehe da: die in diesem Stack erzeugt Maschine
besitzt eine öffentliche IP. Hier der Code dazu:

```plain
heat_template_version: 2014-10-16

parameters:
 key_name:
  type: string
 public_network_id:
  type: string

resources:

  host:
    type: OS::Nova::Server
    properties:
      name: example host
      image: Ubuntu-14.04-LTS from cloud-images.ubuntu.com
      key_name: { get_param: key_name }
      flavor: m1.micro
      networks:
        - port: { get_resource: port }

  port:
    type: OS::Neutron::Port
    properties:
      network_id: { get_resource: net}

  net:
    type: OS::Neutron::Net
    properties:
      name: example-net

  subnet:
    type: OS::Neutron::Subnet
    properties:
      name: example-subnet
      dns_nameservers:
        - 8.8.8.8
        - 8.8.4.4
      network_id: {get_resource: net}
      ip_version: 4
      cidr: 10.0.0.0/24
      allocation_pools:
      - {start: 10.0.0.10, end: 10.0.0.250}

  router:
    type: OS::Neutron::Router
    properties:
      external_gateway_info: {"network": { get_param: public_network_id }}
      name: example-router

  router_subnet_bridge:
    type: OS::Neutron::RouterInterface
    depends_on: subnet
    properties:
      router_id: { get_resource: router }
      subnet: { get_resource: subnet }

  floating_ip:
    type: OS::Neutron::FloatingIP
    properties:
      floating_network: { get_param: public_network_id }
      port_id: { get_resource: port }
```

## Security Groups

Doch auch, wenn wir uns jetzt auf die Maschine verbinden, scheitern wir mit
einem Timeout im Browser bzw. bei dem Versuch, per SSH eine Verbindung zum Host
aufzubauen. Was fehlt? Wir müssen uns überlegen, welchem Zweck die Maschine
dienen soll, die wir starten und daraufhin den entsprechenden Netzwerkverkehr
erlauben. Im SysEleven Stack ist die Standard-Sicherheitsrichlinie, alle
Verbindungen aus dem Internet auf eine virtuelle Maschine zu unterbinden. Das
ist gut und richtig so, damit wir geschützte Umgebungen betreiben können und
beispielsweise ein Datenbankserver nicht einfach aus dem Internet erreichbar
ist. Es ist auch kein großes Problem, das letzte Bindeglied unserem Setup
hinzuzufügen: Eine Security Group. Security Groups folgen von der Bedienung her
den gängigen Regeln einer Firewall, wie sie bespielsweise unter Linux mit
Iptables implementiert ist. D.h., es muss das Protokoll (TCP/UDP/ICMP), ggf.
der Port-Range und Quell- und Zieladressräume definiert werden. Ebenfalls muss
die Fließrichtung des Netzwerkverkehrs angegeben werden, für den diese Regel
gilt: Eingehender Verkehr wird mit *Ingress* bezeichnet, ausgehender Verkehr
mit *Egress*. Starten wir nun unseren Stack, haben wir alle Bausteine
erfolgreich verknüpft und haben unsere erste Maschine live. Keine Angst, der
hier betriebene Aufwand wiederholt sich nicht mit jeder Installation einer
Maschine. Alles, was wir brauchen, ist eine Bibliothek mit Templates, die
unsere Anwendungsfälle abdeckt. Hier der Code, der unsere minimale sinnvolle
Infrastruktur startet:

```plain
heat_template_version: 2014-10-16

parameters:
 key_name:
  type: string
 public_network_id:
  type: string

resources:

  host:
    type: OS::Nova::Server
    properties:
      name: example host
      image: Ubuntu-14.04-LTS from cloud-images.ubuntu.com
      key_name: { get_param: key_name }
      flavor: m1.micro
      networks:
        - port: { get_resource: port }

  port:
    type: OS::Neutron::Port
    properties:
      network_id: { get_resource: net}

  net:
    type: OS::Neutron::Net
    properties:
      name: example-net

  subnet:
    type: OS::Neutron::Subnet
    properties:
      name: example-subnet
      dns_nameservers:
        - 8.8.8.8
        - 8.8.4.4
      network_id: {get_resource: net}
      ip_version: 4
      cidr: 10.0.0.0/24
      allocation_pools:
      - {start: 10.0.0.10, end: 10.0.0.250}

  router:
    type: OS::Neutron::Router
    properties:
      external_gateway_info: {"network": { get_param: public_network_id }}
      name: example-router

  router_subnet_bridge:
    type: OS::Neutron::RouterInterface
    depends_on: subnet
    properties:
      router_id: { get_resource: router }
      subnet: { get_resource: subnet }

  floating_ip:
    type: OS::Neutron::FloatingIP
    properties:
      floating_network: { get_param: public_network_id }
      port_id: { get_resource: port }

  allow_ssh:
    type: OS::Neutron::SecurityGroup
    properties:
      description: allow incoming SSH and ICMP traffic from anywhere.
      name: allow incoming traffic, tcp port 22 and icmp
      rules:
        - { direction: ingress, remote_ip_prefix: 0.0.0.0/0, port_range_min: 22, port_range_max: 22, protocol: tcp }
        - { direction: ingress, remote_ip_prefix: 0.0.0.0/0, protocol: icmp }
```

Jetzt können wir uns erfolgreich in der virtuellen Maschine einloggen. Dafür lassen wir uns die IP-Adresse der Maschine anzeigen:

```shell
nova list
```

Diese IP-Adresse kopieren wir uns und loggen uns ein:

```shell
ssh ec2-user@<IP-Adresse>
```

Der ec2-user ist der Standard-User aus Ubuntu-Cloudimages, so lange nichts anderes konfiguriert wurde.

Wir haben nun die Bausteine Netzwerk und virtuelle Maschinen gezeigt. Das ist
im Prinzip alles, was wir für den Betrieb eines einfachen Setups brauchen. Doch
ganz so anspruchslos sind meist auch die einfachsten Hosting-Projekte nicht:
Was passiert, wenn unsere Maschine größer werden soll als der eingestellte
Flavor? und wo sind meine Daten, die ich in der Maschine aufgebaut habe, wenn
ich den Stack lösche, wie ich es gelernt habe? Die Antwort auf beide Fragen
findet sich [hier](../../02.Documentation/03.block-storage/default.de.md). Jede Maschine im Syseleven Stack wird derzeit
mit einer Größe von 50GB Storage ausgeliefert. Brauche ich zusätzlichen
Speicher, muss ich auf sogenannte Volumes zurückgreifen. Doch auch aus einer
anderen Überlegung heraus sind Volumes interessant: Wenn ich meine Maschine
löschen und dennoch meine Daten erhalten möchte (beispielsweise die Daten
meiner Datenbank), kann ich dies mit Volumes erreichen. Während der Speicher
einer VM also als vergänglich, ephemeral, bezeichnet werden kann, kann ich
Volumes als persistenten Speicher nutzen, der über den Zeitraum der Existenz
eines Stacks hinaus zur Verfügung steht. Dafür lege ich mir am besten einen
eigenen Stack an, der als einzige Aufgabe hat, mein Volume in der gewünschten
Größe anzulegen.

<!--- TODO: Code fehlt. -->

Wenn ich dieses Template starte, erhalte ich ein Volume mit einer UID. Diese
UID kann ich, über Parameter gesteuert, an mein Template der virtuellen
Maschine übergeben. In der virtuellen Maschine taucht nun ein weiteres
Blockdevice, also im Grunde eine weitere Festplatte, auf. So habe ich eine
Lösung für die Persistenz meiner Daten.

Ebenfalls lässt sich so ein Setup realisieren, bei dem eine virtuelle Maschine
mehr Speicherplatz zur Verfügung gestellt bekommt, als die 50GB des
Grundsystems. Hier bietet es sich jedoch an, das Volume nicht separiert zu
erstellen, sondern in dem Stack, in dem die Maschine selbst auch erstellt wird.
Ein vollständiges Setup sieht dann so aus:

<!--- TODO: Code fehlt. -->

## Bestandteile eines Heat-Templates

Wie ist ein Heat-Template, mit dem ich jeden Aspekt meiner Infrastruktur
beschreiben kann, aufgebaut? Die Dateien, die die virtuelle Infrastruktur
beschreiben, sind in YAML geschrieben. Sie sind unterteilt in fünf Sektionen:
`heat_template_version`, `description`, `parameters`, `resources` und `output`.
Die aktuelle Spezifikation aller Heat-Bestandteile und Optionen findet sich
online in der [Online-Dokumentation des Heat-Projekts](http://docs.openstack.org/developer/heat/template_guide/openstack.html)

### Heat-Version

```plain
heat_template_version: 2014-10-16
```

Ein Heat-Template wird eingeleitet mit der Versionsnummer der
Beschreibungssprache selbst; d.h. in dieser Zeile wird festgelegt, welches Set
von Features in den Templates verwendet werden kann und in welcher Notation.
Da die Sprache selbst sich von Release zu Release ändert, ist diese Zeile
erforderlich.

### Description

Eine Beschreibung eines Heat-Stacks ist sinnvoll, aber optional. Sinnvoll ist
sie auch deshalb, weil der Text aus dieser Sektion in der OpenStack-Datenbank
abgelegt wird und daher die hier enthaltenen Informationen abrufbar sind, wenn
der Stack gestartet ist.

### Parameter

Mit der Parametrisierung eines Heat-Stacks wird die Wiederverwendbarkeit
erhöht: Wenn ich für ein Kundenprojekt eine sinnvolle Umgebung definiert habe,
kann ich mit leichten Anpassungen die selbe Umgebung ein weiteres Mal starten.
Hierzu dienen Parameter. Parameter werden in dieser Sektion deklariert.
Definiert werden sie entweder als Übergebene Argumente auf der Kommandozeile
(mit dem Schalter `-P <Parameter>=<Wert>`, in einem sogenannten
Environment-File, oder im Fall modular aufgebauter Heat-Stacks in dem
Eltern-Modul für das Kind-Modul als Übergabewert. Die Deklaration sieht so
aus:

```plain
parameters:
  number_appservers
    type: string
    default: 4
```

Wie man sieht, kann ein optionaler Default angegeben werden. Wenn dieser
gesetzt ist, wird ein Parameter optional. Andersherum formuliert: Gibt es
keinen Default, wird der Parameter erzwungen, wenn man den Heat-Stack starten
möchte. Das ist beispielsweise dann sinnvoll, wenn ein Storage-Volume über
einen Parameter eingebunden werden soll, da die UID des Volumes nicht im
Vorhinein bekannt ist.

### Resources

Die Resources-Sektion ist die wichtigste in einem Template: An dieser Stelle wird festgelegt, was überhaupt gebaut werden soll. Eine Resource kann ein beliebiges Objekt in OpenStack sein. Sehr oft geht es darum, verschiedene Resourcen nicht nur anzulegen, sondern miteinandander sinnvol zu verknüpfen. Ein Beispiel: Damit eine virtuelle Maschine Netzwerk bekommt, muss sie mit einem Port (das virtuelle Äquivalent zu einer Netzwerkkarte) verknüpft werden. Diese Verknüpfung geschieht, indem innerhalb der Maschinendefinition mittels “get_resource” auf die Port-Ressource verwiesen wird:

```plain
resources:
  example_instance
    type: OS:Nova::Server
    properties:
      key_name: { get_param: key_name }
      image: CirrOS 0.3.2 amd64
      flavor: m1.tiny
      networks:
- port: { get_resource: example_port }

```

Wie an diesem Beispiel zu sehen ist, gibt es noch eine andere häufig genutzte Referenzierung: Mit “get_param” wir auf den Inhalt der Parameter zugegriffen, die in der Parameterdeklaration eingeführt und deren Inhalt definiert wurde.

### Output

Die Output-Sektion liefert die Möglichkeit, Parameterwerte auch nach dem
Anlegen eines Stacks abrufen zu können; sie ist völlig optional. Der Aufbau ist
einfach: einem Parameter-Namen folgt der Wert, mit dem der Parameter befüllt
werden soll. So kann beispielsweise eine Floating-IP in der Beschreibung eines
Stacks gespeichert werden:

```plain
outputs:
  loadbalancer_public_ip:
    description: Floating IP address of loadbalancer in public network
    value: { get_attr: [ loadbalancer_floating_ip, floating_ip_address ] }
```