# Copyright IBM Corp. 2026

# MSK connectors should have logging enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.8.0, < 7.0.0"
    }
  }
}

input "msk-connect-connector-logging-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_mskconnect_connector" "logging_enabled" {
    enforcement_level = input.msk-connect-connector-logging-enabled-enforcement-level
    # Pre-filter: Only evaluate connectors that have log_delivery configured
    filter = core::try(attrs.log_delivery, null) != null && core::length(core::try(attrs.log_delivery, [])) > 0

    locals {
        # Extract log_delivery configuration (it's a block, so use [0])
        log_delivery = core::try(attrs.log_delivery[0], null)
        
        # Extract worker_log_delivery configuration
        worker_log_delivery = core::try(local.log_delivery.worker_log_delivery[0], null)
        
        # Check CloudWatch Logs configuration
        cloudwatch_logs = core::try(local.worker_log_delivery.cloudwatch_logs[0], null)
        cloudwatch_enabled = core::try(local.cloudwatch_logs.enabled, false)
        cloudwatch_log_group = core::try(local.cloudwatch_logs.log_group, "")
        
        # Check Firehose configuration
        firehose = core::try(local.worker_log_delivery.firehose[0], null)
        firehose_enabled = core::try(local.firehose.enabled, false)
        firehose_delivery_stream = core::try(local.firehose.delivery_stream, "")
        
        # Check S3 configuration
        s3 = core::try(local.worker_log_delivery.s3[0], null)
        s3_enabled = core::try(local.s3.enabled, false)
        s3_bucket = core::try(local.s3.bucket, "")
        
        # Check if at least one logging destination is enabled
        has_logging_enabled = local.cloudwatch_enabled || local.firehose_enabled || local.s3_enabled
        
        # Validate CloudWatch configuration if enabled
        cloudwatch_valid = !local.cloudwatch_enabled || (local.cloudwatch_enabled && local.cloudwatch_log_group != "")
        
        # Validate Firehose configuration if enabled
        firehose_valid = !local.firehose_enabled || (local.firehose_enabled && local.firehose_delivery_stream != "")
        
        # Validate S3 configuration if enabled
        s3_valid = !local.s3_enabled || (local.s3_enabled && local.s3_bucket != "")
    }

    # Enforce: At least one logging destination (CloudWatch OR Firehose OR S3) must be enabled
    enforce {
        condition = local.has_logging_enabled
        error_message = "MSK connector must have at least one logging destination enabled (CloudWatch Logs, Firehose, or S3)"
    }

    # Enforce: Any enabled logging destination must be fully configured
    enforce {
        condition = local.cloudwatch_valid && local.firehose_valid && local.s3_valid
        error_message = "MSK connector has a logging destination enabled but is missing required configuration (log_group / delivery_stream / bucket)"
    }
}
