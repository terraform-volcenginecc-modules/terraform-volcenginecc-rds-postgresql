output "instance_id" {
  value       = module.postgresql.instance_id
  description = "Created minimal high-availability PostgreSQL instance ID."
}

output "endpoints" {
  value       = module.postgresql.endpoints
  description = "Provider-returned instance connection endpoints."
  sensitive   = true
}
