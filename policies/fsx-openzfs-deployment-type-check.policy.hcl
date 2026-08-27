# Copyright IBM Corp. 2026

# FSx for OpenZFS file systems should be configured for Multi-AZ deployment

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "fsx-openzfs-deployment-type-check-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_fsx_openzfs_file_system" "openzfs_multi_az_deployment" {
    enforcement_level = input.fsx-openzfs-deployment-type-check-enforcement-level
    locals {
        deployment_type = core::try(attrs.deployment_type, "")
    }

    enforce {
        condition = local.deployment_type == "MULTI_AZ_1"
        error_message = "FSx for OpenZFS file system is not configured for Multi-AZ deployment. Set deployment_type = 'MULTI_AZ_1' for high availability and durability in production workloads"
    }
}
