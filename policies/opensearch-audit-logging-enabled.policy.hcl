# Copyright IBM Corp. 2026

# OpenSearch domains should have audit logging enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9.0, < 7.0.0"
    }
  }
}

input "opensearch-audit-logging-enabled-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "aws_opensearch_domain" "audit_logging_enabled" {
  enforcement_level = input.opensearch-audit-logging-enabled-enforcement-level
  locals {

    log_options = core::try([for opt in attrs.log_publishing_options : opt], [])

    # Pass if at least one log_publishing_options entry has log_type = "AUDIT_LOGS"
    # and enabled = true. Other log types (INDEX_SLOW_LOGS, SEARCH_SLOW_LOGS, etc.)
    # are valid alongside AUDIT_LOGS and must not cause a failure.
    audit_log_entries = [
      for opt in local.log_options : opt
      if core::try(opt.enabled, false) == true && core::try(opt.log_type, "") == "AUDIT_LOGS"
    ]

    has_audit_logging = core::length(local.audit_log_entries) > 0
  }

  enforce {
    condition     = local.has_audit_logging
    error_message = "OpenSearch domain must have at least one log_publishing_options block with log_type = 'AUDIT_LOGS' and enabled = true."
  }
}