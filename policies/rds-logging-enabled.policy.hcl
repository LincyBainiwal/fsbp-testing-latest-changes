# Copyright IBM Corp. 2026

# RDS DB instances should publish logs to CloudWatch Logs

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "rds-logging-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_db_instance" "rds_logging_enabled" {
    enforcement_level = input.rds-logging-enabled-enforcement-level
    locals {
        engine = core::try(attrs.engine, "")
        enabled_logs = core::try(attrs.enabled_cloudwatch_logs_exports, [])

        required_logs = local.engine == "oracle-ee" || local.engine == "oracle-ee-cdb" || local.engine == "oracle-se2" || local.engine == "oracle-se2-cdb" ? ["alert", "audit", "trace", "listener"] : local.engine == "postgres" ? ["postgresql", "upgrade"] : local.engine == "mysql" ? ["audit", "error", "general", "slowquery"] : local.engine == "mariadb" ? ["audit", "error", "general", "slowquery"] : local.engine == "sqlserver-ee" || local.engine == "sqlserver-ex" || local.engine == "sqlserver-se" || local.engine == "sqlserver-web" ? ["error", "agent"] : []

        missing_logs = [
            for required_log in local.required_logs :
            required_log if !core::contains(local.enabled_logs, required_log)
        ]
    }

    enforce {
        condition = core::length(local.required_logs) == 0 || core::length(local.missing_logs) == 0
        error_message = "RDS DB instance must enable all required CloudWatch log exports for engine '${local.engine}'"
    }
}
