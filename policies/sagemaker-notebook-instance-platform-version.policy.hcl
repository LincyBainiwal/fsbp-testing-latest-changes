# Copyright IBM Corp. 2026

# SageMaker notebook instances should run on supported platforms

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "sagemaker-notebook-instance-platform-version-enforcement-level" {
  type = string
  default = "advisory"
}

input "supported_platform_identifier_versions" {
    type = string
    default = "notebook-al2-v3"
}

resource_policy "aws_sagemaker_notebook_instance" "supported_platform" {
    enforcement_level = input.sagemaker-notebook-instance-platform-version-enforcement-level
    locals {
        # Get platform_identifier, defaulting to "notebook-al2-v3" if not explicitly set
        platform_identifier = core::try(attrs.platform_identifier, "notebook-al2-v3")
        
        # List of deprecated platform identifiers that should fail the control
        deprecated_platforms = ["notebook-al1-v1", "notebook-al2-v1", "notebook-al2-v2"]
        
        is_deprecated = core::contains(local.deprecated_platforms, local.platform_identifier)
        
        # The only supported platform per AWS Config rule
        supported_platforms = core::split(",", input.supported_platform_identifier_versions)
        
        # Check if platform is the supported version
        is_supported = core::contains(local.supported_platforms, local.platform_identifier)
    }

    enforce {
        condition = local.is_supported && !local.is_deprecated
        error_message = "SageMaker notebook instance is running on unsupported platform '${local.platform_identifier}'"
    }
}
