---
title: Secrets
published: true
date: '26-07-2021 16:25'
taxonomy:
    category:
        - docs
---

## Overview

SysEleven Stack uses the OpenStack component `Barbican` for secret storage. We introduced the Barbican secret storage first of all to provide a safe way to store SSL certificates and private keys for [Octavia Load balancer as a Service](../08.network/02.lbaas/docs.en.md).

The barbican secret storage is part of our global region. This means, similar to [Keystone (Identity and Access)](../01.identity-and-access/docs.en.md) and [Designate (DNSaaS)](../07.dns/docs.en.md), there is one API for all regions.

Barbican feature                     | Supported
-------------------------------------|-------------
Secret storage and metadata          | Yes
Containers                           | Yes
Access control lists                 | Yes
Certificate orders                   | No

## Secret storage and metadata

All secrets are transferred and stored fully encrypted at all times. Metadata may not be stored fully encrypted.

## Containers

Containers represent a set of secrets, for a certain purpose.

Containers can be of type `generic`, `RSA`, or `Certificate`.

Type              | Accompanied secret names
------------------|----------------------------
Generic           | No restrictions
RSA               | `public_key`, `private_key`, and `private_key_passphrase`
Certificate       | `certificate` and optionally `private_key`, `private_key_passphrase`, and `intermediates`

## Access control lists

By default, secrets and containers are accessible for all users of a project (See the [identity and access reference guide](../01.identity-and-access/docs.en.md) for more information about users, groups and projects).

Using access control lists, you can reduce access to certain users or groups.

!! Currently the access control list (ACL) settings defined for a container are not propagated down to associated secrets.

## Known issues

- Currently it is not possible to create containers of type certificate with Terraform. See [the terraform issue tracker](https://github.com/terraform-providers/terraform-provider-openstack/issues/1005) and the [OpenStack issue tracker](https://storyboard.openstack.org/#!/story/2007629).
