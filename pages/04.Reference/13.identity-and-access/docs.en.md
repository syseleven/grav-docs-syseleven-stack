---
title: Identity and Access
published: true
date: '20-03-2020 10:40'
taxonomy:
    category:
        - docs
---

## Overview

OpenStack's Identity API is implemented via Keystone. It provides API client authentication, service discovery, and distributed multi-tenant authorization.

## Password

The common way for a user or service to authenticate towards Keystone is by using username and password. You may enter the user credentials in the OpenStack dashboard, or use them inside of your software to manage your OpenStack ressources. A sample OpenStack RC file which can be used for the OpenStack python CLI client would be the following.

```shell
export OS_AUTH_URL=https://keystone.cloud.syseleven.net:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_PROJECT_ID="<your-project-id>"
export OS_USER_DOMAIN_NAME="Default"
export OS_INTERFACE=public
export OS_ENDPOINT_TYPE=public
export OS_USERNAME="<your-username>"
export OS_PASSWORD="<your-password>"
export OS_INTERFACE="public"
export OS_REGION_NAME="dbl"
#export OS_REGION_NAME="cbk"
```

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

These tokens are valid for 24 hours and cannot be listed after creation. You can use this token to authenticate yourself by slightly changing your OpenStack RC file you may used for creating this token.

```shell
export OS_TOKEN="ab4d1e500c5245e5a166892943118a44"
export OS_AUTH_TYPE="token"
unset OS_USER_DOMAIN_NAME
unset OS_USERNAME
```

If you want to revoke a token before it expires we may do so manually.

```shell
openstack token revoke ab4d1e500c5245e5a166892943118a44
```

## Roles

By default a user has 2 roles, the viewer role which represents a read-only access and the operator role which represents a read-write access. It is necessary for the user to have both roles assigned in order to be able to delegate the read-only or read-write rights when creating application credentials.

If needed the SysEleven Cloudsupport can also provide you with a read-only user.
