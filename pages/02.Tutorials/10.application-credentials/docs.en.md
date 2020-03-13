---
title: 'Application Credentials'
date: '13-03-2020 12:00'
taxonomy:
    category:
        - docs
---

## Application Credentials

### Overview

Since the Queens update, OpenStack supports the creation of application credentials to allow users and their applications to authenticate towards OpenStack. The users can delegate a subset of their assigned roles, granting an application the same or restricted authorization for their projects.  

### Creating Application Credentials

We can create application credentials using the OpenStack python clients.

```shell
$ openstack application credential --help
Command "application" matches:
  application credential create
  application credential delete
  application credential list
  application credential show

$ openstack application credential create --help
Create new application credential

positional arguments:
  <name>                Name of the application credential

optional arguments:
  -h, --help            show this help message and exit
  --secret <secret>     Secret to use for authentication (if not provided, one
                        will be generated)
  --role <role>         Roles to authorize (name or ID) (repeat option to set
                        multiple values)
  --expiration <expiration>
                        Sets an expiration date for the application
                        credential, format of YYYY-mm-ddTHH:MM:SS (if not
                        provided, the application credential will not expire)
  --description <description>
                        Application credential description
  --unrestricted        Enable application credential to create and delete
                        other application credentials and trusts (this is
                        potentially dangerous behavior and is disabled by
                        default)
  --restricted          Prohibit application credential from creating and
                        deleting other application credentials and trusts
                        (this is the default behavior)
```

For example we could create sample application credentials with all roles which we have currently assigned which will never expire.

```shell
$ openstack application credential create test
+--------------+----------------------------------------------------------------------------------------+
| Field        | Value                                                                                  |
+--------------+----------------------------------------------------------------------------------------+
| description  | None                                                                                   |
| expires_at   | None                                                                                   |
| id           | 0d65b0f6c1814fb886252e5b4d945640                                                       |
| name         | test                                                                                   |
| project_id   | b58617d1abcd4c44b35467f4c41b97ce                                                       |
| roles        | viewer operator                                                                        |
| secret       | PaHdxTYcngnIbbawQu3MLKqqwyf6oh_geeBo6QG9UPNkCl0Qh7FxcJTWTKtNfRViYje590_kBW8QL7Qi9gtxeg |
| unrestricted | False                                                                                  |
+--------------+----------------------------------------------------------------------------------------+
```

All users have the viewer and operator role by default. The viewer role represents a read-only access and the operator role represents a read-write access. The password for the application credential is only shown once on creation, there is no way to receive the password again once the credentials are created.

```shell
$ openstack application credential show test
+--------------+----------------------------------+
| Field        | Value                            |
+--------------+----------------------------------+
| description  | None                             |
| expires_at   | None                             |
| id           | 0d65b0f6c1814fb886252e5b4d945640 |
| name         | test                             |
| project_id   | b58617d1abcd4c44b35467f4c41b97ce |
| roles        | operator viewer                  |
| unrestricted | False                            |
+--------------+----------------------------------+
```

Another example would be to create application credentials which only have read-only role and expires at 31 December 2020 at 12:00.

```shell
$ openstack application credential create read-only --role viewer --expiration 2020-12-31T12:00:00
+--------------+----------------------------------------------------------------------------------------+
| Field        | Value                                                                                  |
+--------------+----------------------------------------------------------------------------------------+
| description  | None                                                                                   |
| expires_at   | 2020-12-31T12:00:00.000000                                                             |
| id           | 00e16b7636724a5b917b583542eccc1c                                                       |
| name         | read-only                                                                              |
| project_id   | b58617d1abcd4c44b35467f4c41b97ce                                                       |
| roles        | viewer                                                                                 |
| secret       | 4nRFnrQHG_WLgWMS7uSEBS9zGheNTB6nyXiGO7fpinxo5kmIJUtinE0iZoAcNMU2Ss3R4cys3DRVH5f_T_DUBQ |
| unrestricted | False                                                                                  |
+--------------+----------------------------------------------------------------------------------------+
```

### Integrate Application Credentials

If we want to use the application credentials that we created in the steps before, we may create a RC file containing the credentials which can be used with the OpenStack CLI. Be sure to replace the `CREDENTIAL_ID` and `CREDENTIAL_SECRET` accordingly and unset other related `OS_.*` variables.

```shell
OS_AUTH_URL=https://keystone.cloud.syseleven.net:5000/v3
OS_AUTH_TYPE=v3applicationcredential
OS_APPLICATION_CREDENTIAL_ID=0d65b0f6c1814fb886252e5b4d945640
OS_APPLICATION_CREDENTIAL_SECRET=PaHdxTYcngnIbbawQu3MLKqqwyf6oh_geeBo6QG9UPNkCl0Qh7FxcJTWTKtNfRViYje590_kBW8QL7Qi9gtxeg
```

### Deleting Application Credentials

If the application credentials are no longer needed, you may delete them be providing their name. Expired credentials will stay in your list until you delete them.

```shell
$ openstack application credential delete test
```