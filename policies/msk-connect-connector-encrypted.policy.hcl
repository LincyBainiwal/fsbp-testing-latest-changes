# Copyright IBM Corp. 2026

# MSK Connect connectors should be encrypted in transit

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.8.0, < 7.0.0"
    }
  }
}

input "msk-connect-connector-encrypted-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_mskconnect_connector" "encryption_in_transit_required" {
    enforcement_level = input.msk-connect-connector-encrypted-enforcement-level
    # Pre-filter to only evaluate connectors that have encryption_in_transit config
    filter = core::try(attrs.kafka_cluster_encryption_in_transit, null) != null && core::length(core::try(attrs.kafka_cluster_encryption_in_transit, [])) > 0

    locals {
        # Safe access to encryption_in_transit configuration
        # kafka_cluster_encryption_in_transit is a block (list of maps)
        encryption_config = core::try(attrs.kafka_cluster_encryption_in_transit[0], null)
        
        # Extract encryption type with safe fallback
        encryption_type = core::try(local.encryption_config.encryption_type, "PLAINTEXT")
        
        # Check if encryption is properly configured
        is_encrypted = local.encryption_type == "TLS"
    }

    enforce {
        condition = local.is_encrypted
        error_message = "MSK Connect connector must have encryption in transit enabled. Current encryption_type: '${local.encryption_type}'. Set kafka_cluster_encryption_in_transit.encryption_type to 'TLS' to meet security best practices"
    }
}
