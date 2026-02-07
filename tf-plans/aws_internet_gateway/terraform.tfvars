# Example variable values for the Internet Gateway wrapper plan

region                  = "ca-central-1"
vpc_id                  = "vpc-056cd97ff3714931d"
enable_internet_gateway = true
name                    = "app-igw"

tags = {
  Environment = "dev"
  Project     = "OpenVPN"
}
