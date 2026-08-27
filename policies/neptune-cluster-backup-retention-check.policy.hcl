# Copyright IBM Corp. 2026

# Neptune DB clusters should have automated backups enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "neptune-cluster-backup-retention-check-enforcement-level" {
  type = string
  default = "advisory"
}

input "min_backup_retention_period" {
    type = number
    default = 7
}

resource_policy "aws_neptune_cluster" "backup-retention-period" {
    enforcement_level = input.neptune-cluster-backup-retention-check-enforcement-level
    enforce {
        condition = input.min_backup_retention_period >= 1 && input.min_backup_retention_period <= 35 && core::try(attrs.backup_retention_period, 1) >= input.min_backup_retention_period
        error_message = "The backup retention period for the Neptune cluster is less than the minimum required"
    }
}