# Copyright IBM Corp. 2026

# OpenSearch domains should have fine-grained access control enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9.0, < 7.0.0"
    }
  }
}

input "opensearch-access-control-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_opensearch_domain" "fine_grained_access_control" {
    enforcement_level = input.opensearch-access-control-enabled-enforcement-level
    locals {
        advanced_security_options = core::try(attrs.advanced_security_options[0], null)
        has_advanced_security_options = local.advanced_security_options != null
        fgac_enabled = local.has_advanced_security_options ? core::try(local.advanced_security_options.enabled, false) : false
    }

    enforce {
        condition = local.has_advanced_security_options && local.fgac_enabled == true
        error_message = "OpenSearch domain does not have fine-grained access control properly configured. Required: 'advanced_security_options { enabled = true }'. Ensure the advanced_security_options block exists and enabled is set to true to comply with AWS Security Hub control Opensearch.7"
    }
}
