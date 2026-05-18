# ── Core ──────────────────────────────────────────────────────────────────────

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Environment label (dev | staging | prod)."
  default     = "dev"
}

variable "name_prefix" {
  type        = string
  description = "Prefix for all resource names. Defaults to <environment>."
  default     = ""
}

# ── Network ───────────────────────────────────────────────────────────────────

variable "vpc_id" {
  type        = string
  description = "Management VPC ID. AD lives in the management VPC — separate from workload VPCs."
}

variable "subnet_ids" {
  type        = list(string)
  description = <<-EOT
    Exactly 2 subnet IDs in different AZs — AWS Managed Microsoft AD requirement.
    Must be private subnets in the management VPC.
  EOT
  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "AWS Managed Microsoft AD requires at least 2 subnets in different AZs."
  }
}

variable "allowed_cidrs" {
  type        = list(string)
  description = <<-EOT
    CIDR blocks allowed to reach AD ports (DNS, Kerberos, LDAP, SMB).
    Typically: Client VPN subnet + management VPC CIDR.
    Use specific CIDRs — avoid 0.0.0.0/0 (AD should never be internet-accessible).
  EOT
}

# ── Directory ─────────────────────────────────────────────────────────────────

variable "domain_name" {
  type        = string
  description = <<-EOT
    Fully qualified domain name for the AD directory.
    Must be a valid DNS name. Use an internal domain — not a public domain.
    Example: corp.platform.internal
  EOT
}

variable "domain_short_name" {
  type        = string
  description = <<-EOT
    NetBIOS name (short name) for the domain. Max 15 characters, no dots.
    Used for Windows workstation domain join and pre-Windows 2000 compatibility.
    Example: CORP
  EOT
  validation {
    condition     = length(var.domain_short_name) <= 15 && !can(regex("\\.", var.domain_short_name))
    error_message = "domain_short_name must be 15 characters or fewer and must not contain dots."
  }
}

variable "edition" {
  type        = string
  description = <<-EOT
    AWS Managed Microsoft AD edition.
      Standard  — up to 30,000 objects, sufficient for Client VPN auth and small orgs. ~$146/month.
      Enterprise — up to 500,000 objects, trusts, schema extensions. ~$288/month.
    Use Standard unless you need trusts or very large object counts.
  EOT
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "Enterprise"], var.edition)
    error_message = "edition must be Standard or Enterprise."
  }
}

variable "enable_sso" {
  type        = bool
  description = "Enable AWS Single Sign-On with this directory. Requires Enterprise edition."
  default     = false
}

# ── DHCP Options ──────────────────────────────────────────────────────────────

variable "enable_dhcp_options" {
  type        = bool
  description = <<-EOT
    Create and associate a DHCP options set that points the management VPC to AD DNS.
    Enables DNS resolution of corp.* names for VPN-connected engineers.
    Disable only if you manage DHCP options separately.
  EOT
  default     = true
}

# ── Secrets ───────────────────────────────────────────────────────────────────

variable "secret_recovery_window_days" {
  type        = number
  description = "Days before a deleted Secrets Manager secret is permanently purged (0 or 7-30)."
  default     = 30
}

# ── Tags ──────────────────────────────────────────────────────────────────────

variable "team" {
  type    = string
  default = "infra-core"
}

variable "cost_center" {
  type    = string
  default = "infra-2026-q1"
}

variable "tags" {
  type    = map(string)
  default = {}
}
