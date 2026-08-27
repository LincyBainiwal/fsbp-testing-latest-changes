# Copyright IBM Corp. 2026

# RDS DB clusters should be configured for multiple Availability Zones

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "rds-cluster-multi-az-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_rds_cluster" "multi_az_enabled" {
    enforcement_level = input.rds-cluster-multi-az-enabled-enforcement-level
    locals {
        engine = core::try(attrs.engine, "")
        multi_az_clusters = ["postgres", "mysql"]
        
        availability_zones = core::try(attrs.availability_zones, [])
        az_count = core::length(local.availability_zones)
        
        # Multi-AZ clusters require exactly 3 AZs
        # Aurora clusters should have at least 2 AZs explicitly configured (RDS will assign 3)
        min_required_azs = core::contains(local.multi_az_clusters, local.engine) ? 3 : 2
    }

    enforce {
        condition = local.az_count >= local.min_required_azs
        error_message = "RDS DB cluster must be configured with multiple Availability Zones for high availability"
    }
}
