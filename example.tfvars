# example.tfvars — CI dry-run plan (no real AWS credentials required)

aws_region  = "us-east-1"
environment = "dev"

# Management VPC (placeholder values for CI plan)
vpc_id     = "vpc-0management123456"
subnet_ids = ["subnet-0mgmt111aaa", "subnet-0mgmt222bbb"]

# Source CIDRs for AD port ingress (VPN subnet + management VPC)
allowed_cidrs = ["172.16.0.0/22", "10.200.0.0/16"]

# Domain
domain_name       = "corp.platform.internal"
domain_short_name = "CORP"

# Standard is sufficient for Client VPN auth
edition    = "Standard"
enable_sso = false

# DHCP options
enable_dhcp_options = true

# Secret recovery
secret_recovery_window_days = 7

team        = "infra-core"
cost_center = "infra-2026-q1"
