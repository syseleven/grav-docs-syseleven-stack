---
title: 'REST API for Quota and Usage Information'
published: true
date: '26-07-2021 16:25'
taxonomy:
    category:
        - docs
---


## Rest API

For many resource types like instances, vCPUs, volume storage you can check the limits and the current usage in the dashboard (Horizon) or use the standard OpenStack APIs to collect the data in some automation. But information about quota and usage of object storage (SEOS, S3) is not available using standard APIs.

For quota and usage information including object storage the SysEleven Stack offers an own REST API.

### Requirements

For queries to the quota API you need an OpenStack Keystone token to authenticate with. If you installed the OpenStack command line tools you can create a token with the command `openstack token issue`.

```plain
openstack token issue
+------------+----------------------------------+
| Field      | Value                            |
+------------+----------------------------------+
| expires    | 2019-11-02T06:43:11+0000         |
| id         | gAAAAABiI...                     |
| project_id | 11111111111111111111111111111111 |
| user_id    | 22222222222222222222222222222222 |
+------------+----------------------------------+
```

The token ("id" row in the table) has to be passed in the `X-Auth-Token` header of the REST API requests.

With the following command you may directly assign a new token to a shell variable:

```plain
token=$(openstack token issue -c id -f value)
```

### API versions

There are 2 versions of the REST API: v1 and v2. Version v2 extends the data schema for usage and quota API endpoints to add values related to Octavia load balancers. The following examples use v2-based URLs, but v1 is still supported (just replace v2 with v1 in the URL).

### Query quota limits

#### URL

```plain
GET https://api.cloud.syseleven.net:5001/v2/projects/{project_id}/quota
```

#### Request parameters

Name        | Where    | Description |
------------|----------|-------------|
project_id  | URL path | The OpenStack project ID. It needs to be the same as the one the token was created with. |
X-Auth-Token | Header | Token for authenticating the request. |
regions      | URL query parameter | Optionally restrict the regions to be queried. Comma-separated list of region names. If no region is given here, all regions are queried. |

Example:

- Project ID "11111111111111111111111111111111"
- Regions cbk and dbl

```shell
token=$(openstack token issue -c id -f value)
curl -H "X-Auth-Token: $token" 'https://api.cloud.syseleven.net:5001/v2/projects/11111111111111111111111111111111/quota?regions=cbk,fes'
```

#### Response

The response contains the quota information in JSON format. Example for a response with information about regions cbk and fes:

```json
{
  "cbk": {
    "compute.cores": 50,
    "compute.instances": 50,
    "compute.ram_mb": 204800,
    "dns.zones": 10,
    "loadbalancer.healthmonitors": 200,
    "loadbalancer.listeners": 200,
    "loadbalancer.loadbalancers": 15,
    "loadbalancer.members": 300,
    "loadbalancer.pools": 200,
    "network.floatingips": 50,
    "network.lb_healthmonitors": 1024,
    "network.lb_listeners": 1024,
    "network.lb_members": 128,
    "network.lb_pools": 128,
    "network.loadbalancers": 1024,
    "network.vpn_endpoint_groups": -1,
    "network.vpn_ikepolicies": -1,
    "network.vpn_ipsec_site_connections": -1,
    "network.vpn_ipsecpolicies": -1,
    "network.vpn_services": -1,
    "s3.space_bytes": 4294967296,
    "volume.space_gb": 1000,
    "volume.volumes": 1024
  },
  "fes": {
    "compute.cores": 60,
    "compute.instances": 60,
    "compute.ram_mb": 245760,
    "dns.zones": 10,
    "loadbalancer.healthmonitors": 200,
    "loadbalancer.listeners": 200,
    "loadbalancer.loadbalancers": 15,
    "loadbalancer.members": 300,
    "loadbalancer.pools": 200,
    "network.floatingips": 50,
    "network.vpn_endpoint_groups": -1,
    "network.vpn_ikepolicies": -1,
    "network.vpn_ipsec_site_connections": -1,
    "network.vpn_ipsecpolicies": -1,
    "network.vpn_services": -1,
    "s3.space_bytes": -1,
    "volume.space_gb": 1000,
    "volume.volumes": 1024
  }
}
```

