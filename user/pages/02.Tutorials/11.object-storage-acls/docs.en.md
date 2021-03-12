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

In this tutorial we will use the [Object Storage](../../04.Reference/05.object-storage/docs.en.md) to create buckets and objects with and limit the access to these by applying ACLs. We will be using [s3cmd](http://s3tools.org/s3cmd) manage our resources.

### Prerequisites

* You know the basics of using the [OpenStack CLI-Tools](../../03.Howtos/02.openstack-cli/docs.en.md).
* Environment variables are set, like shown in the [API-Access-Tutorial](../../02.Tutorials/02.api-access/docs.en.md).
* You have created EC2 credentials for your OpenStack user to be able to use the [Object Storage](../../04.Reference/05.object-storage/docs.en.md).
* You have installed [boto3](https://boto3.amazonaws.com/v1/documentation/api/latest/index.html) or alternatively installed [s3cmd](http://s3tools.org/s3cmd)

We suggest you use boto3 to reproduce all testcases shown in this tutorial as s3cmd is not capable of setting ACLs on object upload and may change bucket ACLs unexpectedly.

### Prepare environment

The access and secret key from our OpenStack user will be needed to properly configure boto3/s3cmd.

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
   #   endpoint_url = 'https://s3.cbk.cloud.syseleven.net'
   )
# Get our client
s3client=s3.meta.client
```

The alternative would be to setup our s3cmd config accordingly : 

```shell
cat <<EOF > s3cfg-admin
[default]
access_key = my-access-key
secret_key = my-secret-key
use_https = True
check_ssl_certificate = True
check_ssl_hostname = False
host_base = s3.dbl.cloud.syseleven.net
#host_base = s3.cbk.cloud.syseleven.net
host_bucket = %(bucket).s3.dbl.cloud.syseleven.net
#host_bucket = %(bucket).s3.cbk.cloud.syseleven.net
EOF
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

When not providing any ACL on bucket creation the default private ACL will be used. Private in this case is a bit misleading as it still allows full control for all access keys created for your OpenStack project. Thus we have to further narrow down the ACLs later.

Lets assume we (the owner of the bucket) have following username : `exampleuser` and our project has following ID `123456789abcdefghijqlmnopqrstuvw` and has following group name `mygroup` (By default the group name is the name of your project + "-operator" in the end). Further we know of an other user with following username : `anotheruser` and his project has following ID `wvutsrqponmlqjihgfedcba987654321`.
 
```python
s3client.create_bucket(Bucket="project-scope-bucket")
s3client.create_bucket(Bucket="project-scope-readonly-bucket",GrantFullControl="ID=u:exampleuser/123456789abcdefghijqlmnopqrstuvw",GrantRead="ID=123456789abcdefghijqlmnopqrstuvw")
s3client.create_bucket(Bucket="group-scope-bucket",GrantFullControl="ID=g:mygroup/123456789abcdefghijqlmnopqrstuvw")
s3client.create_bucket(Bucket="group-scope-readonly-bucket",GrantFullControl="ID=u:exampleuser/123456789abcdefghijqlmnopqrstuvw",GrantRead="ID=g:mygroup/123456789abcdefghijqlmnopqrstuvw")
# The bucket owner always keeps full_control access to his bucket, thus we can use following ACL
s3client.create_bucket(Bucket="user-scope-bucket",GrantFullControl="ID=u:anotheruser/wvutsrqponmlqjihgfedcba987654321")
s3client.create_bucket(Bucket="user-scope-readonly-bucket",GrantFullControl="ID=u:exampleuser/123456789abcdefghijqlmnopqrstuvw",GrantRead="ID=u:anotheruser/wvutsrqponmlqjihgfedcba987654321")
s3client.create_bucket(Bucket="owner-scope-bucket",GrantFullControl="ID=u:exampleuser/123456789abcdefghijqlmnopqrstuvw")
# For the public scope bucket we may use a predefined ACL
s3client.create_bucket(Bucket="public-scope-bucket",ACL="public-read")

# For testing purpose we may force the recreation of the buckets with following snippet
bucket = "myBucket"
try:
   s3client.create_bucket(Bucket=bucket)
except:
   print("there was a problem creating the bucket '{}', it may have already existed".format(bucket))
   oldbucket = s3.Bucket(bucket)
   # Cleanup remaining objects in bucket
   oldbucket.objects.all().delete()
   s3client.delete_bucket(Bucket=bucket)
   s3client.create_bucket(Bucket=bucket)
```

When using s3cmd we may skip tightening bucket ACLs as these will be loosen up again when uploading objects.

Now that we have prepared our buckets we may proceed to upload our objects.

### Create objects 

Using the same ACLs we have defined for creating the buckets we are now creating objects.

```python
for bucket in ["project-scope-bucket project-scope-readonly-bucket group-scope-bucket group-scope-readonly-bucket user-scope-bucket user-scope-readonly-bucket owner-scope-bucket","public-scope-bucket"] :
   s3client.put_object(Body="secret",Bucket=bucket,Key="project-scope-object")
   s3client.put_object(Body="secret",Bucket=bucket,Key="project-scope-readonly-object",GrantFullControl="ID=u:exampleuser/123456789abcdefghijqlmnopqrstuvw",GrantRead="ID=123456789abcdefghijqlmnopqrstuvw")
   s3client.put_object(Body="secret",Bucket=bucket,Key="group-scope-object",GrantFullControl="ID=g:mygroup/123456789abcdefghijqlmnopqrstuvw")
   s3client.put_object(Body="secret",Bucket=bucket,Key="group-scope-readonly-object",GrantFullControl="ID=u:exampleuser/123456789abcdefghijqlmnopqrstuvw",GrantRead="ID=g:mygroup/123456789abcdefghijqlmnopqrstuvw")
   s3client.put_object(Body="secret",Bucket=bucket,Key="user-scope-object",GrantFullControl="ID=u:anotheruser/wvutsrqponmlqjihgfedcba987654321")
   s3client.put_object(Body="secret",Bucket=bucket,Key="user-scope-readonly-object",GrantFullControl="ID=u:exampleuser/123456789abcdefghijqlmnopqrstuvw",GrantRead="ID=u:anotheruser/wvutsrqponmlqjihgfedcba987654321")
   s3client.put_object(Body="secret",Bucket=bucket,Key="owner-scope-object",GrantFullControl="ID=u:exampleuser/123456789abcdefghijqlmnopqrstuvw")
   s3client.put_object(Body="secret",Bucket=bucket,Key="public-scope-object",ACL="public-read")
```

By uploading objects via boto3 we will not change the parent bucket ACLs. Thus access to the buckets/objects will be as expected. Just be aware if you grant write permission to an entity (project/group/user) on bucket level, the entity will inherit write permissions on objects inside of the bucket even if the ACLs of the objects state otherwise.


If you are using s3cmd for object upload the parent bucket ACLs may get changed resulting in unexpected access being granted for project members.

### Grant/revoke access via groups

By default every OpenStack project will get a single group which contains all the users which have access to the project. Similiar to the setup of grants/revokes for users it is possible to implement these using groups.

If you need specific groups for setting up your desired ACLs please feel free to contact our [Cloud-Support (cloudsupport@syseleven.de)](../../06.Support/default.en.md).

## References

* [Object Storage reference guide](../../04.Reference/05.object-storage/docs.en.md)