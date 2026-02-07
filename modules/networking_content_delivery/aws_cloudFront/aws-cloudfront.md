# Amazon CloudFront

Amazon CloudFront is a fast content delivery network (CDN) service that securely delivers data, videos, applications, and APIs to customers globally with low latency and high transfer speeds. CloudFront integrates with other AWS products to give developers and businesses an easy way to accelerate content to end users with no minimum commitments.

## Core Concepts

*   **Content Delivery Network (CDN):** A globally distributed network of proxy servers (Edge Locations) that caches content closer to end users.
*   **Low Latency and High Throughput:** By serving content from Edge Locations, CloudFront reduces the physical distance between users and the data, leading to faster load times and better user experience.
*   **Security:** CloudFront integrates with AWS WAF for web application security, AWS Shield for DDoS protection, and provides options for HTTPS communication.
*   **Global Reach:** Content is delivered from hundreds of Edge Locations around the world.

## Key Components and Configuration

### 1. Distributions

*   **Purpose:** A CloudFront distribution is a specific CDN configuration that tells CloudFront where to get your content (origin) and how to deliver it (behaviors, caching rules).
*   **Web Distribution:** The most common type, used for static and dynamic web content (HTTP/HTTPS).
*   **RTMP Distribution (Legacy):** For streaming media using Adobe Flash Media Server's RTMP protocol (less common now with HTML5 video).

### 2. Origins

*   **Purpose:** The location where CloudFront fetches content to serve to users.
*   **Types:**
    *   **S3 Bucket:**
        *   **Static Website Hosting:** If your S3 bucket is configured for static website hosting, CloudFront treats it as a standard HTTP web server.
        *   **S3 REST API Endpoint:** You can specify the S3 bucket's REST API endpoint. For private content, you can use an Origin Access Control (OAC).
        *   **Real-life Example:** Your static website files (HTML, CSS, JS) are in an S3 bucket. You configure CloudFront to use this S3 bucket as an origin.
    *   **Custom Origin:** Any HTTP server, such as an EC2 instance, an Application Load Balancer (ALB), or an on-premises web server.
        *   **Real-life Example:** Your dynamic web application is running on a fleet of EC2 instances behind an ALB. You configure CloudFront to use the ALB's DNS name as a custom origin.

### 3. Behaviors (Cache Behaviors)

*   **Purpose:** Define how CloudFront handles requests for specific URL paths.
*   **Path Pattern:** You specify a path pattern (e.g., `*.jpg`, `/api/*`, `videos/*`).
*   **Origin Selection:** Which origin to forward requests to.
*   **Viewer Protocol Policy:**
    *   `HTTP and HTTPS` (allow both)
    *   `Redirect HTTP to HTTPS` (best practice)
    *   `HTTPS Only`
*   **Allowed HTTP Methods:** (GET, HEAD, OPTIONS, PUT, POST, PATCH, DELETE).
*   **Cache Policy:**
    *   **Managed Policies:** CloudFront provides pre-defined caching policies (e.g., CachingOptimized, CachingDisabled).
    *   **Custom Policies:** You can define exactly which headers, cookies, and query strings are forwarded to the origin and included in the cache key.
*   **Origin Request Policy:** Defines which headers, cookies, and query strings are forwarded to the origin, regardless of caching.
*   **Response Headers Policy:** Adds, removes, or modifies HTTP headers in the CloudFront response.
*   **Real-life Example:**
    *   **Behavior 1 (`/static/*`):** Use the S3 origin, cache for 1 year, redirect HTTP to HTTPS.
    *   **Behavior 2 (`/api/*`):** Use the ALB custom origin, disable caching, allow GET/POST/PUT/DELETE, forward all headers and query strings.

### 4. Origin Access Control (OAC)

*   **Purpose:** A more secure way to restrict access to your S3 bucket content, preventing users from bypassing CloudFront and accessing your S3 content directly. Replaces the older Origin Access Identity (OAI).
*   **How it Works:** CloudFront signs all requests to S3 with a unique identity that only your S3 bucket trusts.
*   **Real-life Example:** You have private images in an S3 bucket. You configure an OAC for your S3 origin in CloudFront. You then update the S3 bucket policy to only allow `s3:GetObject` requests from the OAC, ensuring that content can only be accessed through CloudFront.

### 5. SSL/TLS Configuration

*   **Custom SSL Certificate:** For using your own domain name (e.g., `www.example.com`) with HTTPS, you must upload an SSL certificate to AWS Certificate Manager (ACM) in the `us-east-1` region (required for CloudFront).
*   **SNI (Server Name Indication):** The default method for serving multiple domains over HTTPS with a single IP address.

### 6. WAF Integration

*   **AWS Web Application Firewall (WAF):** You can associate an AWS WAF Web ACL with your CloudFront distribution to protect your applications from common web exploits.
*   **Real-life Example:** You configure WAF rules to block SQL injection attempts or cross-site scripting attacks before they reach your origin server.

### 7. Lambda@Edge and CloudFront Functions

*   **Purpose:** Run custom code at CloudFront Edge Locations in response to CloudFront events.
*   **Lambda@Edge:**
    *   **Use Cases:** More complex logic, network access, or computations.
    *   **Events:** Viewer Request, Origin Request, Origin Response, Viewer Response.
    *   **Real-life Example:** Rewrite URLs based on user location (Viewer Request), perform A/B testing by routing users to different origins (Origin Request), or add security headers to responses (Viewer Response).
*   **CloudFront Functions:**
    *   **Use Cases:** Lightweight, low-latency JavaScript code for simple operations.
    *   **Events:** Viewer Request, Viewer Response.
    *   **Real-life Example:** Basic URL rewrites, header manipulation, or access validation before the request hits the cache.

## Purpose and Real-Life Use Cases

*   **Accelerate Website and Application Delivery:** Delivering content (images, videos, static files, API responses) faster to global users.
*   **Reduce Load on Origin Servers:** Caching frequently accessed content at Edge Locations reduces the number of requests that hit your origin servers.
*   **Improve Security:** Protecting your applications against DDoS attacks (via AWS Shield) and common web exploits (via AWS WAF).
*   **Static Website Hosting:** Combine with S3 to host highly available and performant static websites.
*   **Global Content Distribution:** Distributing software updates, game assets, or streaming media to a worldwide audience.
*   **Custom Logic at the Edge:** Executing serverless code at the edge for tasks like A/B testing, authentication, or dynamic content manipulation.
*   **API Acceleration:** Accelerating API calls by caching API responses and routing requests efficiently.

CloudFront is a key service for building high-performance, secure, and globally distributed applications on AWS.
