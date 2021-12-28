---
title: 'Object Storage'
published: true
date: '25-11-2021 11:00'
taxonomy:
    category:
        - docs
---

## Overview

SysEleven Stack provides S3 compatible Object Storage.

It stores and retrieves arbitrary unstructured data objects via a RESTful, HTTP-based API. It is highly fault tolerant with its data replication and scale-out architecture. In its implementation as a distributed eventually consistent object storage, it is not mountable like a file server.

You can create the OpenStack API to generate credentials to access the SysEleven Stack Object Storage. You can then use the S3 API with various S3 clients and/or SDKs.

## Supported S3 operations

Feature                          | Supported |
---------------------------------|-----------|
bucket HEAD/GET/PUT/DELETE       | yes       |
object HEAD/GET/PUT/POST/DELETE  | yes       |
multipart upload                 | yes       |
bucket listing                   | yes       |
input compression                | yes       |
request signature authentication | yes       |
bucket/object ACL                | partially*|
predefined ACL groups            | yes       |
bucket/IAM user ACP              | no        |
object versions                  | no        |
object expiration                | no        |
regions and storage classes      | no        |
encryption                       | no        |
access logging                   | no        |
website hosting configuration    | no        |

We do not offer the complete feature set compared to Amazon S3. Thus we cannot guarantee the same user experience. Certain API calls may fail and receive a `501 Not Implemented` response. If you are in doubt, feel free to contact our [Support (support@syseleven.de)](../../06.Support/default.en.md).

