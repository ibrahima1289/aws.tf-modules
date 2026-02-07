# AWS Shield

AWS Shield is a managed Distributed Denial of Service (DDoS) protection service that safeguards applications running on AWS. Shield provides always-on detection and automatic inline mitigations that minimize application downtime and latency. There are two tiers of AWS Shield: Standard and Advanced.

## Core Concepts

*   **DDoS Protection:** Specifically designed to protect against various types of DDoS attacks.
*   **Always-on Detection:** Continuously monitors network traffic for DDoS patterns.
*   **Automatic Mitigations:** Automatically applies mitigations to absorb and block DDoS traffic without manual intervention.
*   **Integrated with AWS:** Works seamlessly with other AWS services like Amazon CloudFront, Elastic Load Balancing (ELB), and Route 53.

## Tiers of AWS Shield

### 1. AWS Shield Standard

*   **Cost:** Included automatically at no additional cost for all AWS customers.
*   **Protection:** Provides always-on detection and inline mitigation of the most common, frequently occurring network and transport layer DDoS attacks (Layer 3 and Layer 4). These include SYN/UDP floods, reflection attacks, and other volumetric attacks.
*   **Managed by AWS:** AWS handles all aspects of protection, you don't need to configure anything.
*   **Protected Resources:** Automatically protects all AWS resources that are exposed to the public internet, such as Elastic Load Balancers (ELB), Amazon CloudFront distributions, AWS Global Accelerator, and Amazon Route 53.
*   **Real-life Example:** Your web application is experiencing a SYN flood attack. AWS Shield Standard automatically detects this and applies mitigations to drop the malicious traffic, allowing legitimate users to continue accessing your application.

### 2. AWS Shield Advanced

*   **Cost:** A paid service that provides enhanced protections and additional features beyond Shield Standard.
*   **Protection:** Extends DDoS protection to more sophisticated and larger attacks, including application layer (Layer 7) DDoS attacks, state-exhaustion attacks, and resource-heavy attacks.
*   **Features:**
    *   **Advanced DDoS Mitigation:** Enhanced, more sophisticated mitigations for larger and more complex attacks.
    *   **24/7 DDoS Response Team (DRT):** Direct access to the AWS DDoS Response Team for expert assistance during an attack.
    *   **Cost Protection:** Protects against scaling costs due to DDoS-related usage spikes on protected resources (e.g., EC2 instances, ELB, CloudFront, Route 53, Global Accelerator).
    *   **Visibility:** Provides enhanced visibility into DDoS attacks and mitigations through near real-time metrics and reports.
    *   **WAF Integration:** Seamlessly integrates with AWS WAF for application layer protection.
    *   **Resource Coverage:** You must explicitly select the resources you want to protect with Shield Advanced.
*   **Real-life Example:** Your e-commerce site is a target of a sophisticated application layer (Layer 7) DDoS attack. With Shield Advanced, the AWS DRT helps you create custom AWS WAF rules in real-time to mitigate the attack. Furthermore, if your application scales up significantly during the attack, Shield Advanced covers the cost of those additional resources.

## Key Components and Configuration (for Shield Advanced)

### 1. Protected Resources

*   **Scope:** You explicitly specify which resources to protect with Shield Advanced.
*   **Supported Resources:** Amazon CloudFront distributions, Elastic Load Balancers (ALB, NLB, CLB), AWS Global Accelerator standard accelerators, Amazon Route 53 hosted zones, and Elastic IP addresses.
*   **Real-life Example:** You protect your production Application Load Balancer and your primary CloudFront distribution with Shield Advanced.

### 2. Integration with AWS WAF

*   **Collaborative Protection:** AWS WAF works in conjunction with Shield Advanced to provide comprehensive DDoS protection at both network/transport (Layer 3/4) and application (Layer 7) layers.
*   **Custom WAF Rules:** The DRT often assists in creating custom AWS WAF rules to block specific Layer 7 DDoS attack patterns during an active incident.
*   **Real-life Example:** During an attack, the DRT might analyze the attack traffic and suggest a custom AWS WAF rule to block requests from specific user agents or IP ranges that are part of the attack.

### 3. DDoS Response Team (DRT) Engagement

*   **Proactive Monitoring:** The DRT actively monitors your protected resources.
*   **Direct Access:** You can engage the DRT at any time through the AWS Support Center.
*   **Expert Assistance:** The DRT helps you analyze attack events, review your application architecture for resilience, and apply custom mitigations.
*   **Real-life Example:** Your application is experiencing unusual traffic patterns, and you suspect a new type of DDoS attack. You contact the DRT, and they help you diagnose the attack and implement appropriate countermeasures.

### 4. Visibility and Metrics

*   **DDoS Attack Reports:** Shield Advanced provides detailed reports and metrics on DDoS attacks, including attack vectors, volume, and mitigated traffic.
*   **CloudWatch Metrics:** Attack metrics are available in Amazon CloudWatch, allowing you to create custom alarms.
*   **Real-life Example:** You use CloudWatch to monitor the `DDoSEntitiesMitigated` metric to see how many unique sources Shield Advanced is blocking during an attack.

### 5. AWS Firewall Manager Integration

*   **Centralized Deployment:** AWS Firewall Manager can be used to centrally deploy AWS Shield Advanced protection across multiple accounts and resources within an AWS Organization. (See `aws-firewall-manager.md`)
*   **Real-life Example:** You create a Firewall Manager policy that ensures all eligible public-facing resources in your production OUs are automatically protected by Shield Advanced.

## Purpose and Real-life Use Cases

*   **Protecting Business-Critical Applications:** Safeguarding high-value web applications, APIs, and services from DDoS attacks that could lead to financial loss, reputational damage, or service disruption.
*   **Maintaining High Availability:** Ensuring that your applications remain available to legitimate users even during large-scale attacks.
*   **Compliance:** Helping meet security and compliance requirements for DDoS protection.
*   **Cost Control:** Preventing unexpected cost spikes due to DDoS-related resource scaling.
*   **Peace of Mind:** Knowing that you have dedicated expert assistance during a DDoS incident.
*   **E-commerce and Online Gaming:** Industries that are frequent targets of DDoS attacks.

AWS Shield provides robust, scalable, and highly effective DDoS protection, with Shield Advanced offering an enhanced layer of security and expert support for your most critical workloads.
