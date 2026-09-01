# Copyright IBM Corp. 2026

# S3 general purpose bucket policies should restrict access to other AWS accounts

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "s3-bucket-blacklisted-actions-prohibited-enforcement-level" {
  type = string
  default = "advisory"
}

input "blacklisted_action_pattern" {
  type    = string
  default = "s3:DeleteBucketPolicy,s3:PutBucketAcl,s3:PutBucketPolicy,s3:PutEncryptionConfiguration,s3:PutObjectAcl"
}

resource_policy "aws_s3_bucket_policy" "s3-bucket-blacklisted-actions-prohibited" {
  enforcement_level = input.s3-bucket-blacklisted-actions-prohibited-enforcement-level
  locals {
    policy_doc          = core::jsondecode(attrs.policy)
    # Normalise blacklisted actions to lowercase for case-insensitive comparison.
    blacklisted_actions = [for a in core::split(",", input.blacklisted_action_pattern) : core::lower(a)]

    violating_statements = [
      for statement in core::try(local.policy_doc.Statement, []) : statement
      if core::try(statement.Effect, "") == "Allow" &&
      # Principal must be a wildcard or cross-account ARN
      (core::contains([
        core::try(statement.Principal == "*", false),
        core::try(statement.Principal.AWS == "*", false),
        core::try(core::length(core::try(statement.Principal.AWS, [])) > 0 && core::contains(statement.Principal.AWS, "*"), false),
        core::try(core::length(core::regexall("^arn:aws:iam::[0-9]{12}:", core::try(statement.Principal.AWS, ""))) > 0, false),
        core::try(core::length([for p in core::try(statement.Principal.AWS, []) : p if core::length(core::regexall("^arn:aws:iam::[0-9]{12}:", p)) > 0]) > 0, false)
      ], true)) &&
      # Action matching is case-insensitive (IAM actions are case-insensitive).
      # Normalise each action to lowercase before comparing against the blacklist.
      # Wildcard actions ("s3:*", "*") are also handled via exact match.
      # Regex metacharacters in action strings (other than "*") are NOT escaped here
      # because the default blacklisted_action_pattern contains no metacharacters.
      # If custom patterns with metacharacters are provided, wrap them in core::try.
      (core::length([
        for action in core::try(core::flatten([statement.Action]), []) : action
        if core::length([
          for blocked in local.blacklisted_actions : blocked
          if core::lower(action) == blocked ||
             action == "*" ||
             core::length(core::regexall(
               core::join(".*", core::split("*", core::lower(action))),
               blocked
             )) > 0
        ]) > 0
      ]) > 0)
    ]

    has_violation = core::length(local.violating_statements) > 0
  }

  enforce {
    condition     = !local.has_violation
    error_message = "S3 bucket policy allows blacklisted actions (${input.blacklisted_action_pattern}) for cross-account or wildcard principals. Review and remove any Allow statements granting these actions to external or wildcard principals."
  }
}
