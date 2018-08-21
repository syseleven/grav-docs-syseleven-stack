---
title: 'Was ist der Unterschied zwischen Local SSD Storage und Distributed Storage?'
published: true
date: '08-08-2018 12:53'
taxonomy:
    category:
        - FAQ
    tag:
        - OpenStack
        - localstorage
        - storage
        - SSD
        - DistributedStorage
---

Auf unserem Distributed Storage werden mehrere Kopien der Datensegmente auf mehrere physische SSDs verteilt, die an unterschiedlichen physischen Servern angeschlossen und durch das Netzwerk verbunden sind. Dadurch können wir generell eine hohe Performance bieten, da Daten auf mehreren SSDs gleichzeitig verarbeitet werden können – jedoch entsteht dadurch eine zusätzliche Latenz für einzelne Operationen, da Daten über das Netzwerk übertragen werden müssen.

Auf unserem Local SSD Storage, werden die Daten auf einem lokalen gespiegelten RAID gespeichert. Die Latenz reduziert sich, denn Daten müssen dafür nicht über das Netzwerk übertragen werden. Verfügbarkeit und Datenbeständigkeit sind jedoch bei diesen Instanztypen reduziert, da die Daten nur lokal auf einem Server vorgehalten werden.