# CLAUDE.md — aj-tf-module-directory

> Local context file for Claude Code. Not pushed to GitHub.

## What This Module Does

AWS Managed Microsoft AD in the management VPC. Used for Client VPN authentication.
Provisioned once per account tier (nonprod or prod), before aj-tf-module-vpn.

## Module Structure

```
main.tf      → random_password, aws_secretsmanager_secret,
               aws_directory_service_directory, aws_security_group,
               aws_vpc_dhcp_options, aws_vpc_dhcp_options_association
variables.tf → vpc_id, subnet_ids, allowed_cidrs, domain_name, domain_short_name,
               edition, enable_sso, enable_dhcp_options, secret_recovery_window_days
locals.tf    → name_prefix, full_tags
outputs.tf   → directory_id, dns_ip_addresses, alias, security_group_id,
               admin_secret_arn, dhcp_options_id
providers.tf → aws + random providers, skip_* flags
```

## Key Design Decisions

- **random_password + Secrets Manager** — admin password never in tfvars or state plaintext;
  `lifecycle { ignore_changes = [password] }` on directory prevents recreation on state refresh
- **slice(subnet_ids, 0, 2)** — AD requires exactly 2 subnets; slice ensures we never pass more
- **enable_dhcp_options = true** — points management VPC DNS to AD servers so VPN-connected
  engineers resolve corp.* names; toggle off only if DHCP managed separately
- **allowed_cidrs** — never 0.0.0.0/0; always scoped to VPN client CIDR + management VPC CIDR

## Outputs → aj-tf-module-vpn

```hcl
module "vpn" {
  directory_id = module.directory.directory_id   # for AD-based VPN auth
  dns_servers  = module.directory.dns_ip_addresses  # for VPN DNS config
}
```

## Known TODOs

- [ ] Fill in vpc_id + subnet_ids in envs/*.tfvars after management VPC is provisioned
- [ ] Test domain join after VPN is working
- [ ] Add AD users/groups for engineer access (manual step in AD console, not Terraform)
