# Copyright IBM Corp. 2026

# S3 general purpose buckets should block public access

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "s3-bucket-level-public-access-prohibited-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_s3_bucket" "s3_block_public_access" {
    enforcement_level = input.s3-bucket-level-public-access-prohibited-enforcement-level
    locals {
        public_access_block = core::getresources("aws_s3_bucket_public_access_block", {
            bucket = attrs.id
        })
        block_public_acls = core::try(local.public_access_block[0].block_public_acls, false)
        block_public_policy = core::try(local.public_access_block[0].block_public_policy, false)
        ignore_public_acls = core::try(local.public_access_block[0].ignore_public_acls, false)
        restrict_public_buckets = core::try(local.public_access_block[0].restrict_public_buckets, false)
    }

    enforce {
        condition = local.block_public_acls && local.block_public_policy && local.ignore_public_acls && local.restrict_public_buckets
        error_message = "S3 bucket does not have all required settings enabled. Set all to 'true' to comply with the control"
    }
}
