---
title: 'Connect two subnets with each other'
published: true
date: '26-07-2021 16:25'
taxonomy:
    category:
        - docs
---

## Prerequisites

* Access to the [Dashboard](https://cloud.syseleven.de/)
* At least two existing routers/networks
* Different IP ranges in both networks

### Step One: Login

Sign in at the  [Dashboard](https://cloud.syseleven.de/)

![SysEleven Login](../../images/horizon-login.png)

### Step Two: Create Interface on Router

To create a new interface on our router:

* Click on the left side bar, then "Network" --> "Routers".
* Click on the first router you want to establish a connection with.
* Click on the tab "Interfaces" --> "Add Interfaces".
* Click on the router we want to connect to and add an IP under "IP" out of the IP range from target router.
* Click "Submit".

Repeat the process with the other router.

![Interface Overview](../../images/router-interface.png)

### Step Three: Add a Static Route

To add a static route:

* Click on the left side bar, then "Network" --> "Routers".
* Click on the first router you want to establish a connection with.
* Click on the tab "Static Routes"
* Click "Add Static Route" and enter the IP range from the target network and as "Next hop" the same IP address as in step two

Repeat the process with the other router

![Interface Overview](../../images/static-route.png)

### Step Four: Creating the Host Route

To create the host route:

* Click on the left side bar, then "Networks", then the network you want to share.
* Click on the subnet you want to connect to
* Click on "Edit Subnet" and go to "Subnet Details".
* Under "Host Routes" we can now set the route.
* Specify the IP range (e.g. `10.0.0.0/24`) and the IP address of the specific router interface.
* Click "Submit" to save the host route

Repeat the process with the other subnet.

![Interface Overview](../../images/hostroute.png)

## Conclusion

You connected two subnets, so they can communicate with another.  
You also set up our own host routes and got to know the networking settings in the dashboard.
