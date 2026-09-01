# Copyright IBM Corp. 2026

# SSM Automation should have CloudWatch logging enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.24.0, < 7.0.0"
    }
  }
}

input "ssm-automation-logging-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_ssm_service_setting" "automation_logging_destination" {
  enforcement_level = input.ssm-automation-logging-enabled-enforcement-level
  filter = core::try(attrs.setting_id, "") == "/ssm/documents/console/customer-script-log-destination"

  locals {
    setting_value = core::try(attrs.setting_value, "")
  }

  enforce {
    condition     = local.setting_value == "CloudWatch"
    error_message = "SSM Automation log destination must be set to 'CloudWatch'. Got '${local.setting_value}'. Set setting_value = \"CloudWatch\" on the aws_ssm_service_setting resource with setting_id '/ssm/documents/console/customer-script-log-destination'."
  }
}

# Enforce that the SSM Automation log-group-name is set to a non-empty value.
resource_policy "aws_ssm_service_setting" "automation_logging_group_name" {
  enforcement_level = input.ssm-automation-logging-enabled-enforcement-level
  filter = core::try(attrs.setting_id, "") == "/ssm/documents/console/customer-script-log-group-name"

  locals {
    setting_value = core::try(attrs.setting_value, "")
  }

  enforce {
    condition     = local.setting_value != ""
    error_message = "SSM Automation log group name must be set to a non-empty CloudWatch log group name. Set setting_value to a valid log group name (e.g. '/aws/ssm/automation/logs') on the aws_ssm_service_setting resource with setting_id '/ssm/documents/console/customer-script-log-group-name'."
  }
}
