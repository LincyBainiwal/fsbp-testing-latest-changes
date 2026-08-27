# Copyright IBM Corp. 2026

# SageMaker models should use private registry in VPC for primary containers
# AWS Config rule: sagemaker-model-private-registry-required
# NON_COMPLIANT if ImageConfig is missing on the primary_container, or RepositoryAccessMode is "Platform".
# Multi-container inference pipelines (using `container` instead of `primary_container`) are out of scope
# for this control and are covered by SageMaker.19.

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "sagemaker-model-private-registry-required-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_sagemaker_model" "private_registry_required" {
    enforcement_level = input.sagemaker-model-private-registry-required-enforcement-level
    locals {
        # Safe access to primary_container list. Empty list => no primary_container configured.
        primary_container_list = core::try(attrs.primary_container, [])
        has_primary_container  = core::length(local.primary_container_list) > 0
    }

    # Skip models that don't configure a primary_container (covered by SageMaker.19).
    filter = local.has_primary_container

    locals {
        # All accessors are guarded with core::try so locals never crash for filtered-out resources.
        primary_container = core::try(local.primary_container_list[0], {})

        image_config_list = core::try(local.primary_container.image_config, [])
        has_image_config  = core::length(local.image_config_list) > 0

        image_config           = core::try(local.image_config_list[0], {})
        repository_access_mode = core::try(local.image_config.repository_access_mode, "")
        is_vpc_mode            = local.repository_access_mode == "Vpc"

        auth_config_list = core::try(local.image_config.repository_auth_config, [])
        has_auth_config  = core::length(local.auth_config_list) > 0

        credentials_arn = core::try(local.auth_config_list[0].repository_credentials_provider_arn, "")

        # If VPC mode AND auth_config block is provided, credentials ARN must be non-empty.
        # (repository_auth_config is only meaningful with Vpc mode, and when present its ARN field is required.)
        valid_credentials = (local.is_vpc_mode && local.has_auth_config) ? local.credentials_arn != "" : true
    }

    # Enforce: image_config must be configured on the primary container.
    enforce {
        condition     = local.has_image_config
        error_message = "SageMaker model must have image_config configured in primary_container. Configure image_config with repository_access_mode set to 'Vpc' to use a private Docker registry in VPC"
    }

    # Enforce: repository_access_mode must be "Vpc" (not "Platform" or empty).
    enforce {
        condition     = local.is_vpc_mode
        error_message = "SageMaker model must use repository_access_mode 'Vpc' (currently: '${local.repository_access_mode}'). Set repository_access_mode to 'Vpc' to pull container images from a private registry within your VPC instead of the public platform"
    }

    # Enforce: if repository_auth_config is provided, its credentials_provider_arn must be set.
    enforce {
        condition     = local.valid_credentials
        error_message = "SageMaker model primary_container uses VPC mode with repository_auth_config but repository_credentials_provider_arn is empty. Provide the ARN of an AWS Lambda function that supplies credentials for the private Docker registry"
    }
}
