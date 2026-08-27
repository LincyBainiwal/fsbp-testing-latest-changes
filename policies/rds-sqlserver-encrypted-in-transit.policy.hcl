# Copyright IBM Corp. 2026

# RDS for SQL Server DB instances should be encrypted in transit

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "rds-sqlserver-encrypted-in-transit-enforcement-level" {
  type = string
  default = "advisory"
}

# Check SQL Server DB instances for encryption in transit
resource_policy "aws_db_instance" "sqlserver_ssl_check" {
  enforcement_level = input.rds-sqlserver-encrypted-in-transit-enforcement-level
  filter = core::contains(["sqlserver-dev-ee", "sqlserver-ee", "sqlserver-se", "sqlserver-ex", "sqlserver-web"], core::try(attrs.engine, ""))
  
  locals {
    param_group_name = core::try(attrs.parameter_group_name, "")
    sqlserver_all_parameter_groups = core::getresources("aws_db_parameter_group", {
      name = local.param_group_name
    })
    has_matching_pg = core::length(local.sqlserver_all_parameter_groups) > 0
    param_group = local.has_matching_pg ? local.sqlserver_all_parameter_groups[0] : null
    force_ssl_params = local.param_group != null ? [for param in core::try(local.param_group.parameter, []) : param if param.name == "rds.force_ssl"] : []
    has_force_ssl = core::length(local.force_ssl_params) > 0
    force_ssl_value = local.has_force_ssl ? local.force_ssl_params[0].value : null
    ssl_disabled = local.force_ssl_value == "0"
    ssl_configured = local.force_ssl_value != null
  }
  
  enforce {
    condition = local.force_ssl_value != null && !local.ssl_disabled
    error_message = "RDS SQL Server instance uses parameter group which either does not have the rds.force_ssl parameter explicitly configured or has rds.force_ssl set to '0' (disabled)"
  }
}
