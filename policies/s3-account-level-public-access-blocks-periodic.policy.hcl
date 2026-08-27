# Copyright IBM Corp. 2026

# S3 general purpose buckets should have block public access settings enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "s3-account-level-public-access-blocks-periodic-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_s3_account_public_access_block" "block-public-access-enabled" {
    enforcement_level = input.s3-account-level-public-access-blocks-periodic-enforcement-level
    locals {
        block_public_acls = core::try(attrs.block_public_acls, true)
        block_public_policy = core::try(attrs.block_public_policy, true)
        ignore_public_acls = core::try(attrs.ignore_public_acls, true)
        restrict_public_buckets = core::try(attrs.restrict_public_buckets, true)
    }

    enforce {
        condition = local.block_public_acls && local.block_public_policy && local.ignore_public_acls && local.restrict_public_buckets
        error_message = "S3 account-level public access block must have ALL four settings enabled"
    }
}