# Copyright IBM Corp. 2026

# Kinesis streams should be encrypted at rest
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "kinesis-stream-encrypted-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_kinesis_stream" "encryption_at_rest" {
    enforcement_level = input.kinesis-stream-encrypted-enforcement-level
    locals {
        encryption_type = core::try(attrs.encryption_type, "NONE")
        
        kms_key_id = core::try(attrs.kms_key_id, null)
        
        is_encrypted = local.encryption_type == "KMS"
        has_kms_key = local.kms_key_id != null && local.kms_key_id != ""
    }

    enforce {
        condition = local.is_encrypted
        error_message = "Kinesis stream does not have encryption enabled. The 'encryption_type' must be set to 'KMS' (currently: '${local.encryption_type}'). Server-side encryption protects data at rest using AWS KMS keys"
    }

    enforce {
        condition = !local.is_encrypted || local.has_kms_key
        error_message = "Kinesis stream has encryption_type set to 'KMS' but 'kms_key_id' is not specified. You must provide a KMS key ID or use the alias 'alias/aws/kinesis' for the Kinesis-owned master key"
    }
}
