---
title: 'Wann sollte ich Local SSD Storage besser nicht einsetzen?'
published: true
date: '08-08-2018 12:16'
taxonomy:
    category:
        - FAQ
    tag:
        - OpenStack
        - localstorage
        - SSD
---

Traditionelle Einzelserver leiden oft unter Performance-Einbußen, wenn sie mit Distributed Storage betrieben werden. Es mag sehr verlockend klingen, sie mit Local SSD Storage zu bauen, um Geschwindigkeit zurückzugewinnen, aber wir raten aufgrund der geringeren Redundanz und Verfügbarkeit dringend davon ab. Um es einfach auszudrücken, setzen Sie Ihren Dienst und Ihre Daten aufs Spiel, wenn sie einen Einzelserver mit lokalem SSD-Speicher betreiben.