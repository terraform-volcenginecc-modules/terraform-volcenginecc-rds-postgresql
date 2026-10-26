module "postgresql" {
  source  = "terraform-volcenginecc-modules/rds-postgresql/volcenginecc"
  version = "~> 1.0"

  instance_name     = var.instance_name
  vpc_id            = var.vpc_id
  subnet_id         = var.subnet_id
  db_engine_version = "PostgreSQL_14"
  storage_space_gb  = 100

  nodes = [
    {
      zone_id   = var.zone_id
      node_spec = var.node_spec
      node_type = "Primary"
    }
    ,
    {
      zone_id   = var.zone_id
      node_spec = var.node_spec
      node_type = "Secondary"
    }
  ]

  charge_detail = {
    charge_type = "PostPaid"
  }

  project_name = var.project_name
}
