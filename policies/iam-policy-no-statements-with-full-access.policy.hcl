# Copyright IBM Corp. 2026

# IAM customer managed policies that you create should not allow wildcard actions for services

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "iam-policy-no-statements-with-full-access-enforcement-level" {
  type = string
  default = "advisory"
}

input "excludePermissionBoundaryPolicy" {
    type = string
    default = "false"
}

locals {
    all_iam_roles = core::getresources("aws_iam_role", {})
    all_iam_users = core::getresources("aws_iam_user", {})

    # Centralised input validation so it is enforced even when no aws_iam_policy
    # resources exist in the plan (every resource_policy block re-uses this).
    valid_exclude_input = input.excludePermissionBoundaryPolicy == "true" || input.excludePermissionBoundaryPolicy == "false"
}

resource_policy "aws_iam_policy" "deny_service_wildcards" {
    enforcement_level = input.iam-policy-no-statements-with-full-access-enforcement-level
    locals {
        policy_json = core::try(core::jsondecode(attrs.policy), {})
        statements = [for statement in core::try(local.policy_json.Statement, []) : statement]
        policy_name = core::try(attrs.name, "unnamed-policy")
        policy_arn = core::try(attrs.arn, "")

        attached_permission_boundary_roles = [
            for role in local.all_iam_roles :
            role if core::try(role.permissions_boundary, "") == local.policy_arn
        ]

        attached_permission_boundary_users = [
            for user in local.all_iam_users :
            user if core::try(user.permissions_boundary, "") == local.policy_arn
        ]

        is_permission_boundary_policy = core::length(local.attached_permission_boundary_roles) + core::length(local.attached_permission_boundary_users) > 0
        exclude_permission_boundary = input.excludePermissionBoundaryPolicy == "true"
        should_evaluate = !(local.exclude_permission_boundary && local.is_permission_boundary_policy)

        violating_actions = [
            for statement in local.statements :
            statement
            if core::try(statement.Effect, "") == "Allow" && (
                core::try(core::length([
                    for action in core::try(statement.Action, []) :
                    action
                    if core::length(core::regexall("^[^:*]+:\\*$", action)) > 0
                ]), 0) > 0
                || core::try(core::length(core::regexall("^[^:*]+:\\*$", core::try(statement.Action, ""))), 0) > 0
            )
        ]

        violating_not_actions = [
            for statement in local.statements :
            statement
            if core::try(statement.Effect, "") == "Allow" && (
                core::try(core::length([
                    for action in core::try(statement.NotAction, []) :
                    action
                    if core::length(core::regexall("^[^:*]+:\\*$", action)) > 0
                ]), 0) > 0
                || core::try(core::length(core::regexall("^[^:*]+:\\*$", core::try(statement.NotAction, ""))), 0) > 0
            )
        ]
    }

    enforce {
        condition = local.valid_exclude_input
        error_message = "input.excludePermissionBoundaryPolicy must be 'true' or 'false'. Current value: '${input.excludePermissionBoundaryPolicy}'."
    }

    enforce {
        condition = !local.should_evaluate || core::length(local.violating_actions) == 0
        error_message = "IAM policy '${local.policy_name}' must not allow full service wildcard actions such as 'ec2:*' in Allow statements"
    }

    enforce {
        condition = !local.should_evaluate || core::length(local.violating_not_actions) == 0
        error_message = "IAM policy '${local.policy_name}' must not use NotAction with full service wildcards such as 'ec2:*' in Allow statements"
    }
}

resource_policy "aws_iam_role_policy" "deny_service_wildcards" {
    enforcement_level = input.iam-policy-no-statements-with-full-access-enforcement-level
    locals {
        policy_json = core::try(core::jsondecode(attrs.policy), {})
        statements = [for statement in core::try(local.policy_json.Statement, []) : statement]

        violating_actions = [
            for statement in local.statements :
            statement
            if core::try(statement.Effect, "") == "Allow" && (
                core::try(core::length([
                    for action in core::try(statement.Action, []) :
                    action
                    if core::length(core::regexall("^[^:*]+:\\*$", action)) > 0
                ]), 0) > 0
                || core::try(core::length(core::regexall("^[^:*]+:\\*$", core::try(statement.Action, ""))), 0) > 0
            )
        ]

        violating_not_actions = [
            for statement in local.statements :
            statement
            if core::try(statement.Effect, "") == "Allow" && (
                core::try(core::length([
                    for action in core::try(statement.NotAction, []) :
                    action
                    if core::length(core::regexall("^[^:*]+:\\*$", action)) > 0
                ]), 0) > 0
                || core::try(core::length(core::regexall("^[^:*]+:\\*$", core::try(statement.NotAction, ""))), 0) > 0
            )
        ]
    }

    enforce {
        condition = local.valid_exclude_input
        error_message = "input.excludePermissionBoundaryPolicy must be 'true' or 'false'. Current value: '${input.excludePermissionBoundaryPolicy}'."
    }

    enforce {
        condition = core::length(local.violating_actions) == 0
        error_message = "IAM role inline policy '${core::try(attrs.name, "unnamed-role-policy")}' must not allow full service wildcard actions such as 'ec2:*' in Allow statements"
    }

    enforce {
        condition = core::length(local.violating_not_actions) == 0
        error_message = "IAM role inline policy '${core::try(attrs.name, "unnamed-role-policy")}' must not use NotAction with full service wildcards such as 'ec2:*' in Allow statements"
    }
}

