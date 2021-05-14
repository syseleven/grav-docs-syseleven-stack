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

In this tutorial we will use the [Object Storage](../../04.Reference/05.object-storage/docs.en.md) to create buckets and objects with and limit the access to these by applying ACLs. We will be using the [s3cmd](http://s3tools.org/s3cmd) S3 client and the python library [boto3](https://boto3.readthedocs.io) to manage our resources.

### Prerequisites

* You know the basics of using the [OpenStack CLI-Tools](../../03.Howtos/02.openstack-cli/docs.en.md).
* Environment variables are set, like shown in the [API-Access-Tutorial](../../02.Tutorials/02.api-access/docs.en.md).
* You have created EC2 credentials for your OpenStack user to be able to use the [Object Storage](../../04.Reference/05.object-storage/docs.en.md).
* You have installed [s3cmd](http://s3tools.org/s3cmd)
* You have installed python and the [boto3](https://boto3.amazonaws.com/v1/documentation/api/latest/index.html) library

We suggest you use the python library boto3 to reproduce all scenarios shown in this tutorial. Using only s3cmd will leave buckets open for group members. We are in contact with the software manufacturer of our object storage about that.

### Prepare environment

To be able to create our buckets, objects and ACLs we first will need to get our access and secret key of the ec2 credentials of our OpenStack user.

For s3cmd we have to create following configuration file:

```shell
syseleven@kickstart:~$ cat .s3cfg
[default]
access_key = < REPLACE ME >
secret_key = < REPLACE ME >
use_https = True
check_ssl_certificate = True
check_ssl_hostname = False

host_base = s3.dbl.cloud.syseleven.net
host_bucket = %(bucket).s3.dbl.cloud.syseleven.net
#host_base = s3.cbk.cloud.syseleven.net
#host_bucket = %(bucket).s3.cbk.cloud.syseleven.net
```

We can configure a s3client with the boto3 library using following python snippet:

```python
import boto3
import botocore
# Get our session
session = boto3.session.Session()
s3 = session.resource(
   service_name = 's3',
   aws_access_key_id = "my-access-key",
   aws_secret_access_key = "my-secret-key",
   endpoint_url = 'https://s3.dbl.cloud.syseleven.net'
   #endpoint_url = 'https://s3.cbk.cloud.syseleven.net'
)
# Get our client
s3client = s3.meta.client
```

In the following sections we will take a look at different scenarios for using ACLs in our object storage.

### Create buckets/objects 

Using the S3 client s3cmd or the S3 python library boto3 we can create buckets and objects. By default these buckets and objects will be read/writeable by all your OpenStack project members (to be more specific, the buckets created without defining any ACL will be accessible for all users who have created ec2 credentials for the underlying OpenStack project).

To do so with s3cmd:

```shell
echo "project members can read me" > test.txt
s3cmd -c <your-s3-config> mb s3://project-scope-bucket
s3cmd -c <your-s3-config> put test.txt s3://project-scope-bucket/project-scope-object.txt
```

And using the boto3 library with our previously-created python s3client.

```python
s3client.create_bucket(Bucket="project-scope-bucket")
s3client.put_object(Body="project members can read me", Bucket="project-scope-bucket", Key="project-scope-object.txt")
```

Great! We successfully created our first bucket and object using the default `private` ACL. There are other predefined ACLs which we may use and we will take a look at them in the next step.

### Predefined ACLs

If you do not need complex ACLs and just want to create a bucket whose contents can be read/writeable from everyone with access to your OpenStack project or you plan to create a public readable bucket you are fine with using predefined ACLs.

In the step before we already used such a predefined ACL. In this case it was the default `private` ACL. Another predefined ACL which may be suitable for your use-case is the `public-read` ACL.

It can be set using the already known s3cmd command with an additional flag:

```shell
echo "everyone out there can read me" > test.txt
s3cmd -c <your-s3-config> mb s3://public-scope-bucket -P
s3cmd -c <your-s3-config> put test.txt s3://public-scope-bucket/public-file.txt -P
```

Or using the boto3 library:

```python
s3client.create_bucket(Bucket="public-scope-bucket",ACL="public-read")
s3client.put_object(Body="public-readable", Bucket="public-scope-bucket", Key="public-file.txt", ACL="public-read")
```

There are further predefined ACLs (called canned ACLs in AWS) which may or may not be supported by the implementation of our object storage. For more information please have a look at our related [Object Storage reference guide](../../04.Reference/05.object-storage/docs.en.md).

### Custom ACLs

To setup a more fine grained control on who can access which buckets or objects we have to define our own ACLs. S3cmd as well as the boto3 python library support setting ACLs on bucket and object level. We can narrow down ACLs for user names, group names and project IDs to specific values:

* write -> grants rights to modify/delete resources
* read -> grants rights to read/list resources
* read-acp -> grants rights to read/list ACLs
* write-acp -> grants rights to modify ACLs
* full-control -> grants all rights : read + write + read-acp + write-acp

We will take a look at the different schemes how and where we can use these values in the following sections.

##### User scope

Narrow down ACLs on specific OpenStack users

Scheme: `u:<user-name>/<project-ID>`

!! **Be aware**
!! For the user scope ACLs to work, your username unfortunately has to be POSIX compliant. If you have a username containing unsupported characters (e.g. `@` from a mail address) please get into contact with our [Cloud-Support (cloudsupport@syseleven.de)](../../06.Support/default.en.md).

Examples:

* 1) Narrow down full control ACL to the owner itself so it will be an isolated private bucket for the bucket owner.

This use-case cannot be implemented using s3cmd. Our tests show it fails to revoke group read access on the bucket.

```python
s3client.create_bucket(Bucket="owner-scope-bucket", GrantFullControl="ID=u:user.name.of.bucket.owner/project-id")
s3client.put_object(Body="only readable by owner", Bucket="owner-scope-bucket", Key="owner-scope-object.txt", GrantFullControl="ID=u:user.name.of.bucket.owner/project-id-")
s3client.put_object(Body="also only readable by owner", Bucket="owner-scope-bucket", Key="project-scope-object.txt")
```

As the bucket ACL is limiting access on the bucket to the owner himself, any object inside of this bucket (also new objects) will only be read/writeable by the owner.

* 2) Narrow down default full control ACL to the owner itself and allow other project members readonly access.

```python
s3client.create_bucket(Bucket="project-scope-readonly-bucket", GrantFullControl="ID=u:user.name.of.bucket.owner/<your-OpenStack-project-ID>", GrantRead="ID=<your-OpenStack-project-ID>")
s3client.put_object(Body="only visible and writeable by owner", Bucket="project-scope-readonly-bucket", Key="owner-scope-object.txt", GrantFullControl="ID=u:user.name.of.bucket.owner/<your-OpenStack-project-ID>")
s3client.put_object(Body="read-writeable-by-all-project-members",Bucket="project-scope-readonly-bucket",Key="project-scope-object.txt")
s3client.put_object(Body="only-readable-by-all-project-members",Bucket="project-scope-readonly-bucket",Key="project-scope-readonly-object.txt",GrantRead="ID=<your-OpenStack-project-ID>")
```

The `owner-scope-object.txt` object is only visible and read/writeable for the owner. The `project-scope-object.txt` object will be read/writeable for all project members as the ACLs for this object were not further narrowed down. The `project-scope-readonly-object.txt` object will be readable (readonly) for all project members.

To achieve the same ACLs using s3cmd, it would look like the following :

```shell
# Create the bucket
s3cmd -c <your-s3-config> mb s3://project-scope-readonly-bucket
# Narrow down default full_control ACL
s3cmd -c <your-s3-config> setacl --acl-revoke=full_control:<your-OpenStack-project-ID> s3://project-scope-readonly-bucket
# Create and narrow down ACLs for owner scope object
s3cmd -c <your-s3-config> put test.txt s3://project-scope-readonly-bucket/owner-scope-object.txt
s3cmd -c <your-s3-config> setacl --acl-revoke=full_control:<your-OpenStack-project-ID> s3://project-scope-readonly-bucket/owner-scope-object.txt
s3cmd -c <your-s3-config> setacl --acl-revoke=full_control:g:<your-OpenStack-group-name>/<your-OpenStack-project-ID> s3://project-scope-readonly-bucket/owner-scope-object.txt
# Create default object
s3cmd -c <your-s3-config> put test.txt s3://project-scope-readonly-bucket/project-scope-object.txt
# Create and narrow down ACLs for project readonly object
s3cmd -c <your-s3-config> put test.txt s3://project-scope-readonly-bucket/project-scope-readonly-object.txt
s3cmd -c <your-s3-config> setacl --acl-revoke=full_control:<your-OpenStack-project-ID> s3://project-scope-readonly-bucket/project-scope-readonly-object.txt
s3cmd -c <your-s3-config> setacl --acl-revoke=full_control:g:<your-OpenStack-group-name>/<your-OpenStack-project-ID> s3://project-scope-readonly-bucket/project-scope-readonly-object.txt
--acl-grant=read:<your-OpenStack-project-ID> s3://project-scope-readonly-bucket/project-scope-readonly-object.txt
```

##### group scope

Set ACLs for specific OpenStack groups

Scheme : `g:<group-name>/<project-ID>`

!! **Be aware**
!! By default every OpenStack project has one group which contains all users with access to the project. Users currently are not able to see their group memberships. Please get into contact with our [Cloud-Support (cloudsupport@syseleven.de)](../../06.Support/default.en.md) if you need a list of your projects group names.

example :

* 1) Allow one group to have full control and a second group to only read access

