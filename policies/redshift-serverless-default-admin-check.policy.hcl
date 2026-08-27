# Copyright IBM Corp. 2026

# Redshift Serverless namespaces should not use the default admin username

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.23.0, < 7.0.0"
    }
  }
}

input "redshift-serverless-default-admin-check-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_redshiftserverless_namespace" "no_default_admin_username" {
    enforcement_level = input.redshift-serverless-default-admin-check-enforcement-level
    locals {
        # Safely get admin_username, default to "admin" if not specified
        # This matches AWS behavior where omitting admin_username uses "admin" as default
        admin_username = core::try(attrs.admin_username, "admin")
        
        # Check if using default username
        uses_default_username = local.admin_username == "admin"
    }

    enforce {
        condition = !local.uses_default_username
        error_message = "Redshift Serverless namespace must not use the default admin username 'admin'. Specify a custom admin_username to improve security and mitigate brute force attack risks"
    }
}
