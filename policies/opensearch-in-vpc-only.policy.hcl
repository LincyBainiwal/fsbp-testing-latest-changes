# Copyright IBM Corp. 2026

# OpenSearch domains should not be publicly accessible

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9.0, < 7.0.0"
    }
  }
}

input "opensearch-in-vpc-only-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_opensearch_domain" "vpc_deployment_required" {
    enforcement_level = input.opensearch-in-vpc-only-enforcement-level
    locals {
        vpc_options = core::try(attrs.vpc_options, null)
        has_vpc_options = local.vpc_options != null
        has_subnet_ids = local.has_vpc_options && core::length(core::try(local.vpc_options[0].subnet_ids, [])) > 0
    }

    enforce {
        condition = local.has_vpc_options && local.has_subnet_ids
        error_message = "OpenSearch domain must be deployed within a VPC. Configure 'vpc_options' block with 'subnet_ids' to deploy the domain in a VPC. Note: Public domains cannot be migrated to VPC - you must create a new domain"
    }
}
