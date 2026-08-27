# Copyright IBM Corp. 2026

# Amazon Redshift clusters should have automatic snapshots enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "redshift-backup-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

input "min_retention_period" {
    type = number
    default = 1
}

input "max_retention_period" {
    type = number
    default = 35
}

resource_policy "aws_redshift_cluster" "redshift-backup-enabled" {
    enforcement_level = input.redshift-backup-enabled-enforcement-level
    locals {
        backup_enabled = core::try(attrs.automated_snapshot_retention_period, 1)
    }

    enforce {
        condition = (local.backup_enabled >= input.min_retention_period) && (local.backup_enabled <= input.max_retention_period) && (local.backup_enabled != 0)
        error_message = "Redshift cluster does not have automated snapshots enabled"
    }
}