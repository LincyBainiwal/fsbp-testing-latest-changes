# Copyright IBM Corp. 2026

# FSx for Windows File Server file systems should be configured for Multi-AZ deployment

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "fsx-windows-deployment-type-check-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_fsx_windows_file_system" "multi_az_deployment" {
    enforcement_level = input.fsx-windows-deployment-type-check-enforcement-level
    locals {
        deployment_type = core::try(attrs.deployment_type, "SINGLE_AZ_1")
    }

    enforce {
        condition = local.deployment_type == "MULTI_AZ_1"
        error_message = "FSx for Windows File Server file system is not configured for Multi-AZ deployment. Set deployment_type = 'MULTI_AZ_1' for high availability and durability in production workloads"
    }
}
