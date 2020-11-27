---
title: 'REST API for Quota Information'
date: '01-11-2019 12:00'
taxonomy:
    category:
        - docs
---

## Introduction

For many resource types like instances, VCPUs, volume storage you can check
the limits and the current usage in the dashboard (Horizon) or use the
standard OpenStack APIs to collect the data in some automation.
But information about quota and usage of object storage (S3) is not
available using standard APIs.

For quota and usage information including object storage the SysEleven Stack
offers an own REST API.

## Requirements

For queries to the quota API you need an OpenStack Keystone token to
authenticate with. If you installed the OpenStack command line tools
you can create a token with the command `openstack token issue`.

```plain
openstack token issue
+------------+----------------------------------+
| Field      | Value                            |
+------------+----------------------------------+
| expires    | 2019-11-02T06:43:11+0000         |
| id         | 01234567890abcdef01234567890abcd |
| project_id | 11111111111111111111111111111111 |
| user_id    | 22222222222222222222222222222222 |
+------------+----------------------------------+
```

The token ("id" row in the table) has to be passed in the `X-Auth-Token` header of the REST API requests.

## Query quota

### URL

```plain
GET https://api.cloud.syseleven.net:5001/v1/projects/{project_id}/quota
```

### Request parameters

Name        | Where    | Description |
------------|----------|-------------|
project_id  | URL path | The OpenStack project ID. It needs to be the same as the one the token was created with. |
X-Auth-Token | Header | Token for authenticating the request. |
regions      | URL query parameter | Optionally restrict the regions to be queried. Comma-separated list of region names. If no region is given here, all regions are queried. |

Example

- Token "01234567890abcdef01234567890abcd"
- Project ID "11111111111111111111111111111111"
- Regions cbk and dbl

```shell
curl -H 'X-Auth-Token: 01234567890abcdef01234567890abcd' https://api.cloud.syseleven.net:5001/v1/projects/11111111111111111111111111111111/quota?regions=cbk,dbl
```

### Response

The response contains the quota information in JSON format. Example for a response with information about regions cbk and dbl:

```json
{
  "cbk": {
    "compute.cores": 50,
    "compute.instances": 50,
    "compute.ram_mb": 204800,
    "dns.zones": 10,
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
  "dbl": {
    "compute.cores": 60,
    "compute.instances": 60,
    "compute.ram_mb": 245760,
    "dns.zones": 10,
    "network.floatingips": 50,
    "network.lb_healthmonitors": 1024,
    "network.lb_listeners": 1024,
    "network.lb_members": 1024,
    "network.lb_pools": 1024,
    "network.loadbalancers": 1024,
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

Field | Description
-----|---------|-------------
compute.cores | Number of virtual cores |
compute.instances | Number of virtual machines (servers, instances) |
compute.ram_mb | RAM for virtual machines in MiB |
dns.zones | Number of DNS zones |
network.floatingips | Number of floating IP addresses |
network.lb_healthmonitors | Number of Neutron LBaaSv2 health monitors |
network.lb_listeners | Number of Neutron LBaaSv2 listeners |
network.lb_members | Number of Neutron LBaaSv2 pool members |
network.lb_pools | Number of Neutron LBaaSv2 pools |
network.loadbalancers | Number of Neutron LBaaSv2 load balancers |
network.vpn_endpoint_groups | Number of VPNaaS endpoint groups |
network.vpn_ikepolicy | Number of VPNaaS IKE policies |
network.vpn_ipsec_site_connections | Number of VPNaaS site connections |
network.vpn_ipsecpolicies | Number of VPNaaS IPSec policies |
network.vpn_services | Number of VPNaaS VPN services |
s3.space_bytes | Limit of Object Storage (S3) size in bytes |
volume.space_gb | Limit of Block Storage size (for volumes) in GiB |
volume.volumes | Number of Block Storage volumes |

A limit of -1 means "unlimited", 0 means "no resources".

## Query current usage

### URL

```plain
GET https://api.cloud.syseleven.net:5001/v1/projects/{project_id}/current_usage
```

### Request parameters

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

Component names supported by `filter`:

- compute
- dns
- network
- network.lb
- network.vpn
- s3
- volume

Example

- Token "01234567890abcdef01234567890abcd"
- Project ID "11111111111111111111111111111111"
- Regions cbk and dbl
- Filter for components "compute" and "s3"

```shell
curl -H 'X-Auth-Token: 01234567890abcdef01234567890abcd' https://api.cloud.syseleven.net:5001/v1/projects/11111111111111111111111111111111/current_usage?regions=cbk,dbl&filter=compute,s3
```

### Response

The response contains the information about the currently-used resources in JSON format. Example of a response with data about regions cbk and dbl (and without a component filter):

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
  "dbl": {
    "compute.cores": 50,
    "compute.flavors": {
      "m1.medium": 5,
      "m1.small": 3,
      "m1.xxlarge": 1
    },
    "compute.instances": 9,
    "compute.ram_mb": 204800,
    "dns.zones": 2,
    "network.floatingips": 10,
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
    "s3.space_bytes": 12,
    "volume.space_gb": 133,
    "volume.volumes": 7
  }
}
```

Field | Description |
------|-------------|
compute.cores | Number of virtual cores |
compute.flavors | Number of virtual machines per flavor |
compute.instances | Total number of virtual machines |
compute.ram_mb | Total RAM of virtual machines in MiB |
dns.zones | Number of DNS zones |
network.floatingips | Number of floating IP addresses |
network.lb_healthmonitors | Number of LBaaS health monitors |
network.lb_listeners | Number of LBaaS listeners |
network.lb_members | Number of LBaaS pool members |
network.lb_pools | Number of LBaaS pools |
network.loadbalancers | Number of LBaaS load balancers |
network.vpn_endpoint_groups | Number of VPNaaS endpoint groups |
network.vpn_ikepolicy | Number of VPNaaS IKE policies |
network.vpn_ipsec_site_connections | Number of VPNaaS site connections |
network.vpn_ipsecpolicies | Number of VPNaaS IPSec policies |
network.vpn_services | Number of VPNaaS VPN services |
s3.space_bytes | Used size of Object Storage (S3) in Bytes |
volume.space_gb | Used size of Block Storage (volumes) in GiB |
volume.volumes | Number of Block Storage volumes |


## Contributed Software

One of our customers kindly created an exporter to use this API with Prometheus and made it available as open source on [GitHub](https://github.com/Staffbase/syseleven-exporter).
