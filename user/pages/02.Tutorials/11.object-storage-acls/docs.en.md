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

In this tutorial we will use the [Object Storage](../../04.Reference/05.object-storage/docs.en.md) to create buckets and objects with and limit the access to these by applying ACLs. We will be using [boto3](https://boto3.readthedocs.io) to manage our resources.

### Prerequisites

* You know the basics of using the [OpenStack CLI-Tools](../../03.Howtos/02.openstack-cli/docs.en.md).
* Environment variables are set, like shown in the [API-Access-Tutorial](../../02.Tutorials/02.api-access/docs.en.md).
* You have created EC2 credentials for your OpenStack user to be able to use the [Object Storage](../../04.Reference/05.object-storage/docs.en.md).
* You have installed [boto3](https://boto3.amazonaws.com/v1/documentation/api/latest/index.html) or alternatively installed [s3cmd](http://s3tools.org/s3cmd)

We suggest you use boto3 to reproduce all testcases shown in this tutorial as our experiments show, s3cmd is not capable of isolating buckets. 

To verify if the ACLs are in place we may use s3cmd.

### Prepare environment

The access and secret key from our OpenStack user will be needed to properly configure boto3.

We can configure boto3 to our needs using following snippet:

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
s3client=s3.meta.client
```

### Create buckets

Using your personal s3cmd configuration, we will create following buckets.

* `project-scope-bucket` representing a bucket which will be read/writeable by all access keys created for the OpenStack project.
* `project-scope-readonly-bucket` representing a bucket which will be readable by all access keys created for the OpenStack project and read/writeable for the owner of the bucket.

* `group-scope-bucket` representing a bucket which will be read/writeable by all access keys of users who share the same OpenStack group as the owner of the bucket.
* `group-scope-readonly-bucket` representing a bucket which will be readable by all access keys of users which share the same OpenStack group as the owner of the bucket and read/writeable for the owner of the bucket.

* `user-scope-bucket` representing a bucket which will read/writeable for specific access keys and by the owner of the bucket.
* `user-scope-readonly-bucket` representing a bucket which will read for specific access keys and read/writeable by the owner of the bucket.

* `public-scope-bucket` representing a bucket which will be public readable and read/writeable by all access keys created for the OpenStack project.
* `owner-scope-bucket` representing a bucket which will only be read/writeable by the owner of the bucket.

The default private ACL will be used when no ACL is provided on bucket creation. Private in this case can be a bit misleading as this predefined ACL still allows full control for all access keys created for your OpenStack project. Thus we have to further narrow down the ACLs for our use-cases.

Lets assume we (the owner of the bucket) have following username : `exampleuser`, our project has following ID `123456789abcdefghijqlmnopqrstuvw` and our user is in group with following name `project-operator`. Further we know of another user with following username : `anotheruser` who has created his ec2 credentials for a project with following ID `wvutsrqponmlqjihgfedcba987654321`. 
 
Lets have a look at following python snippet whichs shows how we can set the ACLs on bucket creation with boto3.

```python
s3client.create_bucket(Bucket="project-scope-bucket")
s3client.create_bucket(Bucket="project-scope-readonly-bucket",GrantFullControl="ID=u:exampleuser/123456789abcdefghijqlmnopqrstuvw",GrantRead="ID=123456789abcdefghijqlmnopqrstuvw")
s3client.create_bucket(Bucket="group-scope-bucket",GrantFullControl="ID=g:project-operator/123456789abcdefghijqlmnopqrstuvw")
s3client.create_bucket(Bucket="group-scope-readonly-bucket",GrantFullControl="ID=u:exampleuser/123456789abcdefghijqlmnopqrstuvw",GrantRead="ID=g:project-operator/123456789abcdefghijqlmnopqrstuvw")
# The bucket owner always keeps full_control access to his bucket, thus we can use following ACL to allow the other user read/write access.
s3client.create_bucket(Bucket="user-scope-bucket",GrantFullControl="ID=u:anotheruser/wvutsrqponmlqjihgfedcba987654321")
s3client.create_bucket(Bucket="user-scope-readonly-bucket",GrantFullControl="ID=u:exampleuser/123456789abcdefghijqlmnopqrstuvw",GrantRead="ID=u:anotheruser/wvutsrqponmlqjihgfedcba987654321")
s3client.create_bucket(Bucket="owner-scope-bucket",GrantFullControl="ID=u:exampleuser/123456789abcdefghijqlmnopqrstuvw")
# For the public scope bucket we may use the predefined public-read ACL
s3client.create_bucket(Bucket="public-scope-bucket",ACL="public-read")
```

In the next step we will proceed and upload objects with the same ACL structure.

### Create objects 

We are now creating/uploading objects using the same ACLs we have used for creating our initial buckets.

```python
for bucket in ["project-scope-bucket", "project-scope-readonly-bucket", "group-scope-bucket", "group-scope-readonly-bucket", "user-scope-bucket" ,"user-scope-readonly-bucket", "owner-scope-bucket", "public-scope-bucket"] :
   s3client.put_object(Body="secret",Bucket=bucket,Key="project-scope-object")
   s3client.put_object(Body="secret",Bucket=bucket,Key="project-scope-readonly-object",GrantFullControl="ID=u:exampleuser/123456789abcdefghijqlmnopqrstuvw",GrantRead="ID=123456789abcdefghijqlmnopqrstuvw")
   s3client.put_object(Body="secret",Bucket=bucket,Key="group-scope-object",GrantFullControl="ID=g:project-operator/123456789abcdefghijqlmnopqrstuvw")
   s3client.put_object(Body="secret",Bucket=bucket,Key="group-scope-readonly-object",GrantFullControl="ID=u:exampleuser/123456789abcdefghijqlmnopqrstuvw",GrantRead="ID=g:project-operator/123456789abcdefghijqlmnopqrstuvw")
   s3client.put_object(Body="secret",Bucket=bucket,Key="user-scope-object",GrantFullControl="ID=u:anotheruser/wvutsrqponmlqjihgfedcba987654321")
   s3client.put_object(Body="secret",Bucket=bucket,Key="user-scope-readonly-object",GrantFullControl="ID=u:exampleuser/123456789abcdefghijqlmnopqrstuvw",GrantRead="ID=u:anotheruser/wvutsrqponmlqjihgfedcba987654321")
   s3client.put_object(Body="secret",Bucket=bucket,Key="owner-scope-object",GrantFullControl="ID=u:exampleuser/123456789abcdefghijqlmnopqrstuvw")
   s3client.put_object(Body="secret",Bucket=bucket,Key="public-scope-object",ACL="public-read")
```

By uploading objects via boto3, we will not change the parent bucket ACLs. Thus access to the buckets/objects will be set as expected. Just be aware if you grant write permission to an entity (project/group/user) on bucket level, the entity will inherit write permissions on objects inside of the bucket even if the ACLs of the objects state otherwise.


### Note on ACL grant/revoke by groups

By default every OpenStack project will get a single group which contains all the users which have access to the project. The group management is currently handled by SysEleven 

If you need specific groups for setting up your desired ACLs please feel free to contact our [Cloud-Support (cloudsupport@syseleven.de)](../../06.Support/default.en.md).

### Note on ACL grant/revoke by username

Setting ACLs for specific users may not work if the username is not POSIX compliant (e.g. the username is a mail address). If you need a change of usernames in order to setup your desired ACLs please contact our [Cloud-Support (cloudsupport@syseleven.de)](../../06.Support/default.en.md).

## References

* [Object Storage reference guide](../../04.Reference/05.object-storage/docs.en.md)