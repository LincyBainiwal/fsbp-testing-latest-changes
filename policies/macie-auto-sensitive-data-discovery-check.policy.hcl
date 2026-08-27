# Copyright IBM Corp. 2026

# Macie automated sensitive data discovery should be enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "macie-auto-sensitive-data-discovery-check-enforcement-level" {
  type = string
  default = "advisory"
}

# After applying this policy, enable automated discovery separately via:
#   - AWS Console: Macie > Settings > Automated sensitive data discovery
#   - AWS CLI: aws macie2 update-automated-discovery-configuration --status ENABLED

resource_policy "aws_macie2_account" "macie_enabled_for_discovery" {
  enforcement_level = input.macie-auto-sensitive-data-discovery-check-enforcement-level
  filter = core::try(attrs.status, null) != null

  enforce {
    condition     = core::try(attrs.status, "") == "ENABLED"
    error_message = "Amazon Macie must be enabled (status = \"ENABLED\") as a prerequisite for automated sensitive data discovery. This policy validates Macie is enabled only — it CANNOT validate whether automated sensitive data discovery is turned on, as the Terraform AWS provider does not expose that setting. After enabling Macie, enable automated discovery via the AWS Console (Macie > Settings > Automated sensitive data discovery) or `aws macie2 update-automated-discovery-configuration --status ENABLED`."
  }
}