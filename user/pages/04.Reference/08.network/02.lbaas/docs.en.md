---
title: 'Load Balancer as a Service (LBaaS)'
published: true
date: '2019-02-28 17:30'
taxonomy:
    category:
        - docs
---

## Overview

The SysEleven Stack offers LBaaS via two different generations of APIs: Neutron LBaaSv2 and Octavia.

!! Octavia is currently in the public beta phase. This means we invite you to test Octavia load balancers, but we do not recommend you to use them for production workloads yet.

Looking at the API definition both services are similar. But there are differences in the feature set provided by the SysEleven Stack.
With Neutron LBaaS only simple TCP-based load balancers are supported, with Octavia on the other hand also HTTP and HTTPS. Both services optionally allow to set up health monitoring.

The client IP address can only be made visible to the backend servers if an Octavia load balancer is used, in case of Neutron the backends will only see the IP address of the load balancer.

## Quick comparison table

The following table compares the supported features of the two LBaaS services:

Function                | Neutron LBaaSv2 | Octavia LBaaS
------------------------|-----------------|--------------
Loadbalancing protocols | TCP             | TCP, HTTP, HTTPS, TERMINATED_HTTPS
Distribution strategies | ROUND_ROBIN (random) | ROUND_ROBIN, LEAST_CONNECTIONS, SOURCE_IP
Health Monitoring protocols | TCP, HTTP, HTTPS | PING, HTTP, TCP, HTTPS, TLS-HELLO
Header insertion (`X-Forwarded-For` etc.) | no | yes
PROXY protocol support | no | yes
Available in dashboard | yes | no (planned)

## General limitations of the cloud dashboard (Horizon)

