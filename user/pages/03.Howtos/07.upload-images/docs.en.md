---
title: 'Upload images'
published: true
date: '20-08-2018 10:05'
taxonomy:
    category:
        - docs
---

## Upload Images

There are three different ways to upload custom images.

### Dashboard

* First log in to the [Dashboard](https://cloud.syseleven.de/horizon/project/)
* Now navigate to 'Compute' -> 'Images'
* Here click on the button 'Create Image'
* Enter the required info and click on "Create Image" and now the custom image is uploaded into the SysEleven Stack

### OpenStack-CLI

You need to have the [OpenStack-CLI](../../03.Howtos/02.openstack-cli/docs.en.md) installed and configured.
After [sourcing the openrc.sh](../../02.Tutorials/02.api-access/docs.en.md) you can easily upload your own image and use it right after, like this:

```shell
glance --os-image-api-version 1 image-create --progress --is-public False --disk-format=qcow2 \
--container-format=bare --property architecture=x86_64 --name="Debian Stretch" \
--location https://cdimage.debian.org/cdimage/openstack/current-9/debian-9-openstack-amd64.qcow2
```

### Heat-Template

It is also possible to upload images with heat.
An example can look like this:

```yaml
heat_template_version: 2016-04-08

description: Simple template to upload an image

resources:
  glance_image:
    type: OS::Glance::Image
    properties:
      container_format: bare
      disk_format: qcow2
      name: Debian Stretch
      location: https://cdimage.debian.org/cdimage/openstack/current-9/debian-9-openstack-amd64.qcow2
```

Further information can be found [here](https://cloud.syseleven.de/horizon/project/stacks/resource_types/OS::Glance::Image).

## Image sources

!!! [This overview](../../04.Reference/06.images/docs.en.md#image-sources) contains a list of standard images sources.
