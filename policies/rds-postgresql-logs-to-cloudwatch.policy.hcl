# Copyright IBM Corp. 2026

# RDS for PostgreSQL DB instances should publish logs to CloudWatch Logs

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "rds-postgresql-logs-to-cloudwatch-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_db_instance" "postgresql_cloudwatch_logs" {
    enforcement_level = input.rds-postgresql-logs-to-cloudwatch-enforcement-level
    filter = core::try(attrs.engine, "") == "postgres"

    locals {
        log_exports = core::try(attrs.enabled_cloudwatch_logs_exports, [])
        postgresql_logging_enabled = core::contains(local.log_exports, "postgresql")
        upgrade_logging_enabled = core::contains(local.log_exports, "upgrade")
    }

    enforce {
        condition = local.postgresql_logging_enabled && local.upgrade_logging_enabled
        error_message = "RDS PostgreSQL instance does not have CloudWatch Logs export enabled for both 'postgresql' and 'upgrade' logs"
    }
}
