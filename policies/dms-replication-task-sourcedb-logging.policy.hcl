# Copyright IBM Corp. 2026

# DMS replication tasks for the source database should have logging enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "dms-replication-task-sourcedb-logging-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "aws_dms_replication_task" "source_logging_enabled" {
  enforcement_level = input.dms-replication-task-sourcedb-logging-enforcement-level

  locals {
    # Parse the replication_task_settings JSON string.
    # Default to "{}" so jsondecode never receives an empty string.
    settings_raw = core::try(attrs.replication_task_settings, "{}")

    settings = core::try(core::jsondecode(local.settings_raw), {})

    # Extract Logging block
    logging = core::try(local.settings.Logging, {})

    # EnableLogging must be true
    enable_logging = core::try(local.logging.EnableLogging, false)

    # All configured log components
    log_components = core::try(local.logging.LogComponents, [])

    # Valid severity levels accepted by AWS Security Hub
    valid_severities = [
      "LOGGER_SEVERITY_DEFAULT",
      "LOGGER_SEVERITY_DEBUG",
      "LOGGER_SEVERITY_DETAILED_DEBUG"
    ]

    # Find SOURCE_CAPTURE component
    source_capture_components = [
      for component in local.log_components : component
      if core::try(component.Id, "") == "SOURCE_CAPTURE"
    ]

    # Find SOURCE_UNLOAD component
    source_unload_components = [
      for component in local.log_components : component
      if core::try(component.Id, "") == "SOURCE_UNLOAD"
    ]

    # Check SOURCE_CAPTURE exists and has a valid severity
    has_source_capture     = core::length(local.source_capture_components) > 0
    source_capture_severity = local.has_source_capture ? core::try(local.source_capture_components[0].Severity, "") : ""
    source_capture_valid   = local.has_source_capture && core::contains(local.valid_severities, local.source_capture_severity)
    source_capture_display = local.has_source_capture ? local.source_capture_severity : "not configured"

    # Check SOURCE_UNLOAD exists and has a valid severity
    has_source_unload     = core::length(local.source_unload_components) > 0
    source_unload_severity = local.has_source_unload ? core::try(local.source_unload_components[0].Severity, "") : ""
    source_unload_valid   = local.has_source_unload && core::contains(local.valid_severities, local.source_unload_severity)
    source_unload_display = local.has_source_unload ? local.source_unload_severity : "not configured"
  }

  # Enforce: logging must be enabled
  enforce {
    condition     = local.enable_logging == true
    error_message = "DMS replication task must have logging enabled. Set 'EnableLogging' to true in replication_task_settings.Logging configuration."
  }

  # Enforce: SOURCE_CAPTURE component must exist with valid severity
  enforce {
    condition     = local.source_capture_valid
    error_message = "DMS replication task must have SOURCE_CAPTURE logging component configured with severity level of LOGGER_SEVERITY_DEFAULT, LOGGER_SEVERITY_DEBUG, or LOGGER_SEVERITY_DETAILED_DEBUG. Current: ${local.source_capture_display}"
  }

  # Enforce: SOURCE_UNLOAD component must exist with valid severity
  enforce {
    condition     = local.source_unload_valid
    error_message = "DMS replication task must have SOURCE_UNLOAD logging component configured with severity level of LOGGER_SEVERITY_DEFAULT, LOGGER_SEVERITY_DEBUG, or LOGGER_SEVERITY_DETAILED_DEBUG. Current: ${local.source_unload_display}"
  }
}