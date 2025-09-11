---
title: 'Known Issues'
published: true
date: '07-23-2020 15:07'
taxonomy:
    category:
        - docs
---

## Overview

### Object upload fails with a 501 Not Implemented error

**Problem Statement:**
Trying to upload objects towards the SysEleven Stack Object Storage (based on the Ceph backend) can fail depending on the signature version you are using. The integration with the OpenStack identity-and-access service Keystone limits the featureset supported by the Ceph backend. In consequence (depending on your client) you will receive a 501 error trying to upload objects.

**Solutions:**
Switch from signature version 4 to signature version 2 for object uploads.

### Request timeouts using recently created EC2 credentials

**Problem Statement:**
Using recently-created EC2 credentials to communicate with the SysEleven Stack Object Storage may result in requests taking longer than 60 seconds. Depending on the client used for communication to the SysEleven Stack Object Storage (based on the Quobyte backend), this can further lead to request timeouts.

**Solutions:**
The problem will be gone after a few minutes, after the object storage refreshed its own user credentials cache.

### S3cmd cannot download large files

**Problem Statement:**
When using `s3cmd` to manage your data in the SysEleven Stack Object Storage, you may run into an issue trying to download large files (whose size exceeds 100 GiB). You will receive a 503 response asking you to slow down even when reducing download speed to a minimum.

**Solutions:**
We suggest to download the file in multiple chunks using the HTTP Range header. `s4cmd` supports this out of the box using the `--max-singlepart-download-size` option:

```plain
s4cmd get --max-singlepart-download-size=$((50*1024**2)) --multipart-split-size=$((50*1024**2)) s3://BUCKET_NAME/FILE_NAME
````

The value of 52428800 Bytes = 50 GiB specified in this example is actually the default value for those parameters, so that using `s4cmd` without specifying those parameters should already circumvent the mentioned problem by doing multipart transfers.

### Maximum number of objects

**Problem Statement:**
There is a technical limitation in the backend storage of SEOS of 200 million objects or directories per project per region.

**Solutions:**
Please contact our customer support if you run into (or think you may run into) this limitation.

### Unexpected high usage due to stale multipart uploads

**Problem Statement:**
Large files can be uploaded in a set of parts. If such a multipart upload is not finished properly, the already-uploaded parts are kept in the storage system and count into the object-storage usage even though they are not visible when you list the objects inside a bucket.

**Solutions:**
Unfinished multipart uploads are not cleaned up automatically by default. The user is free to decide whether to continue the upload or abort it explicitly. If the upload is aborted all its parts are deleted.

The following S3 API operations can be used to deal with incomplete multipart uploads:

* `ListMultipartUploads` to list the multipart uploads for a given bucket
* `ListParts` to list the already-uploaded parts of a given upload (identified by bucket, key and upload ID)
* `AbortMultipartUpload` to abort a multipart upload and clean up its parts

Example CLI commands:

```plain
# list multipart uploads
s3cmd multipart s3://BUCKET_NAME
aws s3api list-multipart-uploads --bucket BUCKET_NAME --endpoint-url ENDPOINT_URL

# list parts
s3cmd listmp s3://BUCKET_NAME/KEY UPLOAD_ID
aws s3api list-parts --bucket BUCKET_NAME --key KEY --upload-id UPLOAD_ID --endpoint-url ENDPOINT_URL

# abort an upload
s3cmd abortmp s3://BUCKET_NAME/KEY UPLOAD_ID
aws s3api abort-multipart-upload --bucket BUCKET_NAME --key KEY --upload-id UPLOAD_ID --endpoint-url ENDPOINT_URL
```

With ceph-based object storage you may configure a bucket lifecycle rule `AbortIncompleteMultipartUpload` to let unfinished multipart uploads be cleaned up automatically after a certain number of days.

### s3 DeleteBucketLifecycle does not delete lifecycle config

**Problem Statement:**
There is an issue where the s3 DeleteBucketLifecycle which API call fails to actually remove the lifecycle configuration from the bucket. The fix was originally implemented in master but was not included in the squid release line.
[Ceph tracker link](https://github.com/ceph/ceph/pull/64741)

**Reproduce:**
Here you will se an example with aws cli how to reproduce it

```plan
# This is a lifecycle config example
$ cat lifecycle.json
{
  "Rules": [
    {
      "ID": "ExpireOldObjects",
      "Prefix": "",
      "Status": "Enabled",
      "Expiration": {
        "Days": 30
      }
    }
  ]
}

# Put lifecycle config in to our bucket
$ aws s3api put-bucket-lifecycle-configuration \
  --bucket testbucket \
  --lifecycle-configuration file://lifecycle.json \
  --endpoint-url https://objectstorage-replicated.dus2.cloud.syseleven.net

# Verify lifecycle config is there
$ aws s3api get-bucket-lifecycle-configuration \
  --bucket testbucket \
  --endpoint-url https://objectstorage-replicated.dus2.cloud.syseleven.net
{
    "Rules": [
        {
            "Expiration": {
                "Days": 30
            },
            "ID": "ExpireOldObjects",
            "Prefix": "",
            "Status": "Enabled"
        }
    ]
}

# Delete the lifecycle config
$ aws s3api delete-bucket-lifecycle \
  --bucket testbucket \
  --endpoint-url https://objectstorage-replicated.dus2.cloud.syseleven.net

# Check if the lifecycle is deleted or not
$ aws s3api get-bucket-lifecycle-configuration \
  --bucket testbucket \
  --endpoint-url https://objectstorage-replicated.dus2.cloud.syseleven.net
{
    "Rules": [
        {
            "Expiration": {
                "Days": 30
            },
            "ID": "ExpireOldObjects",
            "Prefix": "",
            "Status": "Enabled"
        }
    ]
}
```

**Workaround:**
As a workaround till the upstream fixes the issue in next release, you can Disable your lifecycle config.

```plain
# This is a disabled lifecycle config example
$ cat lifecycle.json
{
  "Rules": [
    {
      "ID": "ExpireOldObjects",
      "Prefix": "",
      "Status": "Disabled",
      "Expiration": {
        "Days": 30
      }
    }
  ]
}

# Put disabled lifecycle config in to our bucket
$ aws s3api put-bucket-lifecycle-configuration \
  --bucket testbucket \
  --lifecycle-configuration file://lifecycle.json \
  --endpoint-url https://objectstorage-replicated.dus2.cloud.syseleven.net

# Verify lifecycle config is disabled
$ aws s3api get-bucket-lifecycle-configuration \
  --bucket testbucket \
  --endpoint-url https://objectstorage-replicated.dus2.cloud.syseleven.net
{
    "Rules": [
        {
            "Expiration": {
                "Days": 30
            },
            "ID": "ExpireOldObjects",
            "Prefix": "",
            "Status": "Disabled"
        }
    ]
}
```
