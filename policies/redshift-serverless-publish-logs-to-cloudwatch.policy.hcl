# Copyright IBM Corp. 2026

# Redshift Serverless namespaces should export logs to CloudWatch Logs

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.23.0, < 7.0.0"
    }
  }
}

input "redshift-serverless-publish-logs-to-cloudwatch-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_redshiftserverless_namespace" "require_cloudwatch_log_exports" {
    enforcement_level = input.redshift-serverless-publish-logs-to-cloudwatch-enforcement-level
    locals {
        log_exports = core::try(attrs.log_exports, [])
        has_connection_log = core::contains(local.log_exports, "connectionlog")
        has_user_log = core::contains(local.log_exports, "userlog")
    }

    enforce {
        condition = local.has_connection_log
        error_message = "Redshift Serverless namespace must export connectionlog to CloudWatch Logs"
    }

    enforce {
        condition = local.has_user_log
        error_message = "Redshift Serverless namespace must export userlog to CloudWatch Logs"
    }
}
