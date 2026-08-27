# Copyright IBM Corp. 2026

# Tests with excludePermissionBoundaryPolicy = "true".

policytest {
  targets = ["iam-policy-no-statements-with-full-access.policy.hcl"]
}

inputs {
  excludePermissionBoundaryPolicy = "true"
}

# PASS - permissions boundary policy with ec2:* is excluded from evaluation
resource "aws_iam_policy" "permissions_boundary_policy_full_access_excluded" {
  attrs = {
    arn    = "arn:aws:iam::123456789012:policy/permissions-boundary-full-access-excluded"
    name   = "permissions-boundary-full-access-excluded"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"BoundaryFullAccess\",\"Effect\":\"Allow\",\"Action\":\"ec2:*\",\"Resource\":\"*\"}]}"
  }
}

resource "aws_iam_user" "user_with_permission_boundary_excluded" {
  attrs = {
    name                 = "user-with-permission-boundary-excluded"
    permissions_boundary = "arn:aws:iam::123456789012:policy/permissions-boundary-full-access-excluded"
  }
}

# FAIL - excludePermissionBoundaryPolicy = "true" must NOT exempt a regular
# customer-managed policy that is not attached as anyone's permissions boundary.
# This is the negative pairing for the PASS case above: if the exclusion logic
# were hard-coded to skip every policy, this would also pass (wrongly).
resource "aws_iam_policy" "regular_policy_still_fails_under_exclude_input" {
  expect_failure = true
  attrs = {
    arn    = "arn:aws:iam::123456789012:policy/regular-wildcard-policy"
    name   = "regular-wildcard-policy"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"WildcardAction\",\"Effect\":\"Allow\",\"Action\":\"ec2:*\",\"Resource\":\"*\"}]}"
  }
}
