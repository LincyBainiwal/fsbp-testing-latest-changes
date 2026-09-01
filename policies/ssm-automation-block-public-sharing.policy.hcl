# Copyright IBM Corp. 2026

# SSM documents should have the block public sharing setting enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.24.0, < 7.0.0"
    }
  }
}

input "ssm-automation-block-public-sharing-enforcement-level" {
  type = string
  default = "advisory"
}

locals {
  required_setting_id = "/ssm/documents/console/public-sharing-permission"

  all_ssm_settings = core::getresources("aws_ssm_service_setting", {})

  matching_public_sharing_settings = [
    for s in local.all_ssm_settings :
    s if core::try(s.setting_id, "") == local.required_setting_id
  ]
}

# Check the value of the public-sharing-permission setting when it is present.
# filter scopes evaluation to only the required setting_id 
resource_policy "aws_ssm_service_setting" "block_public_sharing" {
  enforcement_level = input.ssm-automation-block-public-sharing-enforcement-level
  filter = core::try(attrs.setting_id, "") == local.required_setting_id

  locals {
    setting_value = core::try(attrs.setting_value, "")
  }

  enforce {
    condition     = local.setting_value == "Disable"
    error_message = "SSM block public sharing must be set to 'Disable' to prevent public sharing of SSM documents. Current value: '${local.setting_value}'. Set setting_value = \"Disable\" on the aws_ssm_service_setting resource with setting_id '${local.required_setting_id}'."
  }
}

# Existence check — fails when no aws_ssm_service_setting resource for the
# required setting_id is present
resource_policy "aws_ssm_service_setting" "block_public_sharing_exists" {
  enforcement_level = input.ssm-automation-block-public-sharing-enforcement-level
  # Only run this check once — trigger on the first setting resource in the plan.
  filter = core::length(local.all_ssm_settings) > 0

  enforce {
    condition     = core::length(local.matching_public_sharing_settings) > 0
    error_message = "No aws_ssm_service_setting resource found with setting_id '${local.required_setting_id}'. Add an aws_ssm_service_setting resource with setting_id = \"${local.required_setting_id}\" and setting_value = \"Disable\" to block public sharing of SSM documents."
  }
}