# Copyright IBM Corp. 2026

# S3 Multi-Region Access Points should have block public access settings enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "s3-mrap-public-access-blocked-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_s3control_multi_region_access_point" "block_public_access_enabled" {
    enforcement_level = input.s3-mrap-public-access-blocked-enforcement-level
    locals {
        # Safe access to public_access_block configuration
        # If not defined, this will be null (which means defaults apply - all true)
        public_access_block = core::try(attrs.details[0].public_access_block, null)

        # Extract individual settings with safe defaults
        # If setting is not specified, it defaults to true (compliant)
        block_public_acls = core::try(local.public_access_block[0].block_public_acls, true)
        block_public_policy = core::try(local.public_access_block[0].block_public_policy, true)
        ignore_public_acls = core::try(local.public_access_block[0].ignore_public_acls, true)
        restrict_public_buckets = core::try(local.public_access_block[0].restrict_public_buckets, true)
    }

    # Enforce: all public access block settings must be true
    enforce {
        condition = local.block_public_acls && local.block_public_policy && local.ignore_public_acls && local.restrict_public_buckets
        error_message = "S3 Multi-Region Access Point must have all Block Public Access settings enabled. Set all details.public_access_block fields to true or omit them to use the secure defaults"
    }
}
