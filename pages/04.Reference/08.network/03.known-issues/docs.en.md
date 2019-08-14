---
title: 'Known Issues'
published: true
date: '08-14-2019 10:51'
taxonomy:
    category:
        - docs
---

## Overview

### Idle TCP sessions being closed

**Problem Statement:**\
When a virtual machine establishes a TCP connection to a remote server, it uses a random TCP source port.
In order for return traffic to be allowed to flow into a VM in OpenStack, a dynamic inbound security group rule must be created, allowing traffic to flow to this random TCP port.
This dynamic rule will expire in 60 seconds. If the server was quiet for more than one minute, the dynamic inbound security group rule will be deleted and the return traffic from the remote server will be rejected.

**Solutions:**\
To avoid running into this issue there are 3 possible solutions

 * Add a security group rule in OpenStack which explicitly allow returning traffic, so there will be no need of dynamic rules. The Linux kernel option "net.ipv4.ip_local_port_range" configures the range from which the random source port will be picked when a virtual machine initiates a connection. For example, setting this value to 30000 - 50000 and allowing all incoming traffic to port range 30000 - 50000 will solve the issue.
 * If your application supports TCP keepalives, turn on the keepalives in an interval below 60 seconds.
 * Directly turn on TCP keepalives in the kernel
    * net.ipv4.tcp_keepalive_intvl = 10 
    * net.ipv4.tcp_keepalive_probes = 5 
    * net.ipv4.tcp_keepalive_time = 10

The last suggested solution does not automatically send keepalives on every TCP connection, since the appliaction must request kernel keepalives when it opens the TCP socket. 

### High TCP setup delay on CentOS 

**Problem Statement:**\
Current CentOS 7 has problems handling a huge amount of requests per seconds in its connection tracking implementation. This means whenever a NAT is used on your VM running CentOS you could run into a TCP setup delay of more than 1000ms. Packets get lost and the TCP retransmission timer of 1s will hit. That's why TCP connection setup delay could go over 1000ms and further.

**Solution:**\
We suggest to use Ubuntu 18.04.02 instead of CentOS. There the described problem does not occure.

### High TCP setup delay

**Problem Statement:**\
Our current SDN stack in the SysEleven OpenStack Cloud is based on Midonet. Midonet implementation has one significant design issue in exchanging flow state message between the compute nodes that leads into a packet drop. The packet drops are statisticaly small but however it is important to know that it could occure. A resulting behaviour is a TCP setup delay above 1000ms due to lost SYN packet.

**Solution:**\
Currently there is no solution to overcome this issue.
