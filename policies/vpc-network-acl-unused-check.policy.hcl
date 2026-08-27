# Copyright IBM Corp. 2026

# Unused Network Access Control Lists should be removed

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "vpc-network-acl-unused-check-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_network_acl" "unused_nacl_check" {
  enforcement_level = input.vpc-network-acl-unused-check-enforcement-level

  locals {
    # Check if subnet_ids attribute exists and has associations
    has_direct_subnet_associations = core::try(
      attrs.subnet_ids != null && core::length(attrs.subnet_ids) > 0,
      false
    )
  }

  enforce {
    condition     = local.has_direct_subnet_associations
    error_message = "Network ACL is unused and should be removed. Non-default network ACLs must be associated with at least one subnet via the subnet_ids attribute. Unused network ACLs should be deleted to maintain a clean infrastructure"
  }
}


# aws_default_network_acl is intentionally excluded from this check.
# Default NACLs are automatically created by AWS for every VPC and cannot
# be deleted — they will always exist regardless of subnet associations.
# The "unused NACL" hygiene concern applies only to custom aws_network_acl
# resources, which can be freely created and deleted by users.