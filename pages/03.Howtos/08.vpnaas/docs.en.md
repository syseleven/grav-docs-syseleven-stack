---
title: 'Create a VPN (as a Service)'
date: '02-01-2019 12:20'
taxonomy:
    category:
        - docs
---

## IPSec and IKE based VPN as a Service

### Overview

OpenStack's Neutron provides Site-to-Site IPsec IKEv1 VPN through VPN as a Service (VPNaaS).
This means that IPsec policies and connections are configured within the OpenStack.
No dedicated virtual machines are required to use this service.

!!! **Feature availability**
!!! VPNaaS is currently available in both our regions 'dbl' and 'cbk'.

## Prerequisites

* You know the basics of using the [OpenStack CLI-Tools](../../03.Howtos/02.openstack-cli/docs.en.md).
* Environment variables are set, like shown in the [API-Access-Tutorial](../../02.Tutorials/02.api-access/docs.en.md).
* Following this tutorial you will create new OpenStack networks and subnets. If you want to connect two existing networks, skip steps one and two.

## How to setup a IPSec VPN

### Step One: Create left network

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

#### 1. Allocating subnet for the left network

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

#### 2. Creating a router in the left network

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

#### 3. Attaching a port to the router and link it to the external network

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

### Step Two: Repeat the previous steps and create the right network

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

#### 1. Allocating subnet for the right network

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

#### 2. Creating a router in the right network

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

#### 3. Attaching a port to the router and link it to the external network

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

### Step Three: Create an IKE and IPSec policy

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

### Step Four: Create VPN services on both sides

Create a VPN service on the left side and another on the right side
and note the external IP addresses that were assigned to the VPN services.

#### 1. Create the VPN service on the left side

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

#### 1. Create the VPN service on the right side

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

### Step Five: Create the site connections

#### 1. Create the site connection on the left side

Create a site connection named "left-conn" from the left side (VPN service "left-vpn") to the right side
(peer IP address is 195.192.130.187 and 10.2.0.0/24 is the right subnet).

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

#### 2. Create the site connection on the right side

Create a site connection named "right-conn" from the right side (VPN service "right-vpn") to the left side
(peer IP address is 195.192.128.58 and 10.1.0.0/24 is the left subnet).


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

### Step Six: Check if the VPN works properly

Create virtual machines with interfaces in `right-subnet` and `left-subnet`, and make sure they can reach each other, by sending ICMP echo requests to internal IP addresses.
Note that one of this virtual machines needs to have a Floating IP address, so you can reach the VM itself.

### Step seven: Inspect and clean up

To list the components just created within this howto

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

To remove those components in the reverse order of creation

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
