# Copyright IBM Corp. 2026

# Amazon Macie should be enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "macie-status-check-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_macie2_account" "macie_enabled" {
    enforcement_level = input.macie-status-check-enforcement-level
    locals {
        macie_status = core::try(attrs.status, "")
        remediation_text = "Set status = ENABLED in the aws_macie2_account resource to enable Macie and start all Macie activities for the account."
        
        is_enabled = local.macie_status == "ENABLED"
    }

    enforce {
        condition = local.is_enabled
        error_message = "Amazon Macie must be enabled for the account. Status is '${local.macie_status}' but must be ENABLED. ${local.remediation_text}"
    }
}
