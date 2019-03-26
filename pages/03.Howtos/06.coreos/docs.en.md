---
title: 'Minimal CoreOS Setup'
published: true
date: '08-08-2018 10:03'
taxonomy:
    category:
        - docs
---

## Goal

* You will learn how to start a minimal CoreOS instance on the SysEleven Stack.
* A simple docker container (nginx server) will run on the instance.
* You will learn how to upload the current CoreOS stable image.

## Prerequisites

* You should be able to use simple heat templates, like shown in the [first steps tutorial](../../02.Tutorials/02.firststeps/docs.en.md).
* You know the basics of using the [OpenStack CLI-Tools](../../03.Howtos/05.openstack-cli/docs.en.md).
* Environment variables are set, like shown in the [API-Access-Tutorial](../../02.Tutorials/03.api-access/docs.en.md).

## Clone the example repository

You will be working with the [heat examples repository](https://github.com/syseleven/heat-examples) on Github. Your first step is to clone it:

```shell
git clone https://github.com/syseleven/heat-examples
cd heat-examples/coreOS
```

## Upload the CoreOS image

We created a helper script in the *coreOS* example for this example to upload the [official stable CoreOS image](https://coreos.com/os/docs/latest/booting-on-openstack.html) to the SysEleven Stack.  

```shell
./upload_replacing_coreos_image.sh
```

This helper script first downloads the image, deletes existing images on your SysEleven Stack named `private_coreos` and finally uploads the new image.

The image will reside in the private scope of your project and will persist when the stack is deleted.

## Start the CoreOS instances

After uploading the CoreOS image, you can create the stack:

```shell
openstack stack create -t cluster.yaml <stack name> --parameter key_name=<ssh key name> --wait
```

In this command, `key_name` references an SSH-Key that you created in the [SSH Tutorial](../../02.Tutorials/01.ssh-keys/docs.en.md).  
You can start more than one instance setting the optional parameter `number_instances`. If you do not specify this parameter, only one instance will start up.

## Conclusion

You have now started one or more CoreOS instances on the SysEleven Stack. You will be able to access each one using a public floating IP address.

* `openstack server list` prints a list of all instances, as well as the corresponding IP addresses.

* Every CoreOS instance runs a docker container launching an NGINX based web server, listening on port 80. You can check that using the following command: `curl <ip-address>` (It should only show the nginx welcome page).

* Connecting to the SSH service is allowed by the security group (defined in the yaml files) as well. You can log in via: `ssh core@<ip-address>`.

You can change the number of instances on demand. To scale from the current number of instances (default is 1) to 5, you can run this simple command:

```shell
openstack stack update -t cluster.yaml <stack name> --parameter key_name=<ssh key name> --number_instances=5 --wait
```

This setup is still missing a couple pieces to provide load balancing or high availability. Check out the links in the next section for some advanced setups you can build based on this tutorial.

## Links/Examples

* [CoreOS cluster discovery](https://coreos.com/os/docs/latest/cluster-discovery.html)
* [Running a High Availability Docker Swarm](http://tech.paulcz.net/2016/01/running-ha-docker-swarm/)