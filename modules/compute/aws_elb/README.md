# AWS Elastic Load Balancing (ELB) Family

AWS provides several load balancer types under Elastic Load Balancing (ELB), each suited to different traffic patterns and use cases.

- **Application Load Balancer (ALB):** Layer 7 (HTTP/HTTPS). Supports path/host-based routing, WebSockets, HTTP/2, and advanced routing rules. Use for web applications, microservices, and content-based routing.
- **Network Load Balancer (NLB):** Layer 4 (TCP/TLS/UDP). Handles millions of requests per second with ultra-low latency and static IPs. Use for high-performance, protocol-level traffic and TLS offload.
- **Gateway Load Balancer (GWLB):** Routes traffic to third-party virtual appliances using GENEVE encapsulation (port 6081). Use for inserting security/inspection appliances (firewalls, IDS/IPS) transparently across VPCs.
- **Classic Load Balancer (CLB):** Legacy Layer 4/7 balancer, replaced by ALB and NLB. Avoid for new architectures.

## Quick Use Cases
- **ALB:** Route `/api/*` to microservice target group, `/static/*` to a different group.
- **NLB:** Expose PostgreSQL (`TCP:5432`) or custom TCP services at scale.
- **GWLB:** Insert a firewall cluster into traffic flows between VPCs using GENEVE to inspect and forward traffic.

See module READMEs for detailed configuration and examples:
- [ALB Module](aws_alb/README.md)
- [NLB Module](aws_nlb/README.md)
- [GWLB Module](aws_glb/README.md)
