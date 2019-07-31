---
title: 'VPN (as a Service) erstellen und einschalten'
date: '02-01-2019 12:20'
taxonomy:
    category:
        - docs
---

## IPSec und IKE basiertes VPN as a Service

### Überblick

OpenStack Neutron bietet Site-to-Site IPsec IKEv1 VPN an, als VPNaaS (VPN as a Service).
Das bedeutet, dass IPsec-Regeln und -Verbindungen direkt mit OpenStack konfiguriert werden können.
Im Folge dessen sind keine externen Instanzen (virtuelle Maschinen) für VPN mehr nötig.

!!! **Verfügbarkeit**
!!! VPNaaS ist nun in unseren beiden Regionen 'dbl' und 'cbk' verfügbar.

## Voraussetzungen

* Du solltest Wissen über die Nutzung von OpenStack CLI-Tools verfügen [OpenStack CLI-Tools](../../03.Howtos/02.openstack-cli/docs.de.md).
* Environment-Variablen müssen für den API-Zugang gesetzt sein. Siehe das Beispiel [API-Access-Tutorial](../../02.Tutorials/02.api-access/docs.en.md).
* In dieser Anleitung wirst du zwei seperate Netzwerke in unterschiedlichen Regionen anlegen und sie miteinander verbinden. Wenn du zwei existierende Netzwerke verbinden möchtest, überspringe die Schritte eins und zwei.

## Wie baut man IPSec-VPN

### Schritt eins: Netzwerk für die linke Seite erstellen

```shell
$ openstack network create left-network
+---------------------------+--------------------------------------+
| Field                     | Value                                |
+---------------------------+--------------------------------------+
| admin_state_up            | UP                                   |
| availability_zone_hints   | None                                 |
| availability_zones        | None                                 |
| created_at                | 2018-12-27T10:49:17Z                 |
| description               |                                      |
| dns_domain                | None                                 |
| id                        | e4f43f87-3b31-41e4-9803-8e10edd3167e |
| ipv4_address_scope        | None                                 |
| ipv6_address_scope        | None                                 |
| is_default                | None                                 |
| is_vlan_transparent       | None                                 |
| location                  | None                                 |
| mtu                       | None                                 |
| name                      | left-network                         |
| port_security_enabled     | True                                 |
| project_id                | 70061ce0cd2e47ef9d7dc82174dc9923     |
| provider:network_type     | None                                 |
| provider:physical_network | None                                 |
| provider:segmentation_id  | None                                 |
| qos_policy_id             | None                                 |
| revision_number           | 2                                    |
| router:external           | Internal                             |
| segments                  | None                                 |
| shared                    | False                                |
| status                    | ACTIVE                               |
| subnets                   |                                      |
| tags                      |                                      |
| updated_at                | 2018-12-27T10:49:17Z                 |
+---------------------------+--------------------------------------+
```

#### 1. Subnetz für das obenstehende Netzwerk (links) allokieren

```shell
$ openstack subnet create left-subnet \
  --network left-network \
  --subnet-range 10.1.0.0/24 \
  --gateway 10.1.0.1 \
  --dns-nameserver 8.8.8.8
+-------------------+--------------------------------------+
| Field             | Value                                |
+-------------------+--------------------------------------+
| allocation_pools  | 10.1.0.2-10.1.0.254                  |
| cidr              | 10.1.0.0/24                          |
| created_at        | 2018-12-27T13:00:49Z                 |
| description       |                                      |
| dns_nameservers   | 8.8.8.8                              |
| enable_dhcp       | True                                 |
| gateway_ip        | 10.1.0.1                             |
| host_routes       |                                      |
| id                | 38346388-4b09-4f0a-a3d1-b1a5f6587f4c |
| ip_version        | 4                                    |
| ipv6_address_mode | None                                 |
| ipv6_ra_mode      | None                                 |
| location          | None                                 |
| name              | left-subnet                          |
| network_id        | e4f43f87-3b31-41e4-9803-8e10edd3167e |
| project_id        | 70061ce0cd2e47ef9d7dc82174dc9923     |
| revision_number   | 2                                    |
| segment_id        | None                                 |
| service_types     | None                                 |
| subnetpool_id     | None                                 |
| tags              |                                      |
| updated_at        | 2018-12-27T13:00:49Z                 |
+-------------------+--------------------------------------+
```

