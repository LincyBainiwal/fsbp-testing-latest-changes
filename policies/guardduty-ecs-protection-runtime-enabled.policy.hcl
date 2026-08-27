# Copyright IBM Corp. 2026

# GuardDuty ECS Runtime Monitoring should be enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.21.0, < 7.0.0"
    }
  }
}

input "guardduty-ecs-protection-runtime-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_guardduty_detector_feature" "ecs_runtime_monitoring" {
    enforcement_level = input.guardduty-ecs-protection-runtime-enabled-enforcement-level
    filter = attrs.name == "RUNTIME_MONITORING"

    locals {
        feature_enabled = core::try(attrs.status, "DISABLED") == "ENABLED"

        additional_configs = core::try(attrs.additional_configuration, [])
        ecs_fargate_configs = [
            for config in local.additional_configs :
            config if core::try(config.name, "") == "ECS_FARGATE_AGENT_MANAGEMENT"
        ]
        ecs_fargate_enabled = core::length(local.ecs_fargate_configs) > 0 ? core::try(local.ecs_fargate_configs[0].status, "DISABLED") == "ENABLED" : false
    }

    enforce {
        condition = local.feature_enabled
        error_message = "GuardDuty detector feature must have RUNTIME_MONITORING status set to 'ENABLED'"
    }

    enforce {
        condition = local.ecs_fargate_enabled
        error_message = "GuardDuty detector feature must have ECS_FARGATE_AGENT_MANAGEMENT enabled in additional_configuration"
    }
}

resource_policy "aws_guardduty_organization_configuration_feature" "ecs_runtime_monitoring" {
    enforcement_level = input.guardduty-ecs-protection-runtime-enabled-enforcement-level
    filter = attrs.name == "RUNTIME_MONITORING"

    locals {
        feature_enabled = core::try(attrs.auto_enable, "NONE") == "ALL"

        additional_configs = core::try(attrs.additional_configuration, [])
        ecs_fargate_configs = [
            for config in local.additional_configs :
            config if core::try(config.name, "") == "ECS_FARGATE_AGENT_MANAGEMENT"
        ]
        ecs_fargate_enabled = core::length(local.ecs_fargate_configs) > 0 ? core::try(local.ecs_fargate_configs[0].auto_enable, "NONE") == "ALL" : false
    }

    enforce {
        condition = local.feature_enabled
        error_message = "GuardDuty detector feature must have RUNTIME_MONITORING status set to 'ALL'"
    }

    enforce {
        condition = local.ecs_fargate_enabled
        error_message = "GuardDuty detector feature must have ECS_FARGATE_AGENT_MANAGEMENT enabled in additional_configuration"
    }
}
