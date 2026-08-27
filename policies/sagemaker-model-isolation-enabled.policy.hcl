# Copyright IBM Corp. 2026

# SageMaker models should have network isolation enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "sagemaker-model-isolation-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_sagemaker_model" "network_isolation_enabled" {
    enforcement_level = input.sagemaker-model-isolation-enabled-enforcement-level
    enforce {
        condition = core::try(attrs.enable_network_isolation, false) == true
        error_message = "SageMaker model does not have network isolation enabled. Set 'enable_network_isolation = true' to prevent unintended access from the internet. This ensures no inbound or outbound network calls can be made to or from the model container"
    }
}