Overview of fields:

Field | Description | Notes
------|-------------|-------------
compute.cores | Number of virtual cores ||
compute.instances | Number of virtual machines (servers, instances) ||
compute.ram_mb | RAM for virtual machines in MiB ||
dns.zones | Number of DNS zones ||
loadbalancer.healthmonitors | Number of Octavia LBaaS health monitors | since v2 |
loadbalancer.listeners | Number of Octavia LBaaS listeners | since v2 |
loadbalancer.members | Number of Octavia LBaaS pool members | since v2 |
loadbalancer.pools | Number of Octavia LBaaS pools | since v2 |
loadbalancer.loadbalancers | Number of Octavia LBaaS load balancers | since v2 |
network.floatingips | Number of floating IP addresses ||
network.lb_healthmonitors | Number of Neutron LBaaS v2 health monitors | only in regions cbk and dbl |
network.lb_listeners | Number of Neutron LBaaS v2 listeners | only in regions cbk and dbl |
network.lb_members | Number of Neutron LBaaS v2 pool members | only in regions cbk and dbl |
network.lb_pools | Number of Neutron LBaaS v2 pools | only in regions cbk and dbl |
network.loadbalancers | Number of Neutron LBaaS v2 load balancers | only in regions cbk and dbl |
network.vpn_endpoint_groups | Number of VPNaaS endpoint groups ||
network.vpn_ikepolicy | Number of VPNaaS IKE policies ||
network.vpn_ipsec_site_connections | Number of VPNaaS site connections ||
network.vpn_ipsecpolicies | Number of VPNaaS IPSec policies ||
network.vpn_services | Number of VPNaaS VPN services ||
s3.space_bytes | Limit of Object Storage (S3) size in bytes ||
volume.space_gb | Limit of Block Storage size (for volumes) in GiB ||
volume.volumes | Number of Block Storage volumes ||

A limit of -1 means "unlimited", 0 means "no resources".

### Query current usage

#### URL

```plain
GET https://api.cloud.syseleven.net:5001/v2/projects/{project_id}/current_usage
```

#### Request parameters

Name         | Where    | Description |
-------------|----------|-------------|
project_id   | URL path | The OpenStack project ID. It needs to be the same as the one the token was created with. |
X-Auth-Token | Header | Token for authenticating the request. |
regions      | URL query parameter | Optionally restrict the regions to be queried. Comma-separated list of region names. If no region is given here, all regions are queried. |
filter       | URL query parameter | Optionally restrict the components to be queried. Comma-separated list of component names like "compute", "network", etc. See below for a list |

Using the `regions` and `filter` parameters you may restrict the query to regions and/or components.
If you are only interested in the usage information of certain components, using those filters allows
to accelerate the queries because unnecessary internal communication to other components or regions is
avoided.

**Component names supported by `filter`**

Filter name  | Details |
-------------|---------|
compute      | Compute resources |
dns          | DNS zones |
loadbalancer | Load balancer resources (Octavia LBaaS); since v2 |
network      | Network resources (excl. LBaaS and VPNaaS) |
network.lb   | Neutron LBaaS v2 resources |
network.vpn  | VPNaaS resources |
s3           | Object storage consumption |
volume       | Block storage resources |

Example:

- Project ID "11111111111111111111111111111111"
- Regions cbk and fes
- Filter for components "compute" and "s3"

```shell
token=$(openstack token issue -c id -f value)
curl -H "X-Auth-Token: $token" 'https://api.cloud.syseleven.net:5001/v2/projects/11111111111111111111111111111111/current_usage?regions=cbk,fes&filter=compute,s3'
```

#### Response

The response contains the information about the currently-used resources in JSON format. Example of a response with data about regions cbk and fes (and without a component filter):

