# Copyright IBM Corp. 2026

# SageMaker monitoring schedules should have network isolation enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.63.0, < 7.0.0"
    }
  }
}

input "sagemaker-monitoring-schedule-isolation-enforcement-level" {
  type = string
  default = "advisory"
}

# Check monitoring schedules with inline job definitions
resource_policy "aws_sagemaker_monitoring_schedule" "network_isolation_enabled" {
    enforcement_level = input.sagemaker-monitoring-schedule-isolation-enforcement-level
    filter = core::length(core::try(attrs.monitoring_schedule_config, [])) > 0 && core::length(core::try(core::jsondecode(core::jsonencode(attrs.monitoring_schedule_config[0])).monitoring_job_definition, [])) > 0

    locals {
        schedule_config = core::jsondecode(core::jsonencode(attrs.monitoring_schedule_config[0]))
        job_def = local.schedule_config.monitoring_job_definition[0]
        has_network_config = core::try(local.job_def.network_config, null) != null && core::length(core::try(local.job_def.network_config, [])) > 0
        network_isolation_enabled = local.has_network_config ? core::try(local.job_def.network_config[0].enable_network_isolation, false) : false
    }

    enforce {
        condition = local.network_isolation_enabled == true
        error_message = "SageMaker monitoring schedule does not have network isolation enabled. Set 'monitoring_schedule_config.monitoring_job_definition.network_config.enable_network_isolation = true' to prevent outbound network calls from monitoring containers"
    }
}

# Check data quality job definitions (can be referenced by monitoring schedules)
resource_policy "aws_sagemaker_data_quality_job_definition" "network_isolation_enabled" {
    enforcement_level = input.sagemaker-monitoring-schedule-isolation-enforcement-level
    locals {
        has_network_config = core::try(attrs.network_config, null) != null && core::length(core::try(attrs.network_config, [])) > 0
        network_isolation_enabled = local.has_network_config ? core::try(attrs.network_config[0].enable_network_isolation, false) : false
    }

    enforce {
        condition = local.network_isolation_enabled == true
        error_message = "SageMaker data quality job definition does not have network isolation enabled. Set 'network_config.enable_network_isolation = true' to prevent outbound network calls from monitoring containers"
    }
}
