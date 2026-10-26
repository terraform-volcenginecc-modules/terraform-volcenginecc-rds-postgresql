# terraform-volcenginecc-rds-postgresql

Draft Terraform module for Volcengine RDS PostgreSQL. It is intended for SaaS
backends, transactional applications, JSON or geospatial workloads, and
internal platforms.

> Status: `draft`. Terraform `1.5.7` and Registry Provider `0.0.70` have
> completed a disposable real-cloud lifecycle.

## 1. Overview

The caller owns the VPC, database subnet, and security groups. This module
creates one PostgreSQL instance and can optionally manage parameter templates,
allowlists, database accounts, databases, and explicit backup resources.

The `allow_lists` map uses stable caller-defined keys. Changing a map key
changes the Terraform resource address. The module never creates a public
endpoint or permits `0.0.0.0/0` through its caller-supplied IP allowlists.
Allowlists support CIDRs only; security group bindings are not supported.

Provider `0.0.70` has no instance field that attaches an RDS PostgreSQL
parameter template. When `parameter_template` is supplied, the module creates
and outputs the template, but cannot apply it to the instance. Do not treat
the template output as evidence that its parameters are active.

`manual_backups` manages explicit backup resources. Adding a key requests a
new backup; it is not a passive backup-policy-only setting. The RDS PostgreSQL
API does not support deleting Physical backups; use the retention policy as
the cleanup mechanism.

## 2. Usage

```hcl
module "postgresql" {
  source  = "terraform-volcenginecc-modules/rds-postgresql/volcenginecc"
  version = "~> 1.0"

  instance_name     = var.instance_name
  vpc_id            = var.vpc_id
  subnet_id         = var.subnet_id
  db_engine_version = var.db_engine_version
  nodes             = var.nodes
  charge_detail     = var.charge_detail
}
```

## 3. Examples

- `basic`: basic PostgreSQL for development or
  disposable validation.
- `complete`: production high availability,
  account and database creation, a parameter template, a private CIDR
  allowlist, and an explicit backup strategy.

## 4. Requirements

| Name | Version |
|---|---|
| Terraform | 1.5.7 |
| volcengine/volcenginecc | 0.0.70 |

## 5. Providers

| Name | Source |
|---|---|
| `volcenginecc` | `volcengine/volcenginecc` |

## 6. Resources

| Name | Description |
|---|---|
| PostgreSQL instance | One managed RDS PostgreSQL instance. |
| Optional child resources | Parameter templates, allowlists, accounts, databases, and explicit backups when configured. |

## 7. Inputs

| Name | Description | Required |
|---|---|---|
| `instance_name` | Instance name. | yes |
| `vpc_id` | Existing VPC ID. | yes |
| `subnet_id` | Existing database subnet ID. | yes |
| `db_engine_version` | PostgreSQL engine version. | yes |
| `nodes` | Ordered primary, secondary, and optional read-only node topology. | yes |
| `charge_detail` | Billing configuration. | yes |
| `storage_space_gb` | LocalSSD capacity in GB. | no |
| `allow_list_ids` / `allow_lists` | Existing or module-managed instance allowlists. | no |
| `allow_list_unbind_wait_seconds` | Seconds to wait after instance deletion before deleting module-managed allowlists; defaults to `600`. | no |
| `parameter_template` | Optional standalone PostgreSQL parameter template. | no |
| `accounts` / `account_passwords` | Database accounts and sensitive passwords. | no |
| `databases` | Databases and optional owners. | no |
| `manual_backups` | Explicit physical or logical backup resources. | no |

Refer to the module variable declarations for exact types, validations, and defaults.

## 8. Outputs

| Name | Description |
|---|---|
| Instance information | Instance identifiers and connection information returned by the Provider. |
| Optional child information | Identifiers for module-managed child resources. |

## 9. Notes

- Account passwords are sensitive inputs but are stored in Terraform state by
  the Provider. Use encrypted remote state and a secret manager-backed
  variable source.
- The module ignores computed billing detail changes returned by the Provider
  to avoid perpetual PostPaid updates. Validate all billing changes in a
  dedicated real-cloud fixture.
- The RDS PostgreSQL API cannot delete Physical backups. Destroying the module
  does not delete them; manage cleanup with the backup retention policy.
- RDS unbinds allowlists asynchronously after instance deletion. The module
  waits `allow_list_unbind_wait_seconds` before deleting module-managed
  allowlists; the default is `600` seconds and the supported range is `0` to
  `900` seconds.
- RDS PostgreSQL instance data sources in Provider `0.0.70` can read a bound
  `allow_list_ids` value as `null`. Do not use this field to determine
  allowlist bindings, drive conditional resources, or write instance
  allowlist configuration.
- PostgreSQL API constraints, resource replacement behavior, backup creation
  timing, and parameter-template application require real-cloud validation.
- Import support belongs to each Provider resource; import existing resources
  before declaring them in this module to avoid duplicate ownership.
- Before production use, run `init`, `validate`, and a disposable real-cloud
  lifecycle that includes create, read-back, a second `plan` with no changes,
  and destroy.