For setting up bucket/object ACLs we suggest to use [boto3](https://boto3.amazonaws.com/v1/documentation/api/latest/index.html). Not all predefined (canned) ACLs of [AWS](https://docs.aws.amazon.com/AmazonS3/latest/userguide/acl-overview.html) are supported. We are supporting the following canned ACLs: `private`,`public-read`,`public-read-write`,`authenticated-read`. Not supported canned ACLs will be interpreted as the default `private` ACL. We have prepared a [guide in our Tutorials section](../../02.Tutorials/11.object-storage-acls/docs.en.md) which shows how to set up custom ACLs.

## Buckets

Buckets are the logical unit SysEleven Stack Object Storage uses to stores objects.
Every bucket name can only be used once per SysEleven Stack region among all customers. If a desired bucket name is already taken by any customer, you cannot create another bucket with that name. To minimize the risk of collisions, avoid common and short words, combine multiple rare words, prefix them with your company or brand name, add random numbers or hashes (e.g. `syseleven-bucketname-example-7hg3x` instead of `test` is more likely to succeed). If you create buckets automatedly, prepare to retry with a different choice or resort to manual action.

## Objects

Basically, SysEleven Stack Object Storage is a big key/value store.
A file or file object can be assigned a file name like key, and made available under this key.

!! **Be aware**
!! We discourage the use of special characters, especially dots (`.`) and slashes (`/`) in bucket or object names, especially at the start and end of names. As names can be used or interpreted as dns names, pathnames and/or filenames, this can confuse both server and client software and in consequence may lead to buckets or objects being unaccessible or unmaintainable. In case you are stuck with such a phenomenon, please contact our [Support (support@syseleven.de)](../../06.Support/default.en.md).

## Regions

The SEOS (SysEleven-Object-Storage / S3) is available in every region. The storage systems run independent from each other.

Region   | URL                         | Transfer Encryption |
---------|-----------------------------|---------------------|
CBK      | s3.cbk.cloud.syseleven.net  | Yes                 |
DBL      | s3.dbl.cloud.syseleven.net  | Yes                 |
FES      | s3.fes.cloud.syseleven.net  | Yes                 |


!!!! **Deprecated URL**
!!!! For historical reasons 's3.cloud.syseleven.net' redirects to 's3.cbk.cloud.syseleven.net'.
!!!! We recommend to always use a region specific URL like in the table above.



## Credentials

You need to meet the following prerequisites to generate credentials:

* You need the OpenStack command line tools in version >= `3.13.x`.
* A change to your shell environment (you can add this to your `openrc` file):

```shell
export OS_INTERFACE="public"
```

When these prerequisites are met, you can generate and display S3 credentials:

```shell
openstack ec2 credentials create
openstack ec2 credentials list
```

!! **Important note**
!! Since the authentication service is centralised, the credentials created have access to SEOS/S3 in all regions.
!! Access to a specific region is gained by defining different storage backend URLs.
!! EC2 credentials are not restricted to use on SEOS/S3 resources, they can also be used to create a token for the user owning the credentials, thus providing full access to all OpenStack resources that the user that created the EC2 credentials has access to. This is not a privilege escalation, it is (although probably unexpectedly) designed that way. Handle your EC2 credentials with the same caution as your OpenStack credentials.


## Clients

### S3cmd

Information about the `s3cmd` client can be found [here](http://s3tools.org/s3cmd).

Now you can create an `s3cmd` configuration which could look like this:

```shell
syseleven@kickstart:~$ cat .s3cfg
[default]
access_key = < REPLACE ME >
secret_key = < REPLACE ME >
use_https = True
check_ssl_certificate = True
check_ssl_hostname = False

#host_base = s3.cbk.cloud.syseleven.net
#host_bucket = %(bucket).s3.cbk.cloud.syseleven.net
#website_endpoint = http://%(bucket)s.s3.cbk.cloud.syseleven.net/%(location)s/
#website_endpoint = http://s3.cbk.cloud.syseleven.net/%(bucket)s/%(location)s/
host_base = s3.dbl.cloud.syseleven.net
host_bucket = %(bucket).s3.dbl.cloud.syseleven.net
#website_endpoint = http://%(bucket)s.s3.dbl.cloud.syseleven.net/%(location)s/
website_endpoint = http://s3.dbl.cloud.syseleven.net/%(bucket)s/%(location)s/
#host_base = s3.fes.cloud.syseleven.net
#host_bucket = %(bucket).s3.fes.cloud.syseleven.net
#website_endpoint = http://s3.fes.cloud.syseleven.net/%(bucket)s/%(location)s/
#website_endpoint = http://%(bucket)s.s3.fes.cloud.syseleven.net/%(location)s/
```

Next, create an S3 Bucket.

```shell
s3cmd mb s3://BUCKET_NAME -P
```

The option `-P` or `--acl-public` makes this a public bucket which means that public objects in this bucket and a list of public objects can be retrieved. Without this option or with `--acl-private` the public retrieval of objects and the list is not possible.

Then add some object(s):

```shell
s3cmd put test.jpg s3://BUCKET_NAME -P
```

Here we upload a file and make it public by specifying the option `-P` or `--acl-public`. Objects without this option or with `--acl-private` are not publicly available and will not be contained in the listing.

Please note that `s3cmd` may be configured to return incorrect URLs, i.e. by default:

```shell
Public URL of the object is: http://BUCKET_NAME.s3.amazonaws.com/test.jpg
```

The correct URL for this object in SysEleven Stack would be:

`https://s3.REGION.cloud.syseleven.net/BUCKET_NAME/test.jpg`

where REGION is the SysEleven Stack region (e.g. cbk, dbl or fes).

When your bucket name satisfies the limitations of dns hostnames, your object may also be available under this URL:

`https://BUCKET_NAME.s3.REGION.cloud.syseleven.net/test.jpg`

You can use these URLs to refer to the uploaded files as static assets in your web applications.

### Boto3

Information about the `boto3` python S3 library can be found [here](https://boto3.amazonaws.com/v1/documentation/api/latest/index.html). We suggest to make use of this library to set up and manage more complex ACLs.

Using the following python snippet we can configure our client:

```python
import boto3
import botocore
# Get our session
session = boto3.session.Session()
s3 = session.resource(
    service_name = 's3',
    aws_access_key_id = "< REPLACE ME >",
    aws_secret_access_key = "< REPLACE ME >",
    endpoint_url = 'https://s3.dbl.cloud.syseleven.net'
)
# Get our client
s3client = s3.meta.client
```

For (re)creating a bucket we can use following snippet:

```python
bucket = "myBucket"
try:
    s3client.create_bucket(Bucket=bucket)
except Exception:
    print("There was a problem creating the bucket '{}', it may have already existed".format(bucket))
    oldbucket = s3.Bucket(bucket)
    # Cleanup remaining objects in bucket
    oldbucket.objects.all().delete()
    s3client.delete_bucket(Bucket=bucket)
    s3client.create_bucket(Bucket=bucket)
```

To upload our first objects we may use following commands:

```python
bucket = "myBucket"
s3client.put_object(Body="secret", Bucket=bucket, Key="private-scope-object")
```

Boto3 also supports defining ACLs for your buckets and objects. To learn more take a look on our [ACL guide in the Tutorials section](../../02.Tutorials/11.object-storage-acls/docs.en.md).


### Minio

Information about the Minio client can be found [here](https://minio.io).

**Installation of Minio client into the home directory of the current user is necessary for the following example commands to work!**

!!!! **Client functionality**
!!!! The Minio client is currently **incapable** of generating **public** files.
!!!! While synchronising many files Minio's performance is much better than with `s3cmd` though.

Now you can create a Minio S3 configuration:

```shell
~/mc config host add <ALIAS> <YOUR-S3-ENDPOINT> <YOUR-ACCESS-KEY> <YOUR-SECRET-KEY> --api <API-SIGNATURE> --lookup <BUCKET-LOOKUP-TYPE>
~/mc config host add dbl https://s3.dbl.cloud.syseleven.net accesskey secretkey --api S3v4 --lookup dns
~/mc config host add cbk https://s3.cbk.cloud.syseleven.net accesskey secretkey --api S3v4 --lookup dns
```

Next, create an S3 Bucket:

```shell
~/mc mb dbl/bucketname
Bucket created successfully ‘dbl/bucketname’.
```

Then, use it to add some file(s):

```shell
~/mc cp /root/test.jpg dbl/bucketname/test.jpg
/root/test.jpg: 380.21 KB / 380.21 KB ┃▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┃ 100.00% 65.42 MB/s 0s
```

List the file(s):

```shell
~/mc ls dbl/bucketname
[2018-04-27 14:18:28 UTC] 380KiB test.jpg
```
