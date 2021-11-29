---
title: 'Network'
published: true
date: '25-11-2021 10:15'
taxonomy:
    category:
        - docs
---

## Overview

Using the SysEleven Stack Network service, you can do much more than just accessing the Internet; It's possible to build arbitrary private network topologies using virtual routers, networks, subnets, load balancers and VPN site connections.

Servers can access the Internet using virtual routers (SNAT). For making servers and load balancers accessible from the Internet, we offer an IPv4 Floating IP service (DNAT), Load Balancers and IPv6 Global Unicast Addresses.

You can improve security and control isolation by using security groups.

You can manage networking objects both via our [public OpenStack API endpoints](../../02.Tutorials/02.api-access/docs.en.md), as well as using the [Dashboard](https://cloud.syseleven.de/).

## Feature Support Matrix

| OpenStack Neutron Feature                      | CBK region | DBL region | FES region |
|------------------------------------------------|------------|------------|------------|
| Basic networking                               | yes        | yes        | yes        |
| Floating IPs                                   | yes        | yes        | yes        |
| Security groups                                | yes        | yes        | yes        |
| IPsec VPN (VPNaaS)                             | yes        | yes        | yes        |
| Customer public IP space (Bring your own IP)   | yes        | yes        | yes        |
| L4 Load balancing (TCP) (Neutron-LBaaS)        | yes        | yes        | no         |
| L7 Load balancing (HTTP/HTTPS) (Octavia-LBaaS) | yes        | yes        | yes        |
| Neutron DNS integration and PTR records        | yes        | yes        | yes        |
| Firewall rules (FWaaS)                         | no         | no         | no         |
| Dynamic routing (BGP)                          | no         | no         | no         |
| Metering support                               | no         | no         | no         |
| Quality of service (QoS)                       | no         | no         | no         |
| Service function chaining (SFC)                | no         | no         | no         |
| Port Trunking                                  | no         | no         | yes        |
| IPv6                                           | no         | no         | yes        |

## Basic networking

*OpenStack networks* act as virtual bridges.

You can associate one or more *OpenStack subnets* to your networks. You can use subnets to manage IP addresses and the DHCP server configuration.

Virtual machines and virtual routers use *OpenStack ports* to connect to virtual networks. When creating a port, you can let it choose a free IP address automatically for you, or assign a fixed IP address.

By creating different networks, you can have multiple isolated layer 2 networks. Different networks can use overlapping IP address spaces if you want, e.g. network A and network B can both use the same `10.0.10.0/24` prefix, if you don't plan to interconnect them.

It is not possible to bridge multiple networks. To communicate from network A to network B you need to use a router.

An *OpenStack router* is a virtual networking device that forwards data between different OpenStack networks and/or the Internet.

For more information how you can connect different networks, [have a look at our How-to guide on connecting two subnets with each other](../../03.Howtos/03.connect-two-subnets-with-each-other/docs.en.md).

For Internet access we provide a network called `ext-net`. Ports cannot be directly added to the `ext-net` external network for Internet access (This is only possible with customer-owned bring-your-own-public-ip networks). To make virtual machines accessible from the Internet, use Floating IPs or load balancers.

By default `Port Security` prevents spoofing attacks by only allowing the IP address/MAC address pair configured on the networking port. To allow different IP addresses/MAC addresses, you can disable port security or add additional allowed address pairs. You can find out [more about port security here](01.port-security/docs.en.md) and have a look at our How-to [for allowing additional subnets on a port](../../03.Howtos/06.allowing-an-additional-subnet-to-talk-to-or-via-a-port/docs.en.md). You need to [allow different IP/MAC pairs as well if you want to use VRRP](../../03.Howtos/10.l3-high-availability/docs.en.md).

You can find an [example heat template with a single network configuration](https://github.com/syseleven/heat-examples/blob/master/networks/1.single-network.yaml) in our GitHub repository.

## Floating IPs

Floating IPs can be associated with ports on virtual machines or load balancers, to make them accessible from the Internet. Port must have a valid IPv4 address to be associated with a Floating IP address. It is not possible to create an IPv6 Floating IP address, or associate an IPv4 Floating IP address with an IPv6 address.

## Security groups

A security group acts as a virtual firewall for servers and other resources on a network. It is a named collection of network access rules.

Rules can reference other security groups and can be even self-referencing.

Let's say you have backend servers, frontend servers, and database servers. You might create a security group for each and then define that backend servers can access database servers, while frontend servers cannot access database servers.

The `default` security group will be used if not specified otherwise. It allows all traffic in your OpenStack project that originates from a port with the `default` security group, and denies everything else.

! We recommend not to block ICMP because path MTU discovery relies on it, to avoid connectivity issues over VPN tunnels.
! For these reasons, ICMP packets from link local range 169.254.0.0/16 are explicitly allowed to enter any virtual machine in our cloud.
! This is not a security concern, since this range is not routed in the Internet and between OpenStack networks.
! If you configure an extra layer of security with iptables or other kind of filtering inside a virtual machine itself, please allow ICMP from this range.

## IPsec VPN (VPNaaS)

With VPNaaS you can establish secure site-to-site tunnels from your premises to SysEleven Stack, so you can access cloud resources like if they were part of your network. This feature can also be used to interconnect different regions.

Currently our VPNaaS implementation supports the following algorithms in both phase 1 and 2:

| Authentication |
| -------------- |
| SHA-1          |
| SHA-256        |
| SHA-384        |
| SHA-512        |

| Encryption     |
| -------------- |
| 3DES           |
| AES-128        |
| AES-192        |
| AES-256        |

| DH Groups      |
| -------------- |
| Group 2        |
| Group 5        |
| Group 14       |

See our heat-examples on GitHub [for an example how to connect two regions using VPNaaS](https://github.com/syseleven/heat-examples/tree/master/vpn-site2site).

### Known interoperability issues

As control over configuration details is limited in this VPNaaS implementation, connections to external destinations require flexibility on the remote side. For example there are multiple ways specified in IPsec how to connect multiple networks over a connection. Our VPNaaS supports only the variant, where each pair of networks uses a distinct SA (security association). This is known to cause problems hard to diagnose in conjunction with [GCP Cloud VPN](https://cloud.google.com/vpn/docs/concepts/choosing-networks-routing#ts-ip-ranges). One possible workaround is to set up distinct connections for each pair of networks, which can become awkward to maintain. Another would be to use a TCP VPN like [OpenVPN](https://openvpn.net/), [VTun](http://vtun.sourceforge.net/), [Wireguard](https://www.wireguard.com/), [Tinc](https://tinc-vpn.org/) or [Zerotier](https://www.zerotier.com/). As a third alternative approach, we are working on the preconditions needed to run virtual appliances like [PFSense](https://www.pfsense.org/) in our platform and let them provide self managed VPN services.

## Customer public IP space (Bring your own IP addresses)

If you want to connect to the Internet without NAT (e.g. using Fixed IPs instead of Floating IPs) or if you have special requirements, you can easily transfer your public IP networks to SysEleven Stack.

In addition to the standard `ext-net`, that is shared across all our customers, you will get your own external network. This gives you more control and can make it easier to integrate SysEleven Stack with your existing infrastructure.

Please [contact our customer support](../../06.Support/default.en.md) if you are interested.

## Load balancing

Using load balancers, you can improve the availability and scalability of your services.

SysEleven Stack offers two options: Neutron LBaaSv2 (TCP-only) and Octavia LBaaS (TCP, HTTP, HTTPS).

!! Octavia is currently in the public beta phase. This means we invite you to test Octavia load balancers, but we do not recommend you to use them for production workloads yet.

Please refer to the [LBaaS reference documentation](02.lbaas/docs.en.md) for a comparison between the two and for more information.

For how to get started, have a look at our [LBaaS tutorial](../../02.Tutorials/05.lbaas/docs.en.md).

## Neutron DNS integration and PTR records

The Neutron DNS integration adds `dns_domain` and `dns_name` attributes to networks, ports and floating IPs.

With these properties, the Neutron networking service will create forward A-type records and reverse PTR-type records in our [Designate DNS service](../07.dns/docs.en.md) for you.

If you need to add a PTR-record to an existing floating IP, have a look at our how-to guide on [adding PTR records to an existing floating IP](../../03.Howtos/14.add-ptr-records/docs.en.md).

If you are using a custom public IP space (Bring your own IP), you first need to delegate your corresponding `in-addr.arpa` to our DNS service before you can use the Neutron DNS integration.

### Floating IPs with DNS properties

To create a reverse lookup PTR entry for a floating IP address, two parameters `--dns-domain` and `--dns-name` can be set. The DNS zone specfied in `--dns-domain` has to be created and owned by the same project. If the zone exists and configured properly, a forward A-type record as specified in `--dns-name` will be created in it. A reverse PTR-type record will be created in the `in-addr.arpa` zone that is hosted in our cloud, but invisible to customer projects.

The full command line to create a floating IP adress with a reverse PTR record will look like this: `openstack floating ip create --dns-domain example.com. --dns-name mx01 ext-net`

It is unfortunately not possible to set the `dns_name` and `dns_domain` properties for a floating IP that has already been created in the past.

### Networks and ports with DNS properties

Forward A-type and reverse PTR-type records can be created automatically for all VMs that have Floating IP addresses attached. In order to achieve this, you need to provide the `--dns-domain` option when creating the network. It can also be updated later (e.g. using `openstack network set example-network --dns-domain example.com.`). You can create a network with the `dns_domain` property set using `openstack network create example-net --dns-domain example.com.`.

The DNS zone specfied in `--dns-domain` must be created and owned by the same project. If the zone exists and is configured properly on a network, forward A-type records and reverse PTR-type records will be created for every VM in that network, as soon as a Floating IP address is attached to it.

The record name will be generated from the VM name. Note that some symbols like underscore (`_`) or spaces ( ) are not allowed in host names, and will be removed from the host name. When a Floating IP address is detached from a VM the corresponding A and PTR records are deleted automatically.

When using this approach, Floating IPs themselves don't need to be created using the `--dns-domain` and `--dns-name` options.

## IPv6

You have the possibility to allocate IPv6 Global Unicast Addresses for your virtual subnets, where supported. IPv6 is supported in the Dual-Stack mode, which means that a single virtual network may have both IPv4 and IPv6 subnets. Ports of virtual machines connected to such network, will get both IPv4 and IPv6 addresses. IPv6-only networks are currently not fully supported, due to limitations in the Metadata service. While you may still run such setups, your virtual machines will not be able to retrieve public SSH keys or use other features that the Metadata service provides.

There is no possibility to use Floating IPs in IPv6 address family, which means that you cannot allocate a Floating IP from the IPv6 address pool, neither you can have a Floating IP pointing at an IPv6 address.

During the creation of an IPv6 subnet, you may enter a CIDR manually, or allocate a globally routable /64 prefix from a public address pool. Subnets with manually-set CIDR can not send traffic or be reached to/from the Internet. Inter-VM communication is not restricted in any way. If you choose to allocate an IPv6 prefix from an address pool instead, you will get a globally routable /64 prefix reachable from the Internet for your load balancers and VMs. You can not choose the exact IPv6 subnet you will get, but as long as your subnet is not deleted, the allocated range can not be changed. The range is assigned to you and does not interfere with any customers, so it is safe to assume that full /64 range is yours, when you configure VPN or Firewalls.

! Please note that every virtual machine or load balancer with an IPv6 address in a globally routable subnet is immediately reachable from the Internet, so plan your security groups accordingly.

### IPv6 addressing

When an IPv6 range is allocated and configured on a subnet, you should set `IPv6 RA mode` and `IPv6 address mode`. These two control how the IPv6 address is allocated for the port that is connected to the IPv6-enabled subnet. We recommend setting both of these options to `dhcpv6-stateless`, which will generate a safe random IPv6 address, that will be acquired by a virtual machine via DHCP. Altough other combinations of these options are available, we don't recommend setting them, unless you know what you are doing and how ICMPv6 RA works. Since these options affect cloud-init, DHCP client, and ICMPv6 ND protocol configuration inside your virtual machines, changing them should always go together with reconfiguration of the operating system inside the virtual machine.
