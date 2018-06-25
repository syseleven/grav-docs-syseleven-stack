# Images

[TOC]

## Overview

SysEleven provides and maintains a set of images in the SysEleven Stack.  
The SysEleven Stack also offers the possibility to upload custom images. 

You can view and manage images both via the OpenStack API, as well as using the [Dashboard (GUI)](https://dashboard.cloud.syseleven.net).

## Provided Images

Images that are marked with **sys11 optimized** are built, optimized, tested and supported by Sys11.  
More images will be added in the future.

Distro           | Name                             | Description                             | Supported |
-----------------|----------------------------------|-----------------------------------------|-----------|
Ubuntu 16.04 LTS | Ubuntu 16.04 LTS                 | Unmodified, directly from Canonical     | yes       |
Ubuntu 16.04 LTS | Ubuntu 16.04 LTS sys11 optimized | Modified, optimized for SysEleven Stack | yes       |
Ubuntu 14.04 LTS | Ubuntu 14.04 LTS                 | Unmodified, directly from Canonical     | yes       |
Ubuntu 14.04 LTS | Ubuntu 14.04 LTS sys11 optimized | Modified, optimized for SysEleven Stack | yes       |
                 |                                  |                                         |           |
Ubuntu 16.04 LTS | Rescue Ubuntu 16.04 sys11        | Modified, optimized for SysEleven Stack | yes       |


## Distros

### Recommendation
SysEleven currently recommends to run **Ubuntu 16.04 LTS sys11 optimized** in the SysEleven Stack.

### Other distros
Basically it is possible to run any kind of operating system within the SysEleven Stack as long as it supports running in [KVM](https://www.linux-kvm.org/page/Main_Page).

Though Windows can be hosted in the SysEleven Stack we do not provide support for instances running Windows.

The following distros are reported to be working in SysEleven Stack:

* Debian
* CentOS
* CoreOS

---

## How to upload custom images?

There are three different ways to upload custom images.

### Dashboard

* First log in to the [Dashboard](https://dashboard.cloud.syseleven.net/horizon/project/)  
* Now navigate to 'Compute' -> 'Images'
* Here click on the button 'Create Image'
* Enter the required info and click on "Create Image" and now the custom image is uploaded into the SysEleven Stack

### OpenStack-CLI

You need to have the [OpenStack-CLI](../tutorials/openstack-cli/) installed and configured.
After [sourcing the openrc.sh](../tutorials/api-access/) you can easily upload your own image and use it right after, like this:

```shell
glance --os-image-api-version 1 image-create --progress --is-public False --disk-format=qcow2 \
--container-format=bare --property architecture=x86_64 --name="Debian" \
--location http://cdimage.debian.org/cdimage/openstack/testing/debian-testing-openstack-amd64.3
```

### Heat-Template

It is also possible to upload images with heat.
An example can look like this:
```plain
heat_template_version: 2016-04-08

description: Simple template to upload an image

resources:
  glance_image:
    type: OS::Glance::Image
    properties:
      container_format: bare
      disk_format: qcow2
      name: Debian
      location: http://cdimage.debian.org/cdimage/openstack/testing/debian-testing-openstack-amd64.qcow2
```
Further information can be found [here](https://dashboard.cloud.syseleven.net/horizon/project/stacks/resource_types/OS::Glance::Image).