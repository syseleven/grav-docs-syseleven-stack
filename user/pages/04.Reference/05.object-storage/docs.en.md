---
title: 'Object Storage'
published: true
date: '08-08-2018 11:16'
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

Setting bucket/object ACLs is only partially possible and currently unintuitive to use. We are in contact with the software manufacturer to solve this problem. For detailed information feel free to contact our [Cloud Support](../../06.Support/default.en.md).

## Buckets

Buckets are the logical unit SysEleven Stack Object Storage uses to stores objects.
Every bucket name can only be used once per SysEleven Stack region among all customers. If a desired bucket name is already taken by any customer, you cannot create another bucket with that name. To minimize the risk of collisions, avoid common and short words, combine multiple rare words, prefix them with your company or brand name, add random numbers or hashes (e.g. `syseleven-bucketname-example-7hg3x` instead of `test` is more likely to succeed). If you create buckets automatedly, prepare to retry with a different choice or resort to manual action.

## Objects

Basically, SysEleven Stack Object Storage is a big key/value store.
A file or file object can be assigned a file name like key, and made available under this key.

## Regions

The SEOS (SysEleven-Object-Storage / S3) is available in every region. The storage systems run independent from each other.

Region   | URL                         | Transfer Encryption |
---------|-----------------------------|---------------------|
CBK      | s3.cbk.cloud.syseleven.net  | Yes                 |
DBL      | s3.dbl.cloud.syseleven.net  | Yes                 |


!!!! **Deprecated URL**
!!!! For historical reasons 's3.cloud.syseleven.net' redirects to 's3.cbk.cloud.syseleven.net'.
!!!! We recommend to always use a region specific URL like in the table above.



## Credentials

You need to meet the following prerequisites to generate credentials:

* You need the OpenStack command line tools in version >= `2.0`.
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

host_base = s3.dbl.cloud.syseleven.net
host_bucket = %(bucket).s3.dbl.cloud.syseleven.net
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

where REGION is the SysEleven Stack region (e.g. cbk or dbl).

You can use these URLs to refer to the uploaded files as static assets in your web applications.

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
