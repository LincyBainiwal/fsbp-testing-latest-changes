# Copyright IBM Corp. 2026

# IAM customer managed policies should not allow decryption actions on all KMS keys

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "iam-customer-policy-blocked-kms-actions-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_iam_policy" "kms_decrypt_restriction" {
    enforcement_level = input.iam-customer-policy-blocked-kms-actions-enforcement-level
    filter = attrs.policy != null

    locals {
        blocked_actions = ["kms:Decrypt", "kms:ReEncryptFrom"]

        policy_doc = core::try(core::jsondecode(attrs.policy), {})
        statements = core::try(local.policy_doc.Statement, [])

        violations = [
            for stmt in local.statements : stmt
            if core::try(stmt.Effect, "") == "Allow"
            && core::length([
                for action in core::try(core::flatten([stmt.Action]), []) :
                action
                if core::length([
                    for pattern in local.blocked_actions : pattern
                    if core::length(core::regexall(
                        "^${core::join(".*", core::split("*", pattern))}$",
                        action
                    )) > 0
                    || core::length(core::regexall(
                        "^${core::join(".*", core::split("*", action))}$",
                        pattern
                    )) > 0
                ]) > 0
            ]) > 0
            && (
                core::try(stmt.Resource, "") == "*"
                || core::try(core::contains(core::flatten([stmt.Resource]), "*"), false)
            )
        ]
    }

    enforce {
        condition     = core::length(local.violations) == 0
        error_message = "IAM customer managed policy violates KMS.1. It must not allow blocked KMS actions on all KMS keys (Resource: \"*\"). Instead, specify the ARN of specific KMS keys (e.g., arn:aws:kms:region:account-id:key/key-id)"
    }
}

