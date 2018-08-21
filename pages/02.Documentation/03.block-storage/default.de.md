---
title: Block-Speicher
published: true
date: '08-08-2018 10:40'
taxonomy:
    category:
        - docu
---

## Übersicht

SysEleven Stacks Block Storage Service basiert auf dem OpenStack Cinder Projekt.

Der Block Storage Service fügt persistenten, langlebigen Block Storage zu deinen Compute Instanzen hinzu.

Sowohl via unserer öffentlichen OpenStack API, als auch durch das SysEleven Stack [Dashboard](https://dashboard.cloud.syseleven.net) können Block Storage Volumes verwaltet und in Compute Instanzen verfügbar gemacht werden.

Es können Snapshots von Block Storage Volumes erstellt werden, welche als Grundlage zur Erstellung neuer Volumes oder Images genutzt werden können.

### Optimales Storage alignment

Das Alignment der von SysEleven bereitgestellen Images wird bereits optimal eingerichtet.

Um die Leistung der virtuellen Volumen optimal auszunutzen sind folgende Einstellungen empfehlenswert:

```shell
mkfs.ext4 -q -L myVolumeLabel -E stride=2048,stripe_width=10240
```