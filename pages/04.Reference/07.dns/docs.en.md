---
title: 'DNS'
published: true
date: '24-06-2919 11:08'
taxonomy:
    category:
        - docs
---

## DNS

Using the SysEleven Stack DNS service you can rely on our authoritative DNS infrastructure and experience for your domains and records.

The service is based on and compatible with the OpenStack Designate project and therefore supported by various clients and tools.

You can manage DNS zones and records both via our [public OpenStack API endpoints](../../02.Tutorials/02.api-access/docs.en.md), as well as using the Dashboard.

The DNS service is shared between all regions. You will need to choose a region in the Dashboard or using the OpenStack CLI environment variable `OS_REGION`, but it does not matter which one you choose. DNS objects are always global.

!! The SysEleven Stack DNS service is currently in the test phase. The test phase ends in September 2019. Until then you can use all features free of charge.

### Feature Support Matrix

| OpenStack Designate Feature             |   CBK region   |   DBL region
| ----------------------------------------|----------------|-------------
| Manage zones and recordsets             | yes            | yes
| Zone transfer to different projects     | yes            | yes
| Secondary Zones                         | yes            | yes
| Zone Import / Export                    | yes            | yes
| PTR records for Floating IPs            | yes            | yes

### Manage zones and recordsets

A `zone` object represents a DNS Zone, e.g. your domain name and your subdomain names. If you want to use the SysEleven Stack DNS service for your domain, you need to delegate it to our DNS servers.

A `recordset` object represents DNS records. One recordset usually consists of a name (e.g. `example.com.` or `www.example.com.`). a type (e.g. `A` for IPv4 records) and one or more records (e.g. `10.0.0.1` and `10.0.0.2`).

To find out more on how you can do this, see our [tutorial](../../02.Tutorials/09.dnsaas/docs.en.md) and [howto guide](../../03.Howtos/09.dnsaas/docs.en.md).

!! Please note that DNS zones in the SysEleven DNS service must be fully qualified, which means they must end with a trailing dot. If your domain name is `example.com`, the corresponding fully qualified zone name would be `example.com.`

### Zone transfer to different projects

It is possible to transfer zones If they need to be maintained using different OpenStack projects. For example you can have a zone named `company.com.` in `project-a` and another zone named `team-1.company.com.` in `project-b`.

#### Zone disputes

It is not automatically possible for us to verify ownership of your domain names, so in very rare circumstances your domain name might have been claimed by another customer already. Please contact our customer support in this case.

### Secondary Zones

It is possible to use our authoritative name server infrastructure together with a hidden master that you maintain yourself. You can accomplish that by creating a secondary zone. Using the OpenStack CLI you can create it like this: `openstack zone create --type secondary --masters master-1.example.com. master-2.example.com`.

Our authoritative name servers will respect the `Refresh`, `Retry`, `Expire` and `TTL` timings in the SOA record as specified by the configured DNS master and our servers will poll for updates using the `AXFR` protocol accordingly. You can expect the `AXFR` to originate from one of our public authoritative DNS servers (`ns01.cloud.syseleven.net`, `ns02.cloud.syseleven.net`, `ns03.cloud.syseleven.net` or `ns04.cloud.syseleven.net`).

Sending the `NOTIFY` message to our DNS servers is not supported.

### Zone Import / Export

To migrate large amounts of zones and records to the SysEleven Stack DNS service, it is possible to use our Import / Export functionality. It is using the master file format as specified in RFC 1035.

### PTR records for Floating IPs

To create a reverse lookup PTR entry for a Floating IP address, two parameters `--dns-domain` and `--dns-name` can be set. DNS zone specfied in `--dns-domain` has to be created and owned by the same project. If zone exists and configured properly, forward A-type record specified in `--dns-name` will be created in it. A reverse PTR-type record will be created in `in-addr.arpa` zone that is hosted in our cloud, but invisible to customer projects.

Full command line to create a Floating IP adress with a reverse PTR record will look like this: `openstack floating ip create --dns-domain example.con. --dns-name mx01 ext-net`

### Automatic PTR records for all VMs with Floating IPs

Forward A-type and reverse PTR-type records can be created automatically for all VMs that have Floating IP address attached. In order to achieve this, `--dns-domain` option should be provied to the OpenStack network during creation time, or later. DNS zone specfied in `--dns-domain` has to be created and owned by the same project. If zone exists and configured properly, forward A-type record and reverse PTR-type record will be created for every VM, after a Floating IP address is attached to it. Host name will be generated from the VM name. Note that disallowed symbols like underscore (_) or space ( ) are not allowed in host names, and will be removed from VM name. When a Floating IP address is detached from a VM, corresponding A and PTR records are deleted. Floating IPs themselves do not have to have any DNS related information.

To create a network with DNS domain set: `openstack network create example-net --dns-domain example.com.`.
To set a DNS domain on existing network: `openstack network set --dns-domain testzone.de. example-net`.
