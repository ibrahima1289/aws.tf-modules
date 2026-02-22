# AWS Transit Gateway

AWS Transit Gateway is a network transit hub that connects VPCs and on-premises networks through a central hub. It acts as a cloud router where each new connection is made only once to the Transit Gateway, eliminating complex peering relationships and simplifying network architecture.

## Overview

Transit Gateway enables you to scale your network across thousands of VPCs, AWS accounts, and on-premises networks. It operates on a regional basis and can be peered across Regions for global network connectivity. Each Transit Gateway can support up to 5,000 VPC and VPN attachments.

## Key Features

### 1. Centralized Network Hub
- **Hub-and-Spoke Architecture:** Eliminates the need for complex mesh VPC peering
- **Scalable Connectivity:** Supports up to 5,000 attachments per Transit Gateway
- **Cross-Account Support:** Share Transit Gateways across AWS accounts using AWS Resource Access Manager (RAM)
- **Simplified Management:** Single point for managing network connectivity

### 2. Routing Capabilities
- **Route Tables:** Multiple route tables for traffic segmentation and isolation
- **Dynamic Routing:** BGP support for dynamic route propagation
- **Static Routes:** Manual route configuration for specific use cases
- **Route Propagation:** Automatic route learning from VPN and Direct Connect attachments
- **Blackhole Routes:** Drop unwanted traffic by routing to blackhole

### 3. Connectivity Options
- **VPC Attachments:** Connect VPCs within the same AWS Region
- **VPN Attachments:** IPsec VPN connections to on-premises networks
- **Direct Connect Gateway Attachments:** Private connectivity via AWS Direct Connect
- **Transit Gateway Peering:** Connect Transit Gateways across different Regions
- **Connect Attachments:** SD-WAN integration using third-party network appliances

### 4. Inter-Region Peering
- **Global Network:** Connect Transit Gateways across AWS Regions
- **AWS Backbone:** Traffic routed over AWS global private network
- **Encryption:** All inter-Region traffic is automatically encrypted
- **Bandwidth:** Up to 50 Gbps per peering connection (upgradeable)

### 5. Multicast Support
- **Application Streaming:** Distribute data to multiple subscribers
- **Multicast Domains:** Isolate multicast traffic
- **Source Filtering:** Control which sources can send multicast traffic
- **Static Group Members:** Configure EC2 instances as group members

### 6. Network Segmentation
- **Route Table Isolation:** Create isolated routing domains
- **Attachment Associations:** Associate attachments with specific route tables
- **Route Propagation Control:** Selectively propagate routes
- **Network Domains:** Implement hub-and-spoke or isolated-spoke architectures

### 7. Security Features
- **Security Group Referencing:** Reference security groups across VPCs
- **Network ACLs:** Apply network access control lists at subnet level
- **Flow Logs:** Monitor and log network traffic
- **Appliance Mode:** Route traffic through security appliances
- **ECMP (Equal Cost Multi-Path):** Distribute traffic across multiple paths for VPN

### 8. High Availability & Performance
- **Multi-AZ Deployment:** Automatically deployed across multiple Availability Zones
- **50 Gbps Bandwidth:** Per VPC attachment (up to 50 Gbps)
- **ECMP Support:** Aggregate bandwidth across multiple VPN tunnels
- **Automatic Failover:** Built-in redundancy and failover

### 9. Monitoring & Logging
- **CloudWatch Metrics:** Monitor bytes in/out, packet count, drops
- **VPC Flow Logs:** Capture network traffic information
- **Transit Gateway Network Manager:** Global network visualization and monitoring
- **CloudTrail Integration:** API call logging for auditing

### 10. AWS Network Manager Integration
- **Global Dashboard:** Visualize and monitor global network
- **Route Analyzer:** Troubleshoot routing issues
- **Performance Monitoring:** Track network performance metrics
- **Event Notifications:** Alerts for topology and routing changes

## Key Components and Configuration

### 1. Transit Gateway
The core resource that acts as the regional network hub.

**Configuration Parameters:**
- **Amazon Side ASN:** BGP ASN for the Transit Gateway (64512-65534, 4200000000-4294967294)
- **DNS Support:** Enable DNS resolution for VPC attachments
- **VPN ECMP Support:** Enable equal-cost multi-path routing for VPN
- **Default Route Table Association:** Auto-associate new attachments
- **Default Route Table Propagation:** Auto-propagate routes from new attachments
- **Multicast Support:** Enable multicast functionality
- **Auto Accept Shared Attachments:** Automatically accept cross-account attachments
- **Transit Gateway CIDR Blocks:** CIDR blocks for Connect attachments

