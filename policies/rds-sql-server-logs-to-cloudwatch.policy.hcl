# Copyright IBM Corp. 2026

# RDS for SQL Server DB instances should publish logs to CloudWatch Logs

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "rds-sql-server-logs-to-cloudwatch-enforcement-level" {
  type = string
  default = "advisory"
}

locals {
    valid_engines = ["sqlserver-dev-ee", "sqlserver-ee", "sqlserver-se", "sqlserver-ex", "sqlserver-web"]
}

resource_policy "aws_db_instance" "sql_cloudwatch_logs" {
    enforcement_level = input.rds-sql-server-logs-to-cloudwatch-enforcement-level
    filter = core::contains(local.valid_engines, core::try(attrs.engine, ""))

    locals {
        log_exports = core::try(attrs.enabled_cloudwatch_logs_exports, [])
        error_logging_enabled = core::contains(local.log_exports, "error")
        agent_logging_enabled = core::contains(local.log_exports, "agent")
    }

    enforce {
        condition = local.error_logging_enabled && local.agent_logging_enabled
        error_message = "RDS SQL server instance does not have CloudWatch Logs export enabled for both 'agent' and 'error' logs"
    }
}
