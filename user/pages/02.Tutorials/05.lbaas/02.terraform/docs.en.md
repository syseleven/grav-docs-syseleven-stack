---
title: 'LBaaS with Terraform'
date: '2022-06-03 17:30'
taxonomy:
    category:
        - docs
---

## Prerequisites

* You have installed [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli).
* You know the basics of using the [OpenStack CLI-Tools](../../../03.Howtos/02.openstack-cli/docs.en.md).
* Environment variables are set, like shown in the [API-Access-Tutorial](../../02.api-access/docs.en.md).

## Git repository with Terraform examples

The Terraform examples used in the tutorials are [available on Github](https://github.com/syseleven/terraform-examples/tree/master/lbaas)

```shell
git clone https://github.com/syseleven/terraform-examples.git
```

This repository is used in both setups described below:

* terraform-examples/lbaas-octavia-http: contains the Terraform receipe for an HTTP load balancer set up using Octavia resources
* terraform-examples/lbaas: contains the terraform template for a TCP load balancer set up using Neutron LBaaSv2 resources

## HTTP Load Balancer with Terraform and Octavia

!! Octavia is currently in the public beta phase. This means we invite you to test Octavia load balancers, but we do not recommend you to use them for production workloads yet.

In this tutorial we demonstrate an Octavia LBaaS setup (in Terraform they call it infrastructure) with the following features:

* an HTTP load balancer
* Round Robin LB algorithm
* Health Monitor for LB pool members (upstream instances)
* a server group with dynamic number of servers
* every upstream node installs nginx via Cloud-Init
* Nginx and a simple static page to show the identity of the back-end

### Step one: Create the infrastructure

Open the folder containing the example code and create the infrastructure, providing your SSH key.

```shell
$ source openrc  # Set OpenStack authentication environment variables
$ cd terraform-examples/lbaas-octavia-http
$ terraform init

Initializing the backend...

...etc...

$ terraform plan -var ssh_publickey="ssh-rsa AAA...== user@example.com" -out planfile
```

Alternatively, you can make a file which contains your variables. It would look like this:

```plain
# Please change the ssh public keys below to yours
ssh_publickey = "ssh-rsa AAAA...== user@example.com"
```

Then, plan and apply the Terraform infrastructure.

```shell
$ terraform plan -var-file=env.tfvars -out planfile

$ terraform apply planfile
openstack_compute_keypair_v2.keypair: Creating...
openstack_compute_secgroup_v2.sg_ssh: Creating...
openstack_networking_router_v2.router_lbdemo: Creating...
openstack_networking_floatingip_v2.fip_lbdemo_jumphost: Creating...
openstack_networking_network_v2.net_lbdemo: Creating...
openstack_networking_floatingip_v2.fip_lbdemo_lb: Creating...
openstack_compute_secgroup_v2.sg_web: Creating...
openstack_compute_keypair_v2.keypair: Creation complete after 1s [id=keypair]
openstack_compute_secgroup_v2.sg_web: Creation complete after 2s [id=a65c71be-b694-4695-92d9-f310caad86b5]
openstack_compute_secgroup_v2.sg_ssh: Creation complete after 2s [id=422d4735-7d38-4817-ada7-a7ea61c42b35]
...
openstack_lb_member_v2.lb_app_pool_members[1]: Creation complete after 10s [id=02013468-5fa1-4cbc-87f1-5bfd422a4b3a]
openstack_lb_member_v2.lb_app_pool_members[2]: Creation complete after 11s [id=85c42f97-ab31-45aa-9699-5175e86e36f7]
openstack_lb_member_v2.lb_app_pool_members[0]: Creation complete after 17s [id=bb59928c-f81c-4f13-a352-4f6b500ea8fc]

Apply complete! Resources: 22 added, 0 changed, 0 destroyed.

Outputs:

loadbalancer_http = "http://185.56.128.100"
```

Note that the "Allowed CIDRs" of the listeners in the example are already set to a value (here 0.0.0.0/0). This is in contrast to Heat, where you have to set them in a separate step. The security groups are also configured in the terraform receipe.

### Step two: Check if the load balancer works properly

The call to `terraform apply` contains the LB floating IP in its output:

```shell
Apply complete! Resources: 22 added, 0 changed, 0 destroyed.

Outputs:

loadbalancer_http = "http://185.56.128.100"
```

Open AnyApp in your browser via `http://<loadbalancerIP>` which shows the IP of the currently-used backend server.
Open AnyApp in other tabs/windows to see the load balancer working.

![Loadbalancer](../../../images/loadbalancer.png)

## TCP Load Balancer with Terraform and Neutron LBaaSv2

With Neutron LBaasV2 only TCP-based load balancing is supported.
With Terraform, you can attach a security group to the load balancer VIP port as part of creating the infrastructure (with Heat that would be a separate step).

In this tutorial we demonstrate a Neutron LBaaSv2 infrastructure with the following features:

* a TCP load balancer
* Round Robin LB algorithm
* Health Monitor for LB pool members (upstream instances)
* a server group with dynamic number of servers
* every upstream node installs Apache2 and PHP7.4 FPM via Cloud-Init
* "AnyApp" as simple PHP application

### Step one: Create the infrastructure

```shell
$ source openrc  # Set OpenStack authentication environment variables
$ cd terraform-examples/lbaas
$ terraform init
$ terraform plan -var ssh_publickey="ssh-rsa AAA...user@example.com" -out planfile
$ terraform apply planfile
...
Outputs:

loadbalancer_http = "http://185.56.128.100"
```

### Step two: Check if the load balancer works properly

The example code contains the LB floating IP in its output:

```shell
# terraform output <Name Of The Output>

$ terraform output loadbalancer_http
"http://195.192.128.20"
```

Open AnyApp in your browser via `http://<loadbalancerIP>` which shows the IP of the currently-used backend server. Since this example installs more software on the backends than the previous example, it may take a minute before the AnyApp is available.
Open AnyApp in other tabs/windows to see the load balancer working.

![LBAnyApp](../../../images/AnyApp_20180301.png)

## Conclusion

You should now be able to adapt this example to your needs. One of the things you might want to change are the upstream servers. The overall architecture should work for many scenarios.
