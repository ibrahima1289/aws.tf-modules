# AWS Route 53

Amazon Route 53 is a highly available and scalable cloud Domain Name System (DNS) web service. It is designed to give developers and businesses an extremely reliable and cost-effective way to route end users to Internet applications by translating human-readable names like `www.example.com` into the numeric IP addresses like `192.0.2.1` that computers use to connect to each other.

## What is Route 53 Used For?

Route 53 performs three main functions:

1.  **Domain Registration:** You can register domain names, such as `example.com`, through Route 53.
2.  **DNS Routing:** Route 53 translates domain names to IP addresses or other resources. It routes user requests to your application's infrastructure running in AWS (like EC2 instances, Elastic Load Balancers, or S3 buckets) and can also be used to route users to infrastructure outside of AWS.
3.  **Health Checking:** Route 53 can monitor the health of your application and its endpoints. It can be configured to route traffic away from unhealthy endpoints to healthy ones, increasing the availability of your application.

## Route 53 Record Types

Here are the most common record types available in Route 53 and their use cases:

| Record Type | Name                     | Purpose                                                                                                                                                                                                                           |
| :---------- | :----------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **A**       | Address Record           | Points a domain or subdomain to an IPv4 address (e.g., `123.45.67.89`). This is the most common record type for a simple website.                                                                                                    |
| **AAAA**    | IPv6 Address Record      | Points a domain or subdomain to an IPv6 address (e.g., `2001:0db8:85a3:0000:0000:8a2e:0370:7334`).                                                                                                                                   |
| **CNAME**   | Canonical Name Record    | Points a subdomain to another domain name (e.g., `blog.example.com` to `another-domain.com`). **Note:** You cannot create a CNAME record for a root domain (e.g., `example.com`).                                                    |
| **ALIAS**   | Alias Record             | An AWS-specific record type that points a domain (including the root domain) to an AWS resource, such as an Elastic Load Balancer, a CloudFront distribution, or another Route 53 record in the same hosted zone. It is similar to a CNAME but has some key differences, including being free and handling changes in the resource's IP address automatically. |
| **MX**      | Mail Exchange Record     | Specifies the mail servers responsible for accepting email messages on behalf of a domain. It includes a priority value to indicate the order in which mail servers should be tried.                                             |
| **NS**      | Name Server Record       | Identifies the name servers for a hosted zone. These are the servers that contain the authoritative DNS records for the domain.                                                                                                   |
| **PTR**     | Pointer Record           | The reverse of an A record; it maps an IP address to a domain name. Primarily used for reverse DNS lookups.                                                                                                                      |
| **SOA**     | Start of Authority Record | Contains administrative information about the domain, such as the primary name server, the email of the domain administrator, and several timers related to refreshing the zone.                                                    |
| **SPF**     | Sender Policy Framework | A type of TXT record that identifies which mail servers are permitted to send email on behalf of your domain. It helps prevent email spoofing.                                                                                    |
| **SRV**     | Service Record           | Specifies the location (hostname and port number) of servers for specific services, such as VoIP or IM.                                                                                                                          |
| **TXT**     | Text Record              | Allows you to include arbitrary text in a DNS record. It's often used for verifying domain ownership with third-party services (like Google Search Console) or for SPF records.                                                      |

## Configuring Route 53 for a New Website

Here’s a typical workflow for configuring Route 53 for a new website hosted on AWS.

### Step 1: Register a Domain Name (if you don't have one)

If you don’t already own a domain name, you can register one with Route 53. If you register your domain with Route 53, it will automatically create a hosted zone for you.

If your domain is registered with another provider (like GoDaddy or Namecheap), you will need to manually create a hosted zone and update the name servers at your registrar.

### Step 2: Create a Hosted Zone

A hosted zone is a container for the DNS records for your domain.

1.  In the Route 53 console, go to **Hosted zones** and click **Create hosted zone**.
2.  Enter your domain name (e.g., `example.com`).
3.  Choose **Public hosted zone**.
4.  Click **Create hosted zone**.

After creating the hosted zone, Route 53 will assign four name servers (NS records) to it. You'll need these if your domain is registered with another provider.

### Step 3: Create DNS Records for Your Website

Now you need to create records to point your domain to your website. Where your website is hosted determines the type of record you should create.

#### Scenario A: Website hosted on an EC2 instance

If your website is on an EC2 instance, you have a public IP address. You should create an **A record**.

1.  In your hosted zone, click **Create record**.
2.  Leave the **Record name** blank to create a record for the root domain (`example.com`).
3.  For **Record type**, select **A**.
4.  In the **Value** field, enter the public IPv4 address of your EC2 instance.
5.  Set the **TTL (Time to Live)**, or leave the default.
6.  Click **Create records**.

To also have `www.example.com` work, create another `A` record, but this time set the **Record name** to `www`.

#### Scenario B: Website served by a CloudFront Distribution or Elastic Load Balancer

If you are using an AWS resource like a CloudFront distribution, an Elastic Load Balancer (ELB), or an S3 bucket configured for website hosting, you should use an **ALIAS record**.

1.  In your hosted zone, click **Create record**.
2.  For the root domain (`example.com`), leave the **Record name** blank. For a subdomain, enter it (e.g., `www`).
3.  For **Record type**, select **A**.
4.  Enable the **Alias** toggle.
5.  In the **Route traffic to** dropdown, select the type of AWS resource (e.g., "Alias to CloudFront distribution").
6.  Choose your specific resource from the list that appears.
7.  Click **Create records**.

Using an ALIAS record is the recommended approach for AWS resources because:
*   **It's free.** Route 53 does not charge for ALIAS record queries.
*   **It's dynamic.** If the IP address of the AWS resource changes, Route 53 automatically updates the DNS record.
*   **It works for root domains.** Unlike CNAMEs, you can create an ALIAS record for your root domain (`example.com`).

### Step 4: Update Name Servers (if your domain is registered elsewhere)

If you registered your domain with a provider other than Route 53, you must update the name servers at your registrar to point to the Route 53 name servers.

1.  In your Route 53 hosted zone, find the four name servers listed in the **NS** record.
2.  Go to your domain registrar's website (e.g., GoDaddy, Namecheap).
3.  Find the DNS or name server management area for your domain.
4.  Replace the existing name servers with the four Route 53 name servers.

It can take up to 48 hours for these changes to propagate across the internet, but it's often much faster. Once propagated, Route 53 will be the authoritative DNS service for your domain.
