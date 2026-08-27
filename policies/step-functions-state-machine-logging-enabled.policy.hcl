# Copyright IBM Corp. 2026

# Step Functions state machines should have logging turned on

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "step-functions-state-machine-logging-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

input "logLevel" {
    type = string
    default = ""
}

input "cloudWatchLogGroupArns" {
    type = string
    default = ""
}

resource_policy "aws_sfn_state_machine" "logging_enabled" {
    enforcement_level = input.step-functions-state-machine-logging-enabled-enforcement-level
    # Pre-filter: Only evaluate state machines that have logging_configuration defined
    filter = core::try(attrs.logging_configuration, null) != null && core::length(core::try(attrs.logging_configuration, [])) > 0

    locals {
        # Safe access to logging configuration (it's a block, so use [0]).
        # Resolve the list first, then index, so a non-list value can't crash before try() catches it.
        logging_config_list = core::try(attrs.logging_configuration, [])
        logging_config      = core::length(local.logging_config_list) > 0 ? core::try(local.logging_config_list[0], null) : null

        # Extract logging level with safe fallback
        log_level = core::try(local.logging_config.level, "OFF")

        # Extract log destination with safe fallback
        log_destination = core::try(local.logging_config.log_destination, "")

        # Valid logging levels (excluding OFF)
        valid_levels = ["ALL", "ERROR", "FATAL"]
        has_log_level_input = input.logLevel != ""
        valid_log_level_input = !local.has_log_level_input || core::contains(local.valid_levels, input.logLevel)

        # Check if logging level is valid (not OFF)
        has_valid_level = core::contains(local.valid_levels, local.log_level)

        required_level_rank = input.logLevel == "ALL" ? 3 : (input.logLevel == "ERROR" ? 2 : (input.logLevel == "FATAL" ? 1 : 0))
        actual_level_rank = local.log_level == "ALL" ? 3 : (local.log_level == "ERROR" ? 2 : (local.log_level == "FATAL" ? 1 : 0))
        meets_required_level = !local.has_log_level_input || local.actual_level_rank >= local.required_level_rank

        # Check if log destination is specified
        has_log_destination = local.log_destination != "" && local.log_destination != null

        # Per Terraform AWS provider, log_destination ARN must end with ":*"
        log_destination_suffix_parts = core::split(":*", local.log_destination)
        has_valid_log_destination_suffix = local.has_log_destination && core::length(local.log_destination_suffix_parts) > 1 && local.log_destination_suffix_parts[core::length(local.log_destination_suffix_parts) - 1] == ""

        # Strip ":*" suffix for comparison against allowed-list input
        log_destination_base = core::length(local.log_destination_suffix_parts) > 0 ? local.log_destination_suffix_parts[0] : local.log_destination

        # Optional allowed CloudWatch log group ARNs (CSV)
        has_log_group_arns_input = input.cloudWatchLogGroupArns != ""
        allowed_log_group_arns_raw = local.has_log_group_arns_input ? core::split(",", input.cloudWatchLogGroupArns) : []
        allowed_log_group_arns = [for a in local.allowed_log_group_arns_raw : core::trimspace(a)]
        allowed_log_group_arns_base = [for a in local.allowed_log_group_arns : (core::length(core::split(":*", a)) > 0 ? core::split(":*", a)[0] : a)]
        matches_allowed_log_group = !local.has_log_group_arns_input || core::contains(local.allowed_log_group_arns_base, local.log_destination_base)
    }

    enforce {
        condition = local.valid_log_level_input
        error_message = "input.logLevel must be one of 'ALL', 'ERROR', or 'FATAL' when provided. Current value: '${input.logLevel}'. Leave it empty to accept any enabled logging level."
    }

    # Enforce: Logging level must be set to ALL, ERROR, or FATAL
    enforce {
        condition = local.has_valid_level
        error_message = "Step Functions state machine must have logging enabled with level set to ALL, ERROR, or FATAL. Current level: '${local.log_level}'"
    }

    # Enforce: When input.logLevel is provided, the state machine's level must meet
    # or exceed that minimum verbosity (e.g. input=ERROR accepts ERROR and ALL).
    enforce {
        condition = local.meets_required_level
        error_message = "Step Functions state machine logging level must be at least '${input.logLevel}' when input.logLevel is provided. Current level: '${local.log_level}'. Verbosity order: ALL > ERROR > FATAL"
    }

    # Enforce: Log destination must be specified
    enforce {
        condition = local.has_log_destination
        error_message = "Step Functions state machine must have a CloudWatch log group ARN specified in logging_configuration.log_destination. Current value is empty or null"
    }

    # Enforce: log_destination ARN must end with ":*" per AWS provider requirement
    enforce {
        condition = !local.has_log_destination || local.has_valid_log_destination_suffix
        error_message = "Step Functions state machine logging_configuration.log_destination must be a CloudWatch log group ARN ending with ':*'. Current value: '${local.log_destination}'"
    }

    # Enforce: when input.cloudWatchLogGroupArns is provided, log_destination must match one of them
    enforce {
        condition = local.matches_allowed_log_group
        error_message = "Step Functions state machine logging_configuration.log_destination ('${local.log_destination}') does not match any of the allowed CloudWatch log group ARNs in input.cloudWatchLogGroupArns ('${input.cloudWatchLogGroupArns}')"
    }
}

# Additional policy to catch state machines without any logging configuration
resource_policy "aws_sfn_state_machine" "logging_configuration_required" {
    enforcement_level = input.step-functions-state-machine-logging-enabled-enforcement-level
    # Only evaluate state machines that don't have logging_configuration
    filter = core::try(attrs.logging_configuration, null) == null || core::length(core::try(attrs.logging_configuration, [])) == 0

    locals {
        has_logging_configuration = core::try(attrs.logging_configuration, null) != null && core::length(core::try(attrs.logging_configuration, [])) > 0
    }

    enforce {
        condition = local.has_logging_configuration
        error_message = "Step Functions state machine must have logging_configuration block defined. Add a logging_configuration block with level set to ALL, ERROR, or FATAL, and log_destination pointing to a CloudWatch log group ARN ending with ':*'. If input.logLevel is provided, the logging level must meet that minimum verbosity"
    }
}
