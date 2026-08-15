# Firewall Fundamentals — Notes

## 1. Core Definition
A firewall **controls traffic between zones** by inspecting it against rules (IP, port, protocol, and in NGFWs — application, user, content) and deciding **allow or deny**.

---

## 2. Zones — The Basic Model

| Zone | Trust Level | Contains | Internet Access |
|---|---|---|---|
| **Trust** | Fully protected | Laptops, internal apps, internal DBs | Never reachable from internet |
| **DMZ** | Semi-protected | Public web server, mail server, public DNS | Reachable, but tightly controlled |
| **Untrust** | Hostile (assumed) | The internet | N/A — this *is* the threat |

**Traffic rules between zones:**
- Internet → DMZ: allowed (controlled, specific ports only)
- Internet → Trust: blocked
- DMZ → Trust: tightly restricted / blocked
- Trust → DMZ: usually allowed (admins manage DMZ servers)

**Key point:** A zone is just a *label/grouping*. It's the **firewall policy** attached to it that actually enforces protection — no zone is safe by default.

### DMZ (Demilitarized Zone) — origin of the name
Borrowed from military term (e.g., Korean DMZ) — a buffer strip between two hostile powers where neither side has full control. In networking: a buffer zone between trusted internal network and the hostile internet, holding things that must be public but are isolated from the true internal network.

### Real-world example — EC2
- EC2 instance with public IP = DMZ-style public-facing resource
- Security Group locking access to your laptop's IP only = firewall policy controlling that DMZ resource
- A private subnet DB with no public IP = trust zone equivalent

---

## 3. Firewall vs. DMZ
- **DMZ** = a place (network zone)
- **Firewall** = the enforcer (device that allows/denies traffic between zones)

Typical setup: one firewall, multiple interfaces, each interface tied to a zone (untrust/DMZ/trust). Real deployments often have 5–10+ zones (guest WiFi, IoT, partner VPN, etc.), not just 3.

---

## 4. Access Control Examples

**Geo-blocking** — allow/deny based on source IP's country (e.g., only allow India). Bypassable via VPN — not airtight, but reduces attack surface.

**IP whitelisting** — allow only specific, named IPs (e.g., bank branch offices). Stricter than geo-blocking. Requires static public IPs at allowed locations.

**Layered defense (common real pattern):** Geo-block + IP whitelist + VPN + MFA — stacked together since no single control is bulletproof.

---

## 5. Stateless vs. Stateful Firewalls

| | Stateless | Stateful |
|---|---|---|
| Memory of past traffic | None — every packet checked fresh | Tracks active sessions in a **state table** |
| Rules needed | Explicit rules in **both directions** | Only need to approve the initial request; replies auto-matched |
| Example | Router ACLs, AWS NACLs | Palo Alto, FortiGate, ASA, AWS Security Groups |
| Unsolicited inbound traffic | Needs explicit deny rules | Dropped by default (no matching session entry) |

**Trade-off:** Stateful is smarter/more secure but costs memory/CPU to maintain the state table (an in-memory hash table, not a database like Postgres/Redis — built for microsecond, line-rate lookups). Vulnerable to state-table exhaustion attacks (e.g., SYN floods).

**On reboot:** State table lives in RAM only — wiped on reboot/failure, rebuilt from scratch as new traffic flows. This is why **HA (High Availability) pairs** exist — two firewalls, sometimes with real-time session-table sync, so failover doesn't drop active connections. (Real PCNSE topic.)

---

## 6. OSI Layers in Firewall Context

| Layer | Checks | Analogy |
|---|---|---|
| **L3** (Network) | Source/destination **IP** | Which building |
| **L4** (Transport) | **Port** + protocol (TCP/UDP) | Which door/floor |
| **L7** (Application) | Actual application/content in the payload | What's inside the delivery bag |

Traditional firewalls (ACLs, classic ASA) = L3/L4 only → see "port 443" and assume HTTPS, can't verify.

---

## 7. NGFW (Next-Gen Firewall)
**Correction to a common misconception:** NGFW is **not** just L7 — it's **L3/L4 + L7 combined**, plus:
- **App-ID** — identifies actual application regardless of port
- **User-ID** — ties traffic to a logged-in identity, not just an IP
- **Threat Prevention** — malware/exploit/intrusion inspection
- **URL Filtering** — categorize/block sites
- **SSL Decryption** — needed so L7 inspection isn't blind to encrypted traffic

---

## 8. Network Firewall vs. Host-Based Firewall

| | Network Firewall | Host-Based Firewall |
|---|---|---|
| Examples | Palo Alto, FortiGate, ASA | Windows Firewall, iptables/ufw, macOS firewall |
| Lives | Dedicated hardware/VM at network boundary | Inside the OS of one device |
| Protects | Entire segment/all devices behind it | Just that one device |

**Defense in depth:** Both are needed — network firewall protects the perimeter, host firewall stops lateral spread if one device inside the trust zone gets compromised.

---

## 9. Network Segmentation

**Purpose:** Split a flat network into isolated segments to limit **lateral movement** if one device/segment is compromised (blast radius containment).

**Implementation building blocks:**
1. **VLANs** — logically separate devices even on the same physical switch
2. **Firewall zones + policies** — enforce which VLANs/segments can talk to which
3. **Subnetting** — one VLAN = one subnet = one zone typically
4. **Micro-segmentation** — granular, workload-level rules (e.g., only web server → DB on port 5432), common in cloud/Zero Trust (Palo Alto Prisma Cloud)
5. **Zero Trust philosophy** — no device/user trusted by default, even within the same segment; every connection explicitly verified

**Example — environment segmentation (DEV/UAT/PROD):**
- Prevents accidental cross-environment access (e.g., script accidentally hitting PROD)
- Different trust/risk levels per environment — PROD gets strictest rules
- Often a **compliance requirement** (e.g., PCI-DSS)
- Isolation is typically **bidirectional** — PROD also shouldn't reach down into UAT/DEV (limits pivot if PROD is compromised)

---

## 10. Palo Alto Terminology Map (for reference)

| Term | What it is |
|---|---|
| **PAN-OS** | The OS running on Palo Alto firewalls (physical or virtual) |
| **Panorama** | Centralized management for multiple PAN-OS firewalls |
| **PCNSE** | Certification exam validating PAN-OS + Panorama knowledge |
| **PA-series** | Physical firewall appliances |
| **VM-series** | Virtual/software firewall (on-prem hypervisor or cloud — AWS/Azure/GCP) |
| **CN-series** | Container-specific variant |

---

## Analogy Used Throughout (Building Watchman)
- **Watchman** = Firewall
- **Residents** = Trust zone traffic (recognized, freely allowed)
- **Swiggy/Zomato delivery, stopped at collection point** = DMZ traffic (legitimate but restricted, not given full access)
- **Random stranger** = Untrust/blocked traffic
- **Watchman logging entry/timing** = Firewall logging (allow/deny records)
- **Watchman remembering you just left, so return is expected** = Stateful behavior
- **Watchman re-checking everyone from scratch every time** = Stateless behavior
- **Segmentation:** even among residents, floor-based access restrictions; guests only in visitor lounge, delivery only in lobby
