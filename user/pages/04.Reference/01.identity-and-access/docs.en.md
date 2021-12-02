---
title: Identity and Access
published: true
date: '20-03-2020 10:40'
taxonomy:
    category:
        - docs
---

## Overview

SysEleven Stack uses the OpenStack component Keystone for identity and access.

There a different ways to authenticate towards Keystone. Upon successful authentication, the identity service provides the user with an authorization token used for subsequent service requests.

## Supported authentication methods

Method                                     | Supported     |
-------------------------------------------|---------------|
Password                                   | yes |
Token                                      | yes |
Application Credentials                    | yes |
Multi-Factor-Authentication (TOTP)         | no  |

### Password

A common way for an user or service to authenticate towards Keystone is by using username and password. For an example, have a look at the [API access tutorial](../../02.Tutorials/02.api-access/docs.en.md).

Users can change their password either using the OpenStack CLI command `openstack user password set`, or via the [OpenStack dashboard](https://cloud.syseleven.de).

If you forgot your password, please contact the [Support at support@syseleven.de](../../06.Support/default.en.md).

### Token

When you authenticate using a token, it is not necessary anymore to provide username and password. Tokens are valid for only one hour.

The OpenStack CLI allows you to create tokens with the command `openstack token issue`. It can also be manually revoked using `openstack token revoke`. For more information how to get started with the OpenStack CLI, have a look at the [API access tutorial](../../02.Tutorials/02.api-access/docs.en.md).

Many clients will switch to the token authentication methods with these environment variables in place:

```shell
export OS_TOKEN="ab4d1e500c5245e5a166892943118a44"
export OS_AUTH_TYPE="token"
unset OS_USER_DOMAIN_NAME
unset OS_USERNAME
```

### Application Credentials

Users can create Application Credentials and use them instead of the Password method. This is useful, if you want to configure third party software like Prometheus to query the OpenStack API.

Using Application Credentials it can be avoided to put clear text passwords into the configuration of applications.

Application Credentials always belong to a user, and can inherit some or all roles of their owner.

Using this approach a user can delegate the `operator` (for read-write access) or, if desired, only the `viewer` role (for read-only access) to an application.

Please refer to the [Application Credentials tutorial](../../03.Howtos/13.application-credentials/docs.en.md) to learn more about how to use Application Credentials.

## Access management

On the SysEleven Stack, `users` belong to `groups`, which can get access to `projects`. The access privileges of the user are defined by their `roles` in the project.

Typically every customer will have one or more users (for every team member), and one or more projects. Users can have access to all customer projects, or only to a subset of projects if required.

We manage projects, users, groups and roles for you. Please contact the [Support (support@syseleven.de)](../../06.Support/default.en.md) if you happen to require changes to your projects, users or groups.

### Projects

Every cloud resource, like virtual machines, belong to a certain project. It might be good practice to separate unrelated pieces of infrastructure into different projects.

### Groups

By default, we create one group for read-only access and one group for read-write access for every project. If you have special requirements, please contact the [Support (support@syseleven.de)](../../06.Support/default.en.md).

### Roles

Role         | Access to cloud resources     |
-------------|-------------------------------|
operator     | create, read, update, delete  |
viewer       | read                          |

For users with read-write access, we will assign both the operator and the viewer roles. This allows them to delegate these roles separately when creating [Application Credentials](../../03.Howtos/13.application-credentials/docs.en.md).

## Access to SEOS (S3-compatible object storage)

For access to the S3-compatible object storage, users can create, list and delete ec2 credentials (access key and secret key). They are only valid for the SysEleven S3-compatible object storage (SEOS).

It is only possible to create ec2 credentials with the `operator` role, because they allow write access to all S3 buckets within a project by default.

For more information, see the [object storage reference guide](../../04.Reference/05.object-storage/docs.en.md).
