---
title: 'Load Balancer as a Service (LBaaS)'
published: true
date: '2019-02-28 17:30'
taxonomy:
    category:
        - docs
---

## Übersicht

Der SysEleven Stack bietet Load-Balancer-as-a-Service (LBaaS)
über zwei verschiedene Generationen von APIs an:
Neutron LBaaSv2 (veraltete API) und Octavia (aktuelle API).

Aus Sicht der API-Definition verhalten sich beide Dienste ähnlich.
Allerdings unterscheiden sich die vom SysEleven Stack untertützten Funktionen.
In der Neutron-Variante sind nur einfache TCP-basierte Lastverteiler möglich,
über Octavia auch HTTP und HTTPS.
Für beide Typen können sie optional auch eine Systemüberwachung (Health Monitoring) einrichten.

Die Client-IP kann nur bei Octavia-Load-Balancern an die Systeme hinter dem LoadBalancer durchgereicht werden.
Bei Neutron-Load-Balancern wird immer nur die IP-Adresse des Lastverteilers als Ausgangsadresse angezeigt.

---

## Fragen & Antworten

### Welche Funktionen bietet der SysEleven Stack LBaaS?

Die folgende Tabelle stellt die verfügbaren Funktionen der beiden LBaaS-Dienste
gegenüber:

Funktion             | Neutron LBaaSv2 | Octavia LBaaS
---------------------|-----------------|--------------
Listener-Protokolle  | TCP             | TCP, HTTP, HTTPS
Pool-Protokolle      | TCP             | TCP, HTTP, HTTPS
Verteilungsstrategie | ROUND_ROBIN     | ROUND_ROBIN
Health-Monitoring-Protokolle | TCP, HTTP, HTTPS | TCP, HTTP, HTTPS
Originale Client-IP auf den Backend-Servern sichtbar? | nein | ja
Verfügbar im Dashboard | ja | nein (geplant)

### Wie kann ich den LBaaS nutzen?

Wir haben ein Tutorial zur [Nutzung des LBaaS](../../../02.Tutorials/05.lbaas/docs.en.md) vorbereitet.
