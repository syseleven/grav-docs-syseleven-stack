---
title: 'Kann ich die Größe von Local SSD Storage ändern?'
published: true
date: '08-08-2018 12:35'
taxonomy:
    category:
        - FAQ
    tag:
        - migration
        - OpenStack
        - flavor
        - localstorage
        - storage
        - SSD
        - Size
        - Resize
---

Nein. Local SSD Storage kann nicht umgewandelt werden, sie müssen in der gewünschten Größe neu erstellt und die Daten migriert werden. 

Man kann allerdings ein Volume anschließen, die Daten hinaufschieben, das Volume dann an eine andere Instanz anschließen und die Daten auf deren Local SSD Storage bewegen. 

Abhängig von der Anwendung gibt es jedoch wahrscheinlich klügere Wege, um neue Systeme in den Verbund aufzunehmen, z.B. Datenbankslaves zu promoten.