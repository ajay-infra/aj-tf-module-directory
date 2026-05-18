locals {
  name_prefix = var.name_prefix != "" ? var.name_prefix : var.environment

  full_tags = merge({
    Project     = "aj-infra-platform"
    ManagedBy   = "Terraform"
    Repository  = "aj-tf-module-directory"
    Environment = var.environment
    Team        = var.team
    CostCenter  = var.cost_center
  }, var.tags)
}
