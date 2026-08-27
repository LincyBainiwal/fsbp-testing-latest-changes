# Copyright IBM Corp. 2026

# Aurora DB clusters should be configured to copy tags to DB snapshots

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "rds-cluster-copy-tags-to-snapshots-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_rds_cluster" "copy_tags_to_snapshots_enabled" {
    enforcement_level = input.rds-cluster-copy-tags-to-snapshots-enabled-enforcement-level
    enforce {
        condition = core::try(attrs.copy_tags_to_snapshot, false)
        error_message = "Aurora DB clusters should be configured to copy tags to DB snapshots"
    }
}
