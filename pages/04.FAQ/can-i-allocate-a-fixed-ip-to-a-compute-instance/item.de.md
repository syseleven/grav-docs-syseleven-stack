---
title: 'Kann ich einer Compute Instanz eine feste interne IP zuweisen?'
published: true
date: '08-08-2018 12:57'
taxonomy:
    category:
        - FAQ
    tag:
        - OpenStack
        - Network
        - IP
        - PrivateIP
        - LocalIP
        - AllocateIP
        - FixedIP
---

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