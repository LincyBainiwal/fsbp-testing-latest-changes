# Copyright IBM Corp. 2026

# Secrets Manager secrets should have automatic rotation enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "secretsmanager-rotation-enabled-check-enforcement-level" {
  type = string
  default = "advisory"
}

input "maximumAllowedRotationFrequency" {
  type    = number
  default = 0
}

locals {
  all_secret_rotations = core::getresources("aws_secretsmanager_secret_rotation", {})
}

resource_policy "aws_secretsmanager_secret" "rotation_enabled_check" {
  enforcement_level = input.secretsmanager-rotation-enabled-check-enforcement-level
  locals {
    secret_name = core::try(attrs.name, "unnamed")

    # A rotation matches this secret if its secret_id attribute equals our name.
    # Matching by name (not by .id or .arn) keeps this policy evaluable at plan
    # time, where aws_secretsmanager_secret.id and .arn are "known after apply".
    # The aws_secretsmanager_secret_rotation.secret_id argument accepts a secret
    # name, ARN, or ID -- users running this policy at plan time should pass the
    # secret's name (e.g. aws_secretsmanager_secret.example.name).
    matching_rotations = [
      for rotation in local.all_secret_rotations : rotation
      if core::try(rotation.secret_id, "") == local.secret_name
    ]

    has_rotation_enabled = core::length(local.matching_rotations) > 0

    # Frequency check (only meaningful when a rotation is found and input is provided).
    matching_rotation     = core::try(local.matching_rotations[0], {})
    rotation_rules        = core::try(local.matching_rotation.rotation_rules, [])
    rotation_days         = core::length(local.rotation_rules) > 0 ? core::try(local.rotation_rules[0].automatically_after_days, 0) : 0
    frequency_input       = input.maximumAllowedRotationFrequency
    frequency_input_valid = local.frequency_input == 0 || (local.frequency_input >= 1 && local.frequency_input <= 365)
    frequency_exceeds_max = local.frequency_input > 0 && local.rotation_days > 0 && local.rotation_days > local.frequency_input
  }

  # Validate input parameter range (Config rule allows 1-365; 0 means "not set" in this policy).
  enforce {
    condition     = local.frequency_input_valid
    error_message = "input.maximumAllowedRotationFrequency must be between 1 and 365 when provided (use 0 to leave unset)."
  }

  # Rotation must be enabled.
  enforce {
    condition     = local.has_rotation_enabled
    error_message = "Secret must have automatic rotation enabled. Configure an aws_secretsmanager_secret_rotation resource with rotation_rules.automatically_after_days"
  }

  # Rotation frequency must not exceed the configured maximum.
  enforce {
    condition     = !local.frequency_exceeds_max
    error_message = "Secret rotation frequency exceeds maximumAllowedRotationFrequency"
  }
}
