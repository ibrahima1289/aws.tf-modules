# AWS WAF (Web Application Firewall)

AWS WAF is a web application firewall that helps protect your web applications or APIs from common web exploits that may affect availability, compromise security, or consume excessive resources. WAF gives you control over how traffic reaches your applications by enabling you to create security rules that block common attack patterns, such as SQL injection or cross-site scripting, and to filter traffic based on conditions that you define, such as IP addresses, HTTP headers, and custom URI strings.

## Core Concepts

*   **Application Layer Firewall (Layer 7):** WAF operates at the application layer of the OSI model, inspecting the content of web requests.
*   **Protects Web Applications/APIs:** Designed to protect resources like Amazon CloudFront distributions, Application Load Balancers (ALBs), Amazon API Gateway, and AWS AppSync.
*   **Customizable Rules:** Allows you to create highly specific rules to control traffic based on your application's needs.
*   **Managed Rules:** AWS and third-party security vendors provide pre-configured rule sets for common threats.

## Key Components and Configuration

### 1. Web ACLs (Web Access Control Lists)

*   **Purpose:** A Web ACL is the core configuration for AWS WAF. It contains a set of rules and an action to take when a rule is matched.
*   **Associated Resources:** You associate a Web ACL with one or more protected resources.
    *   **CloudFront:** To protect websites and APIs distributed globally.
    *   **Application Load Balancer (ALB):** To protect applications and APIs served within a specific AWS Region.
    *   **API Gateway:** To protect REST APIs.
    *   **AppSync:** To protect GraphQL APIs.
*   **Default Web ACL Action:** Specifies what action WAF should take for requests that don't match any of its rules (e.g., `ALLOW` or `BLOCK`).
*   **Real-life Example:** You create a Web ACL named `ProductionWebAppProtection` and associate it with your production ALB that fronts your web application. You set the default action to `ALLOW`.

### 2. Rules

Rules define the specific conditions that WAF inspects in web requests and what action to take when those conditions are met. Rules are organized into Rule Groups.

*   **Rule Types:**
    *   **IP Set Rule:** Matches requests based on the IP address of the viewer.
        *   **Real-life Example:** A rule to `BLOCK` requests from a known malicious IP address list.
    *   **Managed Rule Group:** Pre-configured, continuously updated rules provided by AWS or AWS Marketplace sellers.
        *   **AWS Managed Rule Groups:** (e.g., `AWSManagedRulesCommonRuleSet` for common exploits, `AWSManagedRulesKnownBadInputsRuleSet` for known attacks, `AWSManagedRulesSQLiRuleSet` for SQL injection).
        *   **AWS Marketplace Rule Groups:** Rules from third-party security vendors.
        *   **Real-life Example:** You add `AWSManagedRulesCommonRuleSet` to your Web ACL to protect against a broad range of common web exploits.
    *   **Custom Rules:** You define your own rules based on:
        *   **String Matching:** Match specific strings in HTTP headers, URI, query strings, or body (e.g., block requests containing a specific malicious payload).
        *   **Regex Matching:** Use regular expressions for more flexible pattern matching.
        *   **Size Constraints:** Match requests based on the size of a component (e.g., block requests with very large request bodies).
        *   **SQL Injection Attacks:** Detect SQL injection patterns.
        *   **Cross-Site Scripting (XSS) Attacks:** Detect XSS patterns.
        *   **Geo Match:** Match requests originating from specific countries.
        *   **Rate-based Rule:** Blocks requests from IP addresses that exceed a configured threshold within a 5-minute period. Useful for mitigating brute-force attacks or basic DDoS.
*   **Rule Action:**
    *   **`ALLOW`:** Allows the request to proceed to the protected resource.
    *   **`BLOCK`:** Blocks the request and returns an HTTP 403 (Forbidden) response.
    *   **`COUNT`:** Counts the requests that match the rule without blocking them. Useful for testing new rules.
*   **Priority:** Rules in a Web ACL are evaluated in order of priority (lowest to highest). The first rule that matches and has an action (ALLOW/BLOCK) is applied.

### 3. Rule Groups

*   **Purpose:** A reusable set of rules that you can deploy in multiple Web ACLs.
*   **Managed Rule Groups:** Provided by AWS (e.g., Common Rule Set) or third-party sellers.
*   **Custom Rule Groups:** You can create your own reusable rule groups.
*   **Real-life Example:** You create a custom rule group named `InternalThreats` that blocks specific internal IP addresses or known bad actors and use it across multiple Web ACLs.

### 4. Logging and Monitoring

*   **AWS Kinesis Data Firehose:** WAF can send all its raw web traffic logs to an Amazon Kinesis Data Firehose delivery stream, which can then deliver them to S3, CloudWatch Logs, or OpenSearch Service for analysis.
*   **Amazon CloudWatch Metrics:** WAF publishes metrics to CloudWatch (e.g., `BlockedRequests`, `AllowedRequests`), allowing you to create custom alarms.
*   **Real-life Example:** You send WAF logs to an S3 bucket for long-term storage and a CloudWatch Logs log group for real-time monitoring. You create a CloudWatch alarm that notifies your security team if `BlockedRequests` suddenly spike.

### 5. Integration with AWS Firewall Manager

*   **Centralized Deployment:** AWS Firewall Manager can centrally deploy and manage AWS WAF Web ACLs across multiple accounts and resources within an AWS Organization. (See `aws-firewall-manager.md`)
*   **Real-life Example:** Your central security team uses Firewall Manager to ensure that all internet-facing ALBs in your organization are protected by a standard WAF Web ACL.

## Purpose and Real-life Use Cases

*   **Protection Against Common Web Exploits:** Guarding against SQL injection, cross-site scripting (XSS), cross-site request forgery (CSRF), and other OWASP Top 10 vulnerabilities.
*   **DDoS Protection (Application Layer):** Mitigating Layer 7 DDoS attacks, such as HTTP floods or slow HTTP attacks, especially when combined with AWS Shield.
*   **Access Control:** Blocking traffic from specific IP addresses, geographical locations, or user agents.
*   **Bot Mitigation:** Identifying and blocking malicious bots or web scrapers.
*   **Custom Security Policies:** Implementing custom security rules tailored to your application's specific vulnerabilities or business logic.
*   **Compliance:** Helping meet security compliance requirements (e.g., PCI DSS) that mandate web application firewalls.
*   **Visibility into Web Traffic:** Providing insights into traffic patterns and attack attempts.

AWS WAF is an essential security service for protecting web applications and APIs deployed on AWS, offering flexible and powerful capabilities to defend against a wide range of web-based threats.
