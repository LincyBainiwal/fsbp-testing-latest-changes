# Copyright IBM Corp. 2026

# GuardDuty EKS Audit Log Monitoring should be enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.21.0, < 7.0.0"
    }
  }
}

input "guardduty-eks-protection-audit-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

# Check standalone account GuardDuty detector feature configuration
resource_policy "aws_guardduty_detector_feature" "eks_audit_logs_enabled" {
    enforcement_level = input.guardduty-eks-protection-audit-enabled-enforcement-level
    filter = attrs.name == "EKS_AUDIT_LOGS"

    enforce {
        condition = core::try(attrs.status, "DISABLED") == "ENABLED"
        error_message = "GuardDuty detector feature does not have EKS Audit Log Monitoring enabled. Set status = 'ENABLED' to enable EKS audit log monitoring for threat detection in EKS clusters"
    }
}

# Check organization-wide GuardDuty configuration for EKS Audit Logs
resource_policy "aws_guardduty_organization_configuration_feature" "eks_audit_logs_org_enabled" {
    enforcement_level = input.guardduty-eks-protection-audit-enabled-enforcement-level
    filter = attrs.name == "EKS_AUDIT_LOGS"

    enforce {
        condition = core::try(attrs.auto_enable, "NONE") == "ALL"
        error_message = "GuardDuty organization configuration feature does not have EKS Audit Log Monitoring properly configured for member accounts. Set auto_enable = 'ALL' to enable for all existing and new member accounts"
    }
}
