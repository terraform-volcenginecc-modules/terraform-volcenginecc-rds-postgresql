variable "instance_name" {
  type        = string
  description = "Name of the RDS PostgreSQL instance."
}

variable "vpc_id" {
  type        = string
  description = "Existing VPC ID. The module does not manage the VPC."
}

variable "subnet_id" {
  type        = string
  description = "Existing database subnet ID. The module does not manage the subnet."
}

variable "db_engine_version" {
  type        = string
  description = "PostgreSQL engine version, for example PostgreSQL_14."

  validation {
    condition     = can(regex("^PostgreSQL_[0-9]+$", var.db_engine_version))
    error_message = "db_engine_version must use the PostgreSQL_<major> format."
  }
}

variable "nodes" {
  type = list(object({
    zone_id   = string
    node_spec = string
    node_type = string
  }))
  description = "Ordered instance node topology. Each item must fully specify zone_id, node_spec, and node_type."

  validation {
    condition = (
      length(var.nodes) >= 2 &&
      alltrue([for node in var.nodes : contains(["Primary", "Secondary", "ReadOnly"], node.node_type)]) &&
      length([for node in var.nodes : node if node.node_type == "Primary"]) == 1 &&
      length([for node in var.nodes : node if node.node_type == "Secondary"]) == 1
    )
    error_message = "nodes must include exactly one Primary and one Secondary; ReadOnly nodes are optional."
  }
}

variable "storage_space_gb" {
  type        = number
  description = "Purchased LocalSSD capacity in GB. The provider supports 20 to 3000 GB in 10 GB increments."
  default     = 100

  validation {
    condition     = var.storage_space_gb >= 20 && var.storage_space_gb <= 3000 && var.storage_space_gb % 10 == 0
    error_message = "storage_space_gb must be from 20 to 3000 GB in 10 GB increments."
  }
}

variable "charge_detail" {
  type = object({
    charge_type = string
    auto_renew  = optional(bool)
    period      = optional(number)
    period_unit = optional(string)
  })
  description = "Billing configuration."

  validation {
    condition     = contains(["PrePaid", "PostPaid"], var.charge_detail.charge_type)
    error_message = "charge_detail.charge_type must be PrePaid or PostPaid."
  }
}

variable "project_name" {
  type        = string
  description = "Volcengine project name."
  default     = null
}

variable "maintenance_window" {
  type = object({
    day_kind = optional(string, "Week")
    day_of_week_maintenance_time = optional(list(object({
      day_of_week                   = optional(string)
      maintenance_window_start_time = optional(string)
      period                        = optional(number)
    })), [])
  })
  description = "Optional weekly maintenance window."
  default     = null
}

variable "tags" {
  type        = set(object({ key = string, value = string }))
  description = "Tags applied to the instance."
  default     = []
}

variable "allow_list_ids" {
  type        = set(string)
  description = "Existing allowlist IDs to bind to the instance."
  default     = []
}

variable "allow_list_unbind_wait_seconds" {
  type        = number
  description = "Seconds to wait after instance deletion before deleting managed allowlists. The RDS API can require several minutes to complete unbinding."
  default     = 600

  validation {
    condition = (
      var.allow_list_unbind_wait_seconds >= 0 &&
      var.allow_list_unbind_wait_seconds <= 900 &&
      var.allow_list_unbind_wait_seconds == floor(var.allow_list_unbind_wait_seconds)
    )
    error_message = "allow_list_unbind_wait_seconds must be an integer from 0 to 900."
  }
}

variable "allow_lists" {
  type = map(object({
    name         = string
    category     = optional(string, "Ordinary")
    description  = optional(string)
    ip_addresses = optional(set(string), [])
  }))
  description = "CIDR allowlists managed by stable logical key."
  default     = {}

  validation {
    condition = alltrue(flatten([
      for allow_list in values(var.allow_lists) : [
        for cidr in allow_list.ip_addresses : can(cidrhost(cidr, 0)) && cidr != "0.0.0.0/0"
      ]
    ]))
    error_message = "allow_lists.ip_addresses must be valid CIDRs and must not include 0.0.0.0/0."
  }
}

variable "parameter_template" {
  type = object({
    name        = string
    description = optional(string)
    parameters  = set(object({ name = string, value = string }))
  })
  description = "Optional PostgreSQL parameter template. Provider 0.0.70 cannot attach it to the instance."
  default     = null
}

variable "accounts" {
  type = map(object({
    name                 = string
    type                 = optional(string, "Normal")
    privileges           = optional(string)
    not_allow_privileges = optional(set(string), [])
  }))
  description = "Database accounts managed by stable logical key."
  default     = {}

  validation {
    condition     = alltrue([for account in values(var.accounts) : contains(["Super", "Normal", "InstanceReadOnly"], account.type)])
    error_message = "accounts.type must be Super, Normal, or InstanceReadOnly."
  }
}

variable "account_passwords" {
  type        = map(string)
  description = "Sensitive account passwords keyed identically to accounts. Passwords are stored in Terraform state by the provider."
  default     = {}
  sensitive   = true
}

variable "databases" {
  type = map(object({
    name               = string
    character_set_name = optional(string, "utf8")
    collate            = optional(string)
    c_type             = optional(string)
    owner              = optional(string)
  }))
  description = "Databases managed by stable logical key."
  default     = {}
}

variable "manual_backups" {
  type = map(object({
    description    = optional(string)
    database_names = optional(set(string), [])
    method         = optional(string, "Physical")
    scope          = optional(string, "Instance")
    type           = optional(string, "Full")
    download       = optional(bool, false)
    policy = optional(object({
      backup_retention_period    = optional(number)
      data_incr_backup_periods   = optional(string)
      full_backup_period         = optional(string)
      full_backup_time           = optional(string)
      hourly_incr_backup_enable  = optional(bool)
      increment_backup_frequency = optional(number)
      wal_log_space_limit_enable = optional(bool)
    }))
  }))
  description = "Explicit backup resources managed by stable logical key. Creating a key creates a backup."
  default     = {}
}