#### 2. Einen Router am linken Netzwerk erstellen

```shell
$ openstack router create left-router
+-------------------------+--------------------------------------+
| Field                   | Value                                |
+-------------------------+--------------------------------------+
| admin_state_up          | UP                                   |
| availability_zone_hints | None                                 |
| availability_zones      | None                                 |
| created_at              | 2018-12-27T13:13:16Z                 |
| description             |                                      |
| distributed             | None                                 |
| external_gateway_info   | None                                 |
| flavor_id               | None                                 |
| ha                      | None                                 |
| id                      | c971c888-a0bb-47e3-a922-565899c9f090 |
| location                | None                                 |
| name                    | left-router                          |
| project_id              | 70061ce0cd2e47ef9d7dc82174dc9923     |
| revision_number         | 1                                    |
| routes                  |                                      |
| status                  | ACTIVE                               |
| tags                    |                                      |
| updated_at              | 2018-12-27T13:13:16Z                 |
+-------------------------+--------------------------------------+
```

#### 3. Interface für den Router anlegen und zur äußeren Welt verlinken

```shell
$ openstack port create \
  --fixed-ip subnet=left-subnet,ip-address=10.1.0.1 \
  --network left-network \
  left-port
+-------------------------+-------------------------------------------------------------------------+
| Field                   | Value                                                                   |
+-------------------------+-------------------------------------------------------------------------+
| admin_state_up          | UP                                                                      |
| allowed_address_pairs   |                                                                         |
| binding_host_id         | None                                                                    |
| binding_profile         | None                                                                    |
| binding_vif_details     | None                                                                    |
| binding_vif_type        | None                                                                    |
| binding_vnic_type       | normal                                                                  |
| created_at              | 2018-12-27T13:41:21Z                                                    |
| data_plane_status       | None                                                                    |
| description             |                                                                         |
| device_id               |                                                                         |
| device_owner            |                                                                         |
| dns_assignment          | None                                                                    |
| dns_domain              | None                                                                    |
| dns_name                | None                                                                    |
| extra_dhcp_opts         |                                                                         |
| fixed_ips               | ip_address='10.1.0.1', subnet_id='38346388-4b09-4f0a-a3d1-b1a5f6587f4c' |
| id                      | 93c4691c-405b-4a10-b8c3-2cd59b799b16                                    |
| location                | None                                                                    |
| mac_address             | fa:16:3e:bf:1b:62                                                       |
| name                    | left-port                                                               |
| network_id              | e4f43f87-3b31-41e4-9803-8e10edd3167e                                    |
| port_security_enabled   | True                                                                    |
| project_id              | 70061ce0cd2e47ef9d7dc82174dc9923                                        |
| propagate_uplink_status | None                                                                    |
| qos_policy_id           | None                                                                    |
| revision_number         | 5                                                                       |
| security_group_ids      | 7406b3d8-0937-4fbc-b6cb-50f229653a80                                    |
| status                  | ACTIVE                                                                  |
| tags                    |                                                                         |
| trunk_details           | None                                                                    |
| updated_at              | 2018-12-27T13:41:21Z                                                    |
+-------------------------+-------------------------------------------------------------------------+
```

```shell
openstack router add port left-router left-port
```

```shell
openstack router set left-router \
  --external-gateway ext-net
```

### Schritt zwei: Die vorherigen Schritte wiederholen, um ein Netzwerk für die rechte Seite zu erstellen

