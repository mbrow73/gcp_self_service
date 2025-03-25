# TCP Malformation Feature Comparison: Palo Alto Zone Protection vs. GCP Front End

This document compares the known features of Palo Alto Zone Protection profiles with our lab findings on the GCP Front End. The focus is on TCP malformation techniques only, including:

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
| **TCP Syn Flood**       | Drops excess tcp syn packets exceeding a certain threshhold.                                      | All tcp syn flood packets were dropped by the load balancer without a log. No packets seen on tcpdump of provider. |
| **TCP Split Handshake** | Drops abnormal handshake attempts; prevents any session establishment with non-standard SYN packets. | Connection attempt is dropped; abnormal handshake is filtered out.                 |
| **TCP Fast Open**       | Generally does not support TCP Fast Open; payload in the SYN packet is blocked.                    | TCP Fast Open succeeded; connection established with payload delivered.            |
| **NULL TCP**            | Does not allow connection establishment; packets with no flags are discarded.                    | Connection attempt fails; no session is established with NULL TCP packets.           |
| **XMAS Scan**           | Filters out abnormal packets; no session is created from packets with FIN, PSH, and URG flags.     | Abnormal packets are filtered; no valid connection is established.                   |

---

## Summary

- **TCP Split Handshake:**  
  Both Palo Alto and the GCP Front End drop split handshake attempts, ensuring that abnormal connection initiations are blocked.

- **TCP Fast Open:**  
  While Palo Alto is expected to block TCP Fast Open (i.e., not support delivering payloads in the SYN packet), our lab found that the GCP Front End allows TCP Fast Open, establishing a connection and delivering the payload.

- **NULL TCP:**  
  Neither solution supports establishing a connection using NULL TCP packets; such packets are discarded.

- **XMAS Scan:**  
  Both systems filter out the abnormal packets used in XMAS scans, preventing any valid TCP session from forming.

---

*This comparison highlights the differences and similarities in handling TCP malformation scenarios between a traditional enterprise security solution and the GCP Front End as observed in our lab testing.*
