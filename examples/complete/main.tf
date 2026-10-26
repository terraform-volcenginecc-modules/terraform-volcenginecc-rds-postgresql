module "postgresql" {
  source  = "terraform-volcenginecc-modules/rds-postgresql/volcenginecc"
  version = "~> 1.0"

  instance_name     = var.instance_name
  vpc_id            = var.vpc_id
  subnet_id         = var.subnet_id
  db_engine_version = "PostgreSQL_14"
  storage_space_gb  = 500
  project_name      = var.project_name

  nodes = [
    {
      zone_id   = var.primary_zone_id
      node_spec = var.node_spec
      node_type = "Primary"
    },
    {
      zone_id   = var.secondary_zone_id
      node_spec = var.node_spec
      node_type = "Secondary"
    },
    {
      zone_id   = var.primary_zone_id
      node_spec = var.node_spec
      node_type = "ReadOnly"
    }
  ]

  charge_detail = {
    charge_type = "PostPaid"
  }

  tags = [{ key = "environment", value = "production" }]

  maintenance_window = {
    day_of_week_maintenance_time = [
      {
        day_of_week                   = "Sunday"
        maintenance_window_start_time = "18:00Z"
        period                        = 2
      }
    ]
  }

  parameter_template = {
    name        = "${var.instance_name}-parameters"
    description = "Production PostgreSQL parameter template"
    parameters = [
      { name = "log_min_duration_statement", value = "500" },
    ]
  }

  allow_lists = {
    application = {
      name         = "${var.instance_name}-application"
      description  = "Application database access"
      ip_addresses = var.application_cidrs
    }
  }

  accounts = {
    application = {
      name       = var.account_name
      type       = "Normal"
      privileges = "Inherit,Login"
    }
  }

  account_passwords = {
    application = var.account_password
  }

  databases = {
    application = {
      name               = var.database_name
      character_set_name = "utf8"
      collate            = "C.UTF-8"
      c_type             = "C.UTF-8"
      owner              = var.account_name
    }
  }

  manual_backups = {
    weekly_full = {
      description = "Production PostgreSQL full backup"
      method      = "Physical"
      scope       = "Instance"
      type        = "Full"
      policy = {
        backup_retention_period    = 14
        full_backup_period         = "Monday,Wednesday,Friday,Sunday"
        full_backup_time           = "18:00Z-19:00Z"
        hourly_incr_backup_enable  = true
        increment_backup_frequency = 2
        wal_log_space_limit_enable = true
      }
    }
  }
}