resource_policy "aws_iam_user_policy" "deny_service_wildcards" {
    enforcement_level = input.iam-policy-no-statements-with-full-access-enforcement-level
    locals {
        policy_json = core::try(core::jsondecode(attrs.policy), {})
        statements = [for statement in core::try(local.policy_json.Statement, []) : statement]

        violating_actions = [
            for statement in local.statements :
            statement
            if core::try(statement.Effect, "") == "Allow" && (
                core::try(core::length([
                    for action in core::try(statement.Action, []) :
                    action
                    if core::length(core::regexall("^[^:*]+:\\*$", action)) > 0
                ]), 0) > 0
                || core::try(core::length(core::regexall("^[^:*]+:\\*$", core::try(statement.Action, ""))), 0) > 0
            )
        ]

        violating_not_actions = [
            for statement in local.statements :
            statement
            if core::try(statement.Effect, "") == "Allow" && (
                core::try(core::length([
                    for action in core::try(statement.NotAction, []) :
                    action
                    if core::length(core::regexall("^[^:*]+:\\*$", action)) > 0
                ]), 0) > 0
                || core::try(core::length(core::regexall("^[^:*]+:\\*$", core::try(statement.NotAction, ""))), 0) > 0
            )
        ]
    }

    enforce {
        condition = local.valid_exclude_input
        error_message = "input.excludePermissionBoundaryPolicy must be 'true' or 'false'. Current value: '${input.excludePermissionBoundaryPolicy}'."
    }

    enforce {
        condition = core::length(local.violating_actions) == 0
        error_message = "IAM user inline policy '${core::try(attrs.name, "unnamed-user-policy")}' must not allow full service wildcard actions such as 'ec2:*' in Allow statements"
    }

    enforce {
        condition = core::length(local.violating_not_actions) == 0
        error_message = "IAM user inline policy '${core::try(attrs.name, "unnamed-user-policy")}' must not use NotAction with full service wildcards such as 'ec2:*' in Allow statements"
    }
}

resource_policy "aws_iam_group_policy" "deny_service_wildcards" {
    enforcement_level = input.iam-policy-no-statements-with-full-access-enforcement-level
    locals {
        policy_json = core::try(core::jsondecode(attrs.policy), {})
        statements = [for statement in core::try(local.policy_json.Statement, []) : statement]

        violating_actions = [
            for statement in local.statements :
            statement
            if core::try(statement.Effect, "") == "Allow" && (
                core::try(core::length([
                    for action in core::try(statement.Action, []) :
                    action
                    if core::length(core::regexall("^[^:*]+:\\*$", action)) > 0
                ]), 0) > 0
                || core::try(core::length(core::regexall("^[^:*]+:\\*$", core::try(statement.Action, ""))), 0) > 0
            )
        ]

        violating_not_actions = [
            for statement in local.statements :
            statement
            if core::try(statement.Effect, "") == "Allow" && (
                core::try(core::length([
                    for action in core::try(statement.NotAction, []) :
                    action
                    if core::length(core::regexall("^[^:*]+:\\*$", action)) > 0
                ]), 0) > 0
                || core::try(core::length(core::regexall("^[^:*]+:\\*$", core::try(statement.NotAction, ""))), 0) > 0
            )
        ]
    }

    enforce {
        condition = local.valid_exclude_input
        error_message = "input.excludePermissionBoundaryPolicy must be 'true' or 'false'. Current value: '${input.excludePermissionBoundaryPolicy}'."
    }

    enforce {
        condition = core::length(local.violating_actions) == 0
        error_message = "IAM group inline policy '${core::try(attrs.name, "unnamed-group-policy")}' must not allow full service wildcard actions such as 'ec2:*' in Allow statements"
    }

    enforce {
        condition = core::length(local.violating_not_actions) == 0
        error_message = "IAM group inline policy '${core::try(attrs.name, "unnamed-group-policy")}' must not use NotAction with full service wildcards such as 'ec2:*' in Allow statements"
    }
}
