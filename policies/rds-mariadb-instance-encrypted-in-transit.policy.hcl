# Copyright IBM Corp. 2026

# RDS for MariaDB DB instances should be encrypted in transit

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "rds-mariadb-instance-encrypted-in-transit-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_db_instance" "mariadb_encrypted_transit" {
  enforcement_level = input.rds-mariadb-instance-encrypted-in-transit-enforcement-level
  filter = attrs.engine == "mariadb"
  
  locals {
    engine_version = core::try(attrs.engine_version, "0.0.0")
    is_valid_version = core::semverconstraint(local.engine_version, ">=10.5.0")
    param_group_name = core::try(attrs.parameter_group_name, "")
    mariadb_all_param_groups = core::getresources("aws_db_parameter_group", {
      name = local.param_group_name
    })
    has_matching_group = core::length(local.mariadb_all_param_groups) > 0
    param_group = local.has_matching_group ? local.mariadb_all_param_groups[0] : null
    param_list = local.has_matching_group ? core::try(local.param_group.parameter, []) : []
    transport_params = [for p in local.param_list : p if p.name == "require_secure_transport"]
    has_param = core::length(local.transport_params) > 0
    param_value = core::try(local.transport_params[0].value, "")
    is_enabled = local.param_value == "1"
  }
  
  enforce {
    condition = !local.is_valid_version || (local.has_param && local.is_enabled)
    error_message = "RDS MariaDB instance must have require_secure_transport enabled in parameter group"
  }
}
