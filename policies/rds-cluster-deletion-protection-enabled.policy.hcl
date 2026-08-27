# Copyright IBM Corp. 2026

# RDS clusters should have deletion protection enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "rds-cluster-deletion-protection-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_rds_cluster" "deletion_protection_enabled" {
    enforcement_level = input.rds-cluster-deletion-protection-enabled-enforcement-level
    enforce {
        condition = core::try(attrs.deletion_protection, false)
        error_message = "RDS clusters should have deletion protection enabled"
    }
}
