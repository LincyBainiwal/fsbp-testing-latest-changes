# Copyright IBM Corp. 2026

# SageMaker data quality job definitions should have inter-container traffic encryption enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.63.0, < 7.0.0"
    }
  }
}

input "sagemaker-data-quality-job-encrypt-in-transit-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_sagemaker_data_quality_job_definition" "inter_container_encryption" {
    enforcement_level = input.sagemaker-data-quality-job-encrypt-in-transit-enforcement-level
    filter = core::try(attrs.network_config, null) != null

    enforce {
        condition = core::try(attrs.network_config[0].enable_inter_container_traffic_encryption, false) == true
        error_message = "SageMaker data quality job definition does not have inter-container traffic encryption enabled. Set 'network_config.enable_inter_container_traffic_encryption = true' to protect sensitive ML data during distributed processing"
    }
}
