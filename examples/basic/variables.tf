variable "instance_name" {
  type        = string
  description = "Name of the minimal high-availability PostgreSQL instance."
  default     = "example-postgresql-basic"
}

variable "vpc_id" {
  type        = string
  description = "Existing VPC ID."
}

variable "subnet_id" {
  type        = string
  description = "Existing database subnet ID."
}

variable "zone_id" {
  type        = string
  description = "Available zone ID for the primary node."
}

variable "node_spec" {
  type        = string
  description = "PostgreSQL node specification available in the selected zone."
}

variable "project_name" {
  type        = string
  description = "Volcengine project name."
  default     = null
}
