# Copyright IBM Corp. 2026

# OpenSearch domain error logging to CloudWatch Logs should be enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9.0, < 7.0.0"
    }
  }
}

input "opensearch-logs-to-cloudwatch-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_opensearch_domain" "error_logging_enabled" {
    enforcement_level = input.opensearch-logs-to-cloudwatch-enforcement-level
    locals {
        log_options = core::try(attrs.log_publishing_options, [])
        application_log_configs = [
            for log_config in local.log_options :
            log_config if log_config.log_type == "ES_APPLICATION_LOGS"
        ]
        has_application_logs = core::length(local.application_log_configs) > 0

        is_enabled = local.has_application_logs ? core::try(local.application_log_configs[0].enabled, true) : false

        log_group_arn = local.has_application_logs ? core::try(local.application_log_configs[0].cloudwatch_log_group_arn, null) : null
        has_log_group = local.log_group_arn != null && local.log_group_arn != ""
    }

    enforce {
        condition = local.has_application_logs
        error_message = "OpenSearch domain does not have ES_APPLICATION_LOGS configured. Add a log_publishing_options block with log_type = 'ES_APPLICATION_LOGS' to enable error logging to CloudWatch Logs"
    }

    enforce {
        condition = local.is_enabled
        error_message = "OpenSearch domain has ES_APPLICATION_LOGS configured but it is disabled. Set 'enabled = true' or remove the enabled attribute (defaults to true)"
    }

    enforce {
        condition = local.has_log_group
        error_message = "OpenSearch domain has ES_APPLICATION_LOGS configured but missing 'cloudwatch_log_group_arn'. Specify a valid CloudWatch Log Group ARN to store the logs"
    }
}
