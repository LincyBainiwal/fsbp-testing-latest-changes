# Copyright IBM Corp. 2026

# IAM root user access key should not exist

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "iam-root-access-key-check-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_iam_access_key" "deny_root_user_access_keys" {
    enforcement_level = input.iam-root-access-key-check-enforcement-level
    locals {
        username = core::try(attrs.user, "")
        is_root_user = local.username == "root"
    }

    enforce {
        condition = local.is_root_user == false
        error_message = "IAM access keys for the AWS root user must not exist. Remove the root access key associated with user '${local.username}'"
    }
}
