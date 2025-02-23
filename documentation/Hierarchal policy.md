# Proposal: Hierarchical Firewall Rules for GCP to Optimize Terraform Management

## Overview
This document proposes a centralized hierarchical firewall architecture for GCP to replace the existing model of managing thousands of project-level default deny firewall rules. The new design leverages **folder-level firewall policies** to reduce Terraform workspace apply times, and eliminate "rule already exists" errors.

---

## Problem Statement
- **Performance Issues**: Applying rules across thousands of projects causes 40+ minute apply times.
- **State Conflicts**: Frequent "rule already exists" errors due to overlapping project-level rules.
---

## Proposed Solution
Implement **hierarchical firewall policies** at the folder level to:
1. Define default-deny ingress/egress rules globally.
2. Allow only approved traffic via centralized policies.
3. Delegate specific exceptions to local VPC firewall rules.

### Architecture Diagram
graph TD
    %% Folder Structure
    subgraph Folder["GCP Folder (Hierarchy)"]
        direction TB
        Policy["Firewall Policy: Default Deny<br/>Priority: 1-999"]
        
        %% Ingress Rules
        Policy --> Ingress["Allow Ingress:<br/>✅ 172.16.0.0/12<br/>✅ 192.168.0.0/16<br/>✅ 35.235.240.0/20 (IAP)"]
        
        %% Egress Rules
        Policy --> Egress["Allow Egress:<br/>✅ 172.16.0.0/12<br/>✅ 192.168.0.0/16"]
    end

    %% Projects
    subgraph Project1["Project 1"]
        direction BT
        VPC1["VPC-1"] --> LocalRules1["Local Firewall Rules<br/>(Microsegmentation)"]
        LocalRules1 --> Auto1["Auto-Created Rules<br/>(Priority 65535)"]
    end

    subgraph Project2["Project 2"]
        direction BT
        VPC2["VPC-2"] --> LocalRules2["Local Firewall Rules<br/>(Microsegmentation)"]
        LocalRules2 --> Auto2["Auto-Created Rules<br/>(Priority 65535)"]
    end

    %% Traffic Flow
    Ingress -->|Allowed Non-Routable<br/>+ IAP Traffic| VPC1
    Ingress -->|Allowed Non-Routable<br/>+ IAP Traffic| VPC2
    Egress -->|Allowed Non-Routable<br/>Egress| VPC1
    Egress -->|Allowed Non-Routable<br/>Egress| VPC2

    %% Policy Enforcement
    Auto1 -->|Lower Priority| Final1["Final Decision:<br/>🛡️ Combine Hierarchy + Local Rules"]
    Auto2 -->|Lower Priority| Final2["Final Decision:<br/>🛡️ Combine Hierarchy + Local Rules"]

    %% Test Scenario
    External["External SSH Attempt"] --> IAPCheck{"Source IP in<br/>35.235.240.0/20?"}
    IAPCheck -->|Yes| IAPAllow["SSH Allowed via IAP<br/>(Hierarchy Allows → VPC Permits)"]
    IAPCheck -->|No| Deny["SSH Blocked<br/>(Hierarchy Denies)"]
    IAPAllow --> VPC1
    IAPAllow --> VPC2

---

## Key Features
| Feature | Description |
|---------|-------------|
| **Centralized Management** | Rules are defined once at the folder level. |
| **Default-Deny Model** | Block all traffic unless explicitly allowed. To entire environment. |
| **CIDR-Driven Delegation** | Pass known non-routable ranges (`172.16.0.0/12`, `192.168.0.0/16`) to local VPC rules. |
| **State Consistency** | Eliminate duplicate rule conflicts through Terraform-managed policies. |

---

## Validation Tests

### Test 1: SSH Block Without IAP Range
- **Hierarchical Policy**: Deny all ingress except `172.16.0.0/12`, `192.168.0.0/16`
- **Local VPC Rule**: Allow SSH from `0.0.0.0/0`
- **Result**: Connection blocked ❌  
![sshfailed](../images/) 

### Test 2: SSH Success With IAP Range
- **Hierarchical Policy Added**: `35.235.240.0/20` to allowed ingress
- **Result**: SSH via IAP succeeded ✅  
![sshallowed](../images/) 

---