```shell
$ openstack network create right-network
+---------------------------+--------------------------------------+
| Field                     | Value                                |
+---------------------------+--------------------------------------+
| admin_state_up            | UP                                   |
| availability_zone_hints   | None                                 |
| availability_zones        | None                                 |
| created_at                | 2018-12-27T13:53:16Z                 |
| description               |                                      |
| dns_domain                | None                                 |
| id                        | 46e614d1-baaa-46cf-8e4c-c96fe63fecf2 |
| ipv4_address_scope        | None                                 |
| ipv6_address_scope        | None                                 |
| is_default                | None                                 |
| is_vlan_transparent       | None                                 |
| location                  | None                                 |
| mtu                       | None                                 |
| name                      | right-network                        |
| port_security_enabled     | True                                 |
| project_id                | 70061ce0cd2e47ef9d7dc82174dc9923     |
| provider:network_type     | None                                 |
| provider:physical_network | None                                 |
| provider:segmentation_id  | None                                 |
| qos_policy_id             | None                                 |
| revision_number           | 2                                    |
| router:external           | Internal                             |
| segments                  | None                                 |
| shared                    | False                                |
| status                    | ACTIVE                               |
| subnets                   |                                      |
| tags                      |                                      |
| updated_at                | 2018-12-27T13:53:16Z                 |
+---------------------------+--------------------------------------+
```

#### 1. Subnetz für das obenstehende Netzwerk (rechts) allokieren

```shell
$ openstack subnet create right-subnet  \
  --network right-network \
  --subnet-range 10.2.0.0/24 \
  --gateway 10.2.0.1
+-------------------+--------------------------------------+
| Field             | Value                                |
+-------------------+--------------------------------------+
| allocation_pools  | 10.2.0.2-10.2.0.254                  |
| cidr              | 10.2.0.0/24                          |
| created_at        | 2018-12-27T13:56:54Z                 |
| description       |                                      |
| dns_nameservers   |                                      |
| enable_dhcp       | True                                 |
| gateway_ip        | 10.2.0.1                             |
| host_routes       |                                      |
| id                | a1026c99-8dd6-496a-a565-74a49f2e95ec |
| ip_version        | 4                                    |
| ipv6_address_mode | None                                 |
| ipv6_ra_mode      | None                                 |
| location          | None                                 |
| name              | right-subnet                         |
| network_id        | 46e614d1-baaa-46cf-8e4c-c96fe63fecf2 |
| project_id        | 70061ce0cd2e47ef9d7dc82174dc9923     |
| revision_number   | 2                                    |
| segment_id        | None                                 |
| service_types     | None                                 |
| subnetpool_id     | None                                 |
| tags              |                                      |
| updated_at        | 2018-12-27T13:56:54Z                 |
+-------------------+--------------------------------------+
```

#### 2. Einen Router am rechten Netzwerk erstellen

```shell
$ openstack router create right-router
+-------------------------+--------------------------------------+
| Field                   | Value                                |
+-------------------------+--------------------------------------+
| admin_state_up          | UP                                   |
| availability_zone_hints | None                                 |
| availability_zones      | None                                 |
| created_at              | 2018-12-27T13:57:47Z                 |
| description             |                                      |
| distributed             | None                                 |
| external_gateway_info   | None                                 |
| flavor_id               | None                                 |
| ha                      | None                                 |
| id                      | 56f95788-1c34-432f-8ad6-f304776221a2 |
| location                | None                                 |
| name                    | right-router                         |
| project_id              | 70061ce0cd2e47ef9d7dc82174dc9923     |
| revision_number         | 1                                    |
| routes                  |                                      |
| status                  | ACTIVE                               |
| tags                    |                                      |
| updated_at              | 2018-12-27T13:57:47Z                 |
+-------------------------+--------------------------------------+
```

#### 3. Interface für den Router anlegen und zur äußeren Welt verlinken

