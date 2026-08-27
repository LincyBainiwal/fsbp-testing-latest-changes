# Copyright IBM Corp. 2026

# OpenSearch domains should have encryption at rest enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9.0, < 7.0.0"
    }
  }
}

input "opensearch-encrypted-at-rest-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_opensearch_domain" "encryption_at_rest_enabled" {
    enforcement_level = input.opensearch-encrypted-at-rest-enforcement-level
    locals {
        encrypt_at_rest = core::try(attrs.encrypt_at_rest, [])
        has_enabled = core::length(local.encrypt_at_rest) > 0 ? core::try(local.encrypt_at_rest[0].enabled, false) : false
        engine_version = core::try(attrs.engine_version, "")
        engine_version_parts = core::split("_", local.engine_version)
        is_elasticsearch = local.engine_version != "" ? local.engine_version_parts[0] == "Elasticsearch" : false
        is_opensearch = local.engine_version != "" ? local.engine_version_parts[0] == "OpenSearch" : false
        is_valid_version = local.is_opensearch || (local.is_elasticsearch && core::semverconstraint(local.engine_version_parts[1], ">= 5.1.0"))
    }

    filter = local.is_valid_version

    enforce {
        condition = local.has_enabled
        error_message = "OpenSearch domains should have encryption at rest enabled"
    }
}
