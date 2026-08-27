# Copyright IBM Corp. 2026

# SageMaker data quality job definitions should have network isolation enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.63.0, < 7.0.0"
    }
  }
}

input "sagemaker-data-quality-job-isolation-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_sagemaker_data_quality_job_definition" "data_quality_network_isolation_enabled" {
    enforcement_level = input.sagemaker-data-quality-job-isolation-enforcement-level
    locals {
        network_config = core::try(attrs.network_config, [])
        has_network_config = core::length(local.network_config) > 0
        
        network_isolation_enabled = local.has_network_config ? core::try(local.network_config[0].enable_network_isolation, false) : false
    }

    enforce {
        condition = local.network_isolation_enabled == true
        error_message = "SageMaker data quality job definition does not have network isolation enabled. Set 'network_config.enable_network_isolation = true' to reduce attack surface and prevent unauthorized external access"
    }
}
