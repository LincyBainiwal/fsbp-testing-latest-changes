# Copyright IBM Corp. 2026

# Existing RDS event notification subscriptions should be configured for critical database instance events

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "rds-instance-event-notifications-configured-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_db_event_subscription" "critical_events_configured" {
    enforcement_level = input.rds-instance-event-notifications-configured-enforcement-level
    filter = core::try(attrs.source_type, "") == "db-instance" || core::try(attrs.source_type, "") == ""

    locals {
        event_categories = core::try(attrs.event_categories, [])
        is_enabled = core::try(attrs.enabled, true)
        
        has_maintenance = core::contains(local.event_categories, "maintenance")
        has_config_change = core::contains(local.event_categories, "configuration change")
        has_failure = core::contains(local.event_categories, "failure")
        
        all_categories_present = local.has_maintenance && local.has_config_change && local.has_failure
    }

    enforce {
        condition = local.event_categories == [] || (local.is_enabled && local.all_categories_present)
        error_message = "RDS event subscription must include all critical event categories: 'maintenance', 'configuration change', and 'failure'"
    }
}
