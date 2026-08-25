# skills.md — aj-tf-module-directory

## Purpose
Provisions AWS Managed Microsoft AD (Directory Service) for LDAP/Kerberos authentication, used for VPN client auth and SSO federation.

## Type
`tf-module`

## Stable ref
```
source = "github.com/ajay-infra/aj-tf-module-directory?ref=v1.0.0"
```

## Key inputs
| Variable | Description |
|---|---|
| `environment` | dev \| staging \| uat \| prod |
| `name_prefix` | Resource name prefix |
| `vpc_id` | VPC to place the directory in |
| `subnet_ids` | Private subnet IDs (min 2, different AZs) |
| `allowed_cidrs` | CIDRs allowed to reach directory |
| `domain_name` | AD domain name (FQDN) |
| `domain_short_name` | NetBIOS short name |

## AWS tags applied
`Project`, `ManagedBy`, `Repository`, `Environment`, `Team`, `CostCenter` (set in
`locals.full_tags`), plus whatever's in `var.tags`. No `Env`, `Model`, or `Customer`
tag exists in this module.

## Branching convention
- `main` — active development
- semver tags (`v1.0.0`, ...) — stable pinned releases, per `README.md` usage examples

## CI checks
fmt, validate, plan (dry-run), tfsec/checkov

## Agentic capabilities
- Validate directory is in private subnets only
- Check allowed_cidrs doesn't include 0.0.0.0/0
- Flag if only one subnet AZ is provided (single point of failure)
