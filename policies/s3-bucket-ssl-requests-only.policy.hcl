# Copyright IBM Corp. 2026

# S3 general purpose buckets should require requests to use SSL

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "s3-bucket-ssl-requests-only-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_s3_bucket" "ssl_required" {
  enforcement_level = input.s3-bucket-ssl-requests-only-enforcement-level
  locals {
    bucket_name = core::try(attrs.bucket, "")

    # Look up the aws_s3_bucket_policy resource attached to this bucket.
    matching_policies = core::getresources("aws_s3_bucket_policy", {
      bucket = local.bucket_name
    })

    has_policy_resource = core::length(local.matching_policies) > 0
    bucket_policy       = local.has_policy_resource ? local.matching_policies[0] : null
    policy_document     = core::try(local.bucket_policy.policy, "")

    # Statement may be a list OR a single object. Normalize to a list.
    raw_stmts      = core::try(core::jsondecode(local.policy_document).Statement, [])
    list_stmts     = core::try([for s in local.raw_stmts : s if core::try(s.Effect, "") != ""], [])
    single_wrapped = core::try(local.raw_stmts.Effect, "") != "" ? [local.raw_stmts] : []
    statements     = core::concat(local.list_stmts, local.single_wrapped)

    bucket_arn        = "arn:aws:s3:::${local.bucket_name}"
    bucket_object_arn = "arn:aws:s3:::${local.bucket_name}/*"

    ssl_only_statements = [
      for stmt in local.statements :
      stmt if (
        core::try(stmt.Effect, "") == "Deny" &&
        (
          core::try(stmt.Principal, "") == "*" ||
          core::try(stmt.Principal.AWS, "") == "*" ||
          core::try(stmt.Principal.AWS[0], "") == "*"
        ) &&
        (
          # Action may be a string "s3:*" or a list containing "s3:*"
          core::try(stmt.Action, "") == "s3:*" ||
          core::try(core::contains(stmt.Action, "s3:*"), false)
        ) &&
        (
          core::try(stmt.Condition.Bool["aws:SecureTransport"], "") == "false" ||
          core::try(stmt.Condition.Bool["aws:SecureTransport"], true) == false
        ) &&
        (
          
          (
            core::try(stmt.Resource, "") == local.bucket_arn ||
            core::try(stmt.Resource, "") == local.bucket_object_arn ||
            core::try(core::contains(stmt.Resource, local.bucket_arn), false) ||
            core::try(core::contains(stmt.Resource, local.bucket_object_arn), false)
          )
        )
      )
    ]

    has_ssl_only_statement = core::length(local.ssl_only_statements) > 0
  }

  enforce {
    condition     = local.has_policy_resource && local.policy_document != ""
    error_message = "S3 bucket '${local.bucket_name}' must have an associated 'aws_s3_bucket_policy' with a non-empty 'policy' document that denies non-HTTPS requests"
  }

  enforce {
    condition     = !local.has_policy_resource || local.policy_document == "" || local.has_ssl_only_statement
    error_message = "S3 bucket '${local.bucket_name}' policy must include a statement that denies non-HTTPS requests, e.g.: {\"Effect\":\"Deny\",\"Principal\":\"*\",\"Action\":\"s3:*\",\"Resource\":[\"arn:aws:s3:::<bucket>\",\"arn:aws:s3:::<bucket>/*\"],\"Condition\":{\"Bool\":{\"aws:SecureTransport\":\"false\"}}}"
  }
}