```shell
$ openstack port create \
  --fixed-ip subnet=right-subnet,ip-address=10.2.0.1 \
  --network right-network \
  right-port
+-------------------------+-------------------------------------------------------------------------+
| Field                   | Value                                                                   |
+-------------------------+-------------------------------------------------------------------------+
| admin_state_up          | UP                                                                      |
| allowed_address_pairs   |                                                                         |
| binding_host_id         | None                                                                    |
| binding_profile         | None                                                                    |
| binding_vif_details     | None                                                                    |
| binding_vif_type        | None                                                                    |
| binding_vnic_type       | normal                                                                  |
| created_at              | 2018-12-27T13:59:43Z                                                    |
| data_plane_status       | None                                                                    |
| description             |                                                                         |
| device_id               |                                                                         |
| device_owner            |                                                                         |
| dns_assignment          | None                                                                    |
| dns_domain              | None                                                                    |
| dns_name                | None                                                                    |
| extra_dhcp_opts         |                                                                         |
| fixed_ips               | ip_address='10.2.0.1', subnet_id='a1026c99-8dd6-496a-a565-74a49f2e95ec' |
| id                      | dfe963ec-4f36-4144-96c2-071af9d3c920                                    |
| location                | None                                                                    |
| mac_address             | fa:16:3e:93:06:ad                                                       |
| name                    | right-port                                                              |
| network_id              | 46e614d1-baaa-46cf-8e4c-c96fe63fecf2                                    |
| port_security_enabled   | True                                                                    |
| project_id              | 70061ce0cd2e47ef9d7dc82174dc9923                                        |
| propagate_uplink_status | None                                                                    |
| qos_policy_id           | None                                                                    |
| revision_number         | 5                                                                       |
| security_group_ids      | 7406b3d8-0937-4fbc-b6cb-50f229653a80                                    |
| status                  | ACTIVE                                                                  |
| tags                    |                                                                         |
| trunk_details           | None                                                                    |
| updated_at              | 2018-12-27T13:59:44Z                                                    |
+-------------------------+-------------------------------------------------------------------------+
```

```shell
openstack router add port right-router right-port
```

```shell
openstack router set right-router \
  --external-gateway ext-net
```

### Schritt drei: IKE- und IPSec-Regeln erstellen

```shell
$ openstack vpn ike policy create ikepolicy
+-------------------------------+----------------------------------------+
| Field                         | Value                                  |
+-------------------------------+----------------------------------------+
| Authentication Algorithm      | sha1                                   |
| Description                   |                                        |
| Encryption Algorithm          | aes-128                                |
| ID                            | ff1f540b-6ea9-42ee-8973-cba841835dfa   |
| IKE Version                   | v1                                     |
| Lifetime                      | {u'units': u'seconds', u'value': 3600} |
| Name                          | ikepolicy                              |
| Perfect Forward Secrecy (PFS) | group5                                 |
| Phase1 Negotiation Mode       | main                                   |
| Project                       | 70061ce0cd2e47ef9d7dc82174dc9923       |
| project_id                    | 70061ce0cd2e47ef9d7dc82174dc9923       |
+-------------------------------+----------------------------------------+
```

```shell
$ openstack vpn ipsec policy create ipsecpolicy
+-------------------------------+----------------------------------------+
| Field                         | Value                                  |
+-------------------------------+----------------------------------------+
| Authentication Algorithm      | sha1                                   |
| Description                   |                                        |
| Encapsulation Mode            | tunnel                                 |
| Encryption Algorithm          | aes-128                                |
| ID                            | f9633763-2393-4ec3-824a-1e07dd7cfc2e   |
| Lifetime                      | {u'units': u'seconds', u'value': 3600} |
| Name                          | ipsecpolicy                            |
| Perfect Forward Secrecy (PFS) | group5                                 |
| Project                       | 70061ce0cd2e47ef9d7dc82174dc9923       |
| Transform Protocol            | esp                                    |
| project_id                    | 70061ce0cd2e47ef9d7dc82174dc9923       |
+-------------------------------+----------------------------------------+
```

### Schritt vier: VPN-Services erstellen

Erstellen Sie je einen VPN-Service für die linke und die rechte Seite
und notieren Sie sich die externe IP-Adresse, die der VPN-Service
zugewiesen bekommen hat.

#### 1. VPN-Service auf der linken Seite erstellen

