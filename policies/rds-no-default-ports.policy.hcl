# Copyright IBM Corp. 2026

# RDS instances should not use a database engine default port

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "rds-no-default-ports-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_db_instance" "no_default_port" {
    enforcement_level = input.rds-no-default-ports-enforcement-level
    locals {
        engine = core::try(attrs.engine, "")
        configured_port = attrs.port
        
        # Determine default port based on engine type
        engine_port_map = {
            "mysql" = 3306
            "mariadb" = 3306
            "aurora-mysql" = 3306
            "postgres" = 5432
            "aurora-postgresql" = 5432
            "oracle-ee" = 1521
            "oracle-ee-cdb" = 1521
            "oracle-se2" = 1521
            "oracle-se2-cdb" = 1521
            "sqlserver-ee" = 1433
            "sqlserver-se" = 1433
            "sqlserver-ex" = 1433
            "sqlserver-web" = 1433
            "sqlserver-dev-ee" = 1433
            "db2-ae" = 50000
            "db2-se" = 50000
        }
        
        default_port = core::try(local.engine_port_map[local.engine], 0)
    }

    enforce {
        condition = local.configured_port != local.default_port
        error_message = "RDS instance uses the default port. Configure a non-default port to reduce attack surface"
    }
}

# Check RDS clusters (Aurora and Multi-AZ)
resource_policy "aws_rds_cluster" "no_default_port_cluster" {
    enforcement_level = input.rds-no-default-ports-enforcement-level
    locals {
        engine = core::try(attrs.engine, "")
        configured_port = attrs.port
        
        engine_port_map = {
            "mysql" = 3306
            "aurora-mysql" = 3306
            "postgres" = 5432
            "aurora-postgresql" = 5432
        }
        
        default_port = core::try(local.engine_port_map[local.engine], 0)
    }

    enforce {
        condition = local.configured_port != local.default_port
        error_message = "RDS cluster uses the default port. Configure a non-default port to reduce attack surface"
    }
}
