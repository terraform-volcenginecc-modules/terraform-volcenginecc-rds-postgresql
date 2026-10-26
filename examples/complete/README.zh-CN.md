# 完整 PostgreSQL

## 1. 概述

创建 PostgreSQL 14 的 Primary、Secondary 和 ReadOnly 高可用拓扑，并管理私网 CIDR 白名单、应用账号与数据库、独立参数模板和显式物理备份请求。

## 2. 用法

```shell
terraform init
terraform plan
terraform apply
terraform plan
terraform destroy
```

## 3. 示例

本目录即为完整 PostgreSQL 示例。

## 4. 版本要求

| 名称 | 版本 |
|---|---|
| Terraform | `>= 1.5.7` |
| OpenTofu | `>= 1.11.8` |

## 5. Provider

| 名称 | 来源 |
|---|---|
| `volcenginecc` | `volcengine/volcenginecc` |

## 6. 资源

| 名称 | 说明 |
|---|---|
| `terraform-volcenginecc-modules/rds-postgresql/volcenginecc` | 已发布的 RDS PostgreSQL 模块。 |

## 7. 输入

| 名称 | 说明 |
|---|---|
| `vpc_id`、`subnet_id` | 已有 VPC 和数据库子网 ID。 |
| `primary_zone_id`、`secondary_zone_id` | 高可用拓扑的可用区。 |
| `node_spec` | 两个可用区均可售的 PostgreSQL 节点规格。 |
| `application_cidrs` | 白名单使用的私网应用 CIDR。 |
| `account_password` | 通过 `TF_VAR_account_password` 传入的敏感应用账号密码。 |

## 8. 输出

| 名称 | 说明 |
|---|---|
| 模块输出 | PostgreSQL 实例和模块管理子资源的标识。 |

## 9. 注意事项

- Physical 备份由服务保留策略处理，因为 API 不支持删除。
- 实例删除后，模块默认等待 600 秒，再删除模块管理的 CIDR 白名单，以等待
  RDS 异步完成解绑。
- RDS PostgreSQL 实例 Data Source 的 `allow_list_ids` 可能回读为 `null`，
  不能用于判断白名单绑定状态或条件编排。
- Provider `0.0.70` 可创建但不能绑定参数模板。
- apply 后的最终 plan 必须报告无变更，才能执行销毁。
