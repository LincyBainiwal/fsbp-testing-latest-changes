# Copyright IBM Corp. 2026

# FSx for OpenZFS file systems should be configured to copy tags to backups and volumes

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "fsx-openzfs-copy-tags-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_fsx_openzfs_file_system" "copy_tags_enabled" {
    enforcement_level = input.fsx-openzfs-copy-tags-enabled-enforcement-level
    enforce {
        condition = core::try(attrs.copy_tags_to_backups, false) && core::try(attrs.copy_tags_to_volumes, false)
        error_message = "FSx for OpenZFS file system must be configured to copy tags to backups and volumes"
    }
}
