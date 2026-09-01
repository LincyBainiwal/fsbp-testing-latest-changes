# Copyright IBM Corp. 2026

# Amazon Inspector EC2 scanning should be enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.37.0, < 7.0.0"
    }
  }
}

input "inspector-ec2-scan-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

locals {
    # Used by the existence-check block below to assert EC2 scanning is present.
    all_ec2_enablers = core::getresources("aws_inspector2_enabler", {})
    has_ec2_scanner  = core::length([
        for e in local.all_ec2_enablers :
        e if core::contains(core::try(e.resource_types, []), "EC2")
    ]) > 0
}

# Block 1: Every aws_inspector2_enabler in the plan must include EC2.
resource_policy "aws_inspector2_enabler" "ec2_scanning_enabled" {
    enforcement_level = input.inspector-ec2-scan-enabled-enforcement-level
    filter = attrs.resource_types != null

    locals {
        resource_types = core::try(attrs.resource_types, [])
    }

    enforce {
        condition     = core::contains(local.resource_types, "EC2")
        error_message = "Amazon Inspector EC2 scanning must be enabled. Add 'EC2' to the resource_types list to enable EC2 scanning."
    }
}

# Block 2: The org configuration must have EC2 auto-enable set.
resource_policy "aws_inspector2_organization_configuration" "ec2_org_scanning_enabled" {
    enforcement_level = input.inspector-ec2-scan-enabled-enforcement-level
    filter = core::try(attrs.auto_enable, null) != null && core::length(core::try(attrs.auto_enable, [])) > 0
    enforce {
        condition     = core::try(attrs.auto_enable[0].ec2, false) == true
        error_message = "Amazon Inspector EC2 scanning must be enabled. Set 'auto_enable.ec2 = true' to enable EC2 scanning."
    }
}

# Block 3: Existence check — anchored on aws_inspector2_organization_configuration
# (a different resource type that fires independently). Verifies that at least one
# aws_inspector2_enabler with EC2 is also present 
resource_policy "aws_inspector2_organization_configuration" "ec2_enabler_must_exist" {
    enforcement_level = input.inspector-ec2-scan-enabled-enforcement-level
    filter = core::try(attrs.auto_enable, null) != null && core::length(core::try(attrs.auto_enable, [])) > 0

    enforce {
        condition     = local.has_ec2_scanner
        error_message = "Amazon Inspector EC2 scanning must be enabled. An aws_inspector2_enabler resource with 'EC2' in resource_types must exist in the plan."
    }
}