---
title: 'Lokaler SSD Speicher'
published: true
date: '08-08-2018 10:50'
taxonomy:
    category:
        - docs
---

## Übersicht

Der SysEleven Stack bietet zwei Arten (flavors) von Ephemeral Storage. Der Standard-Speicher ist ein Distributed Storage und basiert auf Quobyte. Er bietet hohen Datendurchsatz, Redundanz und Skalierbarkeit um den Preis einer Netzwerklatenz. Für bestimmte Lastprofile, bei denen diese Latenz einen Flaschenhals darstellt, bieten wir alternativ Local SSD Storage an.

---

## Fragen & Antworten

### Wo finde ich eine Liste der verfügbaren Local SSD Storage Instanztypen?

Eine Übersicht befindet sich [hier](../../04.Reference/02.compute/docs.de.md).

### Wie benutze ich Local SSD Storage?

Für einen schnellen Start zum ausprobieren oder herumspielen lesen Sie bitte unser [Tutorial](../../02.Tutorials/08.local-storage/docs.de.md).

### Wann sollte ich Local SSD Storage besser nicht einsetzen?

Traditionelle Einzelserver leiden oft unter Performance-Einbußen, wenn sie mit Distributed Storage betrieben werden. Es mag sehr verlockend klingen, sie mit Local SSD Storage zu bauen, um Geschwindigkeit zurückzugewinnen, aber wir raten aufgrund der geringeren Redundanz und Verfügbarkeit dringend davon ab. Um es einfach auszudrücken, setzen Sie Ihren Dienst und Ihre Daten aufs Spiel, wenn sie einen Einzelserver mit lokalem SSD-Speicher betreiben.

### Was muß ich beachten, damit ein Setup für Local SSD Storage geeignet ist?

Abhängig vom Anwendungszweck gibt es bewährte Mittel, ein Setup oder eine Applikation so zu entwerfen, daß die fehlende Redundanz ausgeglichen wird. Anwendungsserver können verfielfacht und hinter einen LoadBalancer betrieben werden, Datenbanken können in Replikations-Topologien oder als Cluster aufgebaut werden. Wir versuchen, Anregungen dafür in unseren [Heat-Teamplates](https://github.com/syseleven/heat-examples) zur Verfügung zu stellen, sprechen Sie uns an, wenn sie weitere Unterstützung benötigen.

### Kann lokaler SSD Speicher für Volumes verwendet werden?

Nein. lokaler SSD Speicher ist ausschließlich für Ephemeral Storage verfügbar.

### Kann Local SSD Storage mit Distributed Storage kombiniert werden?

Ja. Volumes mit Distributes Storages können an die Instanz angeschlossen werden und das kann sehr nützlich sein, um sie initial mit Daten zu bestücken oder Backups anzufertigen, bei denen die Latenz nicht so ein Problem darstellt, wie beim laufenden Dienst.

### Kann ich Local SSD Storage durch ein Volume ersetzen?

Ja, aber das ergibt selten Sinn, denn sie nutzt ja dann den Local SSD Storage nicht mehr. Es kann aber in bestimmten Fällen hilfreich sein, um Dinge einzurichten oder zu reparieren, siehe auch unsere Anleitung zur [Datenrettung](../../03.Howtos/05.nova-rescue-mode/docs.de.md).

### Kann ich Local SSD Storage in anderen Größen erhalten?

Nein. Local SSD Storage ist ausschließlich in den angegebenen [Flavors](../../04.Reference/02.compute/docs.de.md) erhältlich.

### Kann ich die Größe von Local SSD Storage ändern?

Nein. Local SSD Storage kann nicht umgewandelt werden, sie müssen in der gewünschten Größe neu erstellt und die Daten migriert werden.
Man kann allerdings ein Volume anschließen, die Daten hinaufschieben, das Volume dann an eine andere Instanz anschließen und die Daten auf deren Local SSD Storage bewegen.
Abhängig von der Anwendung gibt es jedoch wahrscheinlich klügere Wege, um neue Systeme in den Verbund aufzunehmen, z.B. Datenbank-Slaves zu fördern.

### Was passiert im Fall einer Hardware-Störung?

Local SSD Storage Instanzen können nicht zwischen Hardware-Servern migriert werden. Das bedeutet, daß alle Instanzen eines betroffenen Servers ebenfalls von **unvermeidlichem Ausfall oder Datenverlust** betroffen sind.
Sie müssen darauf vorbereitet sein, eine Local SSD Storage Instanz durch eine neue zu ersetzen, deren Daten sie aus einem Backup oder den überlebenden Mitgliedern des Clusters wiederherstellen.

### Was passiert im Fall einer Hardware-Wartung?

Obwohl Local SSD Storage Instanzen nicht (live) migriert werden können, müssen wir regelmäßig Wartungen durchführen, um die Software aktuell zu halten. Dies **betrifft unausweichlich auch alle Local SSD Storage Gastsysteme eines Servers**.

### Wann ist das Hardware-Wartungsfenster für local SSD Storage Nodes?

Um die Auswirkungen vorhersehbar zu gestalten, kündigen wir hiermit ein Wartungsfenster an:

> Jede Woche in der Nacht von Mittwoch, 23 Uhr bis Donnerstag, 4 Uhr,

werden wir ca. 25% unserer Local SSD Storage Server warten. Statistisch gesehen wird jede Instanz

> einmal im Monat heruntergefahren.

### Wie läuft eine Hardware-Wartung für local SSD storage nodes ab?

Betroffene Instanzen erhalten zunächst ein ACPI Shutdown Signal und eine Frist von einer Minute, um sich ordentlich herunterzufahren. Rechnen sie mit bis zu einer halben Stunde Ausfallzeit, bevor die Instanzen wieder hochgefahren werden. Es sind neben dem ACPI Shutdown Event

> keine weiteren Ankündigungen vorgesehen.

### Wieviele Instanzen sind gleichzeitig von Hardware-Wartungen der local SSD storage nodes betroffen?

Geplante Hardware-Wartungen betreffen immer nur einen Hardware-Server zu einer Zeit und zwischen zwei Hardware-Wartungen wird eine halbe Stunde gewartet, damit die betroffenen Instanzen sich wieder in ihren Cluster oder Wasauchimmer integrieren können. Es werden jedoch alle Local SSD Storage Instanzen auf der selben Serverhardware gleichzeitig vom Ausfall betroffen sein. Damit redundante System nicht gleichzeitig ausfallen, müssen sie diese unbedingt in eine [anti-affinity-groups](../../02.Tutorials/07.affinity/docs.de.md) aufnehmen.
