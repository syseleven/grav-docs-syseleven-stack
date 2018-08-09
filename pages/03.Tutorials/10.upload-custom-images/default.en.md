---
title: 'Upload custom images'
published: true
date: '08-08-2018 11:34'
taxonomy:
    category:
        - tutorial
---

## Uploading Custom Images

There are three different ways to upload custom images.

### Dashboard

* First log in to the [Dashboard](https://dashboard.cloud.syseleven.net/horizon/project/)  
* Now navigate to 'Compute' -> 'Images'
* Here click on the button 'Create Image'
* Enter the required info and click on "Create Image" and now the custom image is uploaded into the SysEleven Stack

### OpenStack-CLI

You need to have the [OpenStack-CLI](../03.openstack-cli/default.en.md) installed and configured.
After [sourcing the openrc.sh](../04.api-access/default.en.md) you can easily upload your own image and use it right after, like this:

```shell
glance --os-image-api-version 1 image-create --progress --is-public False --disk-format=qcow2 \
--container-format=bare --property architecture=x86_64 --name="Debian" \
--location http://cdimage.debian.org/cdimage/openstack/testing/debian-testing-openstack-amd64.qcow2
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