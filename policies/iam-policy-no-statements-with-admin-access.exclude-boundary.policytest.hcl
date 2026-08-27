# Copyright IBM Corp. 2026

policytest {
  targets = ["iam-policy-no-statements-with-admin-access.policy.hcl"]
  
}
inputs {
    excludePermissionBoundaryPolicy_admin = "true"
  }
# PASS - Permission boundary policy with admin wildcard is skipped when
# excludePermissionBoundaryPolicy is set to "true".
resource "aws_iam_policy" "permissions_boundary_policy_admin_excluded" {
  attrs = {
    arn    = "arn:aws:iam::123456789012:policy/permissions-boundary-admin-excluded"
    name   = "permissions-boundary-admin-excluded"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"*\",\"Resource\":\"*\"}]}"
  }
}

resource "aws_iam_role" "role_with_boundary_excluded" {
  attrs = {
    name                 = "role-with-boundary-excluded"
    permissions_boundary = "arn:aws:iam::123456789012:policy/permissions-boundary-admin-excluded"
  }
}

# FAIL - A non-permission-boundary admin policy still fails even when
# excludePermissionBoundaryPolicy = "true" (only boundary policies are skipped).
resource "aws_iam_policy" "managed_policy_admin_still_fails" {
  expect_failure = true
  attrs = {
    arn    = "arn:aws:iam::123456789012:policy/managed-admin-still-fails"
    name   = "managed-admin-still-fails"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"*\",\"Resource\":\"*\"}]}"
  }
}
