# Copyright IBM Corp. 2026

# Athena workgroups should have logging enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "athena-workgroup-logging-enabled-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "aws_athena_workgroup" "logging_enabled" {
  enforcement_level = input.athena-workgroup-logging-enabled-enforcement-level

  locals {
    # configuration block is optional — default to empty list if absent.
    configuration = core::try(attrs.configuration, [])
    has_config    = core::length(local.configuration) > 0

    # --- Signal 1: publish_cloudwatch_metrics_enabled ---
    # Standard SQL workgroups: the AWS Config rule athena-workgroup-logging-enabled
    # evaluates PublishCloudWatchMetricsEnabled as the primary logging signal.
    # Default to false — a missing configuration block means logging is not enabled.
    publish_cloudwatch_metrics_enabled = local.has_config ? core::try(local.configuration[0].publish_cloudwatch_metrics_enabled, false) : false

    # --- Signals 2/3/4: monitoring_configuration (Apache Spark engine only) ---
    # monitoring_configuration supports three log destinations; any one enabled satisfies the control.
    monitoring = core::try(local.configuration[0].monitoring_configuration, [])
    has_monitoring = local.has_config && core::length(local.monitoring) > 0

    cloudwatch_logging_enabled = local.has_monitoring ? core::try(local.monitoring[0].cloud_watch_logging_configuration[0].enabled, false) : false
    s3_logging_enabled         = local.has_monitoring ? core::try(local.monitoring[0].s3_logging_configuration[0].enabled, false) : false
    managed_logging_enabled    = local.has_monitoring ? core::try(local.monitoring[0].managed_logging_configuration[0].enabled, false) : false

    # Pass if ANY one logging mechanism is enabled.
    is_logging_enabled = (
      local.publish_cloudwatch_metrics_enabled ||
      local.cloudwatch_logging_enabled ||
      local.s3_logging_enabled ||
      local.managed_logging_enabled
    )
  }

  enforce {
    condition     = local.is_logging_enabled
    error_message = "Athena workgroup does not have logging enabled. Enable at least one of: configuration.publish_cloudwatch_metrics_enabled (SQL workgroups), or configuration.monitoring_configuration with cloud_watch_logging_configuration, s3_logging_configuration, or managed_logging_configuration enabled (Spark workgroups)."
  }
}