# Copyright IBM Corp. 2026

# GuardDuty RDS Protection should be enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.21.0, < 7.0.0"
    }
  }
}

input "guardduty-rds-protection-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_guardduty_detector_feature" "rds_feature_validation" {
  enforcement_level = input.guardduty-rds-protection-enabled-enforcement-level
  filter = attrs.name == "RDS_LOGIN_EVENTS"

  enforce {
    condition = core::try(attrs.status, "DISABLED") == "ENABLED"
    error_message = "GuardDuty RDS Protection feature must have status='ENABLED'"
  }
}

resource_policy "aws_guardduty_organization_configuration_feature" "rds_feature_org_enabled" {
    enforcement_level = input.guardduty-rds-protection-enabled-enforcement-level
    filter = attrs.name == "RDS_LOGIN_EVENTS"

    enforce {
        condition = core::try(attrs.auto_enable, "NONE") == "ALL"
        error_message = "GuardDuty RDS Protection feature does not have RDS_LOGIN_EVENTS properly configured for member accounts. Set auto_enable = 'ALL' to enable for all existing and new member accounts"
    }
}
