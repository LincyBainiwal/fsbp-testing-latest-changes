# Copyright IBM Corp. 2026

policytest {
  targets = ["iam-user-no-policies-check.policy.hcl"]
}

# Pass case 1: IAM user without any policy attachments (no violations)
resource "aws_iam_user" "compliant_user" {
  attrs = {
    name = "test-user"
    path = "/"
  }
}

# Fail case 1: Inline policy attached to user
resource "aws_iam_user_policy" "inline_policy_violation" {
  expect_failure = true
  attrs = {
    name = "test-policy"
    user = "test-user"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"s3:*\",\"Resource\":\"*\"}]}"
  }
}

# Fail case 2: Managed policy attached to user
resource "aws_iam_user_policy_attachment" "managed_policy_violation" {
  expect_failure = true
  attrs = {
    user = "test-user"
    policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  }
}

# Fail case 3: Multiple inline policies attached to different users
resource "aws_iam_user_policy" "user1_inline_policy" {
  expect_failure = true
  attrs = {
    name = "user1-policy"
    user = "user1"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"s3:GetObject\",\"Resource\":\"*\"}]}"
  }
}

resource "aws_iam_user_policy" "user2_inline_policy" {
  expect_failure = true
  attrs = {
    name = "user2-policy"
    user = "user2"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"ec2:Describe*\",\"Resource\":\"*\"}]}"
  }
}

# Fail case 4: Multiple managed policy attachments to different users
resource "aws_iam_user_policy_attachment" "user1_managed_attachment" {
  expect_failure = true
  attrs = {
    user = "user1"
    policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  }
}

resource "aws_iam_user_policy_attachment" "user2_managed_attachment" {
  expect_failure = true
  attrs = {
    user = "user2"
    policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
  }
}