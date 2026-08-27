# Copyright IBM Corp. 2026

# FSx for Lustre file systems should be configured to copy tags to backups

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "fsx-lustre-copy-tags-to-backups-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_fsx_lustre_file_system" "copy_tags_to_backups" {
    enforcement_level = input.fsx-lustre-copy-tags-to-backups-enforcement-level
    filter = core::try(attrs.deployment_type, "") == "PERSISTENT_1" || core::try(attrs.deployment_type, "") == "PERSISTENT_2"
    enforce {
        condition = core::try(attrs.copy_tags_to_backups, false)
        error_message = "FSx for Lustre file system must be configured to copy tags to backups"
    }
}
