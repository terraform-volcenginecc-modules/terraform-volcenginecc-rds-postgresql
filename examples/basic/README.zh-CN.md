# 基础 PostgreSQL

## 1. 概述

创建满足服务要求的最小按量付费 PostgreSQL 14 拓扑，用于开发或一次性验证。调用方负责 VPC 与数据库子网。

## 2. 用法

```shell
terraform init
terraform plan
terraform apply
terraform plan
terraform destroy
```

## 3. 示例

本目录即为基础 PostgreSQL 示例。

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
| `vpc_id` | 已有 VPC ID。 |
| `subnet_id` | 已有数据库子网 ID。 |
| `zone_id` | Primary 与 Secondary 节点的可用区。 |
| `node_spec` | 目标可用区中可售的 PostgreSQL 节点规格。 |

## 8. 输出

| 名称 | 说明 |
|---|---|
| 模块输出 | PostgreSQL 实例标识和连接信息。 |

## 9. 注意事项

- 请将 `instance_name` 设置为唯一值。
- 本示例不创建白名单，配置白名单前数据库访问会保持拒绝状态。
- apply 后的最终 plan 必须报告无变更，才能执行销毁。
