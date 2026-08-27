# Copyright IBM Corp. 2026

# AWS KMS keys should not be deleted unintentionally

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "kms-cmk-not-scheduled-for-deletion-2-enforcement-level" {
  type = string
  default = "advisory"
}

input "minimumDeletionWindowInDays" {
    type = number
    default = 30
}

resource_policy "aws_kms_key" "kms_deletion_window" {
    enforcement_level = input.kms-cmk-not-scheduled-for-deletion-2-enforcement-level
    locals {
        valid_input = input.minimumDeletionWindowInDays >= 7 && input.minimumDeletionWindowInDays <= 30
    }

    enforce {
        condition     = local.valid_input && core::try(attrs.deletion_window_in_days, 30) >= input.minimumDeletionWindowInDays
        error_message = "KMS key has a 'deletion_window_in_days' below the required minimum (must be between 7 and 30 days, inclusive). A longer waiting period reduces the risk of unintended key deletion (and unrecoverable data loss). Set 'deletion_window_in_days' to at least the required minimum (max 30)"
    }
}

