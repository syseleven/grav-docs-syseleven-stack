---
title: Regions
published: true
date: '08-08-2018 11:24'
taxonomy:
    category:
        - docs
---

## Overview

* Regions are available to all customers.
* Currently 2 regions are available.
* The dashboard "Overview" shows the resources of the currently selected region.

## Goal

* Select Region via GUI (Horizon)
* Select Region via CLI (OpenStack client)

---

## Select via GUI

### Prerequisites

* You need to have the login data for the SysEleven Stack API (user name and passphrase).

### How to select?

* Log in to the [SysEleven Stack Dashboard](https://dashboard.cloud.syseleven.net) using the username and password (API credentials) that were provided by SysEleven.

![SysEleven Login](../../images/horizon-login.png)

* In order to select a region via the dashboard, we go to the dropdown menu at the top of the dashboard.
* There we select the region (cbk / dbl).

![Select region](../../images/selectregion.png)

Once selected we can start creating resources in the selected region.

---

## Select via CLI

### Prerequisites

* You need to have the login data for the SysEleven Stack API (user name and passphrase).
* The [OpenStack CLI-Tools](../../03.Howtos/openstack-cli/docs.de.md) are installed in an up-to-date version.
* Environment variables are set, like shown in the [API-Access-Tutorial](../../02.Tutorials/03.api-access/docs.en.md).

### How to select?

**The default region is defined in the 'openrc' file.**  
For your own comfort you can create one 'openrc' file per region.

Using the username and password (API credentials) that were provided by SysEleven we source the 'openrc' file and enable the CLI client to talk to the Syseleven Stack.

When using the openstack client we can select the region with  
the command line option `--os-region-name <region name>`.

The following example shows how to use it:

```shell
# openstack --os-region-name <region name> <openstack sub command>

openstack --os-region-name cbk server list
+--------------------------------------+--------------+--------+-------------------------------------------+-------------------------+----------+
| ID                                   | Name         | Status | Networks                                  | Image                   | Flavor   |
+--------------------------------------+--------------+--------+-------------------------------------------+-------------------------+----------+
| 9cdf2a81-0271-4b6f-aa3e-61asdas51dsa | lampserver   | ACTIVE | lampserver-net=10.0.0.14, 195.192.128.23  | Ubuntu Server 16.04 LTS | m1.micro |
+--------------------------------------+--------------+--------+-------------------------------------------+-------------------------+----------+

openstack --os-region-name dbl server list
+--------------------------------------+--------------+--------+-------------------------------------------+-------------------------+----------+
| ID                                   | Name         | Status | Networks                                  | Image                   | Flavor   |
+--------------------------------------+--------------+--------+-------------------------------------------+-------------------------+----------+
| 18e28c13-999e-4389-92ce-asd1das1das5 | lampserver   | ACTIVE | lampserver-net=10.0.0.14, 195.192.128.23  | Ubuntu Server 16.04 LTS | m1.micro |
+--------------------------------------+--------------+--------+-------------------------------------------+-------------------------+----------+
```

Once selected we can start using resources via API and templates.