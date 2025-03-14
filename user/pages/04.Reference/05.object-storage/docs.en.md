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

It stores and retrieves arbitrary unstructured data objects via an HTTP-based API. It is highly fault tolerant with its data replication and scale-out architecture. In its implementation as a distributed eventually consistent object storage, it is not mountable like a file server.

You can use the OpenStack API to generate credentials to access the SysEleven Stack Object Storage. You can then use the S3 API with various S3 clients and/or SDKs.

## Supported S3 operations by backend

Feature                          | Support in Quobyte            | Support in Ceph               |
---------------------------------|-------------------------------|-------------------------------|
bucket HEAD/GET/PUT/DELETE       | yes                           | yes                           |
object HEAD/GET/PUT/POST/DELETE  | yes                           | yes                           |
multipart upload                 | yes                           | yes                           |
bucket listing                   | yes                           | yes                           |
input compression                | yes                           | yes                           |
request signature authentication | yes                           | yes                           |
predefined ACL groups            | yes                           | yes                           |
bucket/object ACL                | partially*                    | partially*                    |
bucket policies                  | no                            | yes                           |
object versions                  | no                            | yes                           |
object expiration                | no                            | yes                           |
encryption                       | no                            | yes                           |
setting CORS headers             | no                            | yes                           |
website hosting configuration    | no                            | no                            |
bucket/IAM user ACP              | no                            | no                            |
regions and storage classes      | no                            | no                            |
access logging                   | no                            | no                            |

(*)
For setting up bucket/object ACLs we suggest to use [boto3](https://boto3.amazonaws.com/v1/documentation/api/latest/index.html). Not all predefined (canned) ACLs of [AWS](https://docs.aws.amazon.com/AmazonS3/latest/userguide/acl-overview.html) are supported. We are supporting the following canned ACLs: `private`,`public-read`,`public-read-write`,`authenticated-read`. Not supported canned ACLs will be interpreted as the default `private` ACL. We have prepared a [guide in our Tutorials section](../../02.Tutorials/11.object-storage-acls/docs.en.md) which shows how to set up custom ACLs.

We do not offer the complete feature set compared to Amazon S3. Thus we cannot guarantee the same user experience. Certain API calls may fail and receive a `501 Not Implemented` response. If you are in doubt, feel free to contact our [Support (support@syseleven.de)](../../06.Support/default.en.md).

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

Region   | URL                                    | Backend             |
---------|----------------------------------------|---------------------|
CBK      | s3.cbk.cloud.syseleven.net             | Quobyte             |
DBL      | s3.dbl.cloud.syseleven.net             | Quobyte             |
FES      | s3.fes.cloud.syseleven.net             | Quobyte (eol 2025-06-15)  |
FES      | objectstorage.fes.cloud.syseleven.net  | Ceph                |

!!!! **Deprecated URL**
!!!! For historical reasons 's3.cloud.syseleven.net' redirects to 's3.cbk.cloud.syseleven.net'.
!!!! We recommend to always use a region specific URL like in the table above.

!! s3.fes.cloud.syseleven.net will be end-of-life on 2025-06-15. We recommend to use `objectstorage.fes.cloud.syseleven.net instead. For existing object data refer to our [migration howto](../../03.Howtos/16.migrate-quobyte-to-ceph/docs.en.md).

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

Information about the `s3cmd` client can be found [here](https://s3tools.org/s3cmd).

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
#website_endpoint = https://%(bucket)s.s3.cbk.cloud.syseleven.net/%(location)s/
#website_endpoint = https://s3.cbk.cloud.syseleven.net/%(bucket)s/%(location)s/
host_base = s3.dbl.cloud.syseleven.net
host_bucket = %(bucket).s3.dbl.cloud.syseleven.net
#website_endpoint = https://%(bucket)s.s3.dbl.cloud.syseleven.net/%(location)s/
website_endpoint = https://s3.dbl.cloud.syseleven.net/%(bucket)s/%(location)s/
#host_base = objectstorage.fes.cloud.syseleven.net
#host_bucket = %(bucket).objectstorage.fes.cloud.syseleven.net
#website_endpoint = https://objectstorage.fes.cloud.syseleven.net/%(bucket)s/%(location)s/
#website_endpoint = https://%(bucket)s.objectstorage.fes.cloud.syseleven.net/%(location)s/
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


### AWS CLI

Information about the AWS client can be found [here](https://aws.amazon.com/cli/).

!!!! **Ceph and Quobyte specific commands**
!!!! There are some incompatibilities with some S3 commands in AWS CLI for Ceph S3 which works fine with Quobyte S3. This part will cover commands for `s3.xxx.cloud.syseleven.net` endpoints which are Quobyte and `objectstorage.fes.cloud.syseleven.net` which is our Ceph endpoint.
!!!!
!!!! This part will be updated regularly so it's suggested to check often.

The `aws-cli` also has a configuration file which can be created under the home directory of the user which runs the command.

```shell
mdkir ~/.aws
```

The configuration for a simple use should be like this:

```shell
syseleven@kickstart:~$ cat ~/.aws/config
[default]
aws_access_key_id = < REPLACE ME >
aws_secret_access_key = < REPLACE ME >
```

Listing buckets: **[Quobyte - Ceph]**

```shell
aws --endpoint-url https://s3.cbk.cloud.syseleven.net s3 ls
```

Creating a bucket:  **[Quobyte]**

```shell
aws --endpoint-url https://s3.cbk.cloud.syseleven.net s3 mb s3://test-bucket-sys11-j2j4
```

Creating a bucket:  **[Ceph]**

```shell
aws --endpoint-url https://objectstorage.fes.cloud.syseleven.net s3api create-bucket --bucket test-bucket-sys11-j2j4
```

Put a file to the bucket: **[Quobyte - Ceph]**

```shell
aws --endpoint-url https://s3.cbk.cloud.syseleven.net s3 cp test.pdf s3://test-bucket-sys11-j2j4
```

After this a simple query for the S3 bucket list can be simple as the following: **[Quobyte - Ceph]**

```shell
aws --endpoint-url https://s3.cbk.cloud.syseleven.net s3 ls s3://test-bucket-sys11-j2j4
2022-12-14 15:14:39       3652 test.pdf
```

Objects can be removed as follows: **[Quobyte - Ceph]**

```shell
aws --endpoint-url https://s3.cbk.cloud.syseleven.net s3 rm s3://test-bucket-sys11-j2j4/test.pdf
delete: s3://test-bucket-sys11-j2j4/test.pdf
```

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
