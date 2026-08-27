# Copyright IBM Corp. 2026

# An RDS event notifications subscription should be configured for critical database security group events

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "rds-sg-event-notifications-configured-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_db_event_subscription" "sg_event_notifications" {
    enforcement_level = input.rds-sg-event-notifications-configured-enforcement-level
    filter = core::try(attrs.source_type, "") == "db-security-group" || core::try(attrs.source_type, "") == ""
    locals {
        event_categories = core::try(attrs.event_categories, [])
        
        has_config_change = core::contains(local.event_categories, "configuration change")
        has_failure = core::contains(local.event_categories, "failure")
        
        is_enabled = core::try(attrs.enabled, true)
    }

    enforce {
        condition = local.event_categories == [] || (local.is_enabled && local.has_config_change && local.has_failure)
        error_message = "RDS event subscription for db-security-group events must be enabled for both 'configuration change' and 'failure' event_categories"
    }
}
