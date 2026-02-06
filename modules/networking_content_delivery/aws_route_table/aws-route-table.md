# AWS Route Table

An AWS Route Table contains a set of rules, called routes, that determine where network traffic from your subnets or gateway is directed. Each subnet in your Amazon Virtual Private Cloud (VPC) must be associated with a route table.

## Core Concepts

*   **Traffic Direction:** Routes in a route table dictate how packets should leave a subnet.
*   **Subnet Association:** Every subnet must be explicitly associated with one route table. If you don't explicitly associate a subnet with a route table, it is implicitly associated with the VPC's main route table.
*   **Main Route Table:** The route table that comes by default with your VPC. By default, all subnets are implicitly associated with it.

## Key Components and Configuration

### 1. Routes

Each route consists of a destination and a target.

*   **Destination:** The CIDR block (e.g., `0.0.0.0/0` for all IPv4 traffic, `10.0.0.0/16` for a specific internal network) or an ENI.
*   **Target:** Where the traffic matching the destination is sent. Common targets include:
    *   **Internet Gateway (IGW):** For internet-bound traffic from public subnets.
        *   **Real-life Example:** Route `0.0.0.0/0` to `igw-xxxxxxxxxxxxxxxxx` to allow instances in a public subnet to reach the internet.
    *   **NAT Gateway:** For internet-bound traffic from private subnets.
        *   **Real-life Example:** Route `0.0.0.0/0` to `nat-xxxxxxxxxxxxxxxxx` for instances in a private subnet to access the internet for updates while remaining inaccessible from the internet.
    *   **Virtual Private Gateway (VGW):** For traffic destined for an on-premises network via a VPN connection or AWS Direct Connect.
        *   **Real-life Example:** Route `172.16.0.0/16` (your corporate network) to `vgw-xxxxxxxxxxxxxxxxx` for communication with your data center.
    *   **VPC Peering Connection:** For traffic destined for another VPC connected via VPC peering.
        *   **Real-life Example:** Route `10.1.0.0/16` (another VPC) to `pcx-xxxxxxxxxxxxxxxxx` to allow your application VPC to communicate with a shared services VPC.
    *   **Network Interface (ENI):** For sending traffic to a specific instance or a load balancer.
    *   **Gateway Load Balancer Endpoint (GWLBE):** For routing traffic through a fleet of virtual appliances.
        *   **Real-life Example:** To inspect all egress traffic, route `0.0.0.0/0` to `vpce-xxxxxxxxxxxxxxxxx` (a GWLBE).
    *   **Local:** This is a default route that allows communication between instances within the VPC. You cannot modify or delete it.
        *   **Real-life Example:** A route `10.0.0.0/16` (your VPC's CIDR) with a `Local` target means instances in any subnet within `10.0.0.0/16` can talk to each other.

### 2. Subnet Association

*   **Explicit Association:** You explicitly associate a subnet with a specific route table. This is the recommended practice for clarity and control.
*   **Implicit Association:** If a subnet is not explicitly associated with a custom route table, it automatically uses the VPC's "Main" route table. It's generally good practice to leave the main route table empty or only with a local route, and associate subnets with custom route tables to prevent unintended internet access or routing issues.
*   **Real-life Example:** You create a `public-route-table` and associate it with your `web-subnet-1` and `web-subnet-2`. You also create a `private-route-table` and associate it with your `app-subnet-1` and `db-subnet-1`.

### 3. Edge Associations (Gateway Route Tables)

Route tables can also be associated with gateways.

*   **Gateway Route Tables:** These route tables control traffic entering your VPC through a gateway.
*   **Real-life Example:** You have a Transit Gateway that connects multiple VPCs. You can attach a route table to the Transit Gateway attachment in your VPC to control which traffic from the Transit Gateway can enter your VPC.

## Purpose and Real-Life Use Cases

*   **Internet Access Control:** Determining which subnets have direct internet access (public subnets via IGW) and which do not (private subnets, potentially via NAT Gateway).
*   **Inter-VPC Communication:** Routing traffic between different VPCs using VPC peering or Transit Gateway.
*   **Hybrid Cloud Connectivity:** Directing traffic to on-premises networks via VPN or Direct Connect.
*   **Centralized Network Inspection:** Guiding traffic through security appliances using Gateway Load Balancers.
*   **Network Segmentation:** By associating different route tables with different subnets, you can create distinct network segments within your VPC, controlling their communication patterns.
*   **High Availability and Disaster Recovery:** By manipulating routes, you can shift traffic between active and standby resources or between regions during a failover event.

Route tables are a fundamental building block of networking in AWS, allowing you to precisely control the flow of traffic within your VPC and between your VPC and external networks.