This use-case cannot be fully implemented using s3cmd. Our tests show it fails to distinguish between groups if the groups refer to the same project.

```python
s3client.create_bucket(Bucket="group-scope-readwrite-bucket",GrantFullControl="ID=g:group.name.one/<your-OpenStack-project-ID>",GrantRead="ID=g:group.name.two/<your-OpenStack-project-ID>")
s3client.put_object(Body="writeable by group one, readable by group two ",Bucket="group-scope-readwrite-bucket",Key="group-scope-readwrite-object.txt",GrantFullControl="ID=g:group.name.one/<your-OpenStack-project-ID>",GrantRead="ID=g:group.name.two/<your-OpenStack-project-ID>")
s3client.put_object(Body="writeable by group one, invisible to group two ",Bucket="group-scope-readwrite-bucket",Key="group-scope-group-one-object.txt",GrantFullControl="ID=g:group.name.one/<your-OpenStack-project-ID>")
```

Using s3cmd to set up similar ACLs (but referring to a different project for the second group):

```shell
# Create the bucket
s3cmd -c <your-s3-config> mb s3://group-scope-readwrite-bucket
# Revoke full_control ACL for project members
s3cmd -c <your-s3-config> setacl --acl-revoke=full_control:<your-OpenStack-project-ID> s3://group-scope-readwrite-bucket
# Afterwards allow full_control for your group members
s3cmd -c <your-s3-config> setacl --acl-grant=full_control:g:<group-name-with-readwrite-access>/<your-OpenStack-project-ID> s3://group-scope-readwrite-bucket
# And grant read access for the other group
s3cmd -c <your-s3-config> setacl --acl-grant=read:g:<group-name-with-readonly-access>/<not-the-same-OpenStack-project-ID> s3://group-scope-readwrite-bucket
# Create object which will be read+writeable for one group and only readable for the second
s3cmd -c <your-s3-config> put test.txt s3://group-scope-readwrite-bucket/group-scope-readwrite-object.txt
s3cmd -c <your-s3-config> setacl --acl-grant=read:g:<group-name-with-readonly-access>/<not-the-same-OpenStack-project-ID> s3://group-scope-readwrite-bucket/group-scope-readwrite-object.txt
```

### Notes

* The owner of a bucket/object will always keep full control (read/write) access.
* If you grant write permission to an entity (project/group/user) on bucket level, the entity will inherit write permissions on objects inside of the bucket even if the ACLs of the objects state otherwise.
* Not every possible use-case is covered in this tutorial
* By default every OpenStack project will get a single group which contains all the users which have access to the project. The group management is currently handled by SysEleven 

If you need specific groups or users for setting up your desired ACLs please feel free to contact our [Cloud-Support (cloudsupport@syseleven.de)](../../06.Support/default.en.md).

## References

* [Object Storage reference guide](../../04.Reference/05.object-storage/docs.en.md)
