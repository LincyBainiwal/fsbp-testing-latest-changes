# Copyright IBM Corp. 2026

# OpenSearch domains should have at least three data nodes

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9.0, < 7.0.0"
    }
  }
}

input "opensearch-data-node-fault-tolerance-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_opensearch_domain" "data_node_fault_tolerance" {
    enforcement_level = input.opensearch-data-node-fault-tolerance-enforcement-level

    locals {
        cluster_config = core::try(attrs.cluster_config, [])
        instance_count = core::length(local.cluster_config) > 0 ? core::try(local.cluster_config[0].instance_count, 1) : 1
        zone_awareness_enabled = core::try(local.cluster_config[0].zone_awareness_enabled, false)
    }

    enforce {
        condition = local.instance_count >= 3
        error_message = "OpenSearch domain must have at least 3 data nodes for high availability. Set cluster_config.instance_count to 3 or more"
    }

    enforce {
        condition = local.zone_awareness_enabled == true
        error_message = "OpenSearch domain must have zone awareness enabled for fault tolerance. Set cluster_config.zone_awareness_enabled = true"
    }
}
