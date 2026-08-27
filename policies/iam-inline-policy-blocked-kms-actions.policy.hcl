# Copyright IBM Corp. 2026

# IAM principals should not have IAM inline policies that allow decryption actions on all KMS keys

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "iam-inline-policy-blocked-kms-actions-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "aws_iam_role_policy" "kms_restrict_decrypt_actions" {
  enforcement_level = input.iam-inline-policy-blocked-kms-actions-enforcement-level
  locals {
    policy_doc  = core::try(core::jsondecode(attrs.policy), {})
    statements  = [for stmt in core::try(local.policy_doc.Statement, []) : stmt]

    has_blocked_actions = core::length([
      for stmt in local.statements : stmt
      if core::try(stmt.Effect, "") == "Allow" &&
         core::length([
           for action in core::try(stmt.Action, []) : action
           if action == "kms:Decrypt" || action == "kms:ReEncryptFrom"
         ]) > 0 &&
         (core::try(stmt.Resource, "") == "*" || core::try(core::contains(stmt.Resource, "*"), false))
    ]) > 0
  }

  enforce {
    condition     = !local.has_blocked_actions
    error_message = "IAM role inline policy must not allow 'kms:Decrypt' or 'kms:ReEncryptFrom' on all KMS keys ('*')."
  }
}

resource_policy "aws_iam_user_policy" "kms_restrict_decrypt_actions" {
  enforcement_level = input.iam-inline-policy-blocked-kms-actions-enforcement-level
  locals {
    policy_doc  = core::try(core::jsondecode(attrs.policy), {})
    statements  = [for stmt in core::try(local.policy_doc.Statement, []) : stmt]

    has_blocked_actions = core::length([
      for stmt in local.statements : stmt
      if core::try(stmt.Effect, "") == "Allow" &&
         core::length([
           for action in core::try(stmt.Action, []) : action
           if action == "kms:Decrypt" || action == "kms:ReEncryptFrom"
         ]) > 0 &&
         (core::try(stmt.Resource, "") == "*" || core::try(core::contains(stmt.Resource, "*"), false))
    ]) > 0
  }

  enforce {
    condition     = !local.has_blocked_actions
    error_message = "IAM user inline policy must not allow 'kms:Decrypt' or 'kms:ReEncryptFrom' on all KMS keys ('*')."
  }
}

resource_policy "aws_iam_group_policy" "kms_restrict_decrypt_actions" {
  enforcement_level = input.iam-inline-policy-blocked-kms-actions-enforcement-level
  locals {
    policy_doc  = core::try(core::jsondecode(attrs.policy), {})
    statements  = [for stmt in core::try(local.policy_doc.Statement, []) : stmt]

    has_blocked_actions = core::length([
      for stmt in local.statements : stmt
      if core::try(stmt.Effect, "") == "Allow" &&
         core::length([
           for action in core::try(stmt.Action, []) : action
           if action == "kms:Decrypt" || action == "kms:ReEncryptFrom"
         ]) > 0 &&
         (core::try(stmt.Resource, "") == "*" || core::try(core::contains(stmt.Resource, "*"), false))
    ]) > 0
  }

  enforce {
    condition     = !local.has_blocked_actions
    error_message = "IAM group inline policy must not allow 'kms:Decrypt' or 'kms:ReEncryptFrom' on all KMS keys ('*')."
  }
}