```shell
$ openstack vpn service create left-vpn \
  --router left-router \
  --subnet left-subnet
+----------------+--------------------------------------+
| Field          | Value                                |
+----------------+--------------------------------------+
| Description    |                                      |
| ID             | a29b6e62-f456-44b1-9774-28cefc1df9fb |
| Name           | left-vpn                             |
| Project        | 70061ce0cd2e47ef9d7dc82174dc9923     |
| Router         | c971c888-a0bb-47e3-a922-565899c9f090 |
| State          | True                                 |
| Status         | PENDING_CREATE                       |
| Subnet         | 38346388-4b09-4f0a-a3d1-b1a5f6587f4c |
| external_v4_ip | 195.192.128.58                       |
| external_v6_ip | None                                 |
| project_id     | 70061ce0cd2e47ef9d7dc82174dc9923     |
+----------------+--------------------------------------+
```

#### 2. VPN-Service auf der rechten Seite erstellen

```shell
$ openstack vpn service create right-vpn \
  --router right-router \
  --subnet right-subnet
+----------------+--------------------------------------+
| Field          | Value                                |
+----------------+--------------------------------------+
| Description    |                                      |
| ID             | d7c3def8-82f9-4e1d-94ae-0b8d29651cd4 |
| Name           | right-vpn                            |
| Project        | 70061ce0cd2e47ef9d7dc82174dc9923     |
| Router         | 56f95788-1c34-432f-8ad6-f304776221a2 |
| State          | True                                 |
| Status         | PENDING_CREATE                       |
| Subnet         | a1026c99-8dd6-496a-a565-74a49f2e95ec |
| external_v4_ip | 195.192.130.187                      |
| external_v6_ip | None                                 |
| project_id     | 70061ce0cd2e47ef9d7dc82174dc9923     |
+----------------+--------------------------------------+
```

### Schritt fünf: Site-Connections aufbauen

#### 1. Site-Connection auf der linken Seite aufbauen

Erstellen Sie eine Site-Connection namens "left-conn" vom linken VPN-Serive ("left-vpn") zur rechten Seite
(Peer 195.192.130.187 ist die externe IP-Adresse des rechten VPN-Service, 10.2.0.0/24 das rechte Subnet).

```shell
$ openstack vpn ipsec site connection create left-conn \
  --vpnservice left-vpn \
  --ikepolicy ikepolicy \
  --ipsecpolicy ipsecpolicy \
  --local-id left-peer.domain.example \
  --peer-address 195.192.130.187 \
  --peer-id right-peer.domain.example \
  --peer-cidr 10.2.0.0/24 \
  --psk secret
+--------------------------+--------------------------------------------------------+
| Field                    | Value                                                  |
+--------------------------+--------------------------------------------------------+
| Authentication Algorithm | psk                                                    |
| Description              |                                                        |
| ID                       | 56de16f8-deff-4956-a0d0-2f8a04054853                   |
| IKE Policy               | ff1f540b-6ea9-42ee-8973-cba841835dfa                   |
| IPSec Policy             | f9633763-2393-4ec3-824a-1e07dd7cfc2e                   |
| Initiator                | bi-directional                                         |
| Local Endpoint Group ID  | None                                                   |
| Local ID                 | left-peer.domain.example                               |
| MTU                      | 1500                                                   |
| Name                     | left-conn                                              |
| Peer Address             | 195.192.130.187                                        |
| Peer CIDRs               | 10.2.0.0/24                                            |
| Peer Endpoint Group ID   | None                                                   |
| Peer ID                  | right-peer.domain.example                              |
| Pre-shared Key           | secret                                                 |
| Project                  | 70061ce0cd2e47ef9d7dc82174dc9923                       |
| Route Mode               | static                                                 |
| State                    | True                                                   |
| Status                   | PENDING_CREATE                                         |
| VPN Service              | a29b6e62-f456-44b1-9774-28cefc1df9fb                   |
| dpd                      | {u'action': u'hold', u'interval': 30, u'timeout': 120} |
| project_id               | 70061ce0cd2e47ef9d7dc82174dc9923                       |
+--------------------------+--------------------------------------------------------+
```

