# Copyright IBM Corp. 2026

# OpenSearch domains should encrypt data sent between nodes

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9.0, < 7.0.0"
    }
  }
}

input "opensearch-node-to-node-encryption-check-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_opensearch_domain" "node_encryption_enabled" {
    enforcement_level = input.opensearch-node-to-node-encryption-check-enforcement-level
    locals {
        node_encryption = core::try(attrs.node_to_node_encryption, [])
        has_enabled = core::length(local.node_encryption) > 0 ? core::try(local.node_encryption[0].enabled, false) : false
        engine_version = core::try(attrs.engine_version, "")
        engine_version_parts = core::split("_", local.engine_version)
        is_elasticsearch = local.engine_version != "" ? local.engine_version_parts[0] == "Elasticsearch" : false
        is_opensearch = local.engine_version != "" ? local.engine_version_parts[0] == "OpenSearch" : false
        is_valid_version = local.is_opensearch || (local.is_elasticsearch && core::semverconstraint(local.engine_version_parts[1], ">= 6.0.0"))
    }

    filter = local.is_valid_version

    enforce {
        condition = local.has_enabled
        error_message = "OpenSearch domains should have node-to-node encryption enabled"
    }
}
