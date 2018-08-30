---
title: 'Manuelle Datenwiederherstellung'
published: true
date: '08-08-2018 10:17'
taxonomy:
    category:
        - tutorial
---

## Ziel

* Herunterladen eines Instanz-Snapshots
* Dateisystem im Snapshot reparieren und mounten

## Vorraussetzungen

* Der Umgang mit einfachen Heat-Templates, wie [in den ersten Schritten](../02.firststeps/docs.en.md) gezeigt, wird vorausgesetzt.
* Grundlagen zur Bedienung des [OpenStack CLI-Tools](../03.openstack-cli/docs.de.md).
* Umgebungsvariablen gesetzt, wie im [API-Access-Tutorial](../04.api-access/docs.en.md) beschrieben.

## Optional: Temporäre Arbeitsumgebung

<details/>
<summary>Hier klicken um Details einzublenden</summary>

### Temporäre Arbeitsumgebung

Für dieses Tutorial benötigen wir eine *Linux-Umgebung* mit OpenStack Client. Sollte diese noch nicht vorhanden sein, kann sie mit folgenden Kommandos erstellt werden:

```shell
wget https://raw.githubusercontent.com/syseleven/heat-examples/master/kickstart/kickstart.yaml
...
openstack stack create -t kickstart.yaml --parameter key_name=<ssh key name> <stack name> --wait
...
```

Nun müssen wir uns zur erstellten Instanz verbinden.

```shell
ssh syseleven@<server-ip>
```

Alle folgenden Kommandos werden hier ausgeführt.

Wir benötigen auch die OpenStack Zugangsdaten (openrc-Datei).
Diese kann [hier](https://dashboard.cloud.syseleven.net/horizon/project/access_and_security/api_access/openrc/) heruntergeladen werden.

```shell
source openrc
```

</details>

## Erstellen eines Snapshots der defekten Instanz

Um die Daten herunterladen zu können muss ein Snapshot erstellt werden.

Achtung: Der betroffene Server wird für wenige Minuten angehalten.

```shell
openstack server image create <server uuid> --name <snapshot name> --wait
```

Nun kann der Snapshot heruntergeladen werden. Dies kann eine Weile dauern.

```shell
openstack image save --file snapshot.qcow2 <snapshot name>
```

Auf das Dateisystem kann nun mit nbd zugegriffen werden:

```shell
sudo apt-get install -y qemu-utils
sudo modprobe nbd
sudo qemu-nbd --connect /dev/nbd0 snapshot.qcow2
```

Nun können die verfügbaren Partitionen angezeigt werden.

```shell
$ sudo fdisk -l /dev/nbd0
Disk /dev/nbd0: 50 GiB, 53687091200 bytes, 104857600 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x974bb19a

Device      Boot Start       End   Sectors Size Id Type
/dev/nbd0p1 *     2048 104857566 104855519  50G 83 Linux
```

Mit fsck können etwaige Fehler erkannt und repariert werden.

```shell
# Mit der Option -y wird ohne Rückfrage repariert.
$ sudo fsck -f /dev/nbd0p1
[...]
```

Jetzt kann das Dateisystem eingehängt werden.

```shell
sudo mount /dev/nbd0p1 /mnt/
```

## Zusammenfassung

Die Daten sind nun zugreifbar unter `/mnt/`.  
Bei ext-Dateisystemen sollte ein Blick in `/mnt/lost+found` geworfen werden.