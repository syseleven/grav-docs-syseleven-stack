---
title: 'Netzwerk Dienst'
published: true
date: '08-08-2018 11:08'
taxonomy:
    category:
        - docs
---

## Übersicht

SysEleven Stacks Networking Service basiert auf dem OpenStack Neutron Projekt.

Damit kannst du Network-Connectivity-as-a-Service für andere Dienste im SysEleven Stack nutzen, wie zum Beispiel den Compute Service.
Außerdem stellt es Benutzern eine API zur Verfügung um Netzwerke zu definieren und um bestehende anzupassen.

Du hast zwei Möglichkeiten dein Netzwerk zu verwalten. Du kannst dafür die öffentliche OpenStack API benutzen, genau so wie das [Dashboard](https://dashboard.cloud.syseleven.net).

---

## Fragen & Antworten

### Wie kann ich den LBaaS nutzen?

Wir haben ein Tutorial zur [Nutzung des LBaaS](/syseleven-stack/tutorials/lbaas/) vorbereitet.

### Kann auf die originale Client-IP aus den Systemen hinter dem LBaaS zugegriffen werden?

Nein, aktuell ist dies leider nicht möglich. Die IP des Lastverteilers wird als Ausgangsadresse angezeigt.

### Welche Funktionen bietet der SysEleven Stack LBaaS?

Der SysEleven Stack LBaaS ist ein einfacher TCP-basierter LastVerteiler. Er verteilt Anfragen nach dem Round-Robin Prinzip (der Reihe nach).
Ebenfalls ist ein einfacher Health-Check nutzbar.