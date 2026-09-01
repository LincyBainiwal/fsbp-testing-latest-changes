# Copyright IBM Corp. 2026

# EFS file systems should have automatic backups enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "efs-automatic-backups-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

# Evaluate every aws_efs_file_system and require an associated
# aws_efs_backup_policy with status == "ENABLED".
resource_policy "aws_efs_file_system" "automatic_backups_enabled" {
    enforcement_level = input.efs-automatic-backups-enabled-enforcement-level
    locals {
        filesystem_id = core::try(attrs.id, "")

        # Look up any aws_efs_backup_policy resources scoped to this file system.
        backup_policies = core::getresources("aws_efs_backup_policy", {
            file_system_id = local.filesystem_id
        })

        has_backup_policy = core::length(local.backup_policies) > 0

        # backup_policy is a list block on the resource; read the first element's status.
        backup_status = local.has_backup_policy ? core::try(local.backup_policies[0].backup_policy[0].status, "DISABLED") : "DISABLED"

        is_enabled = local.backup_status == "ENABLED"
    }

    enforce {
        condition     = local.is_enabled
        error_message = "EFS file system '${local.filesystem_id}' does not have automatic backups enabled. An aws_efs_backup_policy resource with status = 'ENABLED' must be associated with this file system."
    }
}
