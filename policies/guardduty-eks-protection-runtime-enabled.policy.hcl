# Copyright IBM Corp. 2026

# GuardDuty EKS Runtime Monitoring should be enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.21.0, < 7.0.0"
    }
  }
}

input "guardduty-eks-protection-runtime-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_guardduty_detector_feature" "eks_runtime_monitoring" {
    enforcement_level = input.guardduty-eks-protection-runtime-enabled-enforcement-level
    filter = attrs.name == "EKS_RUNTIME_MONITORING"

    locals {
        additional_config = core::try(attrs.additional_configuration, [])
        addon_configs = [for config in local.additional_config : config if config.name == "EKS_ADDON_MANAGEMENT"]
        addon_management_enabled = core::length(local.addon_configs) > 0 ? core::try(local.addon_configs[0].status, "DISABLED") == "ENABLED" : false
    }

    enforce {
        condition = core::try(attrs.status, "DISABLED") == "ENABLED"
        error_message = "GuardDuty detector feature must have EKS_RUNTIME_MONITORING enabled. Set status = 'ENABLED' to enable EKS Runtime Monitoring"
    }

    enforce {
        condition = local.addon_management_enabled == true
        error_message = "GuardDuty detector feature must have EKS_ADDON_MANAGEMENT enabled for automated agent management. Add 'additional_configuration { name = \"EKS_ADDON_MANAGEMENT\", status = \"ENABLED\" }' to enable automated agent management"
    }
}


resource_policy "aws_guardduty_organization_configuration_feature" "eks_runtime_monitoring_org_enabled" {
    enforcement_level = input.guardduty-eks-protection-runtime-enabled-enforcement-level
    filter = attrs.name == "EKS_RUNTIME_MONITORING"

    locals {
        additional_config = core::try(attrs.additional_configuration, [])
        addon_configs = [for config in local.additional_config : config if config.name == "EKS_ADDON_MANAGEMENT"]
        addon_management_enabled = core::length(local.addon_configs) > 0 ? core::try(local.addon_configs[0].auto_enable, "NONE") == "ALL" : false
    }

    enforce {
        condition = core::try(attrs.auto_enable, "NONE") == "ALL"
        error_message = "GuardDuty organization configuration feature does not have EKS_ADDON_MANAGEMENT properly configured for member accounts. Set auto_enable = 'ALL' to enable for all existing and new member accounts"
    }

    enforce {
        condition = local.addon_management_enabled == true
        error_message = "GuardDuty organization configuration feature must have EKS_ADDON_MANAGEMENT enabled for automated agent management for member accounts. Add 'additional_configuration { name = \"EKS_ADDON_MANAGEMENT\", auto_enable = \"ALL\" }' to enable automated agent management for all existing and new member accounts"
    }
}
