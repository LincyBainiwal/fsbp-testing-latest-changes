# Copyright IBM Corp. 2026

# SNS topic access policies should not allow public access

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "sns-topic-no-public-access-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_sns_topic_policy" "no_public_access" {
  enforcement_level = input.sns-topic-no-public-access-enforcement-level
  # Pre-filter: only evaluate when a policy document is present
  filter = core::try(attrs.policy, "") != ""

  locals {
    # Safely decode the policy JSON; default to empty doc if malformed.
    policy_doc = core::try(core::jsondecode(attrs.policy), {})

    raw_statements = core::try(local.policy_doc.Statement, [])

    # Public statements when Statement is an array.
    # A Condition is only treated as restrictive when it contains one of the
    # known access-scoping keys. Presence of any arbitrary Condition (e.g.
    # StringLike on aws:UserAgent) is not sufficient.
    public_statements_from_list = core::try([
      for stmt in local.raw_statements : stmt
      if (
        core::try(stmt.Effect, "") == "Allow" &&
        (
          core::try(stmt.Principal, "") == "*" ||
          core::contains(core::try([for p in stmt.Principal : p], []), "*") ||
          core::try(stmt.Principal.AWS, "") == "*" ||
          core::contains(core::try([for v in stmt.Principal.AWS : v], []), "*") ||
          core::try(stmt.Principal.Service, "") == "*" ||
          core::contains(core::try([for v in stmt.Principal.Service : v], []), "*") ||
          core::try(stmt.Principal.Federated, "") == "*" ||
          core::contains(core::try([for v in stmt.Principal.Federated : v], []), "*") ||
          core::try(stmt.Principal.CanonicalUser, "") == "*" ||
          core::contains(core::try([for v in stmt.Principal.CanonicalUser : v], []), "*") ||
          core::try(stmt.NotPrincipal, null) != null
        ) &&
        !(
          core::try(stmt.Condition, null) != null && (
            core::try(stmt.Condition.StringEquals["aws:PrincipalOrgID"], null) != null ||
            core::try(stmt.Condition.StringLike["aws:PrincipalOrgID"], null) != null ||
            core::try(stmt.Condition.StringEquals["aws:SourceAccount"], null) != null ||
            core::try(stmt.Condition.StringEquals["aws:SourceArn"], null) != null ||
            core::try(stmt.Condition.ArnLike["aws:SourceArn"], null) != null ||
            core::try(stmt.Condition.StringEquals["aws:SourceOrgID"], null) != null ||
            core::try(stmt.Condition.StringLike["aws:SourceVpce"], null) != null
          )
        )
      )
    ], [])

    # Single-object form: treat as a one-element list when it has an Effect key.
    single_stmt_is_public = core::try(local.raw_statements.Effect, "") == "Allow" && (
      core::try(local.raw_statements.Principal, "") == "*" ||
      core::try(local.raw_statements.Principal.AWS, "") == "*" ||
      core::try(local.raw_statements.Principal.Service, "") == "*" ||
      core::try(local.raw_statements.Principal.Federated, "") == "*" ||
      core::try(local.raw_statements.Principal.CanonicalUser, "") == "*" ||
      core::try(local.raw_statements.NotPrincipal, null) != null
    ) && !(
      core::try(local.raw_statements.Condition, null) != null && (
        core::try(local.raw_statements.Condition.StringEquals["aws:PrincipalOrgID"], null) != null ||
        core::try(local.raw_statements.Condition.StringLike["aws:PrincipalOrgID"], null) != null ||
        core::try(local.raw_statements.Condition.StringEquals["aws:SourceAccount"], null) != null ||
        core::try(local.raw_statements.Condition.StringEquals["aws:SourceArn"], null) != null ||
        core::try(local.raw_statements.Condition.ArnLike["aws:SourceArn"], null) != null ||
        core::try(local.raw_statements.Condition.StringEquals["aws:SourceOrgID"], null) != null ||
        core::try(local.raw_statements.Condition.StringLike["aws:SourceVpce"], null) != null
      )
    )

    public_statement_count = core::length(local.public_statements_from_list) + (local.single_stmt_is_public ? 1 : 0)

    is_compliant = local.public_statement_count == 0
  }

  enforce {
    condition = local.is_compliant
    error_message = "SNS topic policy allows public access. The policy contains ${local.public_statement_count} statement(s) with a wildcard (*) Principal (or NotPrincipal with Allow) and no Condition. Remove wildcard principals or add restrictive conditions"
  }
}

