# Copyright IBM Corp. 2026

# Amazon Inspector Lambda standard scanning should be enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.59.0, < 7.0.0"
    }
  }
}

input "inspector-lambda-standard-scan-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

locals {
    all_lambda_enablers = core::getresources("aws_inspector2_enabler", {})
    has_lambda_scanner  = core::length([
        for e in local.all_lambda_enablers :
        e if core::contains(core::try(e.resource_types, []), "LAMBDA")
    ]) > 0
}

# Block 1: Every aws_inspector2_enabler in the plan must include LAMBDA.
resource_policy "aws_inspector2_enabler" "lambda_scanning_enabled" {
    enforcement_level = input.inspector-lambda-standard-scan-enabled-enforcement-level
    filter = attrs.resource_types != null

    locals {
        resource_types = core::try(attrs.resource_types, [])
    }

    enforce {
        condition     = core::contains(local.resource_types, "LAMBDA")
        error_message = "Amazon Inspector Lambda scanning must be enabled. Add 'LAMBDA' to the resource_types list to enable Lambda scanning."
    }
}

# Block 2: The org configuration must have Lambda auto-enable set.
resource_policy "aws_inspector2_organization_configuration" "lambda_org_scanning_enabled" {
    enforcement_level = input.inspector-lambda-standard-scan-enabled-enforcement-level
    filter = core::try(attrs.auto_enable, null) != null && core::length(core::try(attrs.auto_enable, [])) > 0
    enforce {
        condition     = core::try(attrs.auto_enable[0].lambda, false) == true
        error_message = "Amazon Inspector Lambda scanning must be enabled. Set 'auto_enable.lambda = true' to enable Lambda scanning."
    }
}

# Block 3: Existence check — anchored on aws_inspector2_organization_configuration.
# Verifies that at least one aws_inspector2_enabler with LAMBDA is also present . 
resource_policy "aws_inspector2_organization_configuration" "lambda_enabler_must_exist" {
    enforcement_level = input.inspector-lambda-standard-scan-enabled-enforcement-level
    filter = core::try(attrs.auto_enable, null) != null && core::length(core::try(attrs.auto_enable, [])) > 0

    enforce {
        condition     = local.has_lambda_scanner
        error_message = "Amazon Inspector Lambda scanning must be enabled. An aws_inspector2_enabler resource with 'LAMBDA' in resource_types must exist in the plan."
    }
}