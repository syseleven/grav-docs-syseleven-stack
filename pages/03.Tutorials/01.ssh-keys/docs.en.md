---
title: 'Import SSH keys'
published: true
date: '02-08-2018 17:23'
taxonomy:
    category:
        - docs
---

## Goal

* Upload SSH keys via GUI (Horizon)
* Upload SSH keys via CLI (OpenStack client)

## Overview

SSH keys can be imported via the GUI (Horizon / Dashboad) or the CLI (OpenStack Client). While uploading SSH keys via the dashboard might be easier, uploading the SSH keys via the OpenStack CLI might be faster if SSH keys are to be imported into multiple regions.

!!!  SSH keys are saved in user and <u>not</u> project (tenant) context.

---

## Import via GUI

### Prerequisites

* You need to have the login data for the SysEleven Stack API (user name and passphrase).
* Knowledge how to utilise a terminal/SSH and SSH-keys.

### How to import?

Using the username and password (API credentials) that were provided by SysEleven we login at: [https://dashboard.cloud.syseleven.net](https://dashboard.cloud.syseleven.net).

![SysEleven Login](../../images/horizon-login.png)

* In order to import your SSH-key using the dashboard, we go to "Compute" --> "Access And Security" --> "Key Pairs".
* There we select "Import Key Pair", give the key pair a name (that we remember for later use) and import the public part of the key pair via copy & paste into the interface.

![import SSH key](../../images/sshkeys.png)

Once submitted we can use the key pair with this name in the API and Templates.

---

## Import via CLI

### Prerequisites

* You need to have the login data for the SysEleven Stack API (user name and passphrase).
* The [OpenStack CLI-Tools](../03.openstack-cli/docs.en.md) are installed in an up-to-date version.
* Environment variables are set, like shown in the [API-Access-Tutorial](../04.api-access/docs.en.md).
* Knowledge how to utilise a terminal/SSH and SSH-keys.

### How to import?

Using the username and password (API credentials) that were provided by SysEleven we source the 'openrc' file and enable the CLI client to talk to the SysEleven Stack.

Then we create a new keypair in openstack as follows:

```shell
# openstack keypair create --public-key <pathToSSHPublicKey> <my_ssh_key_name>

openstack keypair create --public-key ~/.ssh/id_rsa.pub username_rsa

+-------------+-------------------------------------------------+
| Field       | Value                                           |
+-------------+-------------------------------------------------+
| fingerprint | 77:65:11:11:11:11:45:eb:99:bd:aa:55:44:33:22:11 |
| name        | username_rsa                                    |
| user_id     | adsaae15f2b244dnfnskbsfa1c7e19gm                |
+-------------+-------------------------------------------------+
```

Once imported we can use the key pair with this name in the API and Templates.