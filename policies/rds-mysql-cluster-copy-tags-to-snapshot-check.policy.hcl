# Copyright IBM Corp. 2026

# RDS for MySQL DB clusters should be configured to copy tags to DB snapshots

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "rds-mysql-cluster-copy-tags-to-snapshot-check-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_rds_cluster" "copy_mysql_tags_to_snapshot_enabled" {
    enforcement_level = input.rds-mysql-cluster-copy-tags-to-snapshot-check-enforcement-level
    filter = core::try(attrs.engine, "") == "aurora-mysql"

    enforce {
        condition = core::try(attrs.copy_tags_to_snapshot, false) == true
        error_message = "RDS MySQL cluster does not have copy_tags_to_snapshot enabled. Set 'copy_tags_to_snapshot = true' to automatically copy tags to DB snapshots for proper resource tracking and governance"
    }
}
