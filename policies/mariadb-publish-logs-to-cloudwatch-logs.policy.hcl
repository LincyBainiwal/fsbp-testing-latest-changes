# Copyright IBM Corp. 2026

# RDS for MariaDB DB instances should publish logs to CloudWatch Logs

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "mariadb-publish-logs-to-cloudwatch-logs-enforcement-level" {
  type = string
  default = "advisory"
}

input "log_mariadb_types" {
    type = string
    default = "audit,error"
}

resource_policy "aws_db_instance" "mariadb_cloudwatch_logs" {
    enforcement_level = input.mariadb-publish-logs-to-cloudwatch-logs-enforcement-level
    filter = attrs.engine == "mariadb"

    locals {
        enabled_logs = core::try(attrs.enabled_cloudwatch_logs_exports, [])
        input_log_types = core::split(",", input.log_mariadb_types)
        input_logging_not_enabled = core::contains([
            for type in local.input_log_types : core::contains(local.enabled_logs, type)
        ], false)
        audit_logging_enabled = core::contains(local.enabled_logs, "audit")
        error_logging_enabled = core::contains(local.enabled_logs, "error")
    }

    enforce {
        condition = local.audit_logging_enabled || local.error_logging_enabled || !local.input_logging_not_enabled
        error_message = "RDS MariaDB instance does not have CloudWatch Logs export enabled for 'audit' or 'error' logs"
    }
}
