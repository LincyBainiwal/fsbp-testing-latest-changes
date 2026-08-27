# Copyright IBM Corp. 2026

# An RDS event notifications subscription should be configured for critical database parameter group events

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "rds-pg-event-notifications-configured-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_db_event_subscription" "parameter_group_events" {
    enforcement_level = input.rds-pg-event-notifications-configured-enforcement-level
    filter = core::try(attrs.source_type, "") == "db-parameter-group" || core::try(attrs.source_type, "") == ""

    locals {
        event_categories = core::try(attrs.event_categories, [])
        is_enabled = core::try(attrs.enabled, true)
        
        has_config_change = core::contains(local.event_categories, "configuration change")
    }

    enforce {
        condition = local.event_categories == [] || (local.is_enabled && local.has_config_change)
        error_message = "RDS event subscription must include 'configuration change' in event_categories"
    }
}
