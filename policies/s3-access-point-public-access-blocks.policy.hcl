# Copyright IBM Corp. 2026

# S3 access points should have block public access settings enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "s3-access-point-public-access-blocks-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_s3_access_point" "public_access_blocks" {
    enforcement_level = input.s3-access-point-public-access-blocks-enforcement-level
    locals {
        public_access_block_configuration = core::length(core::try(attrs.public_access_block_configuration, [])) > 0
        block_public_acls = local.public_access_block_configuration ? core::try(attrs.public_access_block_configuration[0].block_public_acls, true) : true
        block_public_policy = local.public_access_block_configuration ? core::try(attrs.public_access_block_configuration[0].block_public_policy, true) : true
        ignore_public_acls = local.public_access_block_configuration ? core::try(attrs.public_access_block_configuration[0].ignore_public_acls, true) : true
        restrict_public_buckets = local.public_access_block_configuration ? core::try(attrs.public_access_block_configuration[0].restrict_public_buckets, true) : true
    }

    enforce {
        condition = local.block_public_acls && local.block_public_policy && local.ignore_public_acls && local.restrict_public_buckets
        error_message = "S3 access point must have ALL four settings enabled"
    }
}