**Real-Life Example:** A financial services company creates a Transit Gateway with ASN 64512, enables VPN ECMP for aggregating VPN bandwidth, and enables multicast support for their trading platform's data distribution needs.

### 2. Transit Gateway Attachments

Connections between the Transit Gateway and other network resources.

**VPC Attachment Configuration:**
- **Subnet IDs:** One subnet per Availability Zone
- **DNS Support:** Enable DNS hostname resolution
- **IPv6 Support:** Enable IPv6 traffic
- **Appliance Mode Support:** Enable for inspection architectures

**VPN Attachment Configuration:**
- **Customer Gateway:** On-premises VPN device
- **Static or Dynamic Routing:** BGP for dynamic or static routes
- **Tunnel Options:** Pre-shared keys, inside CIDR, DPD timeout
- **Acceleration:** Enable for improved VPN performance

**Direct Connect Gateway Attachment:**
- **Allowed Prefixes:** CIDR blocks to advertise
- **Virtual Private Gateway Association:** Link to Direct Connect

**Peering Attachment Configuration:**
- **Peer Region:** Target AWS Region
- **Peer Transit Gateway ID:** Remote Transit Gateway identifier
- **Peer Account ID:** AWS account of peer Transit Gateway

**Real-Life Example:** A retail company attaches 50 VPCs across Development, Staging, and Production environments, connects 5 data centers via VPN with ECMP enabled for 2.5 Gbps total bandwidth, and peers with a Transit Gateway in another Region for disaster recovery.

### 3. Route Tables

Control traffic routing between attachments.

**Configuration Parameters:**
- **Name:** Descriptive identifier
- **Default Association Route Table:** Set as default for new attachments
- **Default Propagation Route Table:** Set as default for route propagation

**Route Types:**
- **Static Routes:** Manually configured routes
- **Propagated Routes:** Automatically learned from attachments
- **Blackhole Routes:** Drop traffic destined for specific CIDRs

**Real-Life Example:** A healthcare organization creates three route tables:
- **Shared Services RT:** All VPCs can reach shared DNS and logging services
- **Production RT:** Isolated production VPCs, no access to dev/test
- **Development RT:** Dev/test VPCs isolated from production but can reach each other

### 4. Route Table Associations

Link attachments to route tables to control their routing behavior.

**Configuration:**
- Associate each attachment with a specific route table
- Only one route table per attachment
- Determines where traffic FROM the attachment is routed

**Real-Life Example:** Production VPC attachments are associated with the Production route table, preventing them from accessing development environments while still allowing access to shared services through specific route entries.

### 5. Route Table Propagations

Control which routes are propagated from attachments to route tables.

**Configuration:**
- Enable propagation from specific attachments to specific route tables
- Automatically adds routes from VPN and Direct Connect attachments
- VPC CIDR blocks can be propagated

**Real-Life Example:** VPN connections from branch offices propagate their routes to the Shared Services route table, making on-premises resources accessible to approved VPCs without manual route entry.

### 6. Multicast Domains

Enable multicast traffic distribution across VPCs.

**Configuration Parameters:**
- **Static Sources Support:** Enable static configuration of multicast sources
- **Auto Accept Shared Associations:** Auto-accept cross-account subnet associations
- **IGMPv2 Support:** Enable IGMP version 2 protocol

**Components:**
- **Multicast Domain Associations:** Link VPC subnets to multicast domain
- **Multicast Group Members:** EC2 instances receiving multicast traffic
- **Multicast Group Sources:** EC2 instances sending multicast traffic

**Real-Life Example:** A media company uses multicast to distribute live video feeds from production servers (sources) to multiple rendering nodes (members) across different VPCs, reducing bandwidth consumption compared to unicast replication.

### 7. Connect Attachments and Connect Peers

Enable SD-WAN integration and third-party network appliance connectivity.

**Connect Attachment Configuration:**
- **Transport Attachment:** Underlying VPC attachment
- **Protocol:** GRE (Generic Routing Encapsulation)

**Connect Peer Configuration:**
- **Peer Address:** IP address of the SD-WAN appliance
- **Inside CIDR Blocks:** /29 CIDR for BGP peering
- **BGP ASN:** ASN of the SD-WAN device
- **Transit Gateway Address:** AWS side of BGP peering

**Real-Life Example:** A global enterprise integrates their Cisco SD-WAN fabric with Transit Gateway using Connect attachments, enabling dynamic routing and centralized management of branch connectivity through their SD-WAN orchestrator.

