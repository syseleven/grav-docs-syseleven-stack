---
title: 'Known Issues'
published: true
date: '30-11-2021 10:15'
taxonomy:
    category:
        - docs
---

## Idle TCP sessions being closed

**Affected Regions:**
CBK and DBL

**Problem Statement:**
When a virtual machine establishes a TCP connection to a remote server, it uses a random TCP source port.
In order for return traffic to be allowed to flow into a VM in OpenStack, a dynamic inbound security group rule will automatically be created by the SDN (Software Defined Network), allowing traffic to flow to this random TCP port.
This dynamic rule will expire after 60 seconds. If the server was quiet for more than one minute, the dynamic inbound security group rule will be deleted and the return traffic from the remote server will be rejected.

**Solutions:**
To avoid running into this issue there are 4 possible solutions:

* Add a security group rule in OpenStack, which explicitly allows returning traffic. Now the SDN has no need to create dynamic rules anymore. The Linux kernel option `net.ipv4.ip_local_port_range` configures the range from which the random source port will be picked when a virtual machine initiates a connection. For example, setting this value to 30000 - 50000 and allowing all incoming traffic to port range 30000 - 50000 will solve the issue.
* If your application supports TCP keepalives, turn on the keepalives in an interval below 60 seconds.
* If both virtual machines run in the same OpenStack project, add a security group to the server which allows all traffic from virtual machines with the client security group attached.
* Directly turn on TCP keepalives in the kernel
  * `net.ipv4.tcp_keepalive_intvl = 10`
  * `net.ipv4.tcp_keepalive_probes = 5`
  * `net.ipv4.tcp_keepalive_time = 10`

The last suggested solution does not automatically send keepalives on every TCP connection, since the application must request kernel keepalives when it opens the TCP socket.


## High TCP setup delay on CentOS

**Affected Regions:**
All regions

**Problem Statement:**
Current CentOS 7 has problems handling a huge amount of requests per seconds in its connection tracking implementation. This means whenever a NAT is used on your VM running CentOS you could run into a TCP setup delay of more than 1000ms. Packets get lost and the TCP retransmission timer of 1s will get hit. That's why TCP connection setup delay could go over 1000ms and further. To confirm that this issue exists, check if the `insert_failed` counter increases by running `conntrack -S`.

**Solution:**
We suggest to use Ubuntu 18.04 instead of CentOS. The described problem does not occur there.


## High TCP setup delay

**Affected Regions:**
CBK and DBL

**Problem Statement:**
Our current SDN stack in the SysEleven OpenStack regions CBK and DBL is based on Midonet. This implementation has one significant design issue in exchanging flow state message between the compute nodes that leads into a packet drop. The packet drops are statistically small but however it is important to know that it could occur. A resulting behaviour is a TCP setup delay above 1000ms because the initial SYN packet gets lost and will be re-transmitted only after 1000ms. This problem only occurs when there is a NAT from OpenStack side involved (any Internet communication, load balancers). It does not happen between instances that allow all traffic from each other configured by their security groups.

Since software-defined network in the region FES is not based on Midonet anymore, this issue does not exist there.

**Solution:**
Currently there is no solution to overcome this issue.


## Error updating Neutron LBaaS load balancer

**Affected Regions:**
CBK and DBL

**Problem Statement:**
When trying to update a Neutron LBaaSv2 load balancer (name, description or admin-state-up), Neutron will answer with 400 Bad Request. The affected load balancer ends up in `ERROR` state. The load balancer itself will get updated accordingly and keeps working as intended. Unfortunately due to the load balancer switching to the ERROR state, further requests (except delete requests) on it will be rejected.

**Solution:**
The Cloud Support needs to reset the load balancer state.


## Connection setup rate limitation

**Affected Regions:**
CBK and DBL

**Problem Statement:**
The SDN solution we are using in the CBK and DBL regions is reactive and thus newly created connections/flows create strain. To avoid a negative performance impact on other users, the maximum rate of newly created outgoing connections has been limited to 5000 per second, which in our observation exceeded all legitimate use cases and was only hit by attempted denial attacks.

**Solution:**
If you approach this limit, try to reduce the number of newly created connections per second. Depending on your use case, it is often possible (and recommended anyway) to reuse existing connections as much as possible (e.g. by using connection pooling techniques). Alternatively, it is possible to spread the traffic over several instances (horizontal scale out). Please approach our support to either propose a suitable workaround or reconsider the limit.

