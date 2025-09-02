## Network Infrastructure Overview

This document explains the network design that supports my DNS server and provides the foundation for future services.
</br>


### 1. Core Components


- ISP Modem/Router | WAN Gateway | Provides internet access & Wi-Fi for clients. 

- Cisco Catalyst Switch | Wired Core | Connects wired devices, VLAN/QoS capable. 
- Debian ThinkCentre Server | DNS Server | Hosts Pi-hole + Unbound and DNS workflow scripts. Storage for future expansion. 
- External Hard Drives | Storage. 

---

### 2. Switch Configuration Highlights

The Cisco switch brings enterprise practices into the home lab environment.

- SSH Access for secure management.
- Security Technologies Port security, DAI, and DHCP Snooping. 
= Syslog Logging for events and port changes.
- QoS Ready for traffic prioritization (useful for future media server/VoIP).
- VLAN Segmentation for isolating Work, Study, Leisure, and Media traffic.
- SNMP for monitoring the network.


Wireless clients connect through the ISP router, and use the DNS server w/ baseline profile as their resolver.

---

## 4. DNS Server Integration

- Pi-hole + Unbound provide:
  - Recursive DNS (privacy + resilience)
  - Ad/tracker blocking
  - Workflow profiles for Study, Work, Leisure
- Config files are stored in [`configs/`](../configs/).

---

## 5. Future Expansion

- **Media Server**
A media server (Plex/Jellyfin) may be integrated into the network, supported by QoS and VLAN separation.
  
- **iPhone 4 Network Dashboard** (yes really) - periodically scans the network for active devices, logs device status over time, and displays the results on a lightweight dashboard

---

