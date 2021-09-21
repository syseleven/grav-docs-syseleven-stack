---
title: 'Create a VPN (using VPNaaS)'
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
!!! VPNaaS is currently available in all our regions.

## Prerequisites

* You know the basics of using the [OpenStack CLI-Tools](../../03.Howtos/02.openstack-cli/docs.en.md).
* Environment variables are set, like shown in the [API-Access-Tutorial](../../02.Tutorials/02.api-access/docs.en.md).
* Following this tutorial you will create new OpenStack networks and subnets in different regions. If you want to connect two existing networks, skip steps one and two.

## How to set up a IPSec VPN

In this tutorial you will create two VPN services. The described steps don't mention it, but they assume that the "left" network and VPN service are created in one region and the "right" network and VPN service in another.

### Step One: Create left network

#### 1. Create left network

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

#### 2. Allocate subnet for the left network

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

#### 3. Create a router for the left network

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

#### 4. Attach the subnet to the router

```shell
$ openstack router add subnet left-router left-subnet
```

#### 5. Link the router to the external network

```shell
$ openstack router set left-router --external-gateway ext-net
```

### Step Two: Repeat the previous steps and create the right network

#### 1. Create the right network

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

#### 2. Allocate a subnet for the right network

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

#### 3. Create a router for the right network

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

#### 4. Attach the subnet to the router

```shell
$ openstack router add subnet right-router right-subnet
```

#### 5. Link the router to the external network

```shell
$ openstack router set right-router --external-gateway ext-net
```

### Step Three: Create an IKE and IPSec policy

You need to create both IKE and IPSec policy in both "left" and "right" region.

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

Create a VPN service on the left side and another on the right side and note the external IP addresses that were assigned to the VPN services.

!!! **Multiple IPSec site connections per router**
!!! If you want to create multiple IPSec site connections it is strongly recommended to create only one VPN service per router and create all site connections in the same VPN service.

!!! **Local subnets and endpoint groups**
!!! There are two ways to configure local and peer subnets: (1) Endpoint groups for both local subnet(s) and for peer CIDR(s) and (2) one local subnet ID in VPN service and one peer CIDR in IPSec site connection.
!!! The preferred way is (1) using endpoint groups. This allows to set potentially multiple local and peer subnets per site connection. Please be aware that the endpoint groups concept cannot be mixed with the (older) approach where the local subnet ID is set in the VPN service configuration. If you use endpoint groups you have to use the concept for both local subnets and peer CIDRs and you must not set the (local) subnet ID in the VPN service. Otherwise creating the IPSec site connection will be rejected. One common mistake is to set the local subnet ID in the VPN service and try to create an IPSec site connection with local and peer endpoint groups (and no peer CIDR) which is rejected with "Missing peer CIDRs for IPsec site-to-site connection".

#### 1. Create the VPN service on the left side

Note that the VPN service is not configured with a subnet here. This is important because it gives us the flexibility to configure multiple local subnets in a local endpoint group per IPSec site connection or multiple site connections with different local subnets.

```shell
$ openstack vpn service create vpn --router left-router
+----------------+--------------------------------------+
| Field          | Value                                |
+----------------+--------------------------------------+
| Description    |                                      |
| ID             | a29b6e62-f456-44b1-9774-28cefc1df9fb |
| Name           | vpn                                  |
| Project        | 70061ce0cd2e47ef9d7dc82174dc9923     |
| Router         | c971c888-a0bb-47e3-a922-565899c9f090 |
| State          | True                                 |
| Status         | PENDING_CREATE                       |
| Subnet         | None                                 |
| external_v4_ip | 195.192.128.58                       |
| external_v6_ip | None                                 |
| project_id     | 70061ce0cd2e47ef9d7dc82174dc9923     |
+----------------+--------------------------------------+
```

Note that the external IP address may be a different one than the one of the router.

#### 2. Create the VPN service on the right side

```shell
$ openstack vpn service create vpn2 --router right-router
+----------------+--------------------------------------+
| Field          | Value                                |
+----------------+--------------------------------------+
| Description    |                                      |
| ID             | d7c3def8-82f9-4e1d-94ae-0b8d29651cd4 |
| Name           | vpn2                                 |
| Project        | 70061ce0cd2e47ef9d7dc82174dc9923     |
| Router         | 56f95788-1c34-432f-8ad6-f304776221a2 |
| State          | True                                 |
| Status         | PENDING_CREATE                       |
| Subnet         | None                                 |
| external_v4_ip | 195.192.130.187                      |
| external_v6_ip | None                                 |
| project_id     | 70061ce0cd2e47ef9d7dc82174dc9923     |
+----------------+--------------------------------------+
```

### Step Five: Create the endpoint groups

#### 1. Create the local endpoint group for the left side

Entries in the local endpoint group are subnets, given by name or ID. The local endpoint group of the left side will contain the left subnet.

```shell
$ openstack vpn endpoint group create left-local-epg \
  --type subnet \
  --value left-subnet
+-------------+------------------------------------------+
| Field       | Value                                    |
+-------------+------------------------------------------+
| Description |                                          |
| Endpoints   | ['38346388-4b09-4f0a-a3d1-b1a5f6587f4c'] |
| ID          | 09f1f822-15aa-4495-ac78-654ccfdf0131     |
| Name        | left-local-epg                           |
| Project     | 70061ce0cd2e47ef9d7dc82174dc9923         |
| Type        | subnet                                   |
| project_id  | 70061ce0cd2e47ef9d7dc82174dc9923         |
+-------------+------------------------------------------+
```

