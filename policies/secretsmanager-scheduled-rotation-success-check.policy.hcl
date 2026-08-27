# Copyright IBM Corp. 2026

# Secrets Manager secrets configured with automatic rotation should rotate successfully

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "secretsmanager-scheduled-rotation-success-check-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_secretsmanager_secret" "rotation_success_check" {
  enforcement_level = input.secretsmanager-scheduled-rotation-success-check-enforcement-level
  locals {
    secret_arn  = core::try(attrs.arn, "")
    secret_name = core::try(attrs.name, "")

    # Look up the aws_secretsmanager_secret_rotation that references this
    # secret. secret_id may be the secret's ARN or its friendly name, so query
    # both forms via the inline getresources filter.
    rotation_by_arn = core::getresources("aws_secretsmanager_secret_rotation", {
      secret_id = local.secret_arn
    })
    rotation_by_name = core::getresources("aws_secretsmanager_secret_rotation", {
      secret_id = local.secret_name
    })
    matching_rotations = core::concat(local.rotation_by_arn, local.rotation_by_name)

    has_rotation_resource = core::length(local.matching_rotations) > 0
    rotation              = local.has_rotation_resource ? local.matching_rotations[0] : null

    # rotation_rules must be defined.
    rotation_rules     = core::try(local.rotation.rotation_rules, [])
    has_rotation_rules = core::length(local.rotation_rules) > 0

    # Schedule must be configured: automatically_after_days or schedule_expression.
    raw_auto_days     = core::try(local.rotation_rules[0].automatically_after_days, 0)
    raw_schedule_expr = core::try(local.rotation_rules[0].schedule_expression, "")
    auto_days         = local.raw_auto_days == null ? 0 : local.raw_auto_days
    schedule_expr     = local.raw_schedule_expr == null ? "" : local.raw_schedule_expr
    has_schedule      = local.auto_days > 0 || local.schedule_expr != ""

    # When automatically_after_days is used, it must be <= 90 days so the secret
    # rotates often enough to be considered "successfully rotated on schedule".
    auto_days_within_limit = local.auto_days == 0 || local.auto_days <= 90
  }

  enforce {
    condition     = local.has_rotation_resource
    error_message = "Secrets Manager secret '${local.secret_name}' must have an associated 'aws_secretsmanager_secret_rotation' resource configured for automatic rotation"
  }

  enforce {
    condition     = !local.has_rotation_resource || local.has_rotation_rules
    error_message = "Secrets Manager secret '${local.secret_name}' rotation must define rotation_rules so that rotation occurs as scheduled"
  }

  enforce {
    condition     = !local.has_rotation_rules || local.has_schedule
    error_message = "Secrets Manager secret '${local.secret_name}' rotation_rules must set either 'automatically_after_days' or 'schedule_expression' so that rotation occurs as scheduled"
  }

  enforce {
    condition     = local.auto_days_within_limit
    error_message = "Secrets Manager secret '${local.secret_name}' rotation 'automatically_after_days' must be 90 or less so the secret rotates frequently enough to satisfy the scheduled-rotation requirement"
  }
}
