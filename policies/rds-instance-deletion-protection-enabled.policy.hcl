# Copyright IBM Corp. 2026

# RDS DB instances should have deletion protection enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "rds-instance-deletion-protection-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

input "database_engines" {
    type = string
    default = "mariadb,mysql,custom-oracle-ee,oracle-ee-cdb,oracle-se2-cdb,oracle-ee,oracle-se2,oracle-se1,oracle-se,postgres,sqlserver-ee,sqlserver-se,sqlserver-ex,sqlserver-web"
}

resource_policy "aws_db_instance" "deletion_protection_enabled" {
    enforcement_level = input.rds-instance-deletion-protection-enabled-enforcement-level
    locals {
        engine = core::try(attrs.engine, "")
        supported_engine = [for engine in core::split(",", core::trimspace(input.database_engines)) : core::trimspace(engine)]
        is_supported_engine = core::contains(local.supported_engine, local.engine)
    }
    enforce {
        condition = local.is_supported_engine && core::try(attrs.deletion_protection, false) == true
        error_message = "RDS DB instances should have deletion protection enabled"
    }
}
