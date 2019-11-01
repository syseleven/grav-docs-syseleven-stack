---
title: 'REST API für Quota-Informationen'
date: '01-11-2019 12:00'
taxonomy:
    category:
        - docs
---

# REST API zur Abfrage von Quota-Informationen
Für die meisten Ressourcen-Typen wie z.B. Instanzen, VCPUs, Volume-Speicher
können Sie die Limits und die aktuelle Auslastung über das Dashboard (Horizon)
einsehen oder die OpenStack APIs nutzen, um die Informationen automatisiert
abzufragen. Die Informationen über die Quota von Object-Storage (S3) sind 
allerdings nicht über diese Standard-APIs verfügbar.

Für Quota- und Ausnutzungsinformationen einschließlich Object-Storage bietet
der SysEleven Stack eine eigene REST API an.

## Voraussetzungen

Für Anfragen an die Quota-API benötigen Sie ein OpenStack-Keystone-Token.
Wenn Sie den OpenStack-Kommandozeilen-Client installiert haben, können Sie
sich ein Token mit dem Kommando `openstack token issue` erzeugen.

```
openstack token issue
+------------+----------------------------------+
| Field      | Value                            |
+------------+----------------------------------+
| expires    | 2019-11-02T06:43:11+0000         |
| id         | 01234567890abcdef01234567890abcd |
| project_id | 11111111111111111111111111111111 |
| user_id    | 22222222222222222222222222222222 |
+------------+----------------------------------+
```
Das so erzeugte Token ("id"-Zeile in der Tabelle) geben Sie dann im `X-Auth-Token` der REST-API-Requests an.

## Quota abfrufen

### URL

GET https://api.cloud.syseleven.net:5001/v1/projects/{project_id}/quota

### Anfrage-Parameter

Name        | Wo übergeben | Beschreibung |
------------|--------------|--------------|
project_id  | URL-Pfad     | Die OpenStack Project-ID. Es muss die gleiche sein, für die das Token erstellt wurde. |
X-Auth-Token | Header | Das Token zur Authorisierung der Anfrage. |
regions      | URL-Parameter | Optionale Beschränkung der Abfrage auf bestimmte Regionen. Komma-separierte Liste von Regionsnamen. Ist keine Region angegeben, werden Daten über alle Regionen geliefert. |

Beispiel

- Token "01234567890abcdef01234567890abcd"
- Project-ID "11111111111111111111111111111111"
- Regionen cbk und dbl

```
curl -H 'X-Auth-Token: 01234567890abcdef01234567890abcd' https://api.cloud.syseleven.net:5001/v1/projects/11111111111111111111111111111111/quota?regions=cbk,dbl
```

### Antwort

Die Antwort beinhaltet die Quota-Informationen in JSON-Format. Zum Beispiel bei einer Anfrage für die Regionen cbk und dbl:
```
{
  "cbk": {
    "compute.cores": 50,
    "compute.instances": 50,
    "compute.ram_mb": 204800,
    "dns.zones": 10,
    "network.floatingips": 50,
    "network.lb_healthmonitors": 1024,
    "network.lb_listeners": 1024,
    "network.lb_members": 128,
    "network.lb_pools": 128,
    "network.loadbalancers": 1024,
    "network.vpn_endpoint_groups": -1,
    "network.vpn_ikepolicies": -1,
    "network.vpn_ipsec_site_connections": -1,
    "network.vpn_ipsecpolicies": -1,
    "network.vpn_services": -1,
    "s3.space_bytes": 4294967296,
    "volume.space_gb": 1000,
    "volume.volumes": 1024
  },
  "dbl": {
    "compute.cores": 60,
    "compute.instances": 60,
    "compute.ram_mb": 245760,
    "dns.zones": 10,
    "network.floatingips": 50,
    "network.lb_healthmonitors": 1024,
    "network.lb_listeners": 1024,
    "network.lb_members": 1024,
    "network.lb_pools": 1024,
    "network.loadbalancers": 1024,
    "network.vpn_endpoint_groups": -1,
    "network.vpn_ikepolicies": -1,
    "network.vpn_ipsec_site_connections": -1,
    "network.vpn_ipsecpolicies": -1,
    "network.vpn_services": -1,
    "s3.space_bytes": -1,
    "volume.space_gb": 1000,
    "volume.volumes": 1024
  }
}
```
Übersicht über die einzelnen Elemente:

Name | Beschreibung
-----|---------|-------------
compute.cores | Anzahl der virtuellen Cores |
compute.instances | Anzahl der virtuellen Maschinen (Server, Instanzen) |
compute.ram_mb | RAM für virtuelle Maschinen in MB |
dns.zones | Anzahl der DNS-Zonen |
network.floatingips | Anzahl der Floating IP-Adressen |
network.lb_healthmonitors | Anzahl der LBaaS Health-Monitors |
network.lb_listeners | Anzahl der LBaaS Listener |
network.lb_members | Anzahl der LBaaS Pool Member |
network.lb_pools | Anzahl der LBaaS Pools |
network.loadbalancers | Anzahl der LBaaS Load Balancer |
network.vpn_endpoint_groups | Anzahl der VPNaaS Endpunktgruppen |
network.vpn_ikepolicy | Anzahl der VPNaaS IKE Policies |
network.vpn_ipsec_site_connections | Anzahl der VPNaaS Site Connections |
network.vpn_ipsecpolicies | Anzahl der VPNaaS IPSec Policies |
network.vpn_services | Anzahl der VPNaaS VPN-Dienste |
s3.space_bytes | Limit des Object Storage (S3) Speichers in Bytes |
volume.space_gb | Limit des Block Storage Speichers (für Volumes) in GB |
volume.volumes | Anzahl der Block Storage Volumes |

