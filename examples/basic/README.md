# Basic PostgreSQL

## 1. Overview

Creates the smallest supported pay-as-you-go PostgreSQL 14 topology for development or disposable validation. The caller owns the VPC and database subnet.

## 2. Usage

```shell
terraform init
terraform plan
terraform apply
terraform plan
terraform destroy
```

## 3. Examples

This directory is the basic PostgreSQL example.

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
| `vpc_id` | Existing VPC ID. |
| `subnet_id` | Existing database subnet ID. |
| `zone_id` | Availability zone for primary and secondary nodes. |
| `node_spec` | PostgreSQL node specification available in the target zone. |

## 8. Outputs

| Name | Description |
|---|---|
| Module outputs | PostgreSQL instance identifiers and connection information. |

## 9. Notes

- Set `instance_name` to a unique value.
- This example creates no allowlist, so database access remains denied until one is configured.
- The final plan after apply must report no changes before destruction.
