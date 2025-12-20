# Example variable values for the Internet Gateway wrapper plan

region                 = "ca-central-1"
vpc_id                 = "vpc-08101d4a1dce70809"
enable_internet_gateway = true
name                   = "app-igw"

tags = {
  Environment = "dev"
  Project     = "OpenVPN"
}
