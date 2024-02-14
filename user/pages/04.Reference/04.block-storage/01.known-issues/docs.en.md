---
title: 'Known Issues'
published: true
date: '26-07-2021 16:27'
taxonomy:
    category:
        - docs
---

## Overview

### Performance impact of volume snapshots

**Problem Statement:**
When a snapshot is created of a volume, the format of the backing file is changed to the `qcow2` format.  This has a negative impact on the write performance to the volume.

#### Technical background

When a snapshot is created of a volume, the file which is storing the current contents of the volume is no longer changed.  To allow further writes to the volume, a new file is created in the `qcow2` format (QEMU Copy On Write).  New writes are stored in this file, and thanks to the `qcow2` file format, a record can be kept which content in the new file is replacing data in the snapshot file.

However, keeping this information correct necessarily impacts the write performance. This is the reason why volumes are not stored in this format when created, but after creation of a snapshot this is unavoidable.

**Solutions:**
Avoid using snapshots when possible.
In some cases it is possible to create a copy of a volume instead.