Ein Limit-Wert von -1 bedeutet "unbeschränkt", 0 bedeutet "keine Ressourcen".

## Aktuelle Ausnutzung abfrufen

### URL

GET https://api.cloud.syseleven.net:5001/v1/projects/{project_id}/current_usage

### Anfrage-Parameter

Name        | Wo übergeben | Beschreibung |
------------|--------------|--------------|
project_id  | URL-Pfad     | Die OpenStack Project-ID. Es muss die gleiche sein, für die das Token erstellt wurde. |
X-Auth-Token | Header | Das Token zur Authorisierung der Anfrage. |
regions      | URL-Parameter | Optionale Beschränkung der Abfrage auf bestimmte Regionen. Komma-separierte Liste von Regionsnamen. Ist keine Region angegeben, werden Daten über alle Regionen geliefert. |

Beispiel

- Token "01234567890abcdef01234567890abcd"
- Project-ID "11111111111111111111111111111111"
- Regionen cbk und dbl

```
curl -H 'X-Auth-Token: 01234567890abcdef01234567890abcd' https://api.cloud.syseleven.net:5001/v1/projects/11111111111111111111111111111111/current_usage?regions=cbk,dbl
```

### Antwort
Die Antwort beinhaltet die Informationen über aktuell verwendete Ressourcen in JSON-Format. Zum Beispiel bei einer Anfrage für die Regionen cbk und dbl:

```
{
  "cbk": {
    "compute.cores": 3,
    "compute.flavors": {
      "m1.micro": 3
    },
    "compute.instances": 3,
    "compute.ram_mb": 6144,
    "dns.zones": 2,
    "network.floatingips": 4,
    "network.lb_healthmonitors": 0,
    "network.lb_listeners": 0,
    "network.lb_members": 0,
    "network.lb_pools": 0,
    "network.loadbalancers": 0,
    "network.vpn_endpoint_groups": 0,
    "network.vpn_ikepolicies": 1,
    "network.vpn_ipsec_site_connections": 1,
    "network.vpn_ipsecpolicies": 1,
    "network.vpn_services": 1,
    "s3.space_bytes": 48,
    "volume.space_gb": 6,
    "volume.volumes": 4
  },
  "dbl": {
    "compute.cores": 50,
    "compute.flavors": {
      "m1.medium": 5,
      "m1.small": 3,
      "m1.xxlarge": 1
    },
    "compute.instances": 9,
    "compute.ram_mb": 204800,
    "dns.zones": 2,
    "network.floatingips": 10,
    "network.lb_healthmonitors": 0,
    "network.lb_listeners": 0,
    "network.lb_members": 0,
    "network.lb_pools": 0,
    "network.loadbalancers": 0,
    "network.vpn_endpoint_groups": 0,
    "network.vpn_ikepolicies": 1,
    "network.vpn_ipsec_site_connections": 1,
    "network.vpn_ipsecpolicies": 1,
    "network.vpn_services": 1,
    "s3.space_bytes": 12,
    "volume.space_gb": 133,
    "volume.volumes": 7
  }
}
```

Name | Beschreibung
-----|---------|-------------
compute.cores | Anzahl der virtuellen Cores |
compute.flavors | Anzahl der virtuellen Maschinen pro Flavor |
compute.instances | Gesamtzahl der virtuellen Maschinen |
compute.ram_mb | RAM aktuell laufender virtueller Maschinen in MB |
dns.zones | Anzahl der DNS-Zonen |
network.floatingips | Anzahl der Floating IP-Adressen |
network.lb_healthmonitors | Anzahl der LBaaS Health-Monitors |
network.lb_listeners | Anzahl der LBaaS Listener |
network.lb_members | Anzahl der LBaaS Pool Member |
network.lb_pools | Anzahl der LBaaS Pools |
network.loadbalancers | Anzahl der LBaaS Load Balancer |
network.vpn_endpoint_groups | Anzahl der VPNaaS Endpunktgruppen |
network.vpn_ikepolicy | Anzahl der VPNaaS IKE Policies |
network.vpn_ipsec_site_connections | Anzahl der VPNaaS Site Connections |
network.vpn_ipsecpolicies | Anzahl der VPNaaS IPSec Policies |
network.vpn_services | Anzahl der VPNaaS VPN-Dienste |
s3.space_bytes | Aktuell belegter Speicher im Object Storage (S3) in Bytes |
volume.space_gb | Aktuell belegter Speicher im Block Storage (Volumes) in GB |
volume.volumes | Anzahl der Block Storage Volumes |
