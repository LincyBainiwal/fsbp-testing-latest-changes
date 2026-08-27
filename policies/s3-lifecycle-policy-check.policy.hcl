# Copyright IBM Corp. 2026

# S3 general purpose buckets should have Lifecycle configurations
# AWS Config rule: s3-lifecycle-policy-check
#
# NON_COMPLIANT if there is no active lifecycle configuration rule or the
# configuration does not match the optional parameter values.

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "s3-lifecycle-policy-check-enforcement-level" {
  type = string
  default = "advisory"
}

input "targetPrefix" {
  type    = string
  default = ""
}

input "targetTransitionDays" {
  type    = number
  default = 0
}

input "targetExpirationDays" {
  type    = number
  default = 0
}

input "targetTransitionStorageClass" {
  type    = string
  default = ""
}

input "bucketNames" {
  type    = string
  default = ""
}

locals {
  valid_storage_classes = [
    "STANDARD_IA",
    "INTELLIGENT_TIERING",
    "ONEZONE_IA",
    "GLACIER",
    "GLACIER_IR",
    "DEEP_ARCHIVE",
  ]
}

resource_policy "aws_s3_bucket" "lifecycle_policy_check" {
  enforcement_level = input.s3-lifecycle-policy-check-enforcement-level
  locals {
    bucket_name = core::try(attrs.bucket, "")

    # Look up lifecycle configuration(s) that reference this bucket.
    matching_lifecycles = core::getresources("aws_s3_bucket_lifecycle_configuration", {
      bucket = local.bucket_name
    })

    has_lifecycle_resource = core::length(local.matching_lifecycles) > 0
    lifecycle              = local.has_lifecycle_resource ? local.matching_lifecycles[0] : null
    rules                  = core::try(local.lifecycle.rule, [])

    # bucketNames scoping (CSV). Use a ternary so we never reference
    # bucket_name (which may be unknown at plan time) when no scope filter
    # was provided.
    bucket_in_scope = input.bucketNames == "" ? true : core::contains(core::split(",", input.bucketNames), local.bucket_name)

    # An "active" rule is Enabled and performs a lifecycle action.
    enabled_rules = [
      for rule in local.rules :
      rule if (
        core::try(rule.status, "") == "Enabled" && (
          core::length(core::try(rule.transition, [])) > 0 ||
          core::try(rule.expiration, null) != null ||
          core::length(core::try(rule.noncurrent_version_transition, [])) > 0 ||
          core::try(rule.noncurrent_version_expiration, null) != null ||
          core::try(rule.abort_incomplete_multipart_upload, null) != null
        )
      )
    ]
    has_active_rules = core::length(local.enabled_rules) > 0

    # Optional parameter handling.
    has_target_prefix_input            = input.targetPrefix != ""
    has_transition_days_input          = input.targetTransitionDays > 0
    has_expiration_days_input          = input.targetExpirationDays > 0
    has_transition_storage_class_input = input.targetTransitionStorageClass != ""

    valid_transition_days_input          = !local.has_transition_days_input || (input.targetTransitionDays >= 1 && input.targetTransitionDays <= 36500)
    valid_expiration_days_input          = !local.has_expiration_days_input || (input.targetExpirationDays >= 1 && input.targetExpirationDays <= 36500)
    valid_transition_storage_class_input = !local.has_transition_storage_class_input || core::contains(local.valid_storage_classes, input.targetTransitionStorageClass)

    has_matching_prefix = !local.has_target_prefix_input || core::length([
      for rule in local.enabled_rules :
      rule if core::try(rule.prefix, core::try(rule.filter.prefix, core::try(rule.filter[0].prefix, ""))) == input.targetPrefix
    ]) > 0

    has_matching_transition_days = !local.has_transition_days_input || core::length([
      for rule in local.enabled_rules :
      rule if core::length([
        for transition in core::try(rule.transition, []) :
        transition if core::try(transition.days, 0) == input.targetTransitionDays
      ]) > 0
    ]) > 0

    has_matching_expiration_days = !local.has_expiration_days_input || core::length([
      for rule in local.enabled_rules :
      rule if core::try(core::try(rule.expiration, {}).days, 0) == input.targetExpirationDays
    ]) > 0

    has_matching_transition_storage_class = !local.has_transition_storage_class_input || core::length([
      for rule in local.enabled_rules :
      rule if core::length([
        for transition in core::try(rule.transition, []) :
        transition if core::try(transition.storage_class, "") == input.targetTransitionStorageClass
      ]) > 0
    ]) > 0

    has_only_valid_transition_storage_classes = core::length([
      for rule in local.enabled_rules :
      rule if core::length([
        for transition in core::try(rule.transition, []) :
        transition if !core::contains(local.valid_storage_classes, core::try(transition.storage_class, ""))
      ]) > 0
    ]) == 0
  }

  # Parameter validation.
  enforce {
    condition     = local.valid_transition_days_input
    error_message = "input.targetTransitionDays must be between 1 and 36500 when provided. Current value: ${input.targetTransitionDays}. Use 0 to leave the parameter unset."
  }

  enforce {
    condition     = local.valid_expiration_days_input
    error_message = "input.targetExpirationDays must be between 1 and 36500 when provided. Current value: ${input.targetExpirationDays}. Use 0 to leave the parameter unset."
  }

  enforce {
    condition     = local.valid_transition_storage_class_input
    error_message = "input.targetTransitionStorageClass must be one of STANDARD_IA, INTELLIGENT_TIERING, ONEZONE_IA, GLACIER, GLACIER_IR, or DEEP_ARCHIVE when provided. Current value: '${input.targetTransitionStorageClass}'. Leave it empty to keep the parameter unset."
  }

  # Core requirement: the bucket must have a lifecycle configuration with at
  # least one active rule.
  enforce {
    condition     = !local.bucket_in_scope || local.has_active_rules
    error_message = "S3 bucket '${local.bucket_name}' must have an 'aws_s3_bucket_lifecycle_configuration' resource with at least one Enabled rule that performs a lifecycle action (transition, expiration, noncurrent_version_transition, noncurrent_version_expiration, or abort_incomplete_multipart_upload)"
  }

  enforce {
    condition     = !local.bucket_in_scope || local.has_only_valid_transition_storage_classes
    error_message = "S3 bucket '${local.bucket_name}' lifecycle configuration contains an invalid transition.storage_class value. Allowed values are STANDARD_IA, INTELLIGENT_TIERING, ONEZONE_IA, GLACIER, GLACIER_IR, and DEEP_ARCHIVE"
  }

  # Optional parameter matching.
  enforce {
    condition     = !local.bucket_in_scope || local.has_matching_prefix
    error_message = "S3 bucket '${local.bucket_name}' lifecycle configuration does not include an enabled rule with prefix = '${input.targetPrefix}' as required by input.targetPrefix."
  }

  enforce {
    condition     = !local.bucket_in_scope || local.has_matching_transition_days
    error_message = "S3 bucket '${local.bucket_name}' lifecycle configuration does not include a transition rule with days = ${input.targetTransitionDays} as required by input.targetTransitionDays."
  }

  enforce {
    condition     = !local.bucket_in_scope || local.has_matching_expiration_days
    error_message = "S3 bucket '${local.bucket_name}' lifecycle configuration does not include an expiration rule with days = ${input.targetExpirationDays} as required by input.targetExpirationDays."
  }

  enforce {
    condition     = !local.bucket_in_scope || local.has_matching_transition_storage_class
    error_message = "S3 bucket '${local.bucket_name}' lifecycle configuration does not include a transition rule with storage_class = '${input.targetTransitionStorageClass}' as required by input.targetTransitionStorageClass."
  }
}
