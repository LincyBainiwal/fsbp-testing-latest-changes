# Copyright IBM Corp. 2026

# Secrets Manager secrets should be rotated within a specified number of days
# AWS Config rule: secretsmanager-secret-periodic-rotation
# AWS rule targets AWS::SecretsManager::Secret and flags secrets not rotated within maxDaysSinceRotation
# days (default 90, range 1-180). At Terraform plan time we cannot observe "days since last rotation",
# so this policy targets aws_secretsmanager_secret_rotation and uses rotation_rules.automatically_after_days
# as the plan-time proxy: a secret cannot be rotated less frequently than its configured interval.
# Secrets with no aws_secretsmanager_secret_rotation are out of scope here (covered by SecretsManager.1).

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "secretsmanager-secret-periodic-rotation-enforcement-level" {
  type = string
  default = "advisory"
}

input "maxDaysSinceRotation" {
    type    = number
    default = 90
}

resource_policy "aws_secretsmanager_secret_rotation" "rotation_frequency_check" {
    enforcement_level = input.secretsmanager-secret-periodic-rotation-enforcement-level
    locals {
        rotation_rules_list      = core::try(attrs.rotation_rules, [])
        has_rotation_rules       = core::length(local.rotation_rules_list) > 0
        rotation_rules           = core::try(local.rotation_rules_list[0], {})
        automatically_after_days = core::try(local.rotation_rules.automatically_after_days, 0)
        has_rotation_frequency   = local.automatically_after_days > 0
        threshold                = input.maxDaysSinceRotation
        valid_threshold          = local.threshold >= 1 && local.threshold <= 180
        rotation_frequency_valid = local.has_rotation_frequency && local.automatically_after_days <= local.threshold
    }

    # Only evaluate rotation resources that actually declare rotation_rules.
    filter = local.has_rotation_rules

    # Validate input parameter range (AWS spec: 1-180).
    enforce {
        condition     = local.valid_threshold
        error_message = "input.maxDaysSinceRotation must be between 1 and 180."
    }

    # automatically_after_days must be configured so frequency can be evaluated.
    enforce {
        condition     = local.has_rotation_frequency
        error_message = "Secret rotation must have 'automatically_after_days' configured in rotation_rules so compliance can be evaluated against the configured maxDaysSinceRotation threshold"
    }

    # Configured rotation interval must not exceed the maximum.
    enforce {
        condition     = !local.has_rotation_frequency || local.rotation_frequency_valid
        error_message = "Secret rotation must rotate at least once within the configured maxDaysSinceRotation threshold"
    }
}
