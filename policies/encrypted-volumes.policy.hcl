# Copyright IBM Corp. 2026

# Attached Amazon EBS volumes should be encrypted at-rest

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "encrypted-volumes-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_ebs_volume" "encryption_required" {
    enforcement_level = input.encrypted-volumes-enforcement-level
    locals {
        encrypted = core::try(attrs.encrypted, false)
    }

    enforce {
        condition = local.encrypted == true
        error_message = "EBS volume must have encryption enabled. Set 'encrypted = true' in the resource configuration. Note: This control only applies to attached volumes at runtime"
    }
}

resource_policy "aws_instance" "ebs_encryption_required" {
    enforcement_level = input.encrypted-volumes-enforcement-level
    locals {
        ebs_devices     = core::try(attrs.ebs_block_device, [])
        has_ebs_devices = core::length(local.ebs_devices) > 0

        # Any device missing encrypted=true is a violation.
        unencrypted_ebs_devices = [
            for device in local.ebs_devices :
            device if core::try(device.encrypted, false) != true
        ]
        all_ebs_encrypted = core::length(local.unencrypted_ebs_devices) == 0
    }

    # No filter — instances without inline ebs_block_device must also be evaluated.
    # Condition short-circuits: if no devices are declared, pass (the root block device
    # block and aws_ebs_encryption_by_default policy cover the remaining surface).
    enforce {
        condition     = !local.has_ebs_devices || local.all_ebs_encrypted
        error_message = "EC2 instance has ${core::length(local.unencrypted_ebs_devices)} unencrypted EBS block device(s). All ebs_block_device blocks must have 'encrypted = true'."
    }
}

resource_policy "aws_instance" "root_encryption_required" {
    enforcement_level = input.encrypted-volumes-enforcement-level
    locals {
        root_devices    = core::try(attrs.root_block_device, [])
        has_root_device = core::length(local.root_devices) > 0
        root_device     = local.has_root_device ? local.root_devices[0] : null
        root_encrypted  = core::try(local.root_device.encrypted, false)
    }

    # No filter — instances without root_block_device pass this block; the
    # ebs_encryption_required block and aws_ebs_encryption_by_default cover them.
    enforce {
        condition     = !local.has_root_device || local.root_encrypted == true
        error_message = "EC2 instance has an unencrypted root block device. Set 'encrypted = true' in the root_block_device block."
    }
}

# Launch templates define EBS block device mappings that are applied at instance
# launch time. They were not covered by either aws_instance block above.
resource_policy "aws_launch_template" "ebs_encryption_required" {
    enforcement_level = input.encrypted-volumes-enforcement-level
    locals {
        block_mappings  = core::try(attrs.block_device_mappings, [])
        has_mappings    = core::length(local.block_mappings) > 0

        # Each mapping may have an ebs block; absence means no explicit setting.
        # mapping.ebs may be a single object rather than a list depending on plan
        # serialization. core::try catches the [0] indexing failure and returns
        # false (conservative — treats as unencrypted).
        unencrypted_ebs_mappings = [
            for mapping in local.block_mappings :
            mapping if core::try(mapping.ebs[0].encrypted, false) != true
        ]
        all_ebs_encrypted = core::length(local.unencrypted_ebs_mappings) == 0
    }

    enforce {
        condition     = !local.has_mappings || local.all_ebs_encrypted
        error_message = "Launch template has ${core::length(local.unencrypted_ebs_mappings)} EBS block device mapping(s) without 'encrypted = true'. All block_device_mappings[*].ebs must set 'encrypted = true'."
    }
}
