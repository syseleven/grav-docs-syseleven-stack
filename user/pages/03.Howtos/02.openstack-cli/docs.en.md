---
title: 'Install OpenStack CLI'
published: true
date: '26-07-2021 16:25'
taxonomy:
    category:
        - howtos
---

## Overview

This How-to serves as manual on how to install the OpenStack CLI (Command Line Interface). With the OpenStack CLI you can manage and monitor your stacks.

## Goal

* Install latest OpenStack command line client and required plugins

## Prerequisites

* PC/MAC
* Admin rights
* Basic computer skills
* We assume you know how to utilise SSH and SSH keys.

*In this manual we expect that you haven't installed any of the required tools.
If you already installed any of the tools, please skip that specific step.*

! **Required OpenStack client version to work with the SysEleven Stack**
! OpenStack client version 3.13.x is the minimum to work with multiple regions. Please make sure to install the latest stable version.

## Snap on Linux

If you are using `snap` on your Linux distro, you only need the following step for installing openstackclient:


```shell
sudo snap install openstackclients
```

You can now proceed to [conclusion](#conclusion).

## Python and virtual environment

We recommend to use Python 3 and install the OpenStack client into a python virtual environment.
Even though you could install the OpenStack client system-wide, we will describe the procedure to install it in a [virtual environment](https://docs.python.org/3/tutorial/venv.html) instead. A virtual environment has the advantage to not collide with dependencies other projects may have on your system.

---

## Python installation

### MAC

You may need to install a different Python 3 than the one provided by Apple's XCode tools. At the time of writing this there were problems installing certain python modules if you use Apple's python3. You could install Python 3 using the installer available on python.org or install it from Homebrew.

First open `Terminal` or if installed [iTerm2](https://www.iterm2.com/).

To install python3 from Homebrew:

```shell
brew install python3
```

### Red Hat Enterprise Linux, CentOS or Fedora

Install python3 and some essential build tools which might be needed when you install the openstack client later.

```shell
sudo yum install python3 python3-devel gcc
```

### Ubuntu or Debian

Install python3 and some essential build tools which might be needed when you install the openstack client later.

```shell
sudo apt-get update && sudo apt install -q -y python3-minimal python3-venv python3-pip python3-dev build-essential
```

### Windows

Install Python 3 using the installer available for download on [python.org](https://www.python.org/downloads/).
After the installation is finished, open the command prompt (cmd) and check that the `python` (or `python3`) command opens a python prompt. Exit the prompt with Ctrl+Z and Enter.

---

## Virtualenv

Create a virtual environment called "env", which will create a subdirectory "env". Activate the virtual environment and upgrade `pip` in it.

### MAC or Linux

```shell
python3 -m venv env
source env/bin/activate
pip3 install --upgrade pip
```

### Windows

```batch
python3 -m venv env
env\Scripts\activate.bat
pip3 install --upgrade pip
```

---

## OpenStack Client

Install the OpenStack CLI client and recommended plugins, to be able to communicate with the corresponding OpenStack APIs:

```shell
pip3 install python-openstackclient python-barbicanclient python-cinderclient python-designateclient python-glanceclient python-heatclient python-neutronclient python-novaclient python-octaviaclient
```

The command above will install the general OpenStack client and the plugins for the following OpenStack APIs:

* barbican - Key Manager API
* cinder - Block Storage Volume API
* designate - Domain Name Service API
* glance - Image API
* heat - Orchestration API
* neutron - Network API
* nova - Compute API
* octavia - Load Balancer API

On Windows the installation may fail because of missing development tools. Follow the instructions you see on your screen to install those.

## Conclusion

We have installed the OpenStack Client and we now can use it.
**To be able to use the OpenStack CLI tools the [API access](../../02.Tutorials/02.api-access/docs.en.md) needs to be configured now.**

If needed you can list all commands:

```shell
openstack --help
```
