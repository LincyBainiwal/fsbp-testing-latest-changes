# Copyright IBM Corp. 2026

# RDS Database clusters should use a custom administrator username

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "rds-cluster-default-admin-check-enforcement-level" {
  type = string
  default = "advisory"
}

input "valid_cluster_admin_usernames" {
    type = string
    default = ""
}

resource_policy "aws_rds_cluster" "cluster_admin_username_check" {
    enforcement_level = input.rds-cluster-default-admin-check-enforcement-level
    locals {
        rds_cluster_has_input = input.valid_cluster_admin_usernames != ""
        master_username = core::try(attrs.master_username, "")
        is_default_admin = local.master_username == "postgres" || local.master_username == "admin" || local.master_username == ""

        input_usernames = local.rds_cluster_has_input ? split(",", input.valid_cluster_admin_usernames) : []
        is_valid_input = !(core::contains(local.input_usernames, "postgres") || core::contains(local.input_usernames, "admin"))
    }

    enforce{
        condition = local.rds_cluster_has_input ? !local.is_default_admin && local.is_valid_input && core::contains(local.input_usernames, local.master_username) : !local.is_default_admin
        error_message = "RDS database clusters should use a custom administrator username"
    }
}