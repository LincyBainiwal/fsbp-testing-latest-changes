# Copyright IBM Corp. 2026

policytest {
  targets = ["iam-inline-policy-blocked-kms-actions.policy.hcl"]
}

# ---------------------------------------------------------------------------
# aws_iam_role_policy
# ---------------------------------------------------------------------------

# PASS: Role inline policy allows only non-blocked KMS actions
resource "aws_iam_role_policy" "pass_role_non_blocked_actions" {
  attrs = {
    name   = "pass-role-kms-safe"
    role   = "my-role"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":[\"kms:Encrypt\",\"kms:GenerateDataKey\"],\"Resource\":\"*\"}]}"
  }
}

# PASS: Role inline policy with blocked action but scoped to a specific key ARN (not *)
resource "aws_iam_role_policy" "pass_role_decrypt_scoped_resource" {
  attrs = {
    name   = "pass-role-decrypt-scoped"
    role   = "my-role"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":[\"kms:Decrypt\"],\"Resource\":\"arn:aws:kms:us-east-1:123456789012:key/12345\"}]}"
  }
}

# PASS: Role inline policy with blocked action under Deny effect on *
resource "aws_iam_role_policy" "pass_role_decrypt_deny_effect" {
  attrs = {
    name   = "pass-role-decrypt-denied"
    role   = "my-role"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Deny\",\"Action\":[\"kms:Decrypt\"],\"Resource\":\"*\"}]}"
  }
}

# PASS: Role inline policy with empty statement list
resource "aws_iam_role_policy" "pass_role_empty_statements" {
  attrs = {
    name   = "pass-role-empty"
    role   = "my-role"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
  }
}

# FAIL: Role inline policy allows kms:Decrypt on all keys
resource "aws_iam_role_policy" "fail_role_decrypt_all_keys" {
  expect_failure = true
  attrs = {
    name   = "fail-role-kms-decrypt"
    role   = "my-role"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":[\"kms:Decrypt\"],\"Resource\":\"*\"}]}"
  }
}

# FAIL: Role inline policy allows kms:ReEncryptFrom on all keys
resource "aws_iam_role_policy" "fail_role_reencryptfrom_all_keys" {
  expect_failure = true
  attrs = {
    name   = "fail-role-kms-reencryptfrom"
    role   = "my-role"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":[\"kms:ReEncryptFrom\"],\"Resource\":\"*\"}]}"
  }
}

# FAIL: Role inline policy allows both blocked actions on all keys
resource "aws_iam_role_policy" "fail_role_both_blocked_actions" {
  expect_failure = true
  attrs = {
    name   = "fail-role-kms-both"
    role   = "my-role"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":[\"kms:Decrypt\",\"kms:ReEncryptFrom\"],\"Resource\":\"*\"}]}"
  }
}

# FAIL: Role inline policy — one compliant statement, one with kms:Decrypt on *
resource "aws_iam_role_policy" "fail_role_mixed_statements" {
  expect_failure = true
  attrs = {
    name   = "fail-role-kms-mixed"
    role   = "my-role"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":[\"kms:Encrypt\"],\"Resource\":\"*\"},{\"Effect\":\"Allow\",\"Action\":[\"kms:Decrypt\"],\"Resource\":\"*\"}]}"
  }
}

# ---------------------------------------------------------------------------
# aws_iam_user_policy
# ---------------------------------------------------------------------------

# PASS: User inline policy allows only non-blocked KMS actions
resource "aws_iam_user_policy" "pass_user_non_blocked_actions" {
  attrs = {
    name   = "pass-user-kms-safe"
    user   = "my-user"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":[\"kms:Encrypt\",\"kms:GenerateDataKey\"],\"Resource\":\"*\"}]}"
  }
}

# PASS: User inline policy with blocked action scoped to a specific key ARN
resource "aws_iam_user_policy" "pass_user_decrypt_scoped_resource" {
  attrs = {
    name   = "pass-user-decrypt-scoped"
    user   = "my-user"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":[\"kms:Decrypt\"],\"Resource\":\"arn:aws:kms:us-east-1:123456789012:key/abcde\"}]}"
  }
}

# FAIL: User inline policy allows kms:Decrypt on all keys
resource "aws_iam_user_policy" "fail_user_decrypt_all_keys" {
  expect_failure = true
  attrs = {
    name   = "fail-user-kms-decrypt"
    user   = "my-user"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":[\"kms:Decrypt\"],\"Resource\":\"*\"}]}"
  }
}

# FAIL: User inline policy allows kms:ReEncryptFrom on all keys
resource "aws_iam_user_policy" "fail_user_reencryptfrom_all_keys" {
  expect_failure = true
  attrs = {
    name   = "fail-user-kms-reencryptfrom"
    user   = "my-user"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":[\"kms:ReEncryptFrom\"],\"Resource\":\"*\"}]}"
  }
}

# FAIL: User inline policy — kms:Decrypt mixed with other safe actions on *
resource "aws_iam_user_policy" "fail_user_decrypt_mixed_actions" {
  expect_failure = true
  attrs = {
    name   = "fail-user-kms-mixed-actions"
    user   = "my-user"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":[\"kms:Encrypt\",\"kms:Decrypt\",\"kms:GenerateDataKey\"],\"Resource\":\"*\"}]}"
  }
}

# ---------------------------------------------------------------------------
# aws_iam_group_policy
# ---------------------------------------------------------------------------

# PASS: Group inline policy allows only non-blocked KMS actions
resource "aws_iam_group_policy" "pass_group_non_blocked_actions" {
  attrs = {
    name   = "pass-group-kms-safe"
    group  = "my-group"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":[\"kms:Encrypt\",\"kms:GenerateDataKey\"],\"Resource\":\"*\"}]}"
  }
}

# PASS: Group inline policy with blocked action scoped to a specific key ARN
resource "aws_iam_group_policy" "pass_group_decrypt_scoped_resource" {
  attrs = {
    name   = "pass-group-decrypt-scoped"
    group  = "my-group"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":[\"kms:Decrypt\"],\"Resource\":\"arn:aws:kms:us-east-1:123456789012:key/xyz99\"}]}"
  }
}

# FAIL: Group inline policy allows kms:Decrypt on all keys
resource "aws_iam_group_policy" "fail_group_decrypt_all_keys" {
  expect_failure = true
  attrs = {
    name   = "fail-group-kms-decrypt"
    group  = "my-group"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":[\"kms:Decrypt\"],\"Resource\":\"*\"}]}"
  }
}

# FAIL: Group inline policy allows kms:ReEncryptFrom on all keys
resource "aws_iam_group_policy" "fail_group_reencryptfrom_all_keys" {
  expect_failure = true
  attrs = {
    name   = "fail-group-kms-reencryptfrom"
    group  = "my-group"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":[\"kms:ReEncryptFrom\"],\"Resource\":\"*\"}]}"
  }
}

# FAIL: Group inline policy allows both blocked actions on all keys
resource "aws_iam_group_policy" "fail_group_both_blocked_actions" {
  expect_failure = true
  attrs = {
    name   = "fail-group-kms-both"
    group  = "my-group"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":[\"kms:Decrypt\",\"kms:ReEncryptFrom\"],\"Resource\":\"*\"}]}"
  }
}
