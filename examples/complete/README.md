# Complete PostgreSQL

## 1. Overview

Creates a PostgreSQL 14 primary, secondary, and read-only topology with a private CIDR allowlist, application account and database, a standalone parameter template, and an explicit physical backup request.

## 2. Usage

```shell
terraform init
terraform plan
terraform apply
terraform plan
terraform destroy
```

## 3. Examples

This directory is the complete PostgreSQL example.

## 4. Requirements

| Name | Version |
|---|---|
| Terraform | `>= 1.5.7` |
| OpenTofu | `>= 1.11.8` |

## 5. Providers

| Name | Source |
|---|---|
| `volcenginecc` | `volcengine/volcenginecc` |

## 6. Resources

| Name | Description |
|---|---|
| `terraform-volcenginecc-modules/rds-postgresql/volcenginecc` | Published RDS PostgreSQL module. |

## 7. Inputs

| Name | Description |
|---|---|
| `vpc_id`, `subnet_id` | Existing VPC and database subnet IDs. |
| `primary_zone_id`, `secondary_zone_id` | Availability zones for the HA topology. |
| `node_spec` | PostgreSQL node specification available in both zones. |
| `application_cidrs` | Private application CIDRs for the allowlist. |
| `account_password` | Sensitive application-account password supplied through `TF_VAR_account_password`. |

## 8. Outputs

| Name | Description |
|---|---|
| Module outputs | PostgreSQL instance and module-managed child-resource identifiers. |

## 9. Notes

- Physical backups follow service retention because the API does not support deleting them.
- After instance deletion, the module waits 600 seconds before deleting
  module-managed CIDR allowlists while RDS completes asynchronous unbinding.
- RDS PostgreSQL instance data sources can read `allow_list_ids` as `null`;
  do not use this field to determine bindings or drive conditional resources.
- Provider `0.0.70` creates but cannot attach the parameter template.
- The final plan after apply must report no changes before destruction.
