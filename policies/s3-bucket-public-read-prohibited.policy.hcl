# Copyright IBM Corp. 2026

# S3 general purpose buckets should block public read access

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "s3-bucket-public-read-prohibited-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_s3_bucket_acl" "bucket-public-read-acls-prohibited" {
    enforcement_level = input.s3-bucket-public-read-prohibited-enforcement-level
    locals {
        invalid_acl_values = ["public-read", "public-read-write"]
        invalid_acl = core::try(attrs.acl, "")
        has_acl = local.invalid_acl != ""
        final_acl = local.has_acl ? local.invalid_acl : "private"
        condition = core::contains(local.invalid_acl_values, local.final_acl)

        has_access_control_policy = local.has_acl ? false : core::length(core::try(attrs.access_control_policy, [])) > 0
        invalid_permissions = ["READ", "READ_ACP", "FULL_CONTROL"]
        
        public_grants = local.has_access_control_policy ? [
            for grant in core::try(attrs.access_control_policy[0].grant, []) : grant
            if core::try(grant.grantee[0].type, "") == "Group" &&
            (core::contains(core::split("/", core::try(grant.grantee[0].uri, "")), "AllUsers") || core::contains(core::split("/", core::try(grant.grantee[0].uri, "")), "AuthenticatedUsers")) &&
            core::contains(local.invalid_permissions, core::try(grant.permission, ""))
        ] : []
        
        has_public_grants = core::length(local.public_grants) > 0
    }

    enforce {
        condition = !local.condition
        error_message = "S3 bucket has an invalid ACL"
    }

    enforce {
        condition = !local.has_public_grants
        error_message = "S3 bucket has public access granted to AllUsers"
    }
}

resource_policy "aws_s3_bucket_public_access_block" "bucket-public-read-prohibited" {
    enforcement_level = input.s3-bucket-public-read-prohibited-enforcement-level
    locals {
        block_public_acls = core::try(attrs.block_public_acls, false)
        block_public_policy = core::try(attrs.block_public_policy, false)
        ignore_public_acls = core::try(attrs.ignore_public_acls, false)
        restrict_public_buckets = core::try(attrs.restrict_public_buckets, false)
    }

    enforce {
        condition = local.block_public_acls && local.block_public_policy && local.ignore_public_acls && local.restrict_public_buckets
        error_message = "S3 bucket does not have any Block Public Access settings enabled"
    }
}