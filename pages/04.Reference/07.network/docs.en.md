---
title: 'Network'
published: true
date: '08-08-2018 11:08'
taxonomy:
    category:
        - docs
---

## Network

Using the SysEleven Stack Network service, you can do much more than just accessing the internet; It's possible to build arbitrary private L2 and L3 network topologies using virtual routers, networks, subnets, load balancers and VPN site connections.

Servers can access the internet using virtual routers (SNAT). For making servers and loadbalancers accessible from the internet, we offer a Floating IP service (DNAT).

You can improve security and control isolation by using security groups and by defining firewall rules.

You can manage networking objects both via our [public OpenStack API endpoints](../../02.Tutorials/02.api-access/docs.en.md), as well as using the Dashboard.

### Feature Support Matrix

| OpenStack Neutron Feature               |   CBK region   |   DBL region
| ----------------------------------------|----------------|-------------
| L2 networking (networks and subnets)    | yes | yes
| L3 networking (static routing)          | yes | yes
| Floating IPs                            | yes | yes
| Security groups                         | yes | yes
| Firewall rules (FWaaS)                  | yes | yes
| IPsec VPN (VPNaaS)                      | yes | yes
| Customer public IP space (Bring your own IP) | yes | yes
| L4 Load balancing (TCP) (Neutron-LBaaS) | yes | yes
| L7 Load balancing (HTTP/HTTPS) (Octavia-LBaaS) | no | no
| Dynamic routing (BGP)                   | no | no
| Metering support                        | no | no
| Quality of service (QoS)                | no | no
| Service function chaining (SFC)         | no | no
| IPv6                                    | no | no

### L2 networking (networks and subnets)

You can implement L2 networking by creating *OpenStack networks*.

You can associate one or more *OpenStack subnets* to your networks. You can use subnets to manage IP addresses and the DHCP server configuration.

Virtual machines and virtual routers use *OpenStack ports* to connect to virtual networks. When creating a port, you can let it choose a free IP address automatically for you, or assign a fixed IP address.

By creating different networks, you can have multiple isolated layer 2 networks. Different networks can use overlapping IP address space if you want, e.g. Network A and network B can both use the same `10.0.10.0/24` network.

It is not possible to bridge multiple L2 networks. To communicate from network A to network B you need to use L3 networking (routers).

By default, the "Port Security" prevents spoofing attacks by only allowing the IP address/MAC address pair configured in the networking port. To allow different IP addresses/MAC addresses, you can disable port security or add additional allowed address pairs. You can find out [more about port security here](01.port-security/docs.en.md), have a look at our How-to [for allowing additional subnets on a port](../../03.Howtos/06.allowing-an-additional-subnet-to-talk-to-or-via-a-port/docs.en.md). You need to [allow different IP/MAC pairs as well if you want to use VRRP](../../03.Howtos/09.l3-high-availability/docs.en.md).

You can find an [example heat template with a single network configuration](https://github.com/syseleven/heat-examples/blob/master/networks/1.single-network.yaml) on our GitHub.

### L3 networking

You can implement L3 networking by creating *OpenStack routers* and associating them with your networks.

An OpenStack router is a virtual networking device that forwards data between different OpenStack networks and/or the internet.

For more information how you can connect different networks, [have a look at our How-to guide on connecting two subnets with each other](../../03.Howtos/03.connect-two-subnets-with-each-other/docs.en.md).

For internet access we provide a network called `ext-net`. Ports cannot be directly added to the `ext-net` external network for internet access (This is only possible with customer-owned bring-your-own-public-ip networks). To make virtual machines accessible from the internet, use Floating IPs or load balancers.

### Floating IPs

Floating IPs can be associated with virtual machines or load balancers, to make them accessible from the internet.

### Security groups

*Security groups* are a simple framework for allowing or denying certain traffic between different ports. What is allowed and denied for a certain security group can be defined using rules. Rules can reference other security groups and can be even self-referencing.

Let's say you have backend servers, frontend servers, and database servers. You might create a security group for each and can then define that backend servers can access database servers, while frontend servers cannot access database servers.

The `default` security group will be used if not specified otherwise. It allows all traffic in your OpenStack project that originates from a port with the `default` security group, and denies everything else.

! Blocking ICMP traffic can lead to connectivity issues. Usually it is recommended not to block ICMP.

### Firewall rules (FWaaS)

Using FWaaS you can enforce rules at network boundaries. *OpenStack Firewalls*  can be associated with routers, which will then enforce the *Firewall rules*.

You can find [example code in our terraform-examples](https://github.com/syseleven/terraform-examples/tree/master/FWaaS) on GitHub.

! Blocking ICMP traffic can lead to connectivity issues. Usually it is recommended not to block ICMP.

### IPsec VPN (VPNaaS)

Using VPNaaS you can establish secure connections between different regions and your own premises.

See our heat-examples on GitHub [for an example how to connect two regions using VPNaaS](https://github.com/syseleven/heat-examples/tree/master/vpn-site2site).

### Customer public IP space (Bring your own IP)

If you want to connect to the internet directly (e.g. using Fixed IPs instead of Floating IPs) or if you have special requirements, you can easily transfer your public IP networks to SysEleven Stack.

In addition to the standard `ext-net`, that is shared across all our customers, you will get your own external network. This gives you more control and can make it easier to integrate SysEleven Stack with your existing infrastructure.

Please contact our customer support if you are interested at cloudsupport@syseleven.de.

### L4 Load balancing (TCP) (Neutron-LBaaS)

Using L4 load balancers, you can improve the availability and scalability of your TCP-based services. If configured to do so, the Load balancer will actively monitor all backends and route TCP connections to healthy backends.

See our [tutorial on load balancing for more information](../../02.Tutorials/05.lbaas/docs.en.md).