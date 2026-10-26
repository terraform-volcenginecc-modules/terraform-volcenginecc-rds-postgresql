# terraform-volcenginecc-rds-postgresql

基于 `volcenginecc` Provider 的 Terraform 模块，用于创建火山引擎托管
PostgreSQL 实例，并可选管理白名单、数据库账号、数据库、参数模板和显式备份。

## 1. 概述

调用方负责 VPC、数据库子网和安全组。本模块不创建公网端点，也拒绝在调用方
提供的 IP 白名单中使用 `0.0.0.0/0`。

`allow_lists` 使用调用方定义的稳定键。修改键会改变 Terraform 资源地址。
白名单仅支持 CIDR 地址，不支持通过安全组绑定。
账号密码是敏感输入，Provider 会将其写入状态；请使用加密远端状态和密钥管理
系统提供变量。

Provider `0.0.70` 没有将 PostgreSQL 参数模板绑定到实例的字段。配置
`parameter_template` 时，模块仅创建并输出模板，不能将其视为参数已经生效。

`manual_backups` 会创建显式备份，并非仅设置策略。RDS PostgreSQL API 不支持
删除 Physical 备份，应使用其保留策略完成清理。

## 2. 用法

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

## 3. 示例

- `examples/basic`：用于开发或一次性验证的基础 PostgreSQL 配置。
- `examples/complete`：覆盖生产高可用、账号、数据库、参数模板、私网 CIDR
  白名单和备份策略。

## 4. 版本要求

| 名称 | 版本 |
|---|---|
| Terraform | `1.5.7` |
| `volcengine/volcenginecc` | `0.0.70` |

## 5. Provider

| 名称 | 来源 |
|---|---|
| `volcenginecc` | `volcengine/volcenginecc` |

## 6. 资源

| 名称 | 说明 |
|---|---|
| PostgreSQL 实例 | 一个受模块管理的 RDS PostgreSQL 实例。 |
| 可选子资源 | 配置时管理参数模板、白名单、账号、数据库和显式备份。 |

## 7. 输入

| 名称 | 说明 | 必填 |
|---|---|---|
| `instance_name` | 实例名称。 | 是 |
| `vpc_id` | 已有 VPC ID。 | 是 |
| `subnet_id` | 已有数据库子网 ID。 | 是 |
| `db_engine_version` | PostgreSQL 引擎版本。 | 是 |
| `nodes` | Primary、Secondary 与可选 ReadOnly 节点拓扑。 | 是 |
| `charge_detail` | 计费配置。 | 是 |
| `storage_space_gb` | LocalSSD 容量。 | 否 |
| `allow_list_ids` / `allow_lists` | 已有或模块管理的实例白名单。 | 否 |
| `allow_list_unbind_wait_seconds` | 实例删除后、删除模块管理白名单前的等待秒数，默认 `600`。 | 否 |
| `parameter_template` | 独立 PostgreSQL 参数模板。 | 否 |
| `accounts` / `account_passwords` | 数据库账号与敏感密码。 | 否 |
| `databases` | 数据库与可选 owner。 | 否 |
| `manual_backups` | 显式备份资源。 | 否 |

精确类型、校验和默认值请参阅模块变量声明。

## 8. 输出

| 名称 | 说明 |
|---|---|
| 实例信息 | Provider 返回的实例标识和连接信息。 |
| 可选子资源信息 | 模块管理的子资源标识。 |

## 9. 注意事项

- Provider 返回的计费时间与状态为计算属性，模块会忽略其变化。
- RDS PostgreSQL API 不支持删除 Physical 备份；销毁模块不会删除该类备份，
  应通过备份保留策略清理。
- 实例删除后，RDS 会异步解绑白名单。模块会在删除模块管理的白名单前等待
  `allow_list_unbind_wait_seconds` 秒，默认 `600` 秒，可配置范围为 `0` 至
  `900` 秒。
- Provider `0.0.70` 的 RDS PostgreSQL 实例 Data Source 可能将已绑定的
  `allow_list_ids` 回读为 `null`。该值不能用于判断白名单绑定状态、条件编排
  或回写实例白名单配置。
- 导入已有资源后再声明到模块中，避免重复归属。
- apply 后必须再次执行 `terraform plan`，确认输出 `No changes`。
