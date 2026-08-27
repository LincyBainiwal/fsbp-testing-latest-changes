# Copyright IBM Corp. 2026

# Amazon SageMaker notebook instances should not have direct internet access

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "sagemaker-notebook-no-direct-internet-access-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_sagemaker_notebook_instance" "no_direct_internet_access" {
    enforcement_level = input.sagemaker-notebook-no-direct-internet-access-enforcement-level
    locals {
        internet_access = core::try(attrs.direct_internet_access, "Enabled")
        
        has_subnet = core::try(attrs.subnet_id, null) != null
        has_security_groups = core::try(attrs.security_groups, null) != null && core::length(core::try(attrs.security_groups, [])) > 0
        has_vpc_config = local.has_subnet && local.has_security_groups
    }

    enforce {
        condition = local.internet_access == "Disabled"
        error_message = "SageMaker notebook instance has direct internet access enabled. Set 'direct_internet_access = \"Disabled\"' and configure VPC settings (subnet_id and security_groups) to comply with security requirements"
    }

    enforce {
        condition = local.internet_access == "Enabled" || local.has_vpc_config
        error_message = "SageMaker notebook instance has direct_internet_access disabled but is missing required VPC configuration. When direct internet access is disabled, you must specify both 'subnet_id' and 'security_groups' to enable the notebook instance to access resources through a VPC"
    }
}