#### 2. Create the peer endpoint group for the left side

Entries in the peer endpoint group are CIDRs. The peer endpoint group of the left side will contain the CIDR of the peer subnet, in our example that's the right subnet.

```shell
$ openstack vpn endpoint group create left-peer-epg \
  --type cidr \
  --value 10.2.0.0/24
+-------------+--------------------------------------+
| Field       | Value                                |
+-------------+--------------------------------------+
| Description |                                      |
| Endpoints   | ['10.2.0.0/24']                      |
| ID          | 86e851dd-bedc-4d5b-84c9-71944017ad5e |
| Name        | left-peer-epg                        |
| Project     | 70061ce0cd2e47ef9d7dc82174dc9923     |
| Type        | cidr                                 |
| project_id  | 70061ce0cd2e47ef9d7dc82174dc9923     |
+-------------+--------------------------------------+
```

#### 3. Create the local endpoint group for the right side

Entries in the local endpoint group are subnets, given by name or ID. The local endpoint group of the right side contains the right subnet.

```shell
$ openstack vpn endpoint group create right-local-epg \
  --type subnet \
  --value right-subnet
+-------------+------------------------------------------+
| Field       | Value                                    |
+-------------+------------------------------------------+
| Description |                                          |
| Endpoints   | ['a1026c99-8dd6-496a-a565-74a49f2e95ec'] |
| ID          | f6db9f67-7939-4b90-8e56-ef1be737364a     |
| Name        | right-local-epg                          |
| Project     | 70061ce0cd2e47ef9d7dc82174dc9923         |
| Type        | subnet                                   |
| project_id  | 70061ce0cd2e47ef9d7dc82174dc9923         |
+-------------+------------------------------------------+
```

#### 4. Create the peer endpoint group for the right side

Entries in the peer endpoint group are CIDRs. The peer endpoint group of the right side contains the CIDR of the peer subnet, in our example that's the left subnet.

```shell
$ openstack vpn endpoint group create right-peer-epg \
  --type cidr \
  --value 10.1.0.0/24
+-------------+--------------------------------------+
| Field       | Value                                |
+-------------+--------------------------------------+
| Description |                                      |
| Endpoints   | ['10.1.0.0/24']                      |
| ID          | 2c9248d0-00aa-4f8e-a934-f7fa47b45562 |
| Name        | right-peer-epg                       |
| Project     | 70061ce0cd2e47ef9d7dc82174dc9923     |
| Type        | cidr                                 |
| project_id  | 70061ce0cd2e47ef9d7dc82174dc9923     |
+-------------+--------------------------------------+
```

### Step Six: Create the site connections

#### 1. Create the site connection on the left side

Create a site connection named "conn" from the left side (VPN service "vpn") to the right side (peer IP address is 195.192.130.187).
Since endpoint groups are used, the VPN service must not have a (local) subnet set and the peer cidr option of creating the site connection must not be used. Instead the local and peer endpoint groups are set in the site connection.

```shell
$ openstack vpn ipsec site connection create conn \
  --vpnservice vpn \
  --ikepolicy ikepolicy \
  --ipsecpolicy ipsecpolicy \
  --local-endpoint-group left-local-epg \
  --peer-address 195.192.130.187 \
  --peer-id 195.192.130.187 \
  --peer-endpoint-group left-peer-epg \
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
| Local Endpoint Group ID  | 09f1f822-15aa-4495-ac78-654ccfdf0131                   |
| Local ID                 |                                                        |
| MTU                      | 1500                                                   |
| Name                     | conn                                                   |
| Peer Address             | 195.192.130.187                                        |
| Peer CIDRs               |                                                        |
| Peer Endpoint Group ID   | 86e851dd-bedc-4d5b-84c9-71944017ad5e                   |
| Peer ID                  | 195.192.130.187                                        |
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

Create a site connection named "conn2" from the right side (VPN service "vpn2") to the left side (peer IP address is 195.192.128.58).
Since endpoint groups are used, the VPN service must not have a (local) subnet set and the peer cidr option of creating the site connection must not be used. Instead the local and peer endpoint groups are set in the site connection.


```shell
$ openstack vpn ipsec site connection create conn2 \
  --vpnservice vpn2 \
  --ikepolicy ikepolicy \
  --ipsecpolicy ipsecpolicy \
  --local-endpoint-group right-local-epg \
  --peer-address 195.192.128.58 \
  --peer-id 195.192.128.58 \
  --peer-endpoint-group right-peer-epg \
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
| Local Endpoint Group ID  | f6db9f67-7939-4b90-8e56-ef1be737364a                   |
| Local ID                 |                                                        |
| MTU                      | 1500                                                   |
| Name                     | conn2                                                  |
| Peer Address             | 195.192.128.58                                         |
| Peer CIDRs               |                                                        |
| Peer Endpoint Group ID   | 2c9248d0-00aa-4f8e-a934-f7fa47b45562                   |
| Peer ID                  | 195.192.128.58                                         |
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

### Step Seven: Check if the VPN works properly

Create virtual machines with interfaces in `right-subnet` and `left-subnet`, and make sure they can reach each other, by sending ICMP echo requests to internal IP addresses.
Note that one of this virtual machines needs to have a Floating IP address, so you can reach the VM itself.

## Note on Interoperatibility

Please see the [reference](../../04.Reference/08.network/docs.en.md) for [known interoperability issues](../../04.Reference/08.network/docs.en.md#known-interoperability-issues).
