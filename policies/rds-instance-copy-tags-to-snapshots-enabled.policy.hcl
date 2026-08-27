# Copyright IBM Corp. 2026

# RDS DB instances should be configured to copy tags to snapshots

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "rds-instance-copy-tags-to-snapshots-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_db_instance" "copy_tags_to_snapshots_enabled" {
    enforcement_level = input.rds-instance-copy-tags-to-snapshots-enabled-enforcement-level
    enforce {
        condition = core::try(attrs.copy_tags_to_snapshot, false)
        error_message = "RDS instances should be configured to copy tags to DB snapshots"
    }
}
