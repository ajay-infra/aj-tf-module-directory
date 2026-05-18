# ── Admin Password ────────────────────────────────────────────────────────────
# Generated at apply time — never in tfvars, never in state in plaintext.
# Stored in Secrets Manager immediately.

resource "random_password" "admin" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}:?"
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
}

resource "aws_secretsmanager_secret" "admin_password" {
  name                    = "${local.name_prefix}/directory/admin-password"
  description             = "AWS Managed Microsoft AD admin password for ${var.domain_name}"
  recovery_window_in_days = var.secret_recovery_window_days

  tags = local.full_tags
}

resource "aws_secretsmanager_secret_version" "admin_password" {
  secret_id = aws_secretsmanager_secret.admin_password.id

  secret_string = jsonencode({
    username     = "Admin"
    password     = random_password.admin.result
    domain       = var.domain_name
    domain_short = var.domain_short_name
  })
}

# ── AWS Managed Microsoft AD ──────────────────────────────────────────────────
# Lives in the management VPC — completely separate from workload VPCs.
# Used for: Client VPN authentication, machine accounts, engineer LDAP auth.

resource "aws_directory_service_directory" "main" {
  name       = var.domain_name
  short_name = var.domain_short_name
  password   = random_password.admin.result
  edition    = var.edition
  type       = "MicrosoftAD"
  enable_sso = var.enable_sso

  vpc_settings {
    vpc_id     = var.vpc_id
    subnet_ids = slice(var.subnet_ids, 0, 2)
  }

  tags = local.full_tags

  # Password change forces directory recreation — lifecycle prevents this
  lifecycle {
    ignore_changes = [password]
  }
}

# ── Security Group ────────────────────────────────────────────────────────────
# All ports required by Microsoft AD. Source is allowed_cidrs — typically the
# Client VPN subnet + management VPC CIDR.

resource "aws_security_group" "directory" {
  name        = "${local.name_prefix}-directory"
  description = "AWS Managed Microsoft AD — required AD port ingress"
  vpc_id      = var.vpc_id

  # DNS
  ingress {
    description = "DNS (TCP)"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
  }
  ingress {
    description = "DNS (UDP)"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = var.allowed_cidrs
  }

  # Kerberos authentication
  ingress {
    description = "Kerberos (TCP)"
    from_port   = 88
    to_port     = 88
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
  }
  ingress {
    description = "Kerberos (UDP)"
    from_port   = 88
    to_port     = 88
    protocol    = "udp"
    cidr_blocks = var.allowed_cidrs
  }

  # LDAP
  ingress {
    description = "LDAP (TCP)"
    from_port   = 389
    to_port     = 389
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
  }
  ingress {
    description = "LDAP (UDP)"
    from_port   = 389
    to_port     = 389
    protocol    = "udp"
    cidr_blocks = var.allowed_cidrs
  }

  # SMB / AD replication
  ingress {
    description = "SMB (TCP)"
    from_port   = 445
    to_port     = 445
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
  }

  # Kerberos password change
  ingress {
    description = "Kerberos password change (TCP)"
    from_port   = 464
    to_port     = 464
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
  }
  ingress {
    description = "Kerberos password change (UDP)"
    from_port   = 464
    to_port     = 464
    protocol    = "udp"
    cidr_blocks = var.allowed_cidrs
  }

  # LDAPS (LDAP over SSL)
  ingress {
    description = "LDAPS (TCP)"
    from_port   = 636
    to_port     = 636
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
  }

  # Global Catalog (cross-domain queries in multi-domain forests)
  ingress {
    description = "Global Catalog (TCP)"
    from_port   = 3268
    to_port     = 3268
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
  }
  ingress {
    description = "Global Catalog SSL (TCP)"
    from_port   = 3269
    to_port     = 3269
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.full_tags, { Name = "${local.name_prefix}-directory" })
}

# ── DHCP Options ──────────────────────────────────────────────────────────────
# Points the management VPC to AD DNS servers so VPN-connected engineers can
# resolve corp.* names and authenticate against AD.

resource "aws_vpc_dhcp_options" "main" {
  count = var.enable_dhcp_options ? 1 : 0

  domain_name         = var.domain_name
  domain_name_servers = tolist(aws_directory_service_directory.main.dns_ip_addresses)

  tags = merge(local.full_tags, { Name = "${local.name_prefix}-directory-dhcp" })
}

resource "aws_vpc_dhcp_options_association" "main" {
  count = var.enable_dhcp_options ? 1 : 0

  vpc_id          = var.vpc_id
  dhcp_options_id = aws_vpc_dhcp_options.main[0].id
}
