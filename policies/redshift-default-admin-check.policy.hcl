# Copyright IBM Corp. 2026

# Amazon Redshift clusters should not use the default Admin username

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "redshift-default-admin-check-enforcement-level" {
  type = string
  default = "advisory"
}

input "valid_admin_usernames" {
    type = string
    default = "awsuser"
}

resource_policy "aws_redshift_cluster" "default-admin-check" {
  enforcement_level = input.redshift-default-admin-check-enforcement-level
  locals {
    username = core::try(attrs.master_username, "awsuser")
    valid_admin_usernames_provided = input.valid_admin_usernames != "awsuser"
    valid_usernames = local.valid_admin_usernames_provided ? core::contains(core::split(",", input.valid_admin_usernames), local.username) : true
  }
  
  enforce {
    condition = local.username != "awsuser" && local.valid_usernames
    error_message = "Redshift cluster username is either set to default 'awsuser' value or does not match accepted list of admin usernames"
  }
}