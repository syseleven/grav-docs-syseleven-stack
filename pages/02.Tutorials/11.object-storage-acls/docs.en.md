---
title: 'Object Storage ACLs'
published: true
date: '08-20-2020 09:37'
taxonomy:
    category:
        - docs
---

## Object Storage ACLs

### Overview

In this tutorial we will use the [Object Storage](../../04.Reference/05.object-storage/docs.en.md) to create private buckets and objects and further limit the access to these, by applying ACLs granting read-only/write rights. We will be using [s3cmd](http://s3tools.org/s3cmd) manage our resources.

### Prerequisites

* You know the basics of using the [OpenStack CLI-Tools](../../03.Howtos/02.openstack-cli/docs.en.md).
* Environment variables are set, like shown in the [API-Access-Tutorial](../../02.Tutorials/02.api-access/docs.en.md).
* You have created EC2 credentials for your OpenStack user to be able to use the [Object Storage](../../04.Reference/05.object-storage/docs.en.md).
* You have installed and configured [s3cmd](http://s3tools.org/s3cmd) with your EC2 credentials.
* You have at least 1 additional user with access to your OpenStack project and you know the name of this user.

### Create initial buckets and objects

Using your personal s3cmd configuration, we will create 2 buckets. `acl-read` representing the bucket to which your additional user will get read-only access and `acl-write` representing the bucket to which your additional user gets read-write access.

```shell
# .s3cfg-admin represents your personal s3cmd config containing your access/secret key pair.
s3cmd -c .s3cfg-admin mb s3://acl-read
s3cmd -c .s3cfg-admin mb s3://acl-write
# Create a test.txt file
echo "secret-text" > test.txt
# Upload the file in both buckets
s3cmd -c .s3cfg-admin put test.txt s3://acl-read/test.txt
s3cmd -c .s3cfg-admin put test.txt s3://acl-write/test.txt
# We will later use the test.txt object to confirm our applied ACLs are working
```

As we did not define any ACLs while creating the buckets/objects, the default private ACL will be used. In the current state all users, who have access to our OpenStack project (users who have created EC2 credentials for this project), have full control on our newly created buckets/objects.

For an object to be accessable to an user, the object itself and the parent buckets have to have proper ACLs set.

### Revoke default ACLs 

In this step we will revoke the access to the buckets/objects for every user with access to our OpenStack project.

*As this point it is important to understand that OpenStack EC2 credentials are bound to a user and a project. Thus if you are managing multiple OpenStack projects, there is more then 1 way to allow an user to be able to access your buckets/objects. You may allow the users EC2 credentials created for project A to access your data but at the same time revoke the access for the users EC2 credentials created for project B* 

```shell
# Get our OpenStack project ID
MY_PROJECT_ID=$(openstack project list -f value -c ID)
# Revoke access to anyone except ourself from your OpenStack project
s3cmd -c .s3cfg-admin setacl --acl-revoke=full_control:${MY_PROJECT_ID} s3://acl-read
s3cmd -c .s3cfg-admin setacl --acl-revoke=full_control:${MY_PROJECT_ID} s3://acl-write
# At this point already the objects will only be accessable by the owner. To make it more clean we will also revoke the default grant of the objects themself.
s3cmd -c .s3cfg-admin setacl --acl-revoke=full_control:${MY_PROJECT_ID} s3://acl-read/test.txt
s3cmd -c .s3cfg-admin setacl --acl-revoke=full_control:${MY_PROJECT_ID} s3://acl-write/test.txt
```

Now only the owner (.s3cfg-admin) has access to the buckets and objects we created for this tutorial. 

### Grant read-only access via user ACLs

We will proceed to grant read rights for our additional user.

```shell
# Assumption : user max.mustermann@myproject.de has access to our project
# Lets grant him read access to your acl-read bucket and all objects contained inside (using the recursive option)
s3cmd -c .s3cfg-admin setacl --acl-grant=read:u:max.mustermann@myproject.de/${MY_PROJECT_ID} s3://acl-read --recursive
# We may also only grant the user to specific objects inside the bucket, in this case we leave out the recursive option and directly add the object names :
# e.g : s3cmd -c .s3cfg-admin setacl --acl-grant=read:u:max.mustermann@myproject.de/${MY_PROJECT_ID} s3://acl-read/test.txt
```

**Unfortunately every grant of rights via ACLs will re-add a default ACL grant providing full control for all users from the OpenStack project the object is contained in for all involved buckets/objects** 

Thus we have to manually remove the default ACL again

```shell
s3cmd -c .s3cfg-admin setacl --acl-revoke=full_control:${MY_PROJECT_ID} s3://acl-read --recursive
# or without recursive option e.g. : s3cmd -c .s3cfg-admin setacl --acl-revoke=full_control:${MY_PROJECT_ID} s3://acl-read/test.txt
# We also have to remove the grants on the bucket itself which are not removed by default
s3cmd -c .s3cfg-admin setacl --acl-revoke=full_control:${MY_PROJECT_ID} s3://acl-read
```

Now the additional user has read-only access to our bucket. If we would not have re-removed the default ACLs from the bucket ,the user would be able to modify/delete objects of the bucket as he inherits the full control from the bucket ACLs.

### Grant write access via user ACLs

We will proceed to grant write rights for our additional user. As we also want the user to be able to list the files of the `acl-write` bucket we would have to grant him the read ACL too. We may use the full_control ACL to skip the double grant.

*When granting an user both read and write rights, he automatically gets the full_control ACL granted. Thus when you want to revoke the write ACLs for the user you will have to revoke the full_control ACL for the user and re-grant the read ACL.*

```shell
# Grant full control for write bucket, 
s3cmd -c .s3cfg-admin setacl --acl-grant=full_control:u:max.mustermann@myproject.de/${MY_PROJECT_ID} s3://acl-write
# And remove the default ACL which got added additionally
s3cmd -c .s3cfg-admin setacl --acl-revoke=full_control:${MY_PROJECT_ID} s3://acl-write
```

### List object ACLs

If you want to check your current ACLs for an object you may issue the `s3cmd info` command. Be aware [s3cmd](http://s3tools.org/s3cmd) does not support listing the ACLs for buckets yet.

```shell
# The project id : 8d0a3fb580fd46079ac6aeaf3bcc412e will differ in your case
s3cmd -c .s3cfg-admin info s3://acl-write/test.txt | grep ACL
   ACL:       u:max.mustermann@myproject.de/8d0a3fb580fd46079ac6aeaf3bcc412e: FULL_CONTROL
   ACL:       8d0a3fb580fd46079ac6aeaf3bcc412e: FULL_CONTROL

s3cmd -c .s3cfg-admin info s3://acl-read/test.txt
   ACL:       8d0a3fb580fd46079ac6aeaf3bcc412e: FULL_CONTROL
   ACL:       u:max.mustermann@myproject.de/8d0a3fb580fd46079ac6aeaf3bcc412e: READ
```

Additional things to be aware of are the following :

* The user who created/uploaded a bucket/object has unrevokeable full_control on his resources.
* The default ACL will always be shown by the `s3cmd info` command, even if it is not valid anymore.
* ACLs for external users/groups/projects are not listed properly.

### Grant access for external users

It is also possible to grant access on your buckets/objects to external users which have no direct access to your OpenStack project. In this case you need know the external user name and the project for which he created his EC2 credentials.

```shell
# We assume the user name is : someotheruser@someotherproject.de and the project id that the user created his EC2 credentials in is : 6da1da7f0c7e4afaa39d7119ae764cff
# Lets grant read access for this external user
s3cmd -c .s3cfg-admin setacl --acl-grant=read:u:someotheruser@someotherproject.de/6da1da7f0c7e4afaa39d7119ae764cff s3://acl-read --recursive
# Again a default ACL was added to all involved buckets/objects that now gives full control for all users from the internal project. Lets remove it again.
s3cmd -c .s3cfg-admin setacl --acl-revoke=full_control:${MY_PROJECT_ID} s3://acl-read --recursive
```

And now we ran into a problem. Unfortunately the revoking of the full control with the internal project ID defined will also remove the read access of the external user...

Thus granting access for external users via ACLs is only suitable if you do not use ACLs for your internal OpenStack users of your project.

### Add new objects/buckets with ACLs already in place

If you add new objects to your buckets to which you already set ACLs, there are a few additional things to take care of. New objects will not inherit the parent buckets ACLs and thus have the default ACLs when being added. So if the bucket into which the object is uploaded is not revoking the access for all other users from the OpenStack project, the object can be modified/deleted by all project users.

```shell
# Put another file into the read bucket
s3cmd -c .s3cfg-admin put test.txt s3://acl-read/test2.txt
```

As the default ACL is in place, all users of our OpenStack project would currently have access to the new file (if the parent bucket ACLs allow it). Thus currently Lets set the ACLs for the new object the same way we did for the already existing object. 

```shell
s3cmd -c .s3cfg-admin setacl --acl-grant=read:u:max.mustermann@myproject.de/8d0a3fb580fd46079ac6aeaf3bcc412e s3://acl-read/test2.txt
# Remove default full_control ACL for the added file
s3cmd -c .s3cfg-admin setacl --acl-revoke=full_control:${MY_PROJECT_ID} s3://acl-read/test2.txt
# Remove hidden added full_control ACL from the Bucket which would allow read user to edit the file
s3cmd -c .s3cfg-admin setacl --acl-revoke=full_control:${MY_PROJECT_ID} s3://acl-read
```


### Grant/revoke access via groups

By default every OpenStack project will get a single group which contains all the users which have access to the project. Similiar to the setup of grants/revokes for users it is possible to implement these using groups.

If you need specific groups for setting up your desired ACLs please feel free to contact our [Cloud-Support (cloudsupport@syseleven.de)](../../06.Support/default.en.md).

## References

* [Object Storage reference guide](../../04.Reference/05.object-storage/docs.en.md)
