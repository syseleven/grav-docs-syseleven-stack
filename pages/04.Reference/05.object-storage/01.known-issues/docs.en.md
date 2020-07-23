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
When using S3cmd to manage your data in the SysEleven Stack Object Storage, you may run into an issue trying to download large files (which size exceed 100 GB). You will receive a 503 response asking you to slow down even when reducing download speed to a minimum. 

**Solutions:**  
We suggest to download the file in multiple chunks using the HTTP Range header. S4cmd supports this out of the box using the --max-singlepart-download-size option:

```plain
s4cmd get --max-singlepart-download-size=1000 s3://BUCKET_NAME/FILE_NAME
````

In the example command the option itself defines that files greater then 1000 bytes will be downloaded in multipart transfers.


