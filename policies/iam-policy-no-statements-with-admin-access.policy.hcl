# Copyright IBM Corp. 2026

# IAM policies should not allow full "*" administrative privileges

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "iam-policy-no-statements-with-admin-access-enforcement-level" {
  type = string
  default = "advisory"
}

input "excludePermissionBoundaryPolicy_admin" {
    type    = string
    default = "false"
}

locals {
    all_iam_roles_admin = core::getresources("aws_iam_role", {})
    all_iam_users_admin = core::getresources("aws_iam_user", {})
}

resource_policy "aws_iam_policy" "deny_full_admin_privileges" {
    enforcement_level = input.iam-policy-no-statements-with-admin-access-enforcement-level
    filter = attrs.policy != null

    locals {
        policy_name = core::try(attrs.name, "")
        policy_arn  = core::try(attrs.arn, "")

        policy_doc     = core::try(core::jsondecode(attrs.policy), null)
        raw_statements = core::try(local.policy_doc.Statement, [])
        statements = [
            for stmt in core::flatten([local.raw_statements]) :
            stmt
        ]

        admin_statements = [
            for stmt in local.statements :
            stmt if (
                core::try(stmt.Effect, "") == "Allow" &&
                (
                    # Standard wildcard: Action=* + Resource=*
                    (
                        (
                            core::try(stmt.Action, "") == "*" ||
                            core::try(core::contains(stmt.Action, "*"), false)
                        ) &&
                        (
                            core::try(stmt.Resource, "") == "*" ||
                            core::try(core::contains(stmt.Resource, "*"), false)
                        )
                    ) ||
                    # NotAction + Resource=* : grants all actions except a denylist — effectively admin.
                    (
                        core::try(stmt.NotAction, null) != null &&
                        (
                            core::try(stmt.Resource, "") == "*" ||
                            core::try(core::contains(stmt.Resource, "*"), false)
                        )
                    ) ||
                    # NotResource + Action=* : grants an action on all resources except a denylist — effectively admin.
                    (
                        core::try(stmt.NotResource, null) != null &&
                        (
                            core::try(stmt.Action, "") == "*" ||
                            core::try(core::contains(stmt.Action, "*"), false)
                        )
                    )
                )
            )
        ]

        attached_permission_boundary_roles = [
            for role in local.all_iam_roles_admin :
            role if core::try(role.permissions_boundary, "") == local.policy_arn
        ]

        attached_permission_boundary_users = [
            for user in local.all_iam_users_admin :
            user if core::try(user.permissions_boundary, "") == local.policy_arn
        ]

        is_permission_boundary_policy = core::length(local.attached_permission_boundary_roles) + core::length(local.attached_permission_boundary_users) > 0
        exclude_permission_boundary   = input.excludePermissionBoundaryPolicy_admin == "true"
        should_evaluate               = !(local.exclude_permission_boundary && local.is_permission_boundary_policy)
        has_admin_access              = core::length(local.admin_statements) > 0
    }

    enforce {
        condition     = !local.should_evaluate || !local.has_admin_access
        error_message = "IAM customer managed policy must not allow administrative wildcard access with Effect 'Allow', Action '*', and Resource '*'"
    }
}