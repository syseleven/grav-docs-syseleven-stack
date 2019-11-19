---
title: 'LoadBalancer as a Service (LBaaS)'
published: true
date: '2019-02-28 17:30'
taxonomy:
    category:
        - docs
---

## Übersicht

Der SysEleven Stack LBaaS ist ein einfacher TCP-basierter Lastverteiler, der Anfragen nach dem Round-Robin Prinzip (der Reihe nach) verteilt.
Optional können Sie auch eine Systemüberwachung (Health Monitoring) einrichten.

Leider kann die Client-IP zur Zeit nicht an die Systeme hinter dem LoadBalancer durchgereicht werden. Die IP-Adresse des Lastverteilers wird als Ausgangsadresse angezeigt.

Wir haben ein Tutorial zur [Nutzung des LBaaS](../../../02.Tutorials/05.lbaas/docs.en.md) vorbereitet.

---

## Fragen & Antworten

### Welche Funktionen bietet der SysEleven Stack LBaaS?

Der SysEleven Stack LBaaS ist ein einfacher TCP-basierter Lastverteiler, der Anfragen nach dem Round-Robin Prinzip (der Reihe nach) verteilt.
Optional können Sie auch eine Systemüberwachung (Health Monitoring) einrichten.
Folgende Modi werden unterstützt:

- Listener-Protokoll: TCP
- Pool-Protokoll: TCP
- Verteilungsstrategie: ROUND_ROBIN
- Health-Monitoring-Protokolle: TCP, HTTP, HTTPS

### Kann auf die originale Client-IP aus den Systemen hinter dem LBaaS zugegriffen werden?

Nein, aktuell ist dies leider nicht möglich. Die IP-Adresse des Lastverteilers wird als Ausgangsadresse angezeigt.

### Wie kann ich den LBaaS nutzen?

Wir haben ein Tutorial zur [Nutzung des LBaaS](../../../02.Tutorials/05.lbaas/docs.en.md) vorbereitet.
