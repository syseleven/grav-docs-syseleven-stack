---
title: 'My compute instance was created, but is not accessible via SSH/HTTP etc.'
published: true
date: '08-08-2018 12:58'
taxonomy:
    category:
        - FAQ
    tag:
        - OpenStack
        - Network
        - SSH
        - HTTP
        - Access
        - Firewall
        - SecurityGroups
        - instances
        - Compute
---

By default all compute instances of are using the "default" security group. It's settings do not allow any other packets, except of ICMP in order to be able to ping your compute instance. Any other ports needed by a given instance need to be opened by adding a rule to the security group your instance uses (i.e., SSH or HTTPS).
Here is an example that shows how you can use a heat template to allow incoming HTTP/HTTPS traffic via your security group:

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

This security group can now be connected to a port of your network:

```plain
  example_port:
    type: OS::Neutron::Port
    properties:
      security_groups: [ get_resource: allow_webtraffic, default ]
      network_id: { get_resource: example_net}
```

The security group "default" is added in this example, since this group is taking care of allowing outbound traffic.