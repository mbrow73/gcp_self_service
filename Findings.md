# TCP Malformation Feature Comparison: Palo Alto Zone Protection vs. GCP Front End

This document compares the known features of Palo Alto Zone Protection profiles with our lab findings on the GCP Front End. The focus is on TCP malformation techniques only, including:
- **Syn Flood**
- **Malformed http requests**
- **TCP Split Handshake**
- **TCP Fast Open**
- **NULL TCP**
- **XMAS Scan**

> **Note:**  
> - The Palo Alto Zone Protection capabilities are based on documented features and expected behavior.  
> - The GCP Front End findings are derived from our controlled lab tests.  
> - No Cloud Armor, NGFW, or application layer attacks were performed.

| **TCP Test**            | **Palo Alto Zone Protection (Expected Feature Set)**                                              | **GCP Front End (Lab Findings)**                                                   |
|-------------------------|---------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------|
| **TCP Syn Flood**       | Drops excess tcp syn packets exceeding a certain threshhold.                                      | All tcp syn flood packets were dropped by the load balancer without a log. No packets seen on tcpdump of provider. | ** HTTP malformed requests** | drops illegal http requests if identified as unknown tcp and dropped in zpp.                 | Drops all malformed http requests and logs them in log explorer.
| **TCP Split Handshake** | Drops abnormal handshake attempts; prevents any session establishment with non-standard SYN packets. | Connection attempt is dropped; abnormal handshake is filtered out. No logs shown, does not reach back end      |
| **TCP Fast Open**       | Generally does not support TCP Fast Open; payload in the SYN packet is blocked.                    | TCP Fast Open succeeded; connection established with payload delivered.            |
| **NULL TCP**            | Does not allow vuln scans; packets with no flags are discarded.                    | Connection attempt fails; no port information is enumerated from the back end.           |
| **XMAS Scan**           | Filters out abnormal packets; no port information is enumerated from packets with FIN, PSH, and URG flags.     | Abnormal packets are filtered; no port information is enumerated.                   |

---

## Summary

- **TCP Syn Flood:**
  GCP FE does not forward these requests to the backends because it expects an SSL handshake before forwarding. The syn flood initiated by hping3 did not appear in tcp dump of backend and load balancer remained operational.

- **Malformed http requests:**
  GCP FE dropped and logged multiple malformed requests before they reached the backends. Ex. echo -e "GET / HTTP/1.1\r\nHost: 34.8.184.179\r\nContent-Length: 10\r\nContent-Length: 20\r\n\r\n1234567890" | openssl s_client -connect 34.8.184.179:443 -quiet for multiple content length headers. This was dropped and logged by the GCP FE.

- **TCP Split Handshake:**  
  Both Palo Alto and the GCP Front End drop split handshake attempts before reaching the backends. No logs are produced in gcp but due to the nature of the termination taking place on load balancer, no packets reach the front end.

- **TCP Fast Open:**  
  While Palo Alto is expected to block TCP Fast Open (i.e., not support delivering payloads in the SYN packet), our lab found that the GCP Front End allows TCP Fast Open, establishing a connection and delivering the payload.

- **NULL TCP:**  
  Neither solution supports enumerating port info from a connection using NULL TCP packets; such packets are discarded.

- **XMAS Scan:**  
  Both systems filter out the abnormal packets used in XMAS scans, preventing any valid port enumeration.

---

## Logging findings

- **Threat Logging:**
  When a threat is identified by gcp ngfw and action is taken on that threat; the threat is logged with signature, connection information, action, rule id, etc...
[threat logs documentation](https://cloud.google.com/firewall/docs/threat_logs)

*This comparison highlights the differences and similarities in handling TCP malformation scenarios between a traditional enterprise security solution and the GCP Front End as observed in our lab testing.*
