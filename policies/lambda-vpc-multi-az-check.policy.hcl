# Copyright IBM Corp. 2026

# VPC Lambda functions should operate in multiple Availability Zones

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "lambda-vpc-multi-az-check-enforcement-level" {
  type = string
  default = "advisory"
}

input "availabilityZones" {
  type = number
  default = 2
}

locals {
  all_subnets = core::getresources("aws_subnet", {})
}

resource_policy "aws_lambda_function" "vpc_multi_az_check" {
  enforcement_level = input.lambda-vpc-multi-az-check-enforcement-level
  # Only evaluate Lambda functions that have VPC configuration
  filter = core::try(attrs.vpc_config, null) != null && core::length(core::try(attrs.vpc_config, [])) > 0

  locals {
    valid_input = input.availabilityZones >= 2 && input.availabilityZones <= 6

    # vpc_config is a single block → index [0] to access subnet_ids
    subnet_ids = core::try(attrs.vpc_config[0].subnet_ids, [])

    # Subnets in the current plan that match the Lambda's subnet_ids
    attached_subnets = [
      for subnet in local.all_subnets :
      subnet if core::contains(local.subnet_ids, subnet.id)
    ]

    # Build a distinct AZ set via map keys (duplicates collapse)
    unique_azs = {
      for subnet in local.attached_subnets :
      subnet.availability_zone => true...
    }
    distinct_azs = core::length(core::keys(local.unique_azs))

    meets_requirement = local.distinct_azs >= input.availabilityZones
  }

  enforce {
    condition = local.valid_input && local.meets_requirement
    error_message = "Lambda function must operate in at least the required number of Availability Zones for high availability (input 'availabilityZones' must be between 2 and 6). Note: subnets referenced via data sources or hardcoded IDs (not declared as aws_subnet in this plan) cannot be resolved and will appear as 0 AZs. Add subnets from additional AZs to meet the requirement"
  }
}

