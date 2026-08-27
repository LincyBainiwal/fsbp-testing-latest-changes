# Copyright IBM Corp. 2026

# RDS automatic minor version upgrades should be enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "rds-automatic-minor-version-upgrade-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_db_instance" "automatic_minor_version_upgrade_enabled" {
    enforcement_level = input.rds-automatic-minor-version-upgrade-enabled-enforcement-level
    enforce {
        condition = core::try(attrs.auto_minor_version_upgrade, true)
        error_message = "RDS automatic minor version upgrades should be enabled"
    }
}
