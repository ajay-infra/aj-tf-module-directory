# envs/prod.tfvars — prod management VPC directory

aws_region  = "us-east-1"
environment = "prod"

vpc_id     = "REPLACE_WITH_MGMT_VPC_ID"
subnet_ids = ["REPLACE_WITH_MGMT_SUBNET_A", "REPLACE_WITH_MGMT_SUBNET_B"]

# VPN client CIDR + management VPC CIDR
allowed_cidrs = ["172.16.0.0/22", "10.201.0.0/16"]

domain_name       = "corp.platform.internal"
domain_short_name = "CORP"

# Enterprise for prod if trusts or schema extensions are needed; Standard otherwise
edition    = "Standard"
enable_sso = false

enable_dhcp_options         = true
secret_recovery_window_days = 30

team        = "infra-core"
cost_center = "infra-2026-q1"
