# Copyright IBM Corp. 2026

# SES configuration sets should have TLS enabled for sending emails

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.35.0, < 7.0.0"
    }
  }
}

input "ses-sending-tls-required-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_ses_configuration_set" "tls_required" {
    enforcement_level = input.ses-sending-tls-required-enforcement-level
    locals {

        # Safe access to delivery_options and tls_policy
        delivery_options = core::try(attrs.delivery_options, [])
        has_delivery_options = core::length(local.delivery_options) > 0
        
        # Extract TLS policy (default is 'Optional' if not specified)
        tls_policy = local.has_delivery_options ? core::try(local.delivery_options[0].tls_policy, "Optional") : "Optional"
        
        # Check if TLS is required
        is_compliant = local.tls_policy == "Require"
    }

    enforce {
        condition = local.is_compliant
        error_message = "SES configuration set must have TLS policy set to 'Require'. Current value: '${local.tls_policy}'. Update delivery_options.tls_policy to 'Require'"
    }
}

# Policy for SES v2 configuration sets
resource_policy "aws_sesv2_configuration_set" "tls_required" {
    enforcement_level = input.ses-sending-tls-required-enforcement-level
    locals {
        # Safe access to delivery_options and tls_policy
        delivery_options = core::try(attrs.delivery_options, [])
        has_delivery_options = core::length(local.delivery_options) > 0
        
        # Extract TLS policy (default is 'OPTIONAL' if not specified)
        tls_policy = local.has_delivery_options ? core::try(local.delivery_options[0].tls_policy, "OPTIONAL") : "OPTIONAL"
        
        # Check if TLS is required
        is_compliant = local.tls_policy == "REQUIRE"
    }

    enforce {
        condition = local.is_compliant
        error_message = "SES v2 configuration set must have TLS policy set to 'REQUIRE'. Current value: '${local.tls_policy}'. Update delivery_options.tls_policy to 'REQUIRE'"
    }
}
