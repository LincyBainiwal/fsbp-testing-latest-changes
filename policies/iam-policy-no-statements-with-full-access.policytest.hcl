# Copyright IBM Corp. 2026

policytest {
  targets = ["iam-policy-no-statements-with-full-access.policy.hcl"]
}

# FAIL - aws_iam_policy with service wildcard action (ec2:*)
resource "aws_iam_policy" "managed_policy_wildcard_action_fails" {
  expect_failure = true
  attrs = {
    name = "managed-policy-wildcard"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"WildcardAction\",\"Effect\":\"Allow\",\"Action\":\"ec2:*\",\"Resource\":\"*\"}]}"
  }
}

# FAIL - aws_iam_role_policy with NotAction service wildcard (s3:*)
resource "aws_iam_role_policy" "role_policy_notaction_wildcard_fails" {
  expect_failure = true
  attrs = {
    name = "role-policy-notaction-wildcard"
    role = "example-role"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"WildcardNotAction\",\"Effect\":\"Allow\",\"NotAction\":\"s3:*\",\"Resource\":\"*\"}]}"
  }
}

# PASS - aws_iam_user_policy with a prefixed wildcard (ec2:Describe*) -- not a full service wildcard
resource "aws_iam_user_policy" "user_policy_prefixed_wildcard_passes" {
  attrs = {
    name = "user-policy-describe-prefix"
    user = "example-user"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"DescribeOnly\",\"Effect\":\"Allow\",\"Action\":\"ec2:Describe*\",\"Resource\":\"*\"}]}"
  }
}

# PASS - aws_iam_group_policy with specific actions only
resource "aws_iam_group_policy" "group_policy_specific_actions_passes" {
  attrs = {
    name  = "group-policy-specific-actions"
    group = "example-group"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"SpecificActions\",\"Effect\":\"Allow\",\"Action\":[\"s3:GetObject\",\"s3:ListBucket\"],\"Resource\":\"*\"}]}"
  }
}

# FAIL - aws_iam_user_policy with service wildcard Action (ec2:*)
resource "aws_iam_user_policy" "user_policy_wildcard_action_fails" {
  expect_failure = true
  attrs = {
    name = "user-policy-wildcard"
    user = "example-user"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"WildcardAction\",\"Effect\":\"Allow\",\"Action\":\"ec2:*\",\"Resource\":\"*\"}]}"
  }
}

# FAIL - aws_iam_user_policy with NotAction service wildcard (s3:*)
resource "aws_iam_user_policy" "user_policy_notaction_wildcard_fails" {
  expect_failure = true
  attrs = {
    name = "user-policy-notaction-wildcard"
    user = "example-user"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"WildcardNotAction\",\"Effect\":\"Allow\",\"NotAction\":\"s3:*\",\"Resource\":\"*\"}]}"
  }
}

# FAIL - aws_iam_group_policy with service wildcard Action (s3:*)
resource "aws_iam_group_policy" "group_policy_wildcard_action_fails" {
  expect_failure = true
  attrs = {
    name  = "group-policy-wildcard"
    group = "example-group"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"WildcardAction\",\"Effect\":\"Allow\",\"Action\":\"s3:*\",\"Resource\":\"*\"}]}"
  }
}

# FAIL - aws_iam_group_policy with NotAction service wildcard (ec2:*)
resource "aws_iam_group_policy" "group_policy_notaction_wildcard_fails" {
  expect_failure = true
  attrs = {
    name  = "group-policy-notaction-wildcard"
    group = "example-group"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"WildcardNotAction\",\"Effect\":\"Allow\",\"NotAction\":\"ec2:*\",\"Resource\":\"*\"}]}"
  }
}
