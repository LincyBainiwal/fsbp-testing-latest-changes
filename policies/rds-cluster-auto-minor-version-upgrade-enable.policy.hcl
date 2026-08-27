# Copyright IBM Corp. 2026

# RDS DB clusters should have automatic minor version upgrade enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "rds-cluster-auto-minor-version-upgrade-enable-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_rds_cluster_instance" "auto_minor_version_upgrade_enabled" {
    enforcement_level = input.rds-cluster-auto-minor-version-upgrade-enable-enforcement-level
    enforce {
        condition = core::try(attrs.auto_minor_version_upgrade, true)
        error_message = "RDS cluster instance does not have automatic minor version upgrade enabled. Set 'auto_minor_version_upgrade = true' or remove the attribute to use the default (true) to ensure the instance receives security patches and bug fixes during maintenance windows"
    }
}
