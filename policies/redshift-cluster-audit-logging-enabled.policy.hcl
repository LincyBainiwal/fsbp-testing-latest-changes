# Copyright IBM Corp. 2026

# Amazon Redshift clusters should have audit logging enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.45.0, < 7.0.0"
    }
  }
}

input "redshift-cluster-audit-logging-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_redshift_logging" "logging_properly_configured" {
  enforcement_level = input.redshift-cluster-audit-logging-enabled-enforcement-level
  locals {
    # Get cluster identifier safely
    cluster_id = core::try(attrs.cluster_identifier, "")
    
    # Get log destination type
    log_dest_type = core::try(attrs.log_destination_type, "")
    
    # Check S3 logging configuration
    is_s3_logging = local.log_dest_type == "s3"
    s3_bucket_name = core::try(attrs.bucket_name, "")
    s3_configured = local.is_s3_logging && local.s3_bucket_name != ""
    
    # Check CloudWatch logging configuration
    is_cloudwatch_logging = local.log_dest_type == "cloudwatch"
    log_exports_count = core::try(core::length(attrs.log_exports), 0)
    cloudwatch_configured = local.is_cloudwatch_logging && local.log_exports_count > 0
    
    # Logging is properly configured if either S3 or CloudWatch is set up correctly
    is_compliant = local.s3_configured || local.cloudwatch_configured
  }

  enforce {
    condition = local.is_compliant
    error_message = local.is_s3_logging ? "Redshift logging for cluster has S3 destination but missing 'bucket_name'. Ensure 'bucket_name' is set to a valid S3 bucket." : local.is_cloudwatch_logging ? "Redshift logging for cluster has CloudWatch destination but 'log_exports' is empty. Ensure 'log_exports' contains at least one log type (connectionlog, useractivitylog, or userlog)." : "Redshift logging for cluster has invalid or missing 'log_destination_type'. Must be either 's3' or 'cloudwatch'"
  }
}
