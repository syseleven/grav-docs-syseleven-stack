---
title: 'Known Issues'
published: true
date: '07-23-2020 15:07'
taxonomy:
    category:
        - docs
---

## Overview

### S3cmd cannot download large files

**Problem Statement:**  
When using `s3cmd` to manage your data in the SysEleven Stack Object Storage, you may run into an issue trying to download large files (whose size exceeds 100 GiB). You will receive a 503 response asking you to slow down even when reducing download speed to a minimum.

**Solutions:**  
We suggest to download the file in multiple chunks using the HTTP Range header. `s4cmd` supports this out of the box using the `--max-singlepart-download-size` option:

```plain
s4cmd get --max-singlepart-download-size=$((50*1024**2)) --multipart-split-size=$((50*1024**2)) s3://BUCKET_NAME/FILE_NAME
````

The value of 52428800 Bytes = 50 GiB specified in this example is actually the default value for those parameters, so that using `s4cmd` without specifying those parameters should already circumvent the mentioned problem by doing multipart transfers.

