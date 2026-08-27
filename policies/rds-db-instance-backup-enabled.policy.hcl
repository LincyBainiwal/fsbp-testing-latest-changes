# Copyright IBM Corp. 2026

# RDS instances should have automatic backups enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "rds-db-instance-backup-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

input "min_backup_retention" {
    type = number
    default = 7
}

resource_policy "aws_db_instance" "backup_enabled" {
    enforcement_level = input.rds-db-instance-backup-enabled-enforcement-level
    locals {
        backup_period = core::try(attrs.backup_retention_period, 0)
        is_valid_input = input.min_backup_retention >= 7 && input.min_backup_retention <= 35
    }

    enforce {
        condition = local.backup_period != 0 && local.is_valid_input && local.backup_period >= input.min_backup_retention
        error_message = "RDS instances should have automatic backups enabled"
    }
}
