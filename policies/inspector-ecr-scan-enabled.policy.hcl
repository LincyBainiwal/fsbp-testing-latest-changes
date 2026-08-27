# Copyright IBM Corp. 2026

# Amazon Inspector ECR scanning should be enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.37.0, < 7.0.0"
    }
  }
}

input "inspector-ecr-scan-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

locals {
    all_ecr_enablers = core::getresources("aws_inspector2_enabler", {})
    has_ecr_scanner  = core::length([
        for e in local.all_ecr_enablers :
        e if core::contains(core::try(e.resource_types, []), "ECR")
    ]) > 0
}

resource_policy "aws_inspector2_enabler" "ecr_scanning_enabled" {
    enforcement_level = input.inspector-ecr-scan-enabled-enforcement-level
    filter = attrs.resource_types != null

    locals {
        resource_types = core::try(attrs.resource_types, [])
    }

    enforce {
        condition     = core::contains(local.resource_types, "ECR")
        error_message = "Amazon Inspector ECR scanning must be enabled. Add 'ECR' to the resource_types list to enable ECR scanning."
    }
}

resource_policy "aws_inspector2_organization_configuration" "ecr_org_scanning_enabled" {
    enforcement_level = input.inspector-ecr-scan-enabled-enforcement-level
    filter = core::try(attrs.auto_enable, null) != null && core::length(core::try(attrs.auto_enable, [])) > 0
    enforce {
        condition     = core::try(attrs.auto_enable[0].ecr, false) == true
        error_message = "Amazon Inspector ECR scanning must be enabled. Set 'auto_enable.ecr = true' to enable ECR scanning."
    }
}

resource_policy "aws_inspector2_organization_configuration" "ecr_enabler_must_exist" {
    enforcement_level = input.inspector-ecr-scan-enabled-enforcement-level
    filter = core::try(attrs.auto_enable, null) != null && core::length(core::try(attrs.auto_enable, [])) > 0

    enforce {
        condition     = local.has_ecr_scanner
        error_message = "Amazon Inspector ECR scanning must be enabled. An aws_inspector2_enabler resource with 'ECR' in resource_types must exist in the plan."
    }
}