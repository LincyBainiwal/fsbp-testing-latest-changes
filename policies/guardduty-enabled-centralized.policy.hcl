# Copyright IBM Corp. 2026

# GuardDuty should be enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "guardduty-enabled-centralized-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_guardduty_detector" "guardduty_enabled" {
    enforcement_level = input.guardduty-enabled-centralized-enforcement-level
    enforce {
        condition = core::try(attrs.enable, true) == true
        error_message = "GuardDuty detector must be enabled. Set 'enable = true' to enable threat detection and security monitoring"
    }
}
