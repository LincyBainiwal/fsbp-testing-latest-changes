# Copyright IBM Corp. 2026

# GuardDuty S3 Protection should be enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.21.0, < 7.0.0"
    }
  }
}

input "guardduty-s3-protection-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_guardduty_detector_feature" "s3_protection_enabled" {
    enforcement_level = input.guardduty-s3-protection-enabled-enforcement-level
    filter = attrs.name == "S3_DATA_EVENTS"

    locals {
        feature_status = core::try(attrs.status, "DISABLED")
    }

    enforce {
        condition = core::try(attrs.status, "DISABLED") == "ENABLED"
        error_message = "GuardDuty detector feature for S3 Protection (S3_DATA_EVENTS) must have status 'ENABLED'. Enable S3 Protection to monitor object-level API operations in S3 buckets"
    }
}

resource_policy "aws_guardduty_organization_configuration_feature" "s3_protection_org_enabled" {
    enforcement_level = input.guardduty-s3-protection-enabled-enforcement-level
    filter = attrs.name == "S3_DATA_EVENTS"

    enforce {
        condition = core::try(attrs.auto_enable, "NONE") == "ALL"
        error_message = "GuardDuty organization configuration feature does not have S3 Protection (S3_DATA_EVENTS) properly configured for member accounts. Set auto_enable = 'ALL' to enable for all existing and new member accounts"
    }
}
