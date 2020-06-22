---
title: Secrets
published: true
date: '18-06-2020 10:40'
taxonomy:
    category:
        - docs
---

## Overview

SysEleven Stack uses the OpenStack component Barbican for secret storage. We introduced the Barbican secret storage first of all to provide a safe way to store SSL certificates and private keys for [Octavia Load balancer as a Service](../08.Network/02.lbaas/docs.en.md). 

!! Barbican is part of the Octavia public beta phase. This means we invite you to test the Barbican secret storage, but we do not recommend you to use it for production workloads yet.

The barbican secret storage is part of our global region. This means, similar to [Keystone (Identity and Access)](../01.identity-and-access/docs.en.md) and [Designate (DNSaaS)](../07.dns/docs.en.md), there is one API for all regions.

Barbican feature                     | Supported
-------------------------------------|-------------
Secret storage and metadata          | Yes
Secret containers                    | Yes
Secret consumers                     | Yes
Access control lists                 | Yes
Certificate orders                   | No

### Secret storage and metadata

SysEleven will store every secret under the hood in an instance of [hashicorp vault](www.vaultproject.io), dedicated solely to Barbican. All secrets are transferred and stored fully encrypted at all times.

Metadata will not be stored fully encrypted.

### Secret containers

Secret containers represent a set of secrets, for a certain purpose.

Containers can be of type `generic`, `RSA`, or `Certificate`.

Type              | Accompanied secret names
------------------|----------------------------
Generic           | No restrictions
RSA               | `public_key`, `private_key`, and `private_key_passphrase`
Certificate       | `certificate` and optionally `private_key`, `private_key_passphrase`, and `intermediates`

### Secret consumers

Barbican can be used to persist a list of secret consumers for any given secret container. The secret consumer consists of a consumer name, a URL and a reference to the secret container.

### Access control lists

By default, secrets and secret containers are accessible for all users of a project (See the [identity and access reference guide](../01.identity-and-access/docs.en.md) for more information about users, groups and projects)

Using access control lists, you can reduce access to certain users or groups.

!! Currently the access control list (ACL) settings defined for a container are not propagated down to associated secrets.

### Known issues

- Currently it is not possible to create secret containers of type certificate with Terraform. See [the terraform issue tracker](https://github.com/terraform-providers/terraform-provider-openstack/issues/1005) and the [OpenStack issue tracker](https://storyboard.openstack.org/#!/story/2007629).