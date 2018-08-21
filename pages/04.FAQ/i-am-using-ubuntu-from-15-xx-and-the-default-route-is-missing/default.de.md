---
title: 'Ich benutze ein Ubuntu ab 15.xx und es fehlt die Default Route'
published: true
date: '08-08-2018 13:05'
taxonomy:
    category:
        - FAQ
    tag:
        - OpenStack
        - Network
        - Access
        - DHCP
        - ICMP
        - DefaultRoute
        - DefaultGateway
        - Gateway
---

Ubuntu benutzt seit 15.04 eine RFC-konforme Implementierung von DHCP. Das Software Defined Network schickt keine Default Route mit, daher muss diese explizit mit host_routes gesetzt werden. Wir arbeiten mit dem Hersteller an einer Lösung. Mit der folgenden Konfiguration kann das Problem umgangen werden. Hier ein Beispiel für das Subnet 10.0.0.0/24 mit 10.0.0.1 als Standard Gateway:

```plain
  subnet:
    type: OS::Neutron::Subnet
    properties:
      name: kickstart-subnet
      dns_nameservers:
        - 8.8.8.8
        - 8.8.4.4
      network_id: {get_resource: net}
      ip_version: 4
      host_routes:
        - { destination: 0.0.0.0/0, nexthop: 10.0.0.1 }
      gateway_ip: 10.0.0.1
      cidr: 10.0.0.0/24
      allocation_pools:
      - {start: 10.0.0.10, end: 10.0.0.250}
```