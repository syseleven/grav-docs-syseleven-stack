---
title: Snapshots
published: true
date: '08-08-2018 11:28'
taxonomy:
    category:
        - docu
---

## Snapshot types

OpenStack offers two different snapshot types. The logical mechanism is the same but the management is different.

## Instance Snapshots
Instance snapshots can be created from instances that are using the ephemeral storage.

**Optional: To create proper instance snapshots the instances should be to be shut off.**

```
openstack server image create --name <MyInstanceSnapshotName> <MyInstanceName>
+------------------+-----------------------------------------------------------------------------------------------------------+
| Field            | Value                                                                                                     |                  
+------------------+-----------------------------------------------------------------------------------------------------------+
| checksum         | None                                                                                                      |
| container_format | None                                                                                                      |                        
| created_at       | 2018-05-28T13:00:55Z                                                                                      |                                                                                                                                                                                     
| disk_format      | None                                                                                                      |                                                                                                                                                                                     
| file             | /v2/images/21484215-7679-4673-9093-5d3a4f77a2ab/file                                                      |                                                                                                                                                                                     
| id               | 21484215-7679-4673-9093-5d3a4f77a2ab                                                                      |                                                                                                                                                                                     
| min_disk         | 50                                                                                                        |                                                                                                                                                                                     
| min_ram          | 0                                                                                                         |                                                                                                                                                                                     
| name             | jumphostsnapshot                                                                                          |                                                                                                                                                                                     
| owner            | xxxxxxxx931c4gggggf946yyyyy                                                                               |                                                                                                                                                                                    
| properties       | base_image_ref='34faf858-f2e9-4656-93ac-fcc8371a9877', basename='Ubuntu 16.04 LTS sys11 optimized ...... '|
| protected        | False                                                                                                     |                                                                                                                                                                                     
| schema           | /v2/schemas/image                                                                                         |                                                                                                                                                                                     
| size             | None                                                                                                      |                                                                                                                                                                                     
| status           | queued                                                                                                    |                                                                                                                                                                                     
| tags             |                                                                                                           |                                                                                                                                                                                     
| updated_at       | 2018-05-28T13:00:55Z                                                                                      |                                                                                                                                                                                     
| virtual_size     | None                                                                                                      |                                                                                                                                                                                     
| visibility       | private                                                                                                   |                                                                                                                                                                                     
+------------------+-----------------------------------------------------------------------------------------------------------+
```

## Volume Snapshots
Volume Snapshots can be created from any volume, be it a root disk for an instance or an additional volume.

**Optional: To create proper instance snapshots the instances should be to be shut off.**

```
openstack volume snapshot create --volume <MyVolumeName> <MyVolumeSnapshotName>
+-------------+--------------------------------------+
| Field       | Value                                |
+-------------+--------------------------------------+
| created_at  | 2018-05-02T13:12:24.596134           |
| description | None                                 |
| id          | a06bb744-3b2e-4700-aee7-6e7973d2ec53 |
| name        | <MyVolumeSnapshotName>               |
| properties  |                                      |
| size        | 300                                  |
| status      | creating                             |
| updated_at  | None                                 |
| volume_id   | 1fc8e1bf-69a6-468a-b64f-d296a9872ae0 |
+-------------+--------------------------------------+
```

!!! **Deleting volumes with snapshots**
!!! All snapshots that are linked to a volume have to be copied/transferred into another 
!!! volume/image or deleted before the reference volume can be deleted.

## List snapshots

While listing snapshots there is also a slight difference. Instance snapshots are stored as 
'images' while volume snapshots are stored as 'volume snapshots'.

### Instance Snapshots
````
openstack image list --private
+--------------------------------------+--------------------------+--------+
| ID                                   | Name                     | Status |
+--------------------------------------+--------------------------+--------+
| 21484215-7679-4673-9093-5d3a4f77a2ab | <MyInstanceSnapshotName> | active |
+--------------------------------------+--------------------------+--------+
````

### Volume Snapshots
````
openstack volume snapshot list
+--------------------------------------+------------------------+-------------+-----------+------+
| ID                                   | Name                   | Description | Status    | Size |
+--------------------------------------+------------------------+-------------+-----------+------+
| a06bb744-3b2e-4700-aee7-6e7973d2ec53 | <MyVolumeSnapshotName> | None        | available |  300 |
+--------------------------------------+------------------------+-------------+-----------+------+
````

## Launch instances from snapshots

Snapshots can be used as templates for new instances.

[This heat example](https://github.com/syseleven/heat-examples/tree/master/singles-server-from-snapshot) shows 
how to use snapshots to launch new instances using the ephemeral or volume storage.