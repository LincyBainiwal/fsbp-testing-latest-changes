# Copyright IBM Corp. 2026

# IAM users' access keys should be rotated every 90 days or less

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "access-keys-rotated-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_config_config_rule" "access_keys_rotated" {
  enforcement_level = input.access-keys-rotated-enforcement-level
  locals {
    is_access_keys_rotated_rule = core::try(attrs.name, "") == "access-keys-rotated"

    source_identifier = core::try(attrs.source[0].source_identifier, "")
    is_correct_source = local.source_identifier == "ACCESS_KEYS_ROTATED"

    rule_owner     = core::try(attrs.source[0].owner, "")
    is_aws_managed = local.rule_owner == "AWS"

    input_parameters_raw = core::try(attrs.input_parameters, "{}")
    input_parameters     = core::try(core::jsondecode(local.input_parameters_raw), {})
    max_access_key_age   = core::try(local.input_parameters.maxAccessKeyAge, null)

    has_fixed_max_age = (
      local.max_access_key_age == null ||
      local.max_access_key_age == 90 ||
      local.max_access_key_age == "90"
    )
  }

  filter = local.is_access_keys_rotated_rule

  enforce {
    condition = local.is_correct_source
    error_message = "AWS Config rule '${attrs.name}' must use source identifier 'ACCESS_KEYS_ROTATED'. This rule is required for IAM.3 compliance to monitor access key rotation"
  }

  enforce {
    condition = local.is_aws_managed
    error_message = "AWS Config rule '${attrs.name}' must be AWS-managed. This ensures the rule uses AWS's official implementation for monitoring access key rotation"
  }

  enforce {
    condition     = local.has_fixed_max_age
    error_message = "AWS Config rule '${attrs.name}' must use maxAccessKeyAge = 90 (the parameter is not customizable for Security Hub IAM.3)"
  }
}
