# Copyright IBM Corp. 2026

# Amazon Aurora clusters should have backtracking enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "aurora-mysql-backtracking-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_rds_cluster" "backtracking_enabled" {
    enforcement_level = input.aurora-mysql-backtracking-enabled-enforcement-level
    filter = core::try(attrs.engine, "") == "aurora-mysql"
    locals {
        backtrack_window = core::try(attrs.backtrack_window, 0)
    }
    enforce {
        condition = local.backtrack_window > 0 && local.backtrack_window <= 259200
        error_message = "Amazon Aurora clusters should have backtracking enabled"
    }
}
