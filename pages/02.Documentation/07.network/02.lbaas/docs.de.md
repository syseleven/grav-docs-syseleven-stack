---
title: 'LoadBalancer as a Service (LBaaS)'
published: true
date: '2019-02-19 17:30'
taxonomy:
    category:
        - docs
---

## Übersicht

Der SysEleven Stack LBaaS ist ein einfacher TCP-basierter Lastverteiler. Er verteilt Anfragen nach dem Round-Robin Prinzip (der Reihe nach).
Ebenfalls ist ein einfacher Health-Check nutzbar.

Leider kann die Client-IP zur Zeit nicht an die Systeme hinter dem LoadBalancer durchgereicht werden. Die IP des Lastverteilers wird als Ausgangsadresse angezeigt.

Wir haben ein Tutorial zur [Nutzung des LBaaS](../../../03.Tutorials/07.lbaas/docs.en.md) vorbereitet.

!!! **Verfügbarkeit**
!!! Die Funktionalität des LBaaS ist derzeit nur in der Region 'dbl' verfügbar. Sie wird demnächst auch in der Region 'cbk' bereitgestellt.

---

## Fragen & Antworten

### Welche Funktionen bietet der SysEleven Stack LBaaS?

Der SysEleven Stack LBaaS ist ein einfacher TCP-basierter LastVerteiler. Er verteilt Anfragen nach dem Round-Robin Prinzip (der Reihe nach).
Ebenfalls ist ein einfacher Health-Check nutzbar.

### Kann auf die originale Client-IP aus den Systemen hinter dem LBaaS zugegriffen werden?

Nein, aktuell ist dies leider nicht möglich. Die IP des Lastverteilers wird als Ausgangsadresse angezeigt.

### Wie kann ich den LBaaS nutzen?

Wir haben ein Tutorial zur [Nutzung des LBaaS](../../../03.Tutorials/07.lbaas/docs.en.md) vorbereitet.
