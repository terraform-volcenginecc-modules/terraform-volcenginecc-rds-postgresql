output "instance_id" {
  description = "ID of the managed RDS PostgreSQL instance."
  value       = volcenginecc_rdspostgresql_instance.this.instance_id
}

output "instance_name" {
  description = "Name of the managed RDS PostgreSQL instance."
  value       = volcenginecc_rdspostgresql_instance.this.instance_name
}

output "endpoints" {
  description = "Provider-returned instance connection endpoint metadata."
  value       = volcenginecc_rdspostgresql_instance.this.endpoints
  sensitive   = true
}

output "allow_list_ids" {
  description = "Managed and externally supplied allowlist IDs bound to the instance."
  value       = local.allow_list_ids
}

output "parameter_template_id" {
  description = "ID of the managed parameter template, if configured."
  value       = try(volcenginecc_rdspostgresql_parameter_template.this[0].template_id, null)
}

output "database_ids" {
  description = "Database resource IDs keyed by the caller's stable logical keys."
  value       = { for key, database in volcenginecc_rdspostgresql_database.this : key => database.id }
}

output "account_ids" {
  description = "Database account resource IDs keyed by the caller's stable logical keys."
  value       = { for key, account in volcenginecc_rdspostgresql_db_account.this : key => account.id }
}

output "backup_ids" {
  description = "Explicit backup IDs keyed by the caller's stable logical keys."
  value       = { for key, backup in volcenginecc_rdspostgresql_backup.this : key => backup.backup_id }
}
