---
title: 'OpenStack CLI installieren'
published: true
date: '03-08-2018 13:12'
taxonomy:
    category:
        - howtos
---

## Übersicht

Dieses How-to dient als Anleitung für die Installation der OpenStack CLI (Befehlszeilen-Schnittstelle, engl.: command line interface). Mit der OpenStack CLI kannst du deine Stacks administrieren und überwachen.

## Ziel

* OpenStack Command-Line-Client in einer aktuellen Version und benötigte Plugins installieren

## Voraussetzungen

* PC/MAC
* Admin-Rechte
* Grundlegende PC-Kenntnisse
* Der Umgang mit einem Terminal/SSH ist vertraut.

*In dieser Anleitung gehen wir davon aus, dass bisher nichts von den benötigten Programmen installiert wurde.
Für den Fall das bereits Bestandteile installiert sind, überspringe den jeweiligen Punkt.*

! **Benötigte OpenStack Client Version die mit der SysEleven Cloud kompatibel ist**
! OpenStack Client Version 3.13.x ist die minimale Version um mit mehreren Regionen arbeiten zu können. Bitte sicherstellen dass die neueste stabile Version installiert ist.

---

## Installation unter MAC

Als erstes öffne das `Terminal` oder falls installiert [iTerm2](https://www.iterm2.com/).

### PIP

Um die benötigten Pakete installieren zu können, nutzen wir das Paketverwaltungsprogramm [PIP](https://de.wikipedia.org/wiki/Pip_(Python)).

`PIP` installieren wir mit folgendem Befehl:

```shell
easy_install pip
```

### Python Abhängigkeiten

Als Workaround für ein OSX-Problem führe folgenden Befehl aus:

```shell
sudo -H pip install --ignore-installed six pyparsing pyOpenSSL
```

Alternativ kann eine ["virtuelle Umgebung" mit `virtualenv`](#virtualenv) auch funktionieren, um eine seperate Umgebung für den OpenStack Client zu nutzen.

### OpenStack Client

Nachdem wir `PIP` installiert haben, brauchen wir nun nur noch den OpenStack Client und Plugins mit folgendem Befehl zu installieren, um mit den entsprechenden OpenStack APIs kommunizieren zu können:

```shell
pip install python-openstackclient python-heatclient
```

---

## Installation unter Windows

### Python

Damit die OpenStack CLI unter Windows genutzt werden kann, benötigen wir zunächst [Python 2.7](https://www.python.org/downloads/release/python-2712/).
Nachdem die Installation abgeschlossen ist, wechseln wir in die Eingabeaufforderung und stellen sicher, dass wir im folgenden Pfad sind C:\Python27\Scripts.

### PIP

Nun nutzen wir das `easy_install` Kommando um [PIP](https://de.wikipedia.org/wiki/Pip_(Python)) als Paket-Manager zu installieren

```batch
C:\Python27\Scripts>easy_install pip
```

### OpenStack Client

Nachdem nun `PIP` installiert ist, brauchen wir als letzten Schritt nur noch die OpenStack CLI zu installieren:

```batch
C:\Python27\Scripts>pip install python-openstackclient python-heatclient
```

### OpenStack Plugins

[Installiere anschließend die benötigten Plugins](#plugins-installieren), um mit den entsprechenden OpenStack APIs kommunizieren zu können.

---

## Installation unter Linux

### PIP

Um die benötigten Pakete installieren zu können, nutzen wir das Paketverwaltungsprogramm [PIP](https://de.wikipedia.org/wiki/Pip_(Python)).

#### Red Hat Enterprise Linux, CentOS oder Fedora

```shell
yum install python-minimal python-pip
```

#### Ubuntu oder Debian

```shell
apt install -q -y python-minimal python-pip
```

### OpenStack Client

Bei Abhängigkeitsproblemen kann alternativ eine ["virtuelle Umgebung" mit `virtualenv`](#virtualenv) auch funktionieren, um eine seperate Umgebung für den OpenStack Client zu nutzen.

Nachdem wir `PIP` installiert haben, brauchen wir nun nur noch den OpenStack Client und Plugins mit folgendem Befehl zu installieren, um mit den entsprechenden OpenStack APIs kommunizieren zu können:

```shell
sudo -H pip install python-openstackclient python-heatclient
```

---

## Fazit

Nun ist der OpenStack Client installiert und wir können diesen nutzen.
**Damit die OpenStack CLI-Tools verwendet werden können, muss der [API Zugriff](../../02.Tutorials/02.api-access/docs.en.md) als Nächstes konfiguriert werden.**

Eine Übersicht aller Befehle kannst du dir mit folgendem Befehl anzeigen lassen:

```shell
openstack --help
```

---

## Zusätzliche Informationen

### Plugins installieren

Es besteht die Möglichkeit Plugins zu installieren. Dafür fügt man in den nachfolgenden Befehl einfach das entsprechende Plugin ein:

```shell
pip install python-<PLUGINNAME>client
```

Plugins können dann wie folgt installiert werden:

```shell
pip install python-heatclient
```

Benötigte Plugins für den SysEleven Stack:

* heat - Orchestration API

---

### Virtualenv

***Wenn der OpenStack Client bereits erfolgreich installiert wurde, kann dies übersprungen werden.***

[Virtualenv](https://virtualenv.pypa.io) stellt eine virtuelle Umgebung zur Verfügung, um Probleme mit Abhängigkeiten und anderen Programmen zu vermeiden, wenn wir den OpenStack Client installieren.

Installiere `virtualenv` mit folgendem Befehl:

```shell
pip install virtualenv
```

Nun erstelle einen Projektordner z.B. namens `meinprojekt`, in welchem wir eine `virtualenv` erstellen:

```shell
cd meinprojekt/
virtualenv venv
```

Wenn benötigt kann `virtualenv` global installierte Pakete erben (z.B. IPython oder Numpy), benutze folgenden Befehl um dies zu konfigurieren:

```shell
virtualenv venv --system-site-packages
```

Diese Kommandos erstellen einen virtuellen Unterordner im Projektordner in welchem Alles installiert wird. Allerdings muss dieser erst aktiviert werden (in jedem Terminal in welchem an dem Projekt gearbeitet wird):

```shell
source meinprojekt/venv/bin/activate
```

Jetzt sollten wir `(venv)` am Anfang unserer Terminal-Prompts sehen, welches bestätigt, dass wir innerhalb einer `virtualenv` arbeiten.
Wenn wir nun etwas installieren, landen die installierten Programme im Projektordner und verursachen keine Konflikte mit anderen Projekten.

*Um die virtuelle Umgebung zu verlassen benutzen wir:*

```shell
deactivate
```

