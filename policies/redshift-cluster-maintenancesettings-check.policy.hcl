# Copyright IBM Corp. 2026

# Amazon Redshift should have automatic upgrades to major versions enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "redshift-cluster-maintenancesettings-check-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_redshift_cluster" "maintenance_settings_check" {
    enforcement_level = input.redshift-cluster-maintenancesettings-check-enforcement-level
    locals {
        version_upgrade = core::try(attrs.allow_version_upgrade, true)
        preferred_maintenance_window = core::try(attrs.preferred_maintenance_window, "")
        automated_snapshot_retention_period = core::try(attrs.automated_snapshot_retention_period, 1)
    }

    enforce {
        condition = local.version_upgrade == true && local.automated_snapshot_retention_period != 0
        error_message = "Redshift cluster does not have maintenance settings configured"
    }
}