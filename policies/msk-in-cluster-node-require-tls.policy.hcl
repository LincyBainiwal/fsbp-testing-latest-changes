# Copyright IBM Corp. 2026

# MSK clusters should be encrypted in transit among broker nodes
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "msk-in-cluster-node-require-tls-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_msk_cluster" "encryption_in_transit" {
    enforcement_level = input.msk-in-cluster-node-require-tls-enforcement-level
    locals {
        has_encryption_info = core::try(attrs.encryption_info, null) != null && core::length(core::try(attrs.encryption_info, [])) > 0
        
        has_encryption_in_transit = local.has_encryption_info && core::try(attrs.encryption_info[0].encryption_in_transit, null) != null && core::length(core::try(attrs.encryption_info[0].encryption_in_transit, [])) > 0
        
        in_cluster_encryption = local.has_encryption_in_transit ? core::try(attrs.encryption_info[0].encryption_in_transit[0].in_cluster, true) : true
        
        encryption_enabled = local.in_cluster_encryption == true
    }

    enforce {
        condition = local.encryption_enabled
        error_message = "MSK cluster does not have encryption in transit enabled among broker nodes. The 'encryption_info.encryption_in_transit.in_cluster' setting is explicitly set to false. Set it to true or remove the explicit setting to use the secure default"
    }
}
