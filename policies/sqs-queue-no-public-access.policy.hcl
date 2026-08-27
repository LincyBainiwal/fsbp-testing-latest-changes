# Copyright IBM Corp. 2026

# SQS queue access policies should not allow public access

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "sqs-queue-no-public-access-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_sqs_queue_policy" "no_public_access" {
    enforcement_level = input.sqs-queue-no-public-access-enforcement-level
    locals {
        policy_value = core::try(attrs.policy, null)
        policy_doc   = local.policy_value != null ? core::jsondecode(local.policy_value) : null
        statements   = local.policy_doc != null ? core::try(local.policy_doc.Statement, []) : []

        # A statement is publicly accessible when Effect=Allow, Principal=* and no
        # restrictive Condition is present.
        public_statements = [
            for s in local.statements : s
            if core::try(s.Effect, "") == "Allow"
            && (
                core::try(s.Principal, "") == "*" ||
                core::try(s.Principal.AWS, "") == "*"
            )
            && core::try(s.Condition, null) == null
        ]
    }

    filter = local.policy_value != null

    enforce {
        condition     = core::length(local.public_statements) == 0
        error_message = "SQS queue policy allows public access: found ${core::length(local.public_statements)} statement(s) with Effect=Allow, Principal=* and no restrictive Condition. Restrict access using IAM conditions (e.g. aws:PrincipalOrgID) or remove the wildcard principal."
    }
}

resource_policy "aws_sqs_queue" "no_public_access_inline" {
    enforcement_level = input.sqs-queue-no-public-access-enforcement-level
    locals {
        policy_value = core::try(attrs.policy, null)
        policy_doc   = local.policy_value != null ? core::jsondecode(local.policy_value) : null
        statements   = local.policy_doc != null ? core::try(local.policy_doc.Statement, []) : []

        public_statements = [
            for s in local.statements : s
            if core::try(s.Effect, "") == "Allow"
            && (
                core::try(s.Principal, "") == "*" ||
                core::try(s.Principal.AWS, "") == "*"
            )
            && core::try(s.Condition, null) == null
        ]
    }

    filter = local.policy_value != null

    enforce {
        condition     = core::length(local.public_statements) == 0
        error_message = "SQS queue inline policy allows public access: found ${core::length(local.public_statements)} statement(s) with Effect=Allow, Principal=* and no restrictive Condition. Restrict access using IAM conditions (e.g. aws:PrincipalOrgID) or remove the wildcard principal."
    }
}