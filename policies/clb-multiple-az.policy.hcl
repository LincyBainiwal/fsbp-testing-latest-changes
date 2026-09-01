# Copyright IBM Corp. 2026

# Classic Load Balancer should span multiple Availability Zones

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "clb-multiple-az-enforcement-level" {
  type = string
  default = "advisory"
}

input "clb_min_availability_zones" {
    type = number
    default = 2
}

resource_policy "aws_elb" "multiple_availability_zones" {
    enforcement_level = input.clb-multiple-az-enforcement-level
    locals {
        ec2_classic_az_count = core::try(core::length(attrs.availability_zones), 0)
        subnet_ids = core::try(attrs.subnets, null) != null ? attrs.subnets : []
        subnet_lookups = {
            for subnet_id in local.subnet_ids :
            subnet_id => core::getresources("aws_subnet", { id = subnet_id })
        }
        subnets_data = [
            for subnet_id, results in local.subnet_lookups :
            results[0] if core::length(results) > 0
        ]

        subnet_azs = [
            for s in local.subnets_data :
            core::try(s.availability_zone, "")
            if core::try(s.availability_zone, "") != ""
        ]
        distinct_azs   = core::distinct(local.subnet_azs)
        vpc_az_count   = core::length(local.distinct_azs)

        is_valid_input = core::contains([2, 3, 4, 5, 6], input.clb_min_availability_zones)
        actual_az_count = local.ec2_classic_az_count > 0 ? local.ec2_classic_az_count : local.vpc_az_count
    }

    enforce {
        condition = local.is_valid_input && (local.actual_az_count >= input.clb_min_availability_zones)
        error_message = "Classic Load Balancer does not span enough Availability Zones (found ${local.actual_az_count}, need ${input.clb_min_availability_zones}). For EC2-classic ELBs set availability_zones; for VPC ELBs ensure subnets are in distinct AZs."
    }
}