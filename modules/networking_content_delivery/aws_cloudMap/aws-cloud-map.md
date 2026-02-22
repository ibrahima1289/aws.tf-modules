# AWS Cloud Map

AWS Cloud Map is a cloud resource discovery service. With Cloud Map, you can define custom names for your application resources, and it maintains the updated location of these dynamically changing resources. This increases your application availability because your web service always discovers the most up-to-date locations of its resources.

## Key Features
- **Dynamic Service Discovery:** Automatically tracks the health and location of microservices.
- **API and DNS Based Discovery:** Discover resources using simple DNS queries or via the Cloud Map API.
- **Health Checking:** Automatically removes unhealthy service instances from the registry.
- **Integration:** Works seamlessly with Amazon ECS, EKS, and Lambda.

## Real-Life Example Application: Microservices Communication
A social media application consists of dozens of microservices (User Profile, Feed, Messaging, etc.) running on Amazon ECS. As the application scales, ECS containers are frequently started and stopped, changing their IP addresses. Each service registers itself with AWS Cloud Map upon startup. When the "Feed" service needs to call the "User Profile" service, it queries Cloud Map (using a friendly name like `profile.socialapp.local`) to get a list of healthy IP addresses, ensuring reliable communication in a dynamic environment.
