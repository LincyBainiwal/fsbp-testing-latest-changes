# Copyright IBM Corp. 2026

# IAM authentication should be configured for RDS clusters

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "rds-cluster-iam-authentication-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_rds_cluster" "iam_authentication_enabled" {
    enforcement_level = input.rds-cluster-iam-authentication-enabled-enforcement-level
    enforce {
        condition = core::try(attrs.iam_database_authentication_enabled, false)
        error_message = "RDS cluster does not have IAM database authentication enabled. Set 'iam_database_authentication_enabled = true' to enable password-free authentication with IAM"
    }
}
