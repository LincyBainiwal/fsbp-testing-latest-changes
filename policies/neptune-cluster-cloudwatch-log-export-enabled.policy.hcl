# Copyright IBM Corp. 2026

# Neptune DB clusters should publish audit logs to CloudWatch Logs

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "neptune-cluster-cloudwatch-log-export-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_neptune_cluster" "audit-logging-enabled" {
    enforcement_level = input.neptune-cluster-cloudwatch-log-export-enabled-enforcement-level
    locals {
        log_enabled = core::try(attrs.enable_cloudwatch_logs_exports, [])
    }

    enforce {
        condition = local.log_enabled != [] && core::contains(local.log_enabled, "audit")
        error_message = "The Neptune cluster does not have audit logging enabled"
    }
}