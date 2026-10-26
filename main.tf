locals {
  managed_allow_list_ids = toset([
    for allow_list in volcenginecc_rdspostgresql_allow_list.this : allow_list.allow_list_id
  ])
  allow_list_ids = setunion(var.allow_list_ids, local.managed_allow_list_ids)
}

resource "volcenginecc_rdspostgresql_parameter_template" "this" {
  count = var.parameter_template == null ? 0 : 1

  template_name         = var.parameter_template.name
  template_params       = var.parameter_template.parameters
  template_type         = "PostgreSQL"
  template_type_version = var.db_engine_version
  template_desc         = var.parameter_template.description
}

resource "volcenginecc_rdspostgresql_allow_list" "this" {
  for_each = var.allow_lists

  allow_list_category = each.value.category
  allow_list_desc     = each.value.description
  allow_list_name     = each.value.name
  allow_list_type     = "IPv4"
  user_allow_list = length([
    for ip in coalesce(try(each.value.ip_addresses, null), []) : try(trimspace(ip), "")
    if try(trimspace(ip), "") != ""
    ]) == 0 ? null : join(",", sort(distinct([
      for ip in coalesce(try(each.value.ip_addresses, null), []) : try(trimspace(ip), "")
      if try(trimspace(ip), "") != ""
  ])))
}

# The RDS API completes allowlist unbinding asynchronously after instance deletion.
resource "time_sleep" "allow_list_unbind_wait" {
  count = length(var.allow_lists) == 0 ? 0 : 1

  destroy_duration = "${var.allow_list_unbind_wait_seconds}s"

  depends_on = [volcenginecc_rdspostgresql_allow_list.this]
}

resource "volcenginecc_rdspostgresql_instance" "this" {
  db_engine_version = var.db_engine_version
  node_info         = var.nodes
  storage_type      = "LocalSSD"
  vpc_id            = var.vpc_id
  subnet_id         = var.subnet_id
  charge_detail     = var.charge_detail

  allow_list_ids     = local.allow_list_ids
  instance_name      = var.instance_name
  maintenance_window = var.maintenance_window
  project_name       = var.project_name
  storage_space      = var.storage_space_gb
  tags               = length(var.tags) == 0 ? null : var.tags

  # The provider returns computed billing timestamps and status in this block.
  lifecycle {
    ignore_changes = [charge_detail]
  }

  depends_on = [time_sleep.allow_list_unbind_wait]
}

resource "volcenginecc_rdspostgresql_db_account" "this" {
  for_each = var.accounts

  instance_id          = volcenginecc_rdspostgresql_instance.this.instance_id
  account_name         = each.value.name
  account_password     = var.account_passwords[each.key]
  account_type         = each.value.type
  account_privileges   = each.value.privileges
  not_allow_privileges = length(each.value.not_allow_privileges) == 0 ? null : each.value.not_allow_privileges

  lifecycle {
    precondition {
      condition     = contains(keys(var.account_passwords), each.key)
      error_message = "account_passwords must contain a password for every accounts key."
    }
  }
}

resource "volcenginecc_rdspostgresql_database" "this" {
  for_each = var.databases

  instance_id        = volcenginecc_rdspostgresql_instance.this.instance_id
  db_name            = each.value.name
  character_set_name = each.value.character_set_name
  collate            = each.value.collate
  c_type             = each.value.c_type
  owner              = each.value.owner

  depends_on = [volcenginecc_rdspostgresql_db_account.this]
}

resource "volcenginecc_rdspostgresql_backup" "this" {
  for_each = var.manual_backups

  instance_id        = volcenginecc_rdspostgresql_instance.this.instance_id
  backup_description = each.value.description
  backup_meta        = length(each.value.database_names) == 0 ? null : [for db_name in each.value.database_names : { db_name = db_name }]
  backup_method      = each.value.method
  backup_policy      = each.value.policy
  backup_scope       = each.value.scope
  backup_type        = each.value.type
  download_backup    = each.value.download

  depends_on = [volcenginecc_rdspostgresql_database.this]
}
