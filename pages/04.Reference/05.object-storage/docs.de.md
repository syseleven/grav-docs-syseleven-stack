---
title: 'Object Storage'
published: true
date: '08-08-2018 11:16'
taxonomy:
    category:
        - docs
---

## Übersicht

SysEleven Stacks Object Storage Service stellt einen S3 kompatiblen Object Storage dar.

Der Object Storage Service speichert und liest arbiträre unstrukturierte Datenobjekte via einer RESTful API. Er ist fehlertolerant, durch Datenreplikationen und eine skalierende Architektur. Durch seine Implementation als "eventually consistent storage" ist es nicht wie z.B. ein Fileserver einhängbar als Mountpoint.

Die OpenStack API kann genutzt werden um Credentials für unseren Object Storage zu erstellen. Die S3 API kann mit diversen S3 Clients und SDKs angesprochen werden.

## Buckets

Buckets sind die logische Organisationseinheit unter der Objekte im SysEleven Stack Object Storage gespeichert werden.
Der Name eines Buckets ist im SysEleven Stack einmalig und damit eindeutig.

## Objects

Der SysEleven Stack Object Storage Service ist im Prinzip ein großer Key/Value Storage.
Eine Datei oder Datenobject können einem Key wie einem Dateinamen zugewiesen werden und unter diesem im Object Storage abgelegt und verfügbar gemacht werden.

## Regions

Der SEOS (SysEleven-Object-Storage / S3) ist in jeder Region verfügbar. Die Storage Systeme laufen unabhängig voneinander.

Region   | URL                         | Transfer Encryption |
---------|-----------------------------|---------------------|
CBK      | s3.cbk.cloud.syseleven.net  | Yes                 |
DBL      | s3.dbl.cloud.syseleven.net  | Yes                 |


!!!! **Veraltete URL**
!!!! Aus historischen Gründen leitet 's3.cloud.syseleven.net' auf 's3.cbk.cloud.syseleven.net' um.
!!!! Wir empfehlen immer eine Region spezifische URL aus der obrigen Tabelle zu verwenden.


## Zugangsdaten

Folgende Voraussetzungen müssen erfüllt sein, um Zugangsdaten zu generieren:

* Ein OpenStack Command Line Client in der Version >= `2.0`.
* Eine Anpassung der Shellumgebung oder openrc:

```shell
export OS_INTERFACE="public"
```

Sind diese Voraussetzungen erfüllt können wir uns die S3 Credentials generieren und anzeigen lassen:

```shell
openstack ec2 credentials create
openstack ec2 credentials list
```

!! **Wichtiger Hinweis**
!! Da der Authentifizierungs Dienst zentralisiert ist, haben die erstellten Zugangsdaten Zugriff auf SEOS/S3 in allen Regionen.
!! Zugriff auf die jeweilige Region ist möglich, indem die jeweilige Storage Backend URLs verwendet wird.

## Clients

### S3cmd

Infos über den `s3cmd` Client sind [hier](http://s3tools.org/s3cmd) zu finden.

Mit diesen Informationen können wir uns eine `s3cmd` Konfiguration erstellen, die wie folgt aussehen könnte:

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

Im nächsten Schritt erstellen wir einen S3 Bucket.

```shell
s3cmd mb s3://BUCKET_NAME -P

Mit dem Schalter `-P` oder `--acl-public` machen wir den Bucket öffentlich, d.h. es ist grundsätzlich möglich, Objekte in diesem Bucket öffentlich zu machen und diese öffentlichen Objekte sowie eine Übersicht über die öffentlichen Objekte abzurufen. Ohne den Schalter `-P` oder mit dem Schalter `--acl-private` ist das anonyme Abrufen von Objekten sowie der Übersicht nicht möglich.
```

Nun befüllen wir den Bucket mit Objekten:

```shell
s3cmd put test.jpg s3://BUCKET_NAME -P
```

Hier wird eine Datei hochgeladen und mit dem Schalter `-P` oder `--acl-public` auch öffentlich erreichbar gemacht, wenn der Bucket öffentlich ist. Objekte, die ohne `-P` oder mit `--acl-private` hochgeladen werden, sind nicht öffentlich abrufbar und werden auch nicht in der Übersicht aufgeführt.

Dabei ist zu beachten, dass die Ausgabe von `s3cmd` je nach seiner Konfiguration eine falsche URL ausgeben kann, z.B. in der Voreinstellung:

```shell
Public URL of the object is: http://BUCKET_NAME.s3.amazonaws.com/test.jpg
```

Die korrekte URL für den Zugriff auf das öffentliche S3 Objekt wäre im SysEleven Stack

`https://s3.dbl.cloud.syseleven.net/BUCKET_NAME/test.jpg`

Damit sind wir in der Lage, statische Assets über eine HTTP URL einzubinden.

### Minio

Infos über den Minio Client sind [hier](https://minio.io) zu finden.

**Der Minio Client muss in das Home Directory des aktuellen Benutzers installiert werden, damit die folgenden Beispiel Commandos funktionieren.**

!!!! **Client Funktionen**
!!!! Der Minio Client kann zur Zeit leider **keine öffentlichen** Dateien erstellen.
!!!! Zum Synchronisieren von vielen Dateien ist die Performance von `Minios` jedoch besser als mit `s3cmd`.

Mit diesen Informationen können wir uns eine Minio S3 Konfiguration erstellen:

```shell
~/mc config host add <ALIAS> <YOUR-S3-ENDPOINT> <YOUR-ACCESS-KEY> <YOUR-SECRET-KEY> --api <API-SIGNATURE> --lookup <BUCKET-LOOKUP-TYPE>
~/mc config host add dbl https://s3.dbl.cloud.syseleven.net accesskey secretkey --api S3v4 --lookup dns
~/mc config host add cbk https://s3.cbk.cloud.syseleven.net accesskey secretkey --api S3v4 --lookup dns
```

Im nächsten Schritt erstellen wir einen S3 Bucket:

```shell
~/mc mb dbl/bucketname
Bucket created successfully ‘dbl/bucketname’.
```

und befüllen diesen mit Inhalt:

```shell
~/mc cp /root/test.jpg dbl/bucketname/test.jpg
/root/test.jpg: 380.21 KB / 380.21 KB ┃▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┃ 100.00% 65.42 MB/s 0s
```

Datei(en) listet man wie folgt auf:

```shell
~/mc ls dbl/bucketname
[2018-04-27 14:18:28 UTC] 380KiB test.jpg
```
