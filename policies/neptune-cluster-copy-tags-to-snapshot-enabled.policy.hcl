# Copyright IBM Corp. 2026

# Neptune DB clusters should be configured to copy tags to snapshots

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "neptune-cluster-copy-tags-to-snapshot-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_neptune_cluster" "copy-tags-to-snapshot" {
    enforcement_level = input.neptune-cluster-copy-tags-to-snapshot-enabled-enforcement-level
    enforce {
        condition = core::try(attrs.copy_tags_to_snapshot, false)
        error_message = "The Neptune DB cluster does not have copy tags to snapshot enabled"
    }
}
