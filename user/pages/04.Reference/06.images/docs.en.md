---
title: Images
published: true
date: '05-05-2020 10:08'
taxonomy:
    category:
        - docs
---

## Overview

SysEleven provides and maintains a set of images in the SysEleven Stack. As soon as vendors publish new images, we will verify their origin, test them and publish them automatically. This means that we only publish images that are correctly signed. We don't make any changes in vendor images, to keep checksums intact. That allows our customers to validate image origin if needed.

You can view and manage images both via the OpenStack API and CLI, as well as using the [Dashboard (GUI)](https://cloud.syseleven.de/).

If you need to maintain your own set of images, you can upload them yourself as well using the OpenStack API. It is possible to use tools like [HashiCorp Packer](https://www.packer.io/) to build your own images, for example with certain preinstalled software.

## Available public images

Name                                    | Description                                         |
----------------------------------------|-----------------------------------------------------|
Flatcar Stable (YYYY-MM-DD)             | Unmodified, directly from vendor                    |
Ubuntu Bionic 18.04 (YYYY-MM-DD)        | Unmodified, directly from vendor                    |
Rescue Ubuntu 18.04 sys11               | Modified, for use with the [nova rescue mode](../../03.Howtos/05.nova-rescue-mode/docs.en.md) |
Ubuntu Focal 20.04 (YYYY-MM-DD)         | Unmodified, directly from vendor                    |
Ubuntu Jammy 22.04 (YYYY-MM-DD)         | Unmodified, directly from vendor                    |
Ubuntu Noble 24.04 (YYYY-MM-DD)         | Unmodified, directly from vendor                    |
Red Hat CoreOS <version\> (YYYY-MM-DD)  | Unmodified, directly from vendor, see warning below |

!!! Red Hat CoreOS images are provided despite the lack of cryptographic signature provided by Red Hat, meaning we were not able to verify their authenticity.

### Public image lifecycle

As soon as we upload a new version of an operating system image (recognizable by the current date in their name), we will change the visibility of the old image version:

- If you are using an old public image, the image will stay visible within the project that is using it until you stop using it
- If you are not using an old public image anymore, the image will become invisible for you after some time.
- If a public image becomes completely unused by all customers, we will remove it

!!! We only guarantee the availability of images for the 3 most recent Red Hat CoreOS major versions. If you require older versions, please retrieve them directly from the official Red Hat sources, see <a href="#uploading-images">Uploading images</a> for an alternative.

### Public image properties

Public images get certain properties that you can use for finding the latest images for example with Packer or Terraform.

Property name                    | Description                               |
---------------------------------|-------------------------------------------|
architecture                     | Image only runs with this cpu architecture. Currently always `x86_64`. Same as `cpu_arch` |
ci_job_id                        | Internal reference number                 |
ci_pipeline_id                   | Internal reference number                 |
cpu_arch                         | Image only runs with this cpu architecture. Currently always `x86_64`. Same as `architecture` |
default_ssh_username             | If not configured otherwise using cloud-init, servers using this image can be accessed with this ssh username. Same as `image_original_user` |
distribution                     | Unique identifier for the distribution and version (e.g. `ubuntu-focal`) |
hypervisor_type                  | The hypervisor type. Currently always `qemu` |
hw_disk_bus                      | Specifies the type of disk controller to attach disk devices to. Currently always `virtio` |
hw_rng_model                     | A preference of a random-number generator device type added to the image's instances. Currently always `virtio` |
image_description                | URL to the vendor's image repository notes |
image_source                     | URL to the vendor image file that has been used for this image. Same as `source_url` |
image_build_date                 | Date when the image was added to the catalog |
image_original_user              | If not configured otherwise using cloud-init, servers using this image can be accessed with this ssh username. Same as `default_ssh_username` |
os_distro                        | Name of the distribution (e.g. `ubuntu`) |
os_type                          | Operating system type (currently always `linux`) |
os_version                       | Version of the operating system (e.g. `20.04`) |
provided_until                   | The date until when the image will be available and updated |
replace_frequency                | How often the image will be replaced with an updated version |
source_sha512sum                 | SHA512 hash of the original image file, as provided by the vendor under `source_url` |
source_sha256sum                 | SHA256 hash of the original image file, as provided by the vendor under `source_url` |
source_url                       | URL to the vendor image file that has been used for this image. Same as `image_source` |
uuid_validity                    | How long the image will be referencable by its UUID |

We follow the [SCS Image Metadata Standard](https://docs.scs.community/standards/scs-0102-v1-image-metadata/)
Here is an example for filtering the images by properties using [HashiCorp Terraform's image data source](https://www.terraform.io/docs/providers/openstack/d/images_image_v2.html):

```hcl
data "openstack_images_image_v2" "ubuntu-focal" {
  most_recent = true
  properties = {
    os_version = "20.04"
    os_distro = "ubuntu"
  }
}
```

## Uploading images

### Image sources

If you prefer maintaining your own set of images, this table shows sources for commonly used images suitable for OpenStack:

Distro                    | URL |
--------------------------|-----|
CentOS Stream 9           | `https://cloud.centos.org/centos/9-stream/x86_64/images/` |
Debian 11 (Bullseye)      | `https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-generic-amd64.qcow2` |
Debian 12 (Bookworm)      | `https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2` |
Flatcar Stable            | `https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_openstack_image.img.bz2` |
Ubuntu 18.04 LTS (Bionic) | `https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img` |
Ubuntu 20.04 LTS (Focal)  | `https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img` |
Ubuntu 22.04 LTS (Jammy)  | `https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img` |
Ubuntu 24.04 LTS (Noble)  | `https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img` |

!!! The Flatcar image must be decompressed before uploading:
!!! `bunzip2 flatcar_production_openstack_image.img.bz2`

### How to upload images?

[The "Upload Images" how-to guide](../../03.Howtos/07.upload-images/docs.en.md) explains how to upload images via CLI and GUI.