Currently, the cloud dashboard (Horizon) at [cloud.syseleven.de](https://cloud.syseleven.de) only displays Neutron-LBaaS load balancers. Octavia load balancers you can manage [using the API and the OpenStack CLI](../../../02.Tutorials/02.api-access/docs.en.md) (using the `openstack loadbalancer` commands).

## Neutron LBaaSv2

Neutron load balancers can be maintained using the cloud dashboard (Horizon) at [cloud.syseleven.de](https://cloud.syseleven.de), or [using the API and the neutron CLI](../../../02.Tutorials/02.api-access/docs.en.md) (e.g. `neutron lbaas-loadbalancer-list`).

Neutron LBaaSv2 Feature              | Supported in CBK region | Supported in DBL region
-------------------------------------|-------------------------|---------------
Load balancing protocols             | TCP | TCP
Health Monitoring protocols          | HTTP, TCP, HTTPS | HTTP, TCP, HTTPS
Pool protocols                       | TCP | TCP
Distribution strategies              | ROUND_ROBIN (random) | ROUND_ROBIN (random)
Session persistence                  | SOURCE_IP | SOURCE_IP
L7 rules and policies                | No                     | No

### Limitations

- Only TCP-based load balancers are supported. For this reason, it is not possible to make the client IP address visible to the backend servers with Neutron LBaaSv2

## Octavia LBaaS

!! Octavia is currently in the public beta phase. This means we invite you to test Octavia load balancers, but we do not recommend you to use them for production workloads yet.

Octavia is our more advanced load balancer option. Below you will find the reference documentation. If you want a quick start, please refer to our [LBaaS tutorial](../../../02.Tutorials/05.lbaas/docs.en.md).

Octavia LBaaS Feature                | Supported in CBK region | Supported in DBL region
-------------------------------------|-------------------------|---------------
Load balancing protocols             | TCP, HTTP, HTTPS, TERMINATED_HTTPS | TCP, HTTP, HTTPS, TERMINATED_HTTPS
Health Monitoring protocols          | PING, HTTP, TCP, HTTPS, TLS-HELLO | PING, HTTP, TCP, HTTPS, TLS-HELLO
Pool protocols                       | PROXY, TCP, HTTP, HTTPS | PROXY, TCP, HTTP, HTTPS
Distribution strategies              | ROUND_ROBIN, LEAST_CONNECTIONS, SOURCE_IP                    | ROUND_ROBIN, LEAST_CONNECTIONS, SOURCE_IP
Session persistence                  | Yes                     | Yes
Header insertion                     | Yes                     | Yes
L7 rules and policies                | Yes                     | Yes
Load Balancer Flavors                | Yes                     | Yes
VIP QoS policies                     | No                      | No

### Load balancing protocols

The load balancing protocol can be configured using the Octavia LBaaS listener resource (e.g. `openstack loadbalancer listener create`).

Only when using the HTTP and TERMINATED_HTTPS load balancing protocols, it is possible to use <a href="#header-insertion">header insertion</a> as well as <a href="#l7-rules-and-policies">l7 rules and policies</a>.

With load balancers that use the TCP and HTTPS load balancing protocols, this is unfortunately not possible.

### Health monitoring protocols

Adding a health monitor to your load balancer is optional, but we recommend it. Health monitors will make sure that only load balancer pool members that pass a certain test will be considered.

The test protocol (health monitor type) can be configured, among other things, using the Octavia LBaaS healthmonitor resource (e.g. `openstack loadbalancer healthmonitor create`).

### Pool protocols

The pool together with the pool members represent a set of backend servers. It is possible to configure the protocol between backend and load balancer.

Using the special PROXY protocol it is possible to retrieve the client IP address, even with TCP or non-terminated HTTPS load balancing protocols. Please refer to the HAProxy documentation for a [specification of the PROXY protocol](http://www.haproxy.org/download/1.8/doc/proxy-protocol.txt).

Your application must support the PROXY protocol. It is possible to add a reverse proxy like nginx between your application and the Octavia loadbalancer to add PROXY support. The nginx documentation provides a how-to for [receiving the proxy protocol](https://docs.nginx.com/nginx/admin-guide/load-balancer/using-proxy-protocol/).

### Distribution strategies

The distribution strategy controls how the load balancer chooses its backend.

Distribution strategy | Description
----------------------|--------------------
ROUND_ROBIN           | Distribute new requests evenly across all backends (pool members)
LEAST_CONNECTIONS     | Choose the backend server with the least open connections from the load balancer
SOURCE_IP             | Choose the backend server depending on the client IP address

### Session persistence

Session persistence can be configured on the load balancer pool resource.

For load balancers of type `HTTP` and `TERMINATED_HTTPS`, we support the `APP_COOKIE` and `HTTP_COOKIE` session persistence methods. The `SOURCE_IP` session persistence method is supported for all load balancer types.

With `APP_COOKIE` the load balancer will use the specified `cookie_name` to send future requests to the same backend server (`pool member`).

Using `HTTP_COOKIE`, the load balancer will generate a cookie and insert it to the response.

<!-- For UDP flows it is possible to configure persistence_timeout and persistence_granularity https://docs.openstack.org/api-ref/load-balancer/v2/?expanded=create-pool-detail#session-persistence -->

### Header insertion

Header insertion can be configured on the load balancer listener resource, for example using the command `openstack loadbalancer listener create --insert-headers <HEADER>=true [..]`.

Header insertion is turned off by default. When turned on, the specified header with information about the request will be passed to the pool members.

Header insertion is only supported for the `HTTP` and `TERMINATED_HTTPS` load balancer methods. If you need the client IP address on your backend servers with other load balancer methods, consider the <a href="#pool-protocols">PROXY pool protocol</a>.

Header                        | Description
------------------------------| ------------
X-Forwarded-For               | The client IP address
X-Forwarded-Port              | The source port of the TCP connection to the client
X-Forwarded-Proto             | The used protocol between the client and load balancer (Either `http` or `https`)
X-SSL-Client-Verify           | Contains `0` if the client authentication was successful, or an error ID greater than `0`. The error IDs are defined in the OpenSSL library
X-SSL-Client-Has-Cert         | `true` if a client authentication certificate was presented, and `false` if not. Does not indicate validity.
X-SSL-Client-DN               | Contains the full Distinguished Name of the certificate presented by the client
X-SSL-Client-CN               | Contains the Common Name from the full Distinguished Name of the certificate presented by the client
X-SSL-Issuer                  | Contains the full Distinguished Name of the client certificate issuer
X-SSL-Client-SHA1             | Contains the SHA-1 fingerprint of the certificate presented by the client in hex string format
X-SSL-Client-Not-Before       | Contains the start date presented by the client as a formatted string YYMMDDhhmmss[Z].
X-SSL-Client-Not-After        | Contains the end date presented by the client as a formatted string YYMMDDhhmmss[Z].

### L7 rules and policies

Using L7 policies the load balancer can perform actions defined in the `L7 rule`, when all the conditions defined in the associated `L7 policies` are met.

L7 policies are associated with a load balancer listener resource. The listener will evaluate them in order, sorted by the `position` parameter.

L7 Policy Action    | Description
--------------------|----------------------------------
REDIRECT_TO_POOL    | Will use a different load balancer pool for requests matching the L7 policy rules
REDIRECT_TO_PREFIX  | Will concatenate the given prefix with the complete original URI path, and redirect to the resulting location.
REDIRECT_TO_URL     | Will redirect to the given location
REJECT              | The request is denied with the Forbidden (403) response code, and not forwarded on to any back-end pool

The action of the first matching L7 policy will be executed. The L7 policy matches, if all the L7 rules match (`AND` condition). If you need an `OR` condition, create multiple policies with the same action and different rules.

The L7 rule `type` is one of `COOKIE`, `FILE_TYPE`, `HEADER`, `HOST_NAME`, `PATH`, `SSL_CONN_HAS_CERT`, `SSL_VERIFY_RESULT`, and `SSL_DN_FIELD`.

L7 rules always compare a given value with a request value (specified by the rule type), using a `compare_type` (One of `CONTAINS`, `ENDS_WITH`, `EQUAL_TO`, `REGEX`, or `STARTS_WITH`).

Some rule types allow specifying a `key`. Using the `key` you can choose a specific `COOKIE` or `HEADER` by name.

The result can be optionally inverted using the `invert` parameter.

### Load balancer flavors

The SysEleven Stack currently provides two flavors of Octavia Load Balancers:

LB Flavor | Topology | VM flavor | Description
----------|----------|-----------|-------------
failover-small | Active/Standby | m1c.small | Load balancer is implemented in two virtual machines in an active/standby setup.
standalone-tiny | Stand-alone   | m1c.tiny  | Load balancer is implemented in a single stand-alone virtual machine

The default load balancer flavor is `failover-small` which offers more performance and failure resilience. You may choose `standalone-small` instead for development setups to save some resources when failure resilience is not the top priority.
