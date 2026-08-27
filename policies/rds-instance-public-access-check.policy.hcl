# Copyright IBM Corp. 2026

# RDS DB Instances should prohibit public access, as determined by the PubliclyAccessible configuration

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "rds-instance-public-access-check-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "aws_db_instance" "rds-instance-should-be-private" {
  enforcement_level = input.rds-instance-public-access-check-enforcement-level
  locals {
    publicly_accessible_raw = core::try(attrs.publicly_accessible, false)
    publicly_accessible     = local.publicly_accessible_raw == null ? false : local.publicly_accessible_raw
  }

  enforce {
    condition     = !local.publicly_accessible
    error_message = "Attribute 'publicly_accessible' should be false for aws_db_instance resource."
  }
}
