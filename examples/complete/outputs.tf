output "instance_id" {
  value       = module.postgresql.instance_id
  description = "Created high-availability PostgreSQL instance ID."
}

output "database_ids" {
  value       = module.postgresql.database_ids
  description = "Managed application database IDs."
}

output "account_ids" {
  value       = module.postgresql.account_ids
  description = "Managed application account IDs."
}

output "parameter_template_id" {
  value       = module.postgresql.parameter_template_id
  description = "Created parameter template ID. It is not attached by provider 0.0.70."
}

output "endpoints" {
  value       = module.postgresql.endpoints
  description = "Provider-returned instance connection endpoints."
  sensitive   = true
}
