# Copyright IBM Corp. 2026

# RDS DB instances should be configured with multiple Availability Zones

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "rds-multi-az-support-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_db_instance" "multi_az_support" {
    enforcement_level = input.rds-multi-az-support-enforcement-level
    enforce {
        condition = core::try(attrs.multi_az, false) == true
        error_message = "RDS DB instances should be configured with multiple Availability Zones"
    }
}