```json
{
  "cbk": {
    "compute.cores": 3,
    "compute.flavors": {
      "m1c.tiny": 3
    },
    "compute.instances": 3,
    "compute.ram_mb": 6144,
    "dns.zones": 2,
    "loadbalancer.flavors": {
      "failover-small": 1
    },
    "loadbalancer.healthmonitors": 1,
    "loadbalancer.listeners": 1,
    "loadbalancer.loadbalancers": 1,
    "loadbalancer.members": 2,
    "loadbalancer.pools": 1,
    "network.floatingips": 4,
    "network.lb_healthmonitors": 0,
    "network.lb_listeners": 0,
    "network.lb_members": 0,
    "network.lb_pools": 0,
    "network.loadbalancers": 0,
    "network.vpn_endpoint_groups": 0,
    "network.vpn_ikepolicies": 1,
    "network.vpn_ipsec_site_connections": 1,
    "network.vpn_ipsecpolicies": 1,
    "network.vpn_services": 1,
    "s3.space_bytes": 48,
    "volume.space_gb": 6,
    "volume.volumes": 4
  },
  "fes": {
    "compute.cores": 50,
    "compute.flavors": {
      "m1.medium": 5,
      "m1.small": 3,
      "m1.xxlarge": 1
    },
    "compute.instances": 9,
    "compute.ram_mb": 204800,
    "dns.zones": 2,
    "loadbalancer.flavors": {
      "failover-small": 2,
      "standalone-tiny": 1
    },
    "loadbalancer.healthmonitors": 3,
    "loadbalancer.listeners": 3,
    "loadbalancer.loadbalancers": 3,
    "loadbalancer.members": 6,
    "loadbalancer.pools": 3,
    "network.floatingips": 10,
    "network.vpn_endpoint_groups": 0,
    "network.vpn_ikepolicies": 1,
    "network.vpn_ipsec_site_connections": 1,
    "network.vpn_ipsecpolicies": 1,
    "network.vpn_services": 1,
    "s3.space_bytes": 12,
    "volume.space_gb": 133,
    "volume.volumes": 7
  }
}
```

Field | Description | Notes |
------|-------------|-------|
compute.cores | Number of virtual cores ||
compute.flavors | Number of virtual machines per flavor ||
compute.instances | Total number of virtual machines ||
compute.ram_mb | Total RAM of virtual machines in MiB ||
dns.zones | Number of DNS zones ||
loadbalancer.flavors | Number of Octavia LBaaS load balancers per flavor | since v2 |
loadbalancer.healthmonitors | Number of Octavia LBaaS health monitors | since v2 |
loadbalancer.listeners | Number of Octavia LBaaS  listeners | since v2 |
loadbalancer.loadbalancers | Number of Octavia LBaaS  load balancers | since v2 |
loadbalancer.members | Number of Octavia LBaaS  pool members | since v2 |
loadbalancer.pools | Number of Octavia LBaaS  pools | since v2 |
network.floatingips | Number of floating IP addresses ||
network.lb_healthmonitors | Number of Neutron LBaaS v2 health monitors | only in regions cbk and dbl |
network.lb_listeners | Number of Neutron LBaaS v2 listeners | only in regions cbk and dbl |
network.lb_members | Number of Neutron LBaaS v2 pool members | only in regions cbk and dbl |
network.lb_pools | Number of Neutron LBaaS v2 pools | only in regions cbk and dbl |
network.loadbalancers | Number of Neutron LBaaS v2 load balancers | only in regions cbk and dbl |
network.vpn_endpoint_groups | Number of VPNaaS endpoint groups ||
network.vpn_ikepolicy | Number of VPNaaS IKE policies ||
network.vpn_ipsec_site_connections | Number of VPNaaS site connections ||
network.vpn_ipsecpolicies | Number of VPNaaS IPSec policies ||
network.vpn_services | Number of VPNaaS VPN services ||
s3.space_bytes | Used size of Object Storage (S3) in Bytes ||
volume.space_gb | Used size of Block Storage (volumes) in GiB ||
volume.volumes | Number of Block Storage volumes ||

### Contributed Software

One of our customers kindly created an exporter to use this API (v1) with Prometheus and made it available as open source on [GitHub](https://github.com/Staffbase/syseleven-exporter).
