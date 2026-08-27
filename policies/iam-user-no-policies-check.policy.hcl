# Copyright IBM Corp. 2026

# IAM users should not have IAM policies attached

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "iam-user-no-policies-check-enforcement-level" {
  type = string
  default = "advisory"
}

# Policy 1: Prohibit inline IAM policies attached directly to users
resource_policy "aws_iam_user_policy" "no_inline_user_policies" {
  enforcement_level = input.iam-user-no-policies-check-enforcement-level
  locals {
    policy_name = core::try(attrs.name, "")
  }

  enforce {
    condition = false
    error_message = "IAM.2 violation: Inline policy '${local.policy_name}' is attached directly to IAM user '${attrs.user}'. IAM users must inherit permissions from IAM groups or assume roles instead. Remove this inline policy and attach it to an IAM group, then add the user to that group"
  }
}

# Policy 2: Prohibit managed IAM policies attached directly to users
resource_policy "aws_iam_user_policy_attachment" "no_managed_user_policies" {
  enforcement_level = input.iam-user-no-policies-check-enforcement-level
  enforce {
    condition = false
    error_message = "IAM.2 violation: Managed policy '${attrs.policy_arn}' is attached directly to IAM user '${attrs.user}'. IAM users must inherit permissions from IAM groups or assume roles instead. Remove this policy attachment and attach the policy to an IAM group, then add the user to that group"
  }
}