### 8. Transit Gateway Policy Tables (Route Analyzer)

Advanced routing policy for complex network architectures.

**Configuration:**
- **Policy Rules:** Define routing decisions based on packet metadata
- **Rule Matching:** Based on source/destination CIDR, protocol, ports
- **Actions:** Permit, deny, or redirect traffic

**Real-Life Example:** A multi-tenant SaaS provider uses policy tables to ensure customer VPCs can only communicate with their dedicated database VPC and shared services, preventing cross-tenant data access.

## Advanced Configurations

### 1. Appliance Mode (Stateful Inspection)

Ensures bi-directional traffic flows through the same appliance for stateful inspection.

**Configuration:**
- Enable Appliance Mode Support on VPC attachment
- Deploy firewalls or IDS/IPS in dedicated inspection VPC
- Configure route tables to send traffic through inspection VPC

**Real-Life Example:** Security team deploys Palo Alto firewalls in an inspection VPC with appliance mode enabled. All traffic between production VPCs and the internet flows through these firewalls for deep packet inspection and threat prevention.

### 2. Centralized Egress (Shared Services)

Consolidate internet egress through a centralized VPC.

**Architecture:**
- Egress VPC with NAT Gateways or NAT instances
- Route tables direct internet-bound traffic to egress VPC
- Centralized logging and security controls

**Real-Life Example:** A startup routes all internet egress through a centralized egress VPC with NAT Gateways, URL filtering, and centralized logging to reduce costs and improve security posture.

### 3. Segmented Routing (Isolated Domains)

Create isolated network segments that cannot communicate.

**Configuration:**
- Create separate route tables for each segment
- Associate attachments with their respective route tables
- Do not propagate routes between segments

**Real-Life Example:** A government agency creates separate routing domains for Unclassified, Confidential, and Secret networks, ensuring complete isolation while all use the same Transit Gateway infrastructure.

### 4. Hub-and-Spoke with Shared Services

Common pattern where spoke VPCs access shared services but cannot reach each other.

**Configuration:**
- Shared Services route table receives routes from all spokes
- Spoke route tables only receive routes from shared services
- No route propagation between spokes

**Real-Life Example:** A corporation allows all application VPCs (spokes) to access Active Directory, DNS, and monitoring services (shared services) but prevents direct communication between application VPCs for security isolation.

### 5. VPN ECMP (Equal-Cost Multi-Path)

Aggregate bandwidth across multiple VPN tunnels.

**Configuration:**
- Enable VPN ECMP support on Transit Gateway
- Create multiple VPN connections to same Customer Gateway
- Configure BGP with same path attributes

**Real-Life Example:** A remote office establishes 4 VPN connections to Transit Gateway, each providing 1.25 Gbps, for a total aggregated bandwidth of 5 Gbps using ECMP load balancing.

### 6. Inter-Region Architecture (Global Network)

Connect networks across AWS Regions for global applications.

**Configuration:**
- Deploy Transit Gateways in each Region
- Create Transit Gateway peering attachments
- Configure route tables to route inter-region traffic

**Real-Life Example:** A gaming company operates in US-EAST-1 and EU-WEST-1. Players connect to their nearest Region, but game servers need to communicate globally. Transit Gateway peering enables low-latency, secure inter-region communication over AWS backbone.

### 7. Hybrid Cloud with Direct Connect

Private connectivity to on-premises data centers.

**Configuration:**
- Create Direct Connect Gateway
- Attach Direct Connect Gateway to Transit Gateway
- Associate Virtual Private Gateways or configure allowed prefixes

**Real-Life Example:** An insurance company connects their on-premises mainframe to AWS using Direct Connect with 10 Gbps bandwidth, enabling real-time data synchronization between legacy systems and cloud-native applications across 30 VPCs.

## Routing Patterns

### 1. Full Mesh (Default)
All attachments can communicate with each other.

### 2. Hub-and-Spoke
Spokes communicate through a central hub but not directly with each other.

### 3. Isolated Spokes
Spokes can access shared services but cannot reach each other.

### 4. Segmented
Multiple isolated routing domains with selective connectivity.

### 5. Tiered
Hierarchical routing with graduated access controls (e.g., DMZ → App → Database).

## Monitoring and Troubleshooting

### CloudWatch Metrics
- **BytesIn/BytesOut:** Data transferred through Transit Gateway
- **PacketsIn/PacketsOut:** Number of packets
- **PacketDropCountBlackhole:** Packets dropped due to blackhole routes
- **PacketDropCountNoRoute:** Packets dropped due to missing routes
- **BytesDropCountBlackhole/NoRoute:** Bytes dropped

