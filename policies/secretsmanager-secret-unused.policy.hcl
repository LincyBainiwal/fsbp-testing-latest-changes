# Copyright IBM Corp. 2026

# Remove unused Secrets Manager secrets

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "secretsmanager-secret-unused-enforcement-level" {
  type = string
  default = "advisory"
}

input "unusedForDays" {
  type    = number
  default = 90
}

resource_policy "aws_secretsmanager_secret" "remove_unused_secrets" {
  enforcement_level = input.secretsmanager-secret-unused-enforcement-level
  locals {
    tags_value            = core::try(attrs.tags, {})
    last_accessed_raw     = core::try(local.tags_value.LastAccessed, "")
    created_date_raw      = core::try(local.tags_value.CreatedDate, "")
    usage_reference_raw   = local.last_accessed_raw != "" ? local.last_accessed_raw : local.created_date_raw
    has_usage_reference   = local.usage_reference_raw != ""

    valid_unused_for_days = input.unusedForDays >= 1 && input.unusedForDays <= 365
  }

  # Validate the unusedForDays input (matches AWS spec: integer 1-365).
  enforce {
    condition     = local.valid_unused_for_days
    error_message = "input.unusedForDays must be between 1 and 365."
  }

  # Every secret must carry a LastAccessed (or CreatedDate fallback) tag so unused age can be evaluated.
  enforce {
    condition     = local.has_usage_reference
    error_message = "Secret must include a 'LastAccessed' tag, or a fallback 'CreatedDate' tag, so its unused age can be evaluated against the configured unusedForDays threshold. These timestamps should be maintained by external automation that tracks secret access"
  }
}
