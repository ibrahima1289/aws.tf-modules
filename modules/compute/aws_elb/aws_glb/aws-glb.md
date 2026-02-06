# Gateway Load Balancer (GLB)

A Gateway Load Balancer (GLB) is a type of Elastic Load Balancer that operates at the network layer (Layer 3) of the OSI model. Its specific purpose is to make it easy to deploy, scale, and manage fleets of third-party virtual network appliances, such as firewalls, intrusion detection and prevention systems (IDS/IPS), and deep packet inspection (DPI) systems.

## Core Concepts

*   **Transparent Traffic Insertion:** GLB acts as a "bump in the wire," transparently inserting a fleet of security or networking appliances into the network path without the need for complex routing changes.
*   **Appliance Fleet Management:** It load balances traffic across a fleet of virtual appliances and scales them up or down based on demand.
*   **Centralized Security:** GLB allows you to centralize your security and network inspection appliances, which can then serve multiple VPCs.
*   **Layer 3 Load Balancing:** It forwards entire IP packets, making it protocol-agnostic.

## How it Works: The Architecture

The GLB architecture involves two key components: the Gateway Load Balancer itself and Gateway Load Balancer Endpoints.

### 1. Gateway Load Balancer (GLB)

This is the main component that you create in the "Security VPC" or "Appliance VPC" where your fleet of virtual appliances is located.

*   **Listener:** A GLB listener operates on Layer 3, so it doesn't have a port or protocol. It simply forwards all IP packets it receives.
*   **Target Group:**
    *   **Target Type:** The targets for a GLB are the virtual appliances themselves, registered by their IP address or instance ID. These are typically EC2 instances running firewall software from vendors like Palo Alto Networks, Check Point, Cisco, etc.
    *   **Health Checks:** The GLB performs health checks on the appliances to ensure they are healthy before forwarding traffic.

### 2. Gateway Load Balancer Endpoint (GWLBE)

This is a new type of VPC endpoint that you create in your "Application VPCs" (the VPCs where your application servers are located). The GWLBE acts as the entry and exit point for traffic that needs to be inspected.

*   **Service Name:** The GWLBE is linked to the GLB via a VPC endpoint service name.
*   **Routing Configuration:** You update the route tables in your Application VPC to direct traffic through the GWLBE. For example, you would change the route table for your application subnet to point the default route (`0.0.0.0/0`) to the GWLBE instead of the Internet Gateway.

### Traffic Flow

1.  An application instance in the Application VPC tries to send traffic to the internet.
2.  The subnet's route table directs this traffic to the Gateway Load Balancer Endpoint (GWLBE).
3.  The GWLBE forwards the traffic to the Gateway Load Balancer (GLB) in the Security VPC.
4.  The GLB selects a healthy security appliance from its target group and forwards the traffic to it for inspection.
5.  After inspection, the appliance sends the traffic back to the GLB.
6.  The GLB returns the traffic to the GWLBE in the source VPC.
7.  The GWLBE sends the traffic on to its original destination (e.g., the Internet Gateway).

This entire process is transparent to the source and destination.

## Configuration Options

*   **Cross-Zone Load Balancing:** By default, this is enabled. Traffic is distributed across appliances in all enabled Availability Zones.
*   **Sticky Sessions:** GLB uses 5-tuple (source/destination IP, source/destination port, and protocol) or 3-tuple hashing to ensure that a flow between a specific client and destination is always sent to the same security appliance. This is critical for stateful firewalls.
*   **Health Checks:** You configure health checks on the GLB's target group to ensure that traffic is not sent to unhealthy appliances.

## Real-Life Examples and Use Cases

*   **Centralized Security Inspection:**
    *   **Scenario:** A large enterprise has dozens of VPCs and wants to enforce a consistent security policy for all internet-bound traffic. They want to use a specific next-generation firewall from a third-party vendor.
    *   **GLB Configuration:**
        1.  They create a dedicated "Security VPC."
        2.  In this VPC, they deploy a fleet of their chosen firewall appliances as an Auto Scaling group.
        3.  They create a Gateway Load Balancer and register the firewall appliances with its target group.
        4.  In each of their application VPCs, they create a Gateway Load Balancer Endpoint.
        5.  They update the route tables in the application VPCs to route all internet traffic through the GWLBE.
    *   **Benefit:** All traffic is now centrally inspected by a scalable, highly available fleet of firewalls, without needing to deploy and manage separate firewalls in every single VPC.

*   **Intrusion Detection/Prevention (IDS/IPS):**
    *   **Scenario:** A financial services company needs to monitor all traffic between its application and database tiers for suspicious activity.
    *   **GLB Configuration:** They can place a GLB endpoint in the path between the application subnet and the database subnet, directing traffic to a fleet of IDS/IPS appliances.
    *   **Benefit:** The GLB transparently inserts the inspection fleet into the traffic path, providing full visibility without re-architecting the application's networking.

*   **Virtual Appliance-as-a-Service:**
    *   **Scenario:** A Managed Security Service Provider (MSSP) wants to offer firewall services to its customers on AWS.
    *   **GLB Configuration:** The MSSP runs their firewall fleet behind a GLB and exposes it as a VPC endpoint service. Customers can then subscribe to this service and create a GWLBE in their own VPCs to consume the firewall service, with all traffic being privately routed over the AWS network.

Gateway Load Balancer simplifies how you deploy, scale, and manage network appliances, making it easier to improve your security posture in the cloud.
