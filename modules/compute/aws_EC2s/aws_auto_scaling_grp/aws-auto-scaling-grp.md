# AWS Auto Scaling Groups

An AWS Auto Scaling group contains a collection of Amazon EC2 instances that are treated as a logical grouping for the purposes of automatic scaling and management. Auto Scaling groups allow you to use Amazon EC2 Auto Scaling features such as health check replacements and scaling policies. Both the minimum and maximum size of the Auto Scaling group can be set, and Amazon EC2 Auto Scaling ensures that your group never goes above or below these limits.

## Core Concepts

*   **Launch Configuration/Template:** A template that an Auto Scaling group uses to launch EC2 instances. It includes the Amazon Machine Image (AMI) ID, instance type, key pair, security groups, and other launch parameters. You must create a launch configuration or launch template before you can create an Auto Scaling group.
*   **Desired Capacity:** The number of EC2 instances that the Auto Scaling group attempts to maintain.
*   **Minimum Size:** The minimum number of instances in the Auto Scaling group.
*   **Maximum Size:** The maximum number of instances in the Auto Scaling group.
*   **Scaling Policies:** Rules that determine when and how to scale the Auto Scaling group in or out.

## Configuration Options

### 1. Launch Templates and Launch Configurations

You must specify a launch template or a launch configuration for your Auto Scaling group. Launch templates are newer, more flexible, and recommended over launch configurations.

**Example (Launch Template):**

You have a web application that requires a specific AMI with your application code, and you want to launch `t3.micro` instances. You create a launch template that specifies:

*   **AMI ID:** `ami-0123456789abcdef0`
*   **Instance Type:** `t3.micro`
*   **Key Pair:** `my-key-pair`
*   **Security Group:** `web-server-sg`

### 2. Desired, Minimum, and Maximum Capacity

These settings control the size of your Auto Scaling group.

*   **Real-life Example:** A popular e-commerce website.
    *   **`min-size` = 2:** You always want at least two instances running to ensure high availability. If one instance fails, the other can handle the traffic while a replacement is launched.
    *   **`max-size` = 10:** You want to limit your costs and prevent runaway scaling. The group will never have more than 10 instances.
    *   **`desired-capacity` = 2 (at launch):** When you first create the group, it will launch two instances. This can be adjusted by scaling policies.

### 3. Scaling Policies

Scaling policies define how the Auto Scaling group should scale in response to changing demand.

#### a. Manual Scaling

You manually change the desired capacity of the Auto Scaling group.

*   **Real-life Example:** You are about to launch a marketing campaign and expect a surge in traffic. You manually increase the `desired-capacity` from 2 to 5 an hour before the campaign starts.

#### b. Scheduled Scaling

Scaling actions are performed at specific times.

*   **Real-life Example:** A business application that is heavily used during business hours (9 AM to 5 PM, Monday to Friday).
    *   **Scale-out:** A scheduled action increases the `desired-capacity` to 5 at 8 AM every weekday.
    *   **Scale-in:** Another scheduled action decreases the `desired-capacity` back to 2 at 6 PM every weekday.

#### c. Dynamic Scaling

Scale the group in response to CloudWatch alarms.

##### i. Target Tracking Scaling

The most common and easy-to-use dynamic scaling policy. You select a metric and a target value. Auto Scaling creates and manages the CloudWatch alarms that trigger the scaling policy.

*   **Metric:** Average CPU Utilization
*   **Target Value:** 50%
*   **Real-life Example:** Your application's performance starts to degrade when CPU utilization goes above 50%.
    *   **Scale-out:** If the average CPU utilization of the group exceeds 50%, Auto Scaling will add new instances to bring the CPU utilization back down to 50%.
    *   **Scale-in:** If the CPU utilization drops significantly below 50%, Auto Scaling will remove instances.

##### ii. Step Scaling

You choose scaling metrics and thresholds for the CloudWatch alarms that invoke the scaling policy, and you also define how your Auto Scaling group should respond when the threshold is breached for a specified number of evaluation periods.

*   **Real-life Example:** You want more granular control over scaling.
    *   **Alarm:** Average CPU utilization > 70% for 5 minutes.
    *   **Scaling Policy:**
        *   If CPU is between 70% and 80%, add 1 instance.
        *   If CPU is between 80% and 90%, add 2 instances.
        *   If CPU is > 90%, add 3 instances.

##### iii. Simple Scaling

A legacy policy that is less responsive than step scaling. It waits for the scaling activity or health check to complete and the cooldown period to expire before responding to another alarm.

*   **Not Recommended:** Use Target Tracking or Step Scaling instead.

### 4. Health Checks

Auto Scaling can perform health checks on the instances in the group. If an instance is found to be unhealthy, it will be terminated and replaced.

*   **Types:**
    *   **`EC2` (default):** Checks the instance status. If the instance is not running, it's unhealthy.
    *   **`ELB`:** If you are using an Elastic Load Balancer, you can configure the Auto Scaling group to use the ELB's health checks. If an instance fails the ELB health check, it's considered unhealthy.
*   **Health Check Grace Period:** The time (in seconds) that Auto Scaling waits after an instance comes into service before checking its health status. This is useful for instances that need time to warm up.
*   **Real-life Example:** A web server instance might need a minute to start its services and become ready to serve traffic. You can set the `health-check-grace-period` to 60 seconds to prevent Auto Scaling from prematurely terminating a healthy but not-yet-ready instance.

### 5. Termination Policies

When scaling in, the termination policy determines which instances to terminate first.

*   **Default:** The `Default` policy is designed to be balanced and attempts to terminate instances across multiple Availability Zones. It prioritizes the termination of instances that are not protected from scale-in and were launched from the oldest launch template or launch configuration. If there are still multiple instances to choose from, it selects the instance that is closest to the next billing hour to maximize the use of the instance.
*   **Other Policies:** `OldestInstance`, `NewestInstance`, `OldestLaunchConfiguration`, `ClosestToNextInstanceHour`.
*   **Real-life Example:** You have a long-running task that should not be interrupted. You can use instance protection to prevent specific instances from being terminated during a scale-in event.

### 6. Instance Protection

You can protect instances from being terminated during a scale-in event.

*   **Real-life Example:** You have an instance that is running a critical batch job. You can enable instance protection for that instance. When the Auto Scaling group scales in, it will not terminate this protected instance. Once the job is finished, you can disable instance protection.

## Summary of Purpose and Real-Life Use Cases

*   **High Availability and Fault Tolerance:** Automatically replace unhealthy instances to maintain application uptime. If an EC2 instance crashes, Auto Scaling launches a new one to take its place.
*   **Cost Management:** Scale in during periods of low demand to save money. For example, a development or test environment that is not needed overnight can be scaled down to zero instances.
*   **Elasticity and Scalability:** Automatically scale out to meet an increase in demand, ensuring a smooth user experience. For example, a news website that experiences a sudden traffic spike due to a breaking news story can automatically add more servers to handle the load.
