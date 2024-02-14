---
title: 'Building Layer 3 High Availability'
published: true
date: '16-09-2018 16:20'
taxonomy:
    category:
        - docs
---

## Problem statement

* Some services, like reverse proxies or load balancers cannot use service discovery mechanisms in order to achieve high availability.
* In order to improve high availability and decrease convergence time after failure, it is feasible to have one virtual IP address shared between different instances. Some applications have this functionality built-in, some don't.

## Technology used

* Virtual Router Redundancy Protocol, [RFC 5978](https://tools.ietf.org/html/rfc5798)

## Components used

* `keepalived` is an open source VRRP implementation

## Considerations

* VRRP must discover routers (in our case - application servers) in unicast mode, since broadcast is not available in cloud networking.
* Virtual IP address must resolve to virtual MAC (00:00:5E:00:01:XX) address, so there is no need in Gratuitous ARP, which does not always work correctly with our SDN controller.
* Instances, that share virtual IP address, must be connected to the same OpenStack subnet and must have same subnet and mask configuration.

## Configuration

Let's say we have three instances running:

```shell
+--------------------------------------+-----------+--------+-------------------------------------+--------+---------+
| ID                                   | Name      | Status | Networks                            | Image  | Flavor  |
+--------------------------------------+-----------+--------+-------------------------------------+--------+---------+
| 1f9badd7-13a2-4553-86d1-3aae10ca29f9 | observer  | ACTIVE | ha_lab=10.200.51.34, 185.56.135.125 | bionic | m1.tiny |
| da2c4c9c-2581-474e-8caf-abc443a1d29e | ha_second | ACTIVE | ha_lab=10.200.51.33, 185.56.135.122 | bionic | m1.tiny |
| 685b6cdc-ff7f-4d82-8993-a8ca1ebf95b1 | ha_first  | ACTIVE | ha_lab=10.200.51.32, 185.56.135.121 | bionic | m1.tiny |
+--------------------------------------+-----------+--------+-------------------------------------+--------+---------+
```

Two of them, `ha_first` and `ha_second` will share single virtual IP address from 10.200.51.0/24 between them. The
subnet itself is configured in following way:

```shell
+-------------------+--------------------------------------+
| Field             | Value                                |
+-------------------+--------------------------------------+
| allocation_pools  | 10.200.51.32-10.200.51.254           |
| cidr              | 10.200.51.0/24                       |
| created_at        | 2018-08-06T11:42:44                  |
| description       |                                      |
| dns_nameservers   | 8.8.4.4, 8.8.8.8                     |
| enable_dhcp       | True                                 |
| gateway_ip        | 10.200.51.1                          |
| host_routes       |                                      |
| id                | 9a027a94-e688-45cb-a653-e223ccc9f72f |
| ip_version        | 4                                    |
| ipv6_address_mode | None                                 |
| ipv6_ra_mode      | None                                 |
| name              | ha_lab                               |
| network_id        | 56412e9d-045b-453a-8e09-e3584a8ebaf4 |
| project_id        | 26cfbd9d4ee64d8faecd287bb39d3870     |
| revision_number   | None                                 |
| segment_id        | None                                 |
| service_types     | None                                 |
| subnetpool_id     | None                                 |
| tags              |                                      |
| updated_at        | 2018-08-06T11:42:44                  |
+-------------------+--------------------------------------+
```

Note the DHCP allocation pool here. It is configured in such way, so there are some IP addresses below 10.200.51.32, which
are excluded from pool. Virtual IP address must be allocated from the excluded range, to ensure that it will not be
assigned to any instance by mistake. For this example, we will stick to `10.200.51.10`. The third instance, `observer`,
will be used by us to check connectivity to virtual IP.

First, let's install and configure keepalived on `ha_first` and `ha_second`:

```shell
ubuntu@ha-first:~$ sudo apt install keepalived
```

Now, let's create the keepalived configuration.

`/etc/keepalived/keepalived.conf` on `ha_first`:

```shell
vrrp_instance vrrp_1 {
    debug 2
    interface ens3
    state MASTER
    virtual_router_id 1
    use_vmac
    vmac_xmit_base
    priority 200
    unicast_src_ip 10.200.51.32 dev ens3
    unicast_peer {
        10.200.51.33 dev ens3
    }
    virtual_ipaddress {
        10.200.51.10
    }
}
```

`/etc/keepalived/keepalived.conf` on `ha_second`:

```shell
vrrp_instance vrrp_1 {
    debug 2
    interface ens3
    state MASTER
    virtual_router_id 1
    use_vmac
    vmac_xmit_base
    priority 100
    unicast_src_ip 10.200.51.33 dev ens3
    unicast_peer {
        10.200.51.32 dev ens3
    }
    virtual_ipaddress {
        10.200.51.10
    }
}
```

Some of these options need special attention in cloud environments:

* `use_vmac` - forces VRRP virtual router to use a virtual MAC address as described in RFC. This will decrease convergence time, since there is no need to update the ARP entry on client instances. This also mitigates some limitations, discovered in our SDN controller, since it caches ARP tables and will reply with the MAC address of `ha_first`, even when the virtual IP address is moved to `ha_second`. When two instances share the same MAC address, this problem goes away.
* `vmac_xmit_base` - forces VRRP to use the physical interface MAC address as source when it sends its own packets. This is required for correct operation and to avoid any IP filtering by port security.
* `unicast_src_ip` and `unicast_peer` - since the cloud does not support broadcast, all communication must be unicast.

Now, let's start keepalived and ensure that instances recognize each other, and state of `ha_second` is transitioned to
BACKUP. Let's check some logs for that.

`journalctl -u keepalived` on `ha_first`:

```shell
Aug 07 08:46:33 ha-first systemd[1]: Starting Keepalive Daemon (LVS and VRRP)...
Aug 07 08:46:33 ha-first Keepalived[8765]: Starting Keepalived v1.3.9 (10/21,2017)
Aug 07 08:46:33 ha-first Keepalived[8765]: Opening file '/etc/keepalived/keepalived.conf'.
Aug 07 08:46:33 ha-first systemd[1]: Started Keepalive Daemon (LVS and VRRP).
Aug 07 08:46:33 ha-first Keepalived[8777]: Starting Healthcheck child process, pid=8779
Aug 07 08:46:33 ha-first Keepalived[8777]: Starting VRRP child process, pid=8780
Aug 07 08:46:33 ha-first Keepalived_healthcheckers[8779]: Opening file '/etc/keepalived/keepalived.conf'.
Aug 07 08:46:33 ha-first Keepalived_vrrp[8780]: Registering Kernel netlink reflector
Aug 07 08:46:33 ha-first Keepalived_vrrp[8780]: Registering Kernel netlink command channel
Aug 07 08:46:33 ha-first Keepalived_vrrp[8780]: Registering gratuitous ARP shared channel
Aug 07 08:46:33 ha-first Keepalived_vrrp[8780]: Opening file '/etc/keepalived/keepalived.conf'.
Aug 07 08:46:33 ha-first Keepalived_vrrp[8780]: vmac: Success creating VMAC interface vrrp.1 for vrrp_instance vrrp_1
Aug 07 08:46:33 ha-first Keepalived_vrrp[8780]: NOTICE: setting sysctl net.ipv4.conf.all.rp_filter from 1 to 0
Aug 07 08:46:33 ha-first Keepalived_vrrp[8780]: Using LinkWatch kernel netlink reflector...
Aug 07 08:46:34 ha-first Keepalived_vrrp[8780]: VRRP_Instance(vrrp_1) Transition to MASTER STATE
Aug 07 08:46:35 ha-first Keepalived_vrrp[8780]: VRRP_Instance(vrrp_1) Entering MASTER STATE
Aug 07 08:46:38 ha-first Keepalived_vrrp[8780]: VRRP_Instance(vrrp_1) Received advert with lower priority 100, ours 200, forcing new election
```

`journalctl -u keepalived` on `ha_second`:

```shell
Aug 07 08:46:38 ha-second systemd[1]: Starting Keepalive Daemon (LVS and VRRP)...
Aug 07 08:46:38 ha-second Keepalived[8647]: Starting Keepalived v1.3.9 (10/21,2017)
Aug 07 08:46:38 ha-second Keepalived[8647]: Opening file '/etc/keepalived/keepalived.conf'.
Aug 07 08:46:38 ha-second systemd[1]: Started Keepalive Daemon (LVS and VRRP).
Aug 07 08:46:38 ha-second Keepalived[8662]: Starting Healthcheck child process, pid=8664
Aug 07 08:46:38 ha-second Keepalived[8662]: Starting VRRP child process, pid=8665
Aug 07 08:46:38 ha-second Keepalived_healthcheckers[8664]: Opening file '/etc/keepalived/keepalived.conf'.
Aug 07 08:46:38 ha-second Keepalived_vrrp[8665]: Registering Kernel netlink reflector
Aug 07 08:46:38 ha-second Keepalived_vrrp[8665]: Registering Kernel netlink command channel
Aug 07 08:46:38 ha-second Keepalived_vrrp[8665]: Registering gratuitous ARP shared channel
Aug 07 08:46:38 ha-second Keepalived_vrrp[8665]: Opening file '/etc/keepalived/keepalived.conf'.
Aug 07 08:46:38 ha-second Keepalived_vrrp[8665]: vmac: Success creating VMAC interface vrrp.1 for vrrp_instance vrrp_1
Aug 07 08:46:38 ha-second Keepalived_vrrp[8665]: NOTICE: setting sysctl net.ipv4.conf.all.rp_filter from 1 to 0
Aug 07 08:46:38 ha-second Keepalived_vrrp[8665]: Using LinkWatch kernel netlink reflector...
Aug 07 08:46:38 ha-second Keepalived_vrrp[8665]: VRRP_Instance(vrrp_1) Transition to MASTER STATE
Aug 07 08:46:38 ha-second Keepalived_vrrp[8665]: VRRP_Instance(vrrp_1) Received advert with higher priority 200, ours 100
Aug 07 08:46:38 ha-second Keepalived_vrrp[8665]: VRRP_Instance(vrrp_1) Entering BACKUP STATE
```

Looks like everything is correct. We can confirm that by seeing the virtual IP address on `ha_first` instance:

```shell
ubuntu@ha-first:~$ ip -4 a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: ens3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 576 qdisc fq_codel state UP group default qlen 1000
    inet 10.200.51.32/24 brd 10.200.51.255 scope global dynamic ens3
       valid_lft 86037sec preferred_lft 86037sec
3: vrrp.1@ens3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 576 qdisc noqueue state UP group default qlen 1000
    inet 10.200.51.10/32 scope global vrrp.1
       valid_lft forever preferred_lft forever
ubuntu@ha-first:~$
```

Let's check if we can reach this IP address from our observer instance.

```shell
ubuntu@observer:~$ ping 10.200.51.10 -c 3
PING 10.200.51.10 (10.200.51.10) 56(84) bytes of data.
From 10.200.51.34 icmp_seq=1 Destination Host Unreachable
From 10.200.51.34 icmp_seq=2 Destination Host Unreachable
From 10.200.51.34 icmp_seq=3 Destination Host Unreachable

--- 10.200.51.10 ping statistics ---
3 packets transmitted, 0 received, +3 errors, 100% packet loss, time 2043ms
pipe 3

ubuntu@observer:~$ ip neigh
10.200.51.10 dev ens3  FAILED
10.200.51.1 dev ens3 lladdr fa:16:3e:c9:e0:b1 REACHABLE
ubuntu@observer:~$
```

The reason why we can't ping or even arp a virtual IP address, is neutron port security. We need to allow this IP address
on ports, that connect instances `ha_first` and `ha_second` to the network 10.200.51.0/24.

First, let's find port IDs:

```shell
$ openstack port list --network ha_lab
+--------------------------------------+------+-------------------+-----------------------------------------------------------------------------+--------+
| ID                                   | Name | MAC Address       | Fixed IP Addresses                                                          | Status |
+--------------------------------------+------+-------------------+-----------------------------------------------------------------------------+--------+
| db8fa14d-5800-4db5-8ad7-fe9ad1eaef37 |      | fa:16:3e:08:e6:15 | ip_address='10.200.51.34', subnet_id='9a027a94-e688-45cb-a653-e223ccc9f72f' | ACTIVE |
| 913c4131-0cc3-4df4-9f7e-b4cf4ae885ca |      | fa:16:3e:8d:dc:bb | ip_address='10.200.51.32', subnet_id='9a027a94-e688-45cb-a653-e223ccc9f72f' | ACTIVE |
| a8389d5e-6bd0-4368-a6fb-249127f9cdca |      | fa:16:3e:c9:e0:b1 | ip_address='10.200.51.1', subnet_id='9a027a94-e688-45cb-a653-e223ccc9f72f'  | ACTIVE |
| e220e2d9-f4de-4941-92e0-640ee352aa4f |      | fa:16:3e:f3:a9:a3 | ip_address='10.200.51.33', subnet_id='9a027a94-e688-45cb-a653-e223ccc9f72f' | ACTIVE |
+--------------------------------------+------+-------------------+-----------------------------------------------------------------------------+--------+
```

Second and fourth lines are ports, connecting `ha_first` and `ha_second` accordingly. Now, we must allow `10.200.51.10` on these ports:

```shell
$ openstack port set --allowed-address ip-address=10.200.51.10 913c4131-0cc3-4df4-9f7e-b4cf4ae885ca
(no output)
$ openstack port set --allowed-address ip-address=10.200.51.10 e220e2d9-f4de-4941-92e0-640ee352aa4f
```

Let's check connectivity again:

```shell
ubuntu@observer:~$ ping 10.200.51.10 -c 3
PING 10.200.51.10 (10.200.51.10) 56(84) bytes of data.
64 bytes from 10.200.51.10: icmp_seq=1 ttl=64 time=3.24 ms
64 bytes from 10.200.51.10: icmp_seq=2 ttl=64 time=1.17 ms
64 bytes from 10.200.51.10: icmp_seq=3 ttl=64 time=1.03 ms

--- 10.200.51.10 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2003ms
rtt min/avg/max/mdev = 1.035/1.818/3.243/1.009 ms

ubuntu@observer:~$ ip neigh
10.200.51.10 dev ens3 lladdr 00:00:5e:00:01:01 REACHABLE
10.200.51.1 dev ens3 lladdr fa:16:3e:c9:e0:b1 REACHABLE
ubuntu@observer:~$
```

We can now successfully reach the virtual IP address. It has the MAC address 00:00:5e:00:01:01, which, according to RFC, is
the virtual mac address assigned to VRRP virtual router 1 (configuration option virtual_router_id)

Let's now bring down keepalived process on `ha_first` and check if virtual IP address will now be served by `ha_second`:

```shell
ubuntu@ha-first:~$ sudo systemctl stop keepalived.service
```

Now we can see that instance `ha_second` took the IP address:

```shell
ubuntu@ha-second:~$ ip -4 a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: ens3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 576 qdisc fq_codel state UP group default qlen 1000
    inet 10.200.51.33/24 brd 10.200.51.255 scope global dynamic ens3
       valid_lft 85234sec preferred_lft 85234sec
3: vrrp.1@ens3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 576 qdisc noqueue state UP group default qlen 1000
    inet 10.200.51.10/32 scope global vrrp.1
       valid_lft forever preferred_lft forever
```

There is confirmation in log:

```shell
Aug 07 09:06:18 ha-second Keepalived_vrrp[8665]: VRRP_Instance(vrrp_1) Transition to MASTER STATE
Aug 07 09:06:19 ha-second Keepalived_vrrp[8665]: VRRP_Instance(vrrp_1) Entering MASTER STATE
```

## Conclusion

With this configuration, it takes approximately 2 seconds to discover failure and update MAC forwarding tables.
Convergence time can be decreased by tuning `Advertisement_Interval`, `Skew_Time` and `Master_Down_Interval`.
This could be improved even more, by using [BFD](https://en.wikipedia.org/wiki/Bidirectional_Forwarding_Detection).
