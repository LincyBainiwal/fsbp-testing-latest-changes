# Copyright IBM Corp. 2026

# Service Catalog portfolios should be shared within an AWS organization only

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "service-catalog-shared-within-organization-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_servicecatalog_portfolio_share" "organization_only_sharing" {
    enforcement_level = input.service-catalog-shared-within-organization-enforcement-level
    locals {

        # Extract the share type safely
        share_type = core::try(attrs.type, "")
        
        # Check if this is an external account share (non-compliant)
        is_external_account = local.share_type == "ACCOUNT"
        
        # Valid organization-based share types
        valid_org_types = ["ORGANIZATION", "ORGANIZATIONAL_UNIT", "ORGANIZATION_MEMBER_ACCOUNT"]
        
        # Check if share type is organization-based (compliant)
        is_org_based = core::contains(local.valid_org_types, local.share_type)
    }

    enforce {
        condition = !local.is_external_account
        error_message = "Portfolio share uses type='ACCOUNT' which shares with external accounts. Service Catalog portfolios must be shared within the organization only. Use 'ORGANIZATION_MEMBER_ACCOUNT' (recommended), 'ORGANIZATIONAL_UNIT', or 'ORGANIZATION' instead"
    }

    enforce {
        condition = local.is_org_based
        error_message = "Portfolio share has invalid or missing share type '${local.share_type}'. Valid organization-based types are: ${core::join(", ", local.valid_org_types)}. Recommended: 'ORGANIZATION_MEMBER_ACCOUNT' for sharing with specific accounts in the organization"
    }
}
