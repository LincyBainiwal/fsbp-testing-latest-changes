# Copyright IBM Corp. 2026

# OpenSearch domains should have the latest software update installed

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.16.0, < 7.0.0"
    }
  }
}

input "opensearch-update-check-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_opensearch_domain" "latest_software_update_installed" {
    enforcement_level = input.opensearch-update-check-enforcement-level
    locals {
        has_software_updates = core::try(attrs.software_update_options, null) != null
        auto_software_update_enabled = local.has_software_updates ? core::try(attrs.software_update_options[0].auto_software_update_enabled, false) : false
    }

    enforce {
        condition = local.auto_software_update_enabled == true
        error_message = "OpenSearch domain must explicitly enable software_update_options.auto_software_update_enabled = true so service software updates are automatically installed"
    }
}
