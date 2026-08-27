# Copyright IBM Corp. 2026

# Amazon SQS queues should be encrypted at rest

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "sqs-queue-encrypted-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_sqs_queue" "encryption_required" {
    enforcement_level = input.sqs-queue-encrypted-enforcement-level
    locals {

        # Safe access to encryption attributes with defaults
        sqs_managed_sse = core::try(attrs.sqs_managed_sse_enabled, false)
        kms_key_id = core::try(attrs.kms_master_key_id, null)
        
        # Check if any encryption method is enabled
        has_sqs_sse = local.sqs_managed_sse == true
        has_kms_sse = local.kms_key_id != null && local.kms_key_id != ""
        
        # Queue is compliant if either encryption method is enabled
        is_encrypted = local.has_sqs_sse || local.has_kms_sse
    }

    enforce {
        condition = local.is_encrypted
        error_message = "SQS queue must be encrypted at rest. Enable either 'sqs_managed_sse_enabled = true' for SSE-SQS encryption or configure 'kms_master_key_id' for SSE-KMS encryption"
    }
}
