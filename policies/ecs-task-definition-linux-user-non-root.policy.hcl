# Copyright IBM Corp. 2026

# ECS Task Definitions should configure non-root users in Linux container definitions

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "ecs-task-definition-linux-user-non-root-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_ecs_task_definition" "ecs20_nonroot_user_linux" {
  enforcement_level = input.ecs-task-definition-linux-user-non-root-enforcement-level
  # Only evaluate Linux task definitions.
  # operatingSystemFamily defaults to LINUX when runtime_platform is not specified,
  # so core::try falls back to "LINUX" if the attribute or nested field is absent.
  filter = core::try(attrs.runtime_platform[0].operating_system_family, "LINUX") == "LINUX"

  locals {
    # container_definitions attribute - access directly as structured data
    # In tfpolicy, this attribute is already parsed from JSON
    container_defs = core::jsondecode(attrs.container_definitions)
    
    # Check each container for user configuration
    container_checks = [
      for container in local.container_defs : {
        name     = container.name
        has_user = core::try(container.user, null) != null
        user_value = core::try(container.user, "")
        # Detect root identity in all supported formats:
        #   "root"      — name-only
        #   "0"         — UID-only
        #   "0:1000"    — root UID with non-root GID
        #   "0:0"       — root UID with root GID
        #   "root:app"  — root username with non-root group
        # core::regex() returns the matched string (truthy) or null (falsy).
        is_root = (
          core::try(container.user, "") == "root" ||
          core::try(container.user, "") == "0" ||
          core::length(core::regexall("^0(:|$)", core::try(container.user, ""))) > 0 ||
          core::length(core::regexall("^root(:|$)", core::try(container.user, ""))) > 0
        )
      }
    ]

    # Find containers without user configured
    containers_missing_user = [
      for check in local.container_checks :
      check.name if !check.has_user
    ]

    # Find containers configured as root (exact or UID:GID / username:group formats)
    containers_as_root = [
      for check in local.container_checks :
      check.name if check.has_user && check.is_root
    ]
    

  }

  # Enforce: All containers must have user parameter configured
  enforce {
    condition = core::length(local.containers_missing_user) == 0
    error_message = "ECS task definition has containers without 'user' parameter configured. All Linux containers must specify a non-root user following the principle of least privilege"
  }

  # Enforce: No containers should run as root
  enforce {
    condition = core::length(local.containers_as_root) == 0
    error_message = "ECS task definition has containers configured to run as root user. The 'user' parameter must not be 'root' or '0'. Use a non-root user (e.g., 'appuser', '1000', 'appuser:appgroup', '1000:1000')"
  }
}