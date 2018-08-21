---
title: 'Mein Stack lässt sich nicht mehr löschen! Was kann ich tun?'
published: true
date: '08-08-2018 13:08'
taxonomy:
    category:
        - FAQ
    tag:
        - OpenStack
        - Stack
        - Heat
        - Delete
        - Dependencies
---

Ein Heat-Stack folgt beim Aufbau Abhängigkeiten, die Objekte untereinander in eine bestimmte Reihenfolge bringen. Die Dependencies werden beim Rückbau eines Stack ebenfalls berücksichtigt, so dass man ein Fehlschlagen des Löschens damit umgehen kann. Ist ein Stack ohne Angabe der Dependencies aufgebaut, schlägt das Löschen gerne mit einer Fehlermeldung wie dieser Fehl:

```
Resource DELETE failed: Conflict: resources.router_subnet_connect: Router interface for subnet eaa5a91f-3f45-43cf-8714-95118aabc64c on router 487a984c-692c-4d45-80d2-2e0ee92b505d cannot be deleted, as it is required by one or more floating IPs. 
```

In diesem Fall ist die saubere Lösung, die Abhängigkeiten von Hand zu löschen. Also erst die Floating-IP, die an dem Router hängt, dann den Router selbst und danach den ganzen Stack. Oft reicht es auch, den ``heat stack-delete <stackName>`` mehrfach aufzurufen.
Die Angabe im Heat-Template ``depends_on: <myOtherResourceID>`` vermeidet diese Probleme.