# Copyright IBM Corp. 2026

# SageMaker endpoint production variants should have an initial instance count greater than 1

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.47.0, < 7.0.0"
    }
  }
}

input "sagemaker-endpoint-config-prod-instance-count-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_sagemaker_endpoint_configuration" "endpoint_instance_count_check" {
    enforcement_level = input.sagemaker-endpoint-config-prod-instance-count-enforcement-level
    filter = attrs.production_variants != null && core::length(attrs.production_variants) > 0

    locals {
        instance_based_variants = [
            for variant in attrs.production_variants :
            variant if core::try(variant.serverless_config, null) == null
        ]

        variants_with_ha = [
            for variant in local.instance_based_variants :
            variant if core::try(variant.initial_instance_count, 1) > 1
        ]

        shadow_variants = core::try(attrs.shadow_production_variants, [])
        
        instance_based_shadow_variants = [
            for variant in local.shadow_variants :
            variant if core::try(variant.serverless_config, null) == null
        ]

        shadow_variants_with_ha = [
            for variant in local.instance_based_shadow_variants :
            variant if core::try(variant.initial_instance_count, 1) > 1
        ]

        total_instance_variants = core::length(local.instance_based_variants)
        total_ha_variants = core::length(local.variants_with_ha)
        
        total_shadow_instance_variants = core::length(local.instance_based_shadow_variants)
        total_shadow_ha_variants = core::length(local.shadow_variants_with_ha)

        failing_variants = [
            for variant in local.instance_based_variants :
            core::try(variant.variant_name, "unnamed") if core::try(variant.initial_instance_count, 1) <= 1
        ]

        failing_shadow_variants = [
            for variant in local.instance_based_shadow_variants :
            core::try(variant.variant_name, "unnamed") if core::try(variant.initial_instance_count, 1) <= 1
        ]
    }

    # Enforce: All instance-based production variants must have initial_instance_count > 1
    enforce {
        condition = local.total_instance_variants == 0 || local.total_instance_variants == local.total_ha_variants
        error_message = "SageMaker endpoint configuration has production variants with initial_instance_count <= 1. For high availability, set initial_instance_count > 1 for all instance-based variants. Note: Serverless variants are exempt from this requirement"
    }

    # Enforce: All instance-based shadow production variants must have initial_instance_count > 1
    enforce {
        condition = local.total_shadow_instance_variants == 0 || local.total_shadow_instance_variants == local.total_shadow_ha_variants
        error_message = "SageMaker endpoint configuration has shadow production variants with initial_instance_count <= 1. For high availability, set initial_instance_count > 1 for all instance-based shadow variants. Note: Serverless variants are exempt from this requirement"
    }
}
