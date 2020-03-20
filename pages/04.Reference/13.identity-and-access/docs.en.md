---
title: Identity and Access
published: true
date: '20-03-2020 10:40'
taxonomy:
    category:
        - docs
---

## Overview

OpenStack's Identity API is implemented via Keystone. It provided API client authentication, service discovery, and distributed multi-tenant authorization.


## Roles

By default a cloud user has 2 roles, the viewer role which represents a read-only access and the operator role which represents a read-write access. It is necessary for the user to have both roles assigned in order to be able to delegate the read-only or read-write rights to application credentials.

If there is a need for specific service.

## Tokens

OpenStack supports authorization via tokens, via the OpenStack python CLI you could create a token using your user credentials.

```shell
openstack token issue
+------------+----------------------------------+
| Field      | Value                            |
+------------+----------------------------------+
| expires    | 2020-03-21T08:37:54+0000         |
| id         | ab4d1e500c5245e5a166892943118a44 |
| project_id | 18ba5d3f9d714091bca8859a401d825f |
| user_id    | 0c66382aa9594649abf7a99720058bba |
+------------+----------------------------------+
```


```shell
openstack token revoke ab4d1e500c5245e5a166892943118a44
```