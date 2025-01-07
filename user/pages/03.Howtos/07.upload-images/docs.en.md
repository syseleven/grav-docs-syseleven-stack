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
Download an image you want to use, e.g. an [Ubuntu cloud image](https://cloud-images.ubuntu.com).
After [sourcing the openrc.sh](../../02.Tutorials/02.api-access/docs.en.md) you can easily upload your own image and use it right after, like this:

```shell
openstack image create --progress --private --disk-format=qcow2 --container-format=bare \
--property architecture=x86_64 --name="Ubuntu Noble" --file noble-server-cloudimg-amd64.img
```

## Image sources

!!! [This overview](../../04.Reference/06.images/docs.en.md#image-sources) contains a list of standard images sources.
