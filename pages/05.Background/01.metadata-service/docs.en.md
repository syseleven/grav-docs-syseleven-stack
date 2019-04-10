---
title: 'Metadata service & cloud-init'
published: true
date: '04-01-2019 17:50'
taxonomy:
    category:
        - docs
---

## Overview

This article describes how servers retrieve instance-specific information like hostname, IP address, SSH keys and initialization scripts when started for the first time.

When a new instance starts for the first time, if you are using images that come with cloud-init preinstalled like [the public images we offer](../../04.Reference/06.images/docs.en.md), it will roughly do the following things:

1. On first boot, the instance will look for attached networking interfaces and start a DHCP client on these interfaces.
2. When a network connection has been established, cloud-init will try to retrieve information from the Metadata service
3. Cloud-init will apply configuration settings like the hostname, SSH keys and will run user-provided scripts

## Metadata service

The metadata service can be accessed via HTTP from any virtual machine running on the SysEleven Stack like so:

```bash
$ curl http://169.254.169.254/
1.0
2007-01-19
2007-03-01
2007-08-29
2007-10-10
2007-12-15
2008-02-01
2008-09-01
2009-04-04
```

Some nova server properties map directly to the Metadata service:

- When you set an SSH key via the `keyname` argument, it can be retrieved via `http://169.254.169.254/2009-04-04/meta-data/public-keys/0/openssh-key`
- When you provide a script via the `user_data` argument, it can be retrieved via `http://169.254.169.254/2009-04-04/user-data`

For a more detailed overview of the metadata service, please refer to [the official OpenStack Nova documentation](https://docs.openstack.org/nova/rocky/user/metadata-service.html).

## Cloud-Init configuration

Cloud-init is designed to work with the Metadata service and make it more useful by automatically applying the configuration as specified by the Metadata service.

Operating system vendors like Ubuntu, CentOS, CoreOS, etc. offer official "cloud-images" with cloud-init preinstalled. All [public images we offer](../../04.Reference/06.images/docs.en.md) have cloud-init preinstalled.

For a more detailed overview of all of the cloud-init functionality, please refer to the [official cliud-init documentation](https://cloudinit.readthedocs.io/en/latest/).

### Server provisioning

#### User data

You can use user-data together with cloud-init for provisioning your cloud instances.

You can find an [example of how to do that with Heat](https://github.com/syseleven/heat-examples/tree/master/cloudinit) in our Heat-examples.

For a Terraform example you can refer to the [official Terraform documentation](https://www.terraform.io/docs/providers/openstack/r/compute_instance_v2.html#instance-with-user-data-cloud-init-).

#### SSH provisioning

If you use the Terraform `remote-exec` provisioner or similar tools like ansible, cloud init will still perform important tasks like setting up package management repositories.

To avoid problems, we recommend waiting for cloud-init to complete by running the following command first:

```bash
while [ ! -e /var/lib/cloud/instance/boot-finished ]; do sleep 1; echo 'Waiting for cloud-init to finish.'; done
```

When you are using terraform it will look like this:

```hcl
provisioner "remote-exec" {
  inline = [
    "while [ ! -e /var/lib/cloud/instance/boot-finished ]; do sleep 1; echo 'Waiting for cloud-init to finish.'; done",
    # Do provisioning steps after cloud-init finished
    "apt install -y ..."
  ]
}
```
