---
title: 'Single LAMP Server'
published: true
date: '02-08-2018 17:20'
taxonomy:
    category:
        - tutorial
    tag:
        - heat
        - lamp
        - instance
        - gui
        - horizon
---

## Goal

* Launch an instance via GUI (Horizon)
* Automated installation of a web server running PHP, as well as a database server and a database.

## Prerequisites

* You need to have the login data for the SysEleven Stack API (user name and passphrase).
* Knowledge how to utilise a terminal/SSH and SSH-keys.

---

## Launch Stack

* Log in to the [SysEleven Stack Dashboard](https://dashboard.cloud.syseleven.net) using the username and password (API credentials) that were provided by SysEleven.

![SysEleven Login](/images/horizon-login.png)

* In order to launch the example stack using the dashboard go to "Project" --> "Orchestration" --> "Stacks".  
* Click the button "Launch Stack"
* Select "URL" as "Template Source"
* Copy the URL of the example code file `https://raw.githubusercontent.com/syseleven/heat-examples/master/lamp-server/example.yaml`
* Paste the copied URL into the field "Template URL"
* Select "File" as "Environment Source"  

![horizon-orchestration-stacks-launch-url-file](/images/horizon-orchestration-stacks-launch-url-file.png)

* Click "Next"
* Write "lampserver" into the field "Stack Name"
* Write the name of your SSH key that you uploaded to the Horizon Dashboard - see [SSH Tutorial](../01.ssh-keys/default.en.md)
* Click on "Launch"  

![horizon-orchestration-stacks-launch-stackname-lamp-server](/images/horizon-orchestration-stacks-launch-stackname-lamp-server.png)

* Verify that the stack status is "Create In Progress" or "Create Complete"  
* Go to "Compute" --> "Instances" in order to retrieve the floating IP that is required to access the instance via SSH  
* Copy the floating IP from the example server  
* Open a terminal of your choice and log in to the instance via ssh with the username `syseleven`  

`ssh syseleven@<floating IP> -i ~/.ssh/< private ssh key >`

![ssh-login-syseleven-sshkeyrsa-lamp-server](/images/ssh-login-syseleven-sshkeyrsa-lamp-server.png)

* You should now be logged in your instance via SSH  
* You can follow the installation progress:
  In the background, the web server, database server and a up-to-date PHP version is being installed.  
  We can check the progress with the following command: `tail -f /var/log/cloud-init-output.log`

* Furthermore you may test the webserver:
  This template deploys a simple PHP application.
  You can now place any PHP application to `/var/www/html` and test it.
