# Copyright IBM Corp. 2026

# RDS for PostgreSQL DB clusters should be configured to copy tags to DB snapshots

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "rds-pgsql-cluster-copy-tags-to-snapshot-check-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_rds_cluster" "copy_tags_to_snapshot_enabled" {
    enforcement_level = input.rds-pgsql-cluster-copy-tags-to-snapshot-check-enforcement-level
    filter = core::contains(["aurora-postgresql"], attrs.engine)

    enforce {
        condition = core::try(attrs.copy_tags_to_snapshot, false) == true
        error_message = "RDS PostgreSQL DB cluster does not have copy_tags_to_snapshot enabled. Set 'copy_tags_to_snapshot = true' to ensure tags are automatically copied to snapshots for proper resource tracking and governance"
    }
}