# Additional policy to check aws_sns_topic inline policies
resource_policy "aws_sns_topic" "no_public_access_inline" {
  enforcement_level = input.sns-topic-no-public-access-enforcement-level
  # Only evaluate topics that have an inline policy defined
  filter = core::try(attrs.policy, null) != null && core::try(attrs.policy, "") != ""

  locals {
    policy_doc = core::try(core::jsondecode(attrs.policy), {})

    raw_statements = core::try(local.policy_doc.Statement, [])

    public_statements_from_list = core::try([
      for stmt in local.raw_statements : stmt
      if (
        core::try(stmt.Effect, "") == "Allow" &&
        (
          core::try(stmt.Principal, "") == "*" ||
          core::contains(core::try([for p in stmt.Principal : p], []), "*") ||
          core::try(stmt.Principal.AWS, "") == "*" ||
          core::contains(core::try([for v in stmt.Principal.AWS : v], []), "*") ||
          core::try(stmt.Principal.Service, "") == "*" ||
          core::contains(core::try([for v in stmt.Principal.Service : v], []), "*") ||
          core::try(stmt.Principal.Federated, "") == "*" ||
          core::contains(core::try([for v in stmt.Principal.Federated : v], []), "*") ||
          core::try(stmt.Principal.CanonicalUser, "") == "*" ||
          core::contains(core::try([for v in stmt.Principal.CanonicalUser : v], []), "*") ||
          core::try(stmt.NotPrincipal, null) != null
        ) &&
        !(
          core::try(stmt.Condition, null) != null && (
            core::try(stmt.Condition.StringEquals["aws:PrincipalOrgID"], null) != null ||
            core::try(stmt.Condition.StringLike["aws:PrincipalOrgID"], null) != null ||
            core::try(stmt.Condition.StringEquals["aws:SourceAccount"], null) != null ||
            core::try(stmt.Condition.StringEquals["aws:SourceArn"], null) != null ||
            core::try(stmt.Condition.ArnLike["aws:SourceArn"], null) != null ||
            core::try(stmt.Condition.StringEquals["aws:SourceOrgID"], null) != null ||
            core::try(stmt.Condition.StringLike["aws:SourceVpce"], null) != null
          )
        )
      )
    ], [])

    single_stmt_is_public = core::try(local.raw_statements.Effect, "") == "Allow" && (
      core::try(local.raw_statements.Principal, "") == "*" ||
      core::try(local.raw_statements.Principal.AWS, "") == "*" ||
      core::try(local.raw_statements.Principal.Service, "") == "*" ||
      core::try(local.raw_statements.Principal.Federated, "") == "*" ||
      core::try(local.raw_statements.Principal.CanonicalUser, "") == "*" ||
      core::try(local.raw_statements.NotPrincipal, null) != null
    ) && !(
      core::try(local.raw_statements.Condition, null) != null && (
        core::try(local.raw_statements.Condition.StringEquals["aws:PrincipalOrgID"], null) != null ||
        core::try(local.raw_statements.Condition.StringLike["aws:PrincipalOrgID"], null) != null ||
        core::try(local.raw_statements.Condition.StringEquals["aws:SourceAccount"], null) != null ||
        core::try(local.raw_statements.Condition.StringEquals["aws:SourceArn"], null) != null ||
        core::try(local.raw_statements.Condition.ArnLike["aws:SourceArn"], null) != null ||
        core::try(local.raw_statements.Condition.StringEquals["aws:SourceOrgID"], null) != null ||
        core::try(local.raw_statements.Condition.StringLike["aws:SourceVpce"], null) != null
      )
    )

    public_statement_count = core::length(local.public_statements_from_list) + (local.single_stmt_is_public ? 1 : 0)

    is_compliant = local.public_statement_count == 0
  }

  enforce {
    condition = local.is_compliant
    error_message = "SNS topic has an inline policy that allows public access. The policy contains ${local.public_statement_count} statement(s) with a wildcard (*) Principal (or NotPrincipal with Allow) and no Condition. Remove wildcard principals or add restrictive conditions"
  }
}