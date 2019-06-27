---
title: 'Install OpenStack CLI'
published: true
date: '02-08-2018 17:29'
taxonomy:
    category:
        - howtos
---

## Overview

This How-to serves as manual on how to install the OpenStack CLI (Command Line Interface). With the OpenStack CLI you can manage and monitor your Stacks.

## Goal

* Install latest OpenStack-Command line Client and required plugins

## Prerequisites

* PC/MAC
* Admin rights
* Basic computer skills
* We assume you know how to utilise SSH and SSH-keys.

*In this manual we expect that you haven't installed any of the required tools.
If you already installed any of the tools, please skip that specific step.*

! **Required OpenStack client version to work with the SysEleven Cloud**
! OpenStack client version 3.13.x is the minimum to work with multiple regions. Please make sure to install the latest stable version.

---

## Installation for MAC

First open `Terminal` or if installed [iTerm2](https://www.iterm2.com/).

### PIP

To install the required packages, we use [PIP](https://en.wikipedia.org/wiki/Pip_(package_manager)) as package manager.

We install `PIP`with the following command:

```shell
sudo easy_install pip
```

### Python dependencies

To work around an OSX issue run the following command:

```shell
sudo -H pip install --ignore-installed six pyparsing pyOpenSSL
```

Alternatively running a ["virtual environment" with `virtualenv`](#virtualenv) also works, to have a separate environment for the OpenStack Client.

### OpenStack Client

After the installation of `PIP` finished, we need to install the OpenStack CLI client and required plugins, to be able to communicate with the corresponding OpenStack API:

```shell
sudo -H pip install python-openstackclient python-heatclient python-neutronclient python-designateclient
```

---

## Installation for Windows

### Python

To be able to use the OpenStack Client on Windows we first need [Python 2.7](https://www.python.org/downloads/release/python-2712/).
After the installation is finished, we open our command prompt and ensure that we're in the following directory: `C:\Python27\Scripts`

### PIP

Now we use the `easy_install` command to install [PIP](https://en.wikipedia.org/wiki/Pip_(package_manager)) as package manager:

```batch
C:\Python27\Scripts>easy_install pip
```

### OpenStack Client

After the installation of `PIP` finished, we need to install the OpenStack CLI as last step:

```batch
C:\Python27\Scripts>pip install python-openstackclient python-heatclient python-neutronclient python-designateclient
```

### OpenStack Plugins

After that [install the required plugins](#installation-of-more-plugins) to be able to talk to the corresponding OpenStack APIs.

---

## Installation for Linux

### PIP

To install the required packages, we use [PIP](https://en.wikipedia.org/wiki/Pip_(package_manager)) as package manager.

#### Red Hat Enterprise Linux, CentOS or Fedora

```shell
yum install python-minimal python-pip
```

#### Ubuntu oder Debian

```shell
apt install -q -y python-minimal python-pip
```

### OpenStack Client

If there are dependency errors alternatively running a ["virtual environment" with `virtualenv`](#virtualenv) also works, to have a separate environment for the OpenStack Client.

After the installation of `PIP` finished, we need to install the OpenStack CLI client and required plugins, to be able to communicate with the corresponding OpenStack API:

```shell
pip install python-openstackclient python-heatclient python-neutronclient python-designateclient
```

---

## Conclusion

We have installed the OpenStack Client and we now can use it.  
**To be able to use the OpenStack CLI tools the [API access](../../02.Tutorials/02.api-access/docs.en.md) needs to be configured now.**

If needed you can list all commands:

```shell
openstack --help
```

---

## Additional information

### Installation of more plugins

One has the possibility to install plugins. Place the corresponding plugin name into the following command:

```shell
pip install python-<PLUGINNAME>client
```

Installing the heat plugin:

```shell
pip install python-heatclient
```

Required plugins for the SysEleven Stack:

* heat - Orchestration API
* neutron - Network API
* designate - DNS API

---

### Virtualenv

***If the OpenStack Client was installed successfully already, this is not required.***

[Virtualenv](https://virtualenv.pypa.io) provides a virtual environment to avoid problems with dependencies and other programs when installing the OpenStack Client. This manual applies for MAC and Linux systems.

Install `virtualenv` with the following command:

```shell
pip install virtualenv
```

Now create a project folder e.g. `myproject` into which we create a `virtualenv`:

```shell
cd myproject/
virtualenv venv
```

If required `virtualenv` can inherit global installed packages (e.g IPython or Numpy). Use the following command to configure this:

```shell
virtualenv venv --system-site-packages
```

These commands create a virtual subfolder within the project folder into which everything is being installed. However one has to activate the folder first (within the terminal that we use to work on the project):

```shell
source myproject/venv/bin/activate
```

Now we should see `(venv)` at the beginning of our terminal prompt, that confirms that we are working within a `virtualenv`.
If we install something now the installed programs end up within our project folders and do not create any conflics with other projects.

*To exit the virutal environment we use:*

```shell
deactivate
```
