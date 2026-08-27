# Copyright IBM Corp. 2026

# Transfer Family connectors should have logging enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.6.0, < 7.0.0"
    }
  }
}

input "transfer-connector-logging-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_transfer_connector" "logging_enabled" {
    enforcement_level = input.transfer-connector-logging-enabled-enforcement-level
    locals {
        # Safe access to logging_role attribute with null fallback
        logging_role = core::try(attrs.logging_role, null)
        
        # Check if logging_role is configured (not null and not empty string)
        has_logging_role = local.logging_role != null && local.logging_role != ""
    }

    enforce {
        condition     = local.has_logging_role
        error_message = "Transfer Family connector must have CloudWatch logging enabled. Configure the 'logging_role' attribute with a valid IAM role ARN that has permissions to write to CloudWatch Logs"
    }
}
