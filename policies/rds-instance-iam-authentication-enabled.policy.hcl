# Copyright IBM Corp. 2026

# IAM authentication should be configured for RDS instances

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "rds-instance-iam-authentication-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_db_instance" "iam_database_authentication_enabled" {
    enforcement_level = input.rds-instance-iam-authentication-enabled-enforcement-level
    filter = core::contains(["mysql", "postgres", "aurora", "aurora-mysql", "aurora-postgresql", "mariadb"], core::try(attrs.engine, ""))

    locals {
        iam_authentication_enabled = core::try(attrs.iam_database_authentication_enabled, false)
    }

    enforce {
        condition = local.iam_authentication_enabled == true
        error_message = "RDS DB instance must enable iam_database_authentication_enabled for supported engines"
    }
}
