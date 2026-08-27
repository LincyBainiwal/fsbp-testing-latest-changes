# Copyright IBM Corp. 2026

# S3 directory buckets should have lifecycle configurations

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.28.0, < 7.0.0"
    }
  }
}

input "s3express-dir-bucket-lifecycle-rules-check-enforcement-level" {
  type = string
  default = "advisory"
}

input "expressTargetExpirationDays" {
  type    = number
  default = 0
}

resource_policy "aws_s3_directory_bucket" "directory_bucket_lifecycle" {
  enforcement_level = input.s3express-dir-bucket-lifecycle-rules-check-enforcement-level
  locals {
    bucket_name = core::try(attrs.bucket, "")

    # Look up the aws_s3_bucket_lifecycle_configuration attached to this
    # directory bucket directly via the getresources filter.
    matching_lifecycles = core::getresources("aws_s3_bucket_lifecycle_configuration", {
      bucket = local.bucket_name
    })

    has_lifecycle_resource = core::length(local.matching_lifecycles) > 0
    lifecycle              = local.has_lifecycle_resource ? local.matching_lifecycles[0] : null
    rules                  = core::try(local.lifecycle.rule, [])

    # Enabled rules with at least one directory-bucket-supported action.
    enabled_rules = [
      for rule in local.rules :
      rule if (
        core::try(rule.status, "") == "Enabled" && (
          core::length(core::try(rule.expiration, [])) > 0 ||
          core::length(core::try(rule.abort_incomplete_multipart_upload, [])) > 0
        )
      )
    ]
    has_active_rules = core::length(local.enabled_rules) > 0

    # Optional expiration-days match.
    has_target_expiration_days_input   = input.expressTargetExpirationDays > 0
    valid_target_expiration_days_input = input.expressTargetExpirationDays == 0 || (input.expressTargetExpirationDays >= 1 && input.expressTargetExpirationDays <= 2147483647)

    has_matching_expiration_days = !local.has_target_expiration_days_input || core::length([
      for rule in local.enabled_rules :
      rule if core::try(rule.expiration[0].days, 0) == input.expressTargetExpirationDays
    ]) > 0
  }

  enforce {
    condition     = local.valid_target_expiration_days_input
    error_message = "input.expressTargetExpirationDays must be between 1 and 2147483647 when set. Current value: ${input.expressTargetExpirationDays}. Use 0 to leave the parameter unset."
  }

  enforce {
    condition     = local.has_lifecycle_resource && local.has_active_rules
    error_message = "S3 directory bucket '${local.bucket_name}' must have an associated 'aws_s3_bucket_lifecycle_configuration' with at least one rule whose status = 'Enabled' and that has either expiration or abort_incomplete_multipart_upload set"
  }

  enforce {
    condition     = local.has_matching_expiration_days
    error_message = "S3 directory bucket '${local.bucket_name}' lifecycle configuration must include an enabled rule with expiration.days = ${input.expressTargetExpirationDays} as required by input.expressTargetExpirationDays"
  }
}