### Flow Logs
- Enable VPC Flow Logs on attached VPCs
- Capture accepted and rejected traffic
- Send to CloudWatch Logs or S3

### Route Analyzer
- Analyze routing path between source and destination
- Identify routing issues and blackholes
- Validate routing configurations

### Network Manager
- Global network topology visualization
- Performance monitoring across Regions
- Route analyzer for troubleshooting
- Integration with AWS Transit Gateway Network Manager

## Security Best Practices

1. **Use Resource Access Manager (RAM)** to share Transit Gateways securely across accounts
2. **Implement least privilege routing** with specific route table associations
3. **Enable Flow Logs** for all VPC attachments for security monitoring
4. **Use Network Firewall or appliance mode** for traffic inspection
5. **Encrypt inter-region traffic** (automatic with peering attachments)
6. **Implement route table isolation** to enforce network segmentation
7. **Monitor CloudWatch metrics** for anomalies and drops
8. **Use AWS CloudTrail** to audit Transit Gateway API calls
9. **Tag all resources** for cost allocation and access control
10. **Apply SCPs (Service Control Policies)** to restrict Transit Gateway modifications

## Cost Optimization

1. **Data Processing Charges:** $0.02 per GB processed
2. **Attachment Charges:** Hourly charge per attachment
3. **Inter-Region Peering:** Data transfer charges apply
4. **VPN Connection:** Standard VPN charges apply
5. **Optimization Tips:**
   - Consolidate VPN connections where possible
   - Use Direct Connect for high-volume data transfer
   - Remove unused attachments
   - Monitor data transfer patterns
   - Consider VPC peering for simple point-to-point connections

## Limits and Quotas

- **Transit Gateways per Region:** 5 (adjustable)
- **Attachments per Transit Gateway:** 5,000 (adjustable)
- **Routes per route table:** 10,000 (adjustable)
- **Route tables per Transit Gateway:** 20 (adjustable)
- **Peering attachments per Transit Gateway:** 50
- **Multicast domains per Transit Gateway:** 20
- **Transit Gateway CIDR blocks:** 5
- **Bandwidth per VPC attachment:** 50 Gbps (burst up to 50 Gbps)
- **Bandwidth per VPN connection:** 1.25 Gbps per tunnel
- **Maximum MTU:** 8500 bytes

## Real-Life Example Applications

### 1. Global Corporate Network
A global enterprise has dozens of VPCs across multiple AWS accounts for different business units (Marketing, HR, Engineering). They also have multiple on-premises offices. By using AWS Transit Gateway, they create a "hub-and-spoke" network architecture. All VPCs and the on-premises VPNs connect to a single Transit Gateway. This allows the Engineering VPC to securely access the HR database while the Marketing VPC remains isolated, all managed through centralized route tables rather than hundreds of individual peering connections.

### 2. Multi-Region Application
A streaming platform operates globally with Transit Gateways in US-EAST-1, EU-WEST-1, and AP-SOUTHEAST-1. They use inter-region peering to enable content servers to synchronize data across Regions while maintaining low latency for end users by serving them from the nearest Region.

### 3. Centralized Security Inspection
A financial institution routes all traffic through a dedicated inspection VPC containing next-generation firewalls. Using appliance mode, they ensure stateful inspection of all traffic flows between VPCs, to the internet, and to on-premises networks, maintaining compliance with regulatory requirements.

### 4. Hybrid Cloud Integration
A healthcare provider connects 100+ VPCs to their on-premises data centers using Transit Gateway with Direct Connect. They maintain strict HIPAA compliance by routing all patient data through encrypted connections and implementing network segmentation based on data sensitivity.

### 5. Managed Service Provider (MSP)
An MSP uses Transit Gateway to provide network connectivity as a service to 200+ customer accounts. They share a central Transit Gateway using RAM, assign each customer to isolated route tables, and provide optional shared services (DNS, patching, monitoring) while ensuring complete tenant isolation.

## Conclusion

AWS Transit Gateway is a powerful networking service that simplifies and scales cloud and hybrid network architectures. By centralizing network connectivity through a hub-and-spoke model, it reduces operational complexity, improves security posture, and enables flexible network segmentation. Whether connecting VPCs within a Region, establishing hybrid connectivity to on-premises networks, or building global multi-Region architectures, Transit Gateway provides the foundation for modern enterprise networking in AWS.
