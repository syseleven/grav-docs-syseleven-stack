---
title: 'Network'
published: true
date: '08-08-2018 11:08'
taxonomy:
    category:
        - docs
---

## Network

Using the SysEleven Stack Network service, you can do much more than just accessing the internet; It's possible to build arbitrary private network topologies using virtual routers, networks, subnets, load balancers and VPN site connections.

Servers can access the internet using virtual routers (SNAT). For making servers and loadbalancers accessible from the internet, we offer a Floating IP service (DNAT).

You can improve security and control isolation by using security groups and by defining firewall rules.

You can manage networking objects both via our [public OpenStack API endpoints](../../02.Tutorials/02.api-access/docs.en.md), as well as using the Dashboard.

### Feature Support Matrix

| OpenStack Neutron Feature               |   CBK region   |   DBL region
| ----------------------------------------|----------------|-------------
| Basic networking                        | yes | yes
| Floating IPs                            | yes | yes
| Security groups                         | yes | yes
| Firewall rules (FWaaS)                  | yes | yes
| IPsec VPN (VPNaaS)                      | yes | yes
| Customer public IP space (Bring your own IP) | yes | yes
| L4 Load balancing (TCP) (Neutron-LBaaS) | yes | yes
| L7 Load balancing (HTTP/HTTPS) (Octavia-LBaaS) | yes | yes
| Dynamic routing (BGP)                   | no | no
| Metering support                        | no | no
| Quality of service (QoS)                | no | no
| Service function chaining (SFC)         | no | no
| IPv6                                    | no | no

### Basic networking

*OpenStack networks* act as a virtual bridge.

You can associate one or more *OpenStack subnets* to your networks. You can use subnets to manage IP addresses and the DHCP server configuration.

Virtual machines and virtual routers use *OpenStack ports* to connect to virtual networks. When creating a port, you can let it choose a free IP address automatically for you, or assign a fixed IP address.

By creating different networks, you can have multiple isolated layer 2 networks. Different networks can use overlapping IP address space if you want, e.g. Network A and network B can both use the same `10.0.10.0/24` network, if you don't plan to interconnect them.

It is not possible to bridge multiple networks. To communicate from network A to network B you need to use a router.

An *OpenStack router* is a virtual networking device that forwards data between different OpenStack networks and/or the internet.

For more information how you can connect different networks, [have a look at our How-to guide on connecting two subnets with each other](../../03.Howtos/03.connect-two-subnets-with-each-other/docs.en.md).

For internet access we provide a network called `ext-net`. Ports cannot be directly added to the `ext-net` external network for internet access (This is only possible with customer-owned bring-your-own-public-ip networks). To make virtual machines accessible from the internet, use Floating IPs or load balancers.

By default, the "Port Security" prevents spoofing attacks by only allowing the IP address/MAC address pair configured in the networking port. To allow different IP addresses/MAC addresses, you can disable port security or add additional allowed address pairs. You can find out [more about port security here](01.port-security/docs.en.md), have a look at our How-to [for allowing additional subnets on a port](../../03.Howtos/06.allowing-an-additional-subnet-to-talk-to-or-via-a-port/docs.en.md). You need to [allow different IP/MAC pairs as well if you want to use VRRP](../../03.Howtos/10.l3-high-availability/docs.en.md).

You can find an [example heat template with a single network configuration](https://github.com/syseleven/heat-examples/blob/master/networks/1.single-network.yaml) on our GitHub.

### Floating IPs

Floating IPs can be associated with virtual machines or load balancers, to make them accessible from the internet.

### Security groups

A security group acts as a virtual firewall for servers and other resources on a network. It is a container for security group rules which specify the network access rules.

Rules can reference other security groups and can be even self-referencing.

Let's say you have backend servers, frontend servers, and database servers. You might create a security group for each and can then define that backend servers can access database servers, while frontend servers cannot access database servers.

The `default` security group will be used if not specified otherwise. It allows all traffic in your OpenStack project that originates from a port with the `default` security group, and denies everything else.

! We recommend not to block ICMP because path MTU discovery relies on it, to avoid connectivity issues over VPN tunnels.
! For these reasons, ICMP packets from link local range 169.254.0.0/16 are explicitly allowed to enter any virtual machine in our cloud.
! This is not a security concern, since this range is not routed in Internet and between OpenStack networks.
! If you configure an extra layer of security with iptables or other kind filtering inside virtual machine itself, please
! allow ICMP from this range.

### Firewall rules (FWaaS)

Using FWaaS you can enforce rules at network boundaries. *OpenStack Firewalls*  can be associated with routers, which will then enforce the *Firewall rules*.

You can find [example code in our terraform-examples](https://github.com/syseleven/terraform-examples/tree/master/FWaaS) on GitHub.

! We recommend not to block ICMP because path MTU discovery relies on it, to avoid connectivity issues over VPN tunnels.

### IPsec VPN (VPNaaS)

With VPNaaS you can establish secure site-to-site tunnels from your premises to SysEleven Stack, so you can access cloud resources like if they were part of your network. This feature can also be used to interconnect different regions together.

See our heat-examples on GitHub [for an example how to connect two regions using VPNaaS](https://github.com/syseleven/heat-examples/tree/master/vpn-site2site).

#### Known interoperability issues

As control over configuration details is limited in this VPNaaS implementation, connections to external destinations require flexibility on the remote side. For example there are multiple ways specified in IPsec how to connect multiple networks over a connection. Our VPNaaS supports only the variant, where each pair of networks uses a distinct SA (security association). This is known to cause problems hard to diagnose in conjunction with [GCP Cloud VPN](https://cloud.google.com/vpn/docs/concepts/choosing-networks-routing#ts-ip-ranges). One possible workaround is to set up distinct connections for each pair of networks, which can become awkward to maintain. Another would be to use a TCP VPN like [OpenVPN](https://openvpn.net/), [VTun](http://vtun.sourceforge.net/), [Wireguard](https://www.wireguard.com/), [Tinc](https://tinc-vpn.org/) or [Zerotier](https://www.zerotier.com/). As a third alternative approach, we are working on the preconditions needed to run virtual appliances like [PFSense](https://www.pfsense.org/) in our platform and let them provide self managed vpn services.

### Customer public IP space (Bring your own IP)

If you want to connect to the internet without NAT (e.g. using Fixed IPs instead of Floating IPs) or if you have special requirements, you can easily transfer your public IP networks to SysEleven Stack.

In addition to the standard `ext-net`, that is shared across all our customers, you will get your own external network. This gives you more control and can make it easier to integrate SysEleven Stack with your existing infrastructure.

Please [contact our customer support](../../06.Support/default.en.md) if you are interested.

### Load balancing

Using load balancers, you can improve the availability and scalability of your TCP-based services. If configured to do so, the Load balancer will actively monitor all backends and route connections to healthy backends.
L4 load balancing (TCP) is supported via Neutron LBaaSv2 and Octavia, L7 load balancing (HTTP/HTTPS) only via Octavia.

See our [tutorial on load balancing for more information](../../02.Tutorials/05.lbaas/docs.en.md).
