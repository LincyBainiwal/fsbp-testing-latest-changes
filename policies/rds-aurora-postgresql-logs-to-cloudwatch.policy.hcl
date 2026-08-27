# Copyright IBM Corp. 2026

# Aurora PostgreSQL DB clusters should publish logs to CloudWatch Logs

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "rds-aurora-postgresql-logs-to-cloudwatch-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_rds_cluster" "aurora_postgresql_cloudwatch_logs" {
    enforcement_level = input.rds-aurora-postgresql-logs-to-cloudwatch-enforcement-level
    filter = attrs.engine == "aurora-postgresql"

    locals {
        log_exports = core::try(attrs.enabled_cloudwatch_logs_exports, [])
    }

    enforce {
        condition = core::contains(local.log_exports, "postgresql")
        error_message = "Aurora PostgreSQL cluster does not have 'postgresql' logs enabled for CloudWatch Logs export. Add 'postgresql' to the 'enabled_cloudwatch_logs_exports' attribute to enable centralized logging and monitoring"
    }
}
