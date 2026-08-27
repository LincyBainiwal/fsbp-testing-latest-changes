# Copyright IBM Corp. 2026

policytest {
  targets = ["iam-policy-no-statements-with-admin-access.policy.hcl"]
}

resource "aws_iam_policy" "managed_policy_allows_admin" {
  expect_failure = true
  attrs = {
    arn    = "arn:aws:iam::123456789012:policy/managed-admin-policy"
    name   = "managed-admin-policy"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"*\",\"Resource\":\"*\"}]}"
  }
}

resource "aws_iam_policy" "managed_policy_read_only" {
  attrs = {
    arn    = "arn:aws:iam::123456789012:policy/managed-readonly-policy"
    name   = "managed-readonly-policy"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":[\"s3:GetObject\"],\"Resource\":[\"arn:aws:s3:::example-bucket/*\"]}]}"
  }
}

resource "aws_iam_policy" "managed_policy_admin_action_list" {
  expect_failure = true
  attrs = {
    arn    = "arn:aws:iam::123456789012:policy/managed-admin-action-list"
    name   = "managed-admin-action-list"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":[\"*\"],\"Resource\":\"*\"}]}"
  }
}

resource "aws_iam_policy" "managed_policy_admin_resource_list" {
  expect_failure = true
  attrs = {
    arn    = "arn:aws:iam::123456789012:policy/managed-admin-resource-list"
    name   = "managed-admin-resource-list"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"*\",\"Resource\":[\"*\"]}]}"
  }
}

resource "aws_iam_policy" "managed_policy_deny_admin" {
  attrs = {
    arn    = "arn:aws:iam::123456789012:policy/managed-deny-admin"
    name   = "managed-deny-admin"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Deny\",\"Action\":\"*\",\"Resource\":\"*\"}]}"
  }
}

resource "aws_iam_policy" "permissions_boundary_policy_admin" {
  expect_failure = true
  attrs = {
    arn    = "arn:aws:iam::123456789012:policy/permissions-boundary-admin"
    name   = "permissions-boundary-admin"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"*\",\"Resource\":\"*\"}]}"
  }
}

resource "aws_iam_role" "role_with_boundary" {
  attrs = {
    name = "role-with-boundary"
    permissions_boundary = "arn:aws:iam::123456789012:policy/permissions-boundary-admin"
  }
}

# FAIL - NotAction with Resource=* grants all actions except denylist (effectively admin)
resource "aws_iam_policy" "fail_not_action_resource_star" {
  expect_failure = true
  attrs = {
    arn    = "arn:aws:iam::123456789012:policy/not-action-admin"
    name   = "not-action-admin"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"NotAction\":[\"iam:CreateUser\",\"iam:DeleteUser\"],\"Resource\":\"*\"}]}"
  }
}

# FAIL - NotAction as string with Resource=* (single excluded action)
resource "aws_iam_policy" "fail_not_action_string_resource_star" {
  expect_failure = true
  attrs = {
    arn    = "arn:aws:iam::123456789012:policy/not-action-string-admin"
    name   = "not-action-string-admin"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"NotAction\":\"iam:CreateUser\",\"Resource\":\"*\"}]}"
  }
}

# FAIL - Action=* with NotResource (grants all actions on all resources except denylist)
resource "aws_iam_policy" "fail_action_star_not_resource" {
  expect_failure = true
  attrs = {
    arn    = "arn:aws:iam::123456789012:policy/action-star-not-resource"
    name   = "action-star-not-resource"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"*\",\"NotResource\":[\"arn:aws:s3:::sensitive-bucket\"]}]}"
  }
}

# PASS - NotAction with Deny (denylist pattern — not an admin grant)
resource "aws_iam_policy" "pass_not_action_deny" {
  attrs = {
    arn    = "arn:aws:iam::123456789012:policy/not-action-deny"
    name   = "not-action-deny"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Deny\",\"NotAction\":[\"s3:GetObject\"],\"Resource\":\"*\"}]}"
  }
}

# PASS - NotAction with restricted Resource (not a wildcard resource)
resource "aws_iam_policy" "pass_not_action_restricted_resource" {
  attrs = {
    arn    = "arn:aws:iam::123456789012:policy/not-action-restricted"
    name   = "not-action-restricted"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"NotAction\":[\"iam:*\"],\"Resource\":\"arn:aws:s3:::my-bucket/*\"}]}"
  }
}