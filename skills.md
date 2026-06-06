# skills.md — aj-tf-module-directory

## Purpose
Provisions AWS Managed Microsoft AD (Directory Service) for LDAP/Kerberos authentication, used for VPN client auth and SSO federation.

## Type
`tf-module`

## Stable ref
```
source = "github.com/ajaylakma/aj-tf-module-directory?ref=directory-01"
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
`Env`, `Team`, `ManagedBy`, `CostCenter`, `Model`, `Customer`

## Branching convention
- `main` — active development
- `directory-01` — stable pinned release

## CI checks
fmt, validate, plan (dry-run), tfsec/checkov

## Agentic capabilities
- Validate directory is in private subnets only
- Check allowed_cidrs doesn't include 0.0.0.0/0
- Flag if only one subnet AZ is provided (single point of failure)
