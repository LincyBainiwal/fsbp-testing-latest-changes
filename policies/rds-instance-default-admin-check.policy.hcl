# Copyright IBM Corp. 2026

# RDS database instances should use a custom administrator username

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "rds-instance-default-admin-check-enforcement-level" {
  type = string
  default = "advisory"
}

input "valid_instance_admin_usernames" {
    type = string
    default = ""
}

resource_policy "aws_db_instance" "instance_admin_username_check" {
    enforcement_level = input.rds-instance-default-admin-check-enforcement-level
    locals {
        rds_instance_has_input = input.valid_instance_admin_usernames != ""
        username = core::try(attrs.username, "")
        is_default_admin = local.username == "postgres" || local.username == "admin" || local.username == ""

        input_usernames = local.rds_instance_has_input ? split(",", input.valid_instance_admin_usernames) : []
        is_valid_input = !(core::contains(local.input_usernames, "postgres") || core::contains(local.input_usernames, "admin"))
    }

    enforce{
        condition = local.rds_instance_has_input ? !local.is_default_admin && local.is_valid_input && core::contains(local.input_usernames, local.username) : !local.is_default_admin
        error_message = "RDS database instances should use a custom administrator username"
    }
}