# Copyright IBM Corp. 2026

# Network Firewall logging should be enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "network-firewall-logging-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_networkfirewall_logging_configuration" "logging_enabled" {
  enforcement_level = input.network-firewall-logging-enabled-enforcement-level
  locals {
    # Extract logging configuration safely (logging_configuration is a block, accessed as list)
    logging_config = core::try(attrs.logging_configuration, [])
    
    # Get log destination configs (list of maps)
    log_destinations = core::length(local.logging_config) > 0 ? core::try(local.logging_config[0].log_destination_config, []) : []
    
    # Check if at least one log type is configured
    has_logging = core::length(local.log_destinations) > 0
    
    # Extract configured log types for error message (safely handle null destinations)
    configured_types = [
      for dest in local.log_destinations :
      core::try(dest.log_type, "unknown") if dest != null
    ]
    
    # Check if destinations are properly configured (log_destination is a map)
    # Filter out null destinations first, then check if they have keys
    non_null_destinations = [
      for dest in local.log_destinations :
      dest if core::try(dest.log_destination, null) != null
    ]
    
    valid_destinations = [
      for dest in local.non_null_destinations :
      dest if core::length(core::keys(dest.log_destination)) > 0
    ]
    
    has_valid_destinations = core::length(local.log_destinations) == 0 || core::length(local.valid_destinations) == core::length(local.log_destinations)
  }

  # Enforce: At least one log type must be configured
  enforce {
    condition     = local.has_logging
    error_message = "Network Firewall must have logging enabled for at least one log type (ALERT, FLOW, or TLS). Currently no logging is configured"
  }

  # Enforce: All configured log destinations must exist and be valid
  enforce {
    condition     = local.has_valid_destinations
    error_message = "Network Firewall has logging configured but one or more log destinations are missing or invalid. Ensure all log_destination maps contain valid destination information"
  }
}