#### 2. Site-Connection auf der rechten Seite aufbauen

Erstellen Sie eine Site-Connection namens "right-conn" vom rechten VPN-Serive ("right-vpn") zur linken Seite
(Peer 195.192.128.58 ist die externe IP-Adresse des linken VPN-Service, 10.1.0.0/24 das linke Subnet).

```shell
$ openstack vpn ipsec site connection create right-conn \
  --vpnservice right-vpn \
  --ikepolicy ikepolicy \
  --ipsecpolicy ipsecpolicy \
  --local-id right-peer.domain.example \
  --peer-address 195.192.128.58 \
  --peer-id left-peer.domain.example \
  --peer-cidr 10.1.0.0/24 \
  --psk secret
+--------------------------+--------------------------------------------------------+
| Field                    | Value                                                  |
+--------------------------+--------------------------------------------------------+
| Authentication Algorithm | psk                                                    |
| Description              |                                                        |
| ID                       | ead7e3dc-0515-4abf-9d7b-17e8bbbe5328                   |
| IKE Policy               | ff1f540b-6ea9-42ee-8973-cba841835dfa                   |
| IPSec Policy             | f9633763-2393-4ec3-824a-1e07dd7cfc2e                   |
| Initiator                | bi-directional                                         |
| Local Endpoint Group ID  | None                                                   |
| Local ID                 | right-peer.domain.example                              |
| MTU                      | 1500                                                   |
| Name                     | right-conn                                             |
| Peer Address             | 195.192.128.58                                         |
| Peer CIDRs               | 10.1.0.0/24                                            |
| Peer Endpoint Group ID   | None                                                   |
| Peer ID                  | left-peer.domain.example                               |
| Pre-shared Key           | secret                                                 |
| Project                  | 70061ce0cd2e47ef9d7dc82174dc9923                       |
| Route Mode               | static                                                 |
| State                    | True                                                   |
| Status                   | PENDING_CREATE                                         |
| VPN Service              | d7c3def8-82f9-4e1d-94ae-0b8d29651cd4                   |
| dpd                      | {u'action': u'hold', u'interval': 30, u'timeout': 120} |
| project_id               | 70061ce0cd2e47ef9d7dc82174dc9923                       |
+--------------------------+--------------------------------------------------------+
```

### Schritt sechs: Die aufgebaute Verbindung testen

Erstelle virtuelle Maschinen mit Interfaces in `right-subnet` und `left-subnet` und überprüfe, dass sie einander erreichen können, indem du ICMP Echo Requests zu den internen IP-Adressen sendest (Ping).
Beachte, dass eine der virtuellen Maschinen eine Floating-IP-Adresse benötigt, damit du die VM von außen erreichen kannst.

### Schritt sieben: Inspizieren und Aufräumen

Um die soeben im Rahmen der Anleitung erstellten Komponenten anzusehen

```shell
openstack network list --long
openstack subnet list --long
openstack router list --long
openstack port list --long
openstack vpn ipsec policy list --long
openstack vpn ike policy list --long
openstack vpn service list --long
openstack vpn ipsec site connection list --long
```

Um die Komponenten nach Gebrauch in der umgekehrten Reihenfolge wieder abzuräumen, gehen wir folgendermaßen vor:

```shell
openstack vpn ipsec site connection delete left-conn
openstack vpn service delete left-vpn
openstack vpn ike policy delete ikepolicy
openstack vpn ipsec policy delete ipsecpolicy
openstack router remove port left-router left-port
openstack router delete left-router
openstack subnet delete left-subnet
openstack network delete left-network
```

```shell
openstack vpn ipsec site connection delete right-conn
openstack vpn service delete right-vpn
openstack vpn ike policy delete ikepolicy
openstack vpn ipsec policy delete ipsecpolicy
openstack router remove port right-router right-port
openstack router delete right-router
openstack subnet delete right-subnet
openstack network delete right-network
```
