# Copyright IBM Corp. 2026

# Neptune DB cluster snapshots should be encrypted at rest

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "neptune-cluster-snapshot-encrypted-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_neptune_cluster_snapshot" "snapshot-encrypted" {
    enforcement_level = input.neptune-cluster-snapshot-encrypted-enforcement-level
    enforce {
        condition = core::try(attrs.storage_encrypted, false)
        error_message = "The Neptune cluster snapshot is not encrypted at rest"
    }
}
