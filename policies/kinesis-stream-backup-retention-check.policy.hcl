# Copyright IBM Corp. 2026

# Kinesis streams should have an adequate data retention period

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "kinesis-stream-backup-retention-check-enforcement-level" {
  type = string
  default = "advisory"
}

input "minimumBackupRetentionPeriod" {
    type = number
    default = 168
}

resource_policy "aws_kinesis_stream" "kinesis_retention_check" {
    enforcement_level = input.kinesis-stream-backup-retention-check-enforcement-level
    locals {
        valid_retention = input.minimumBackupRetentionPeriod >= 24 && input.minimumBackupRetentionPeriod <= 8760
    }

    enforce {
        condition     = local.valid_retention && core::try(attrs.retention_period, 24) >= input.minimumBackupRetentionPeriod
        error_message = "Kinesis stream has an insufficient data retention period (must be between 24 and 8760 hours, inclusive). Update the 'retention_period' argument to meet the minimum required hours to comply with AWS Security Hub Kinesis.3 control"
    }
}

