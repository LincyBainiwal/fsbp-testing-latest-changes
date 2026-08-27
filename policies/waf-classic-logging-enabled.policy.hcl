# Copyright IBM Corp. 2026

# AWS WAF Classic Global Web ACL logging should be enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "waf-classic-logging-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_waf_web_acl" "logging_enabled" {
  enforcement_level = input.waf-classic-logging-enabled-enforcement-level
  locals {
    has_logging = core::try(attrs.logging_configuration, null) != null
    log_config = core::try(attrs.logging_configuration, [])
    has_destination = core::length(local.log_config) > 0 ? core::try(local.log_config[0].log_destination, "") != "" : false
  }

  enforce {
    condition = local.has_logging && local.has_destination
    error_message = "WAF Classic Web ACL must have logging_configuration with a valid log_destination ARN pointing to a Kinesis Firehose Delivery Stream"
  }
}