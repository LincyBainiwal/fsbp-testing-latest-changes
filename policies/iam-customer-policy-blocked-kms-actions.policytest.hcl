# Copyright IBM Corp. 2026

policytest {
  targets = [
    "iam-customer-policy-blocked-kms-actions.policy.hcl"
  ]
}
# PASS: IAM policy with kms:Decrypt on specific KMS key ARN
resource "aws_iam_policy" "pass_specific_key_arn" {
  attrs = {
    name = "compliant-kms-policy"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"kms:Decrypt\",\"Resource\":\"arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012\"}]}"
  }
}

# FAIL: IAM policy with kms:Decrypt on all resources (string "*")
resource "aws_iam_policy" "fail_decrypt_wildcard_string" {
  expect_failure = true
  attrs = {
    name = "non-compliant-decrypt-policy"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"kms:Decrypt\",\"Resource\":\"*\"}]}"
  }
}

# FAIL: IAM policy with kms:ReEncryptFrom on all resources
resource "aws_iam_policy" "fail_reencrypt_wildcard" {
  expect_failure = true
  attrs = {
    name = "non-compliant-reencrypt-policy"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"kms:ReEncryptFrom\",\"Resource\":\"*\"}]}"
  }
}

# PASS: IAM policy with both kms:Decrypt and kms:ReEncryptFrom on specific KMS key ARNs
resource "aws_iam_policy" "pass_both_actions_specific_arns" {
  attrs = {
    name = "compliant-both-actions-policy"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":[\"kms:Decrypt\",\"kms:ReEncryptFrom\"],\"Resource\":[\"arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012\",\"arn:aws:kms:us-west-2:123456789012:key/87654321-4321-4321-4321-210987654321\"]}]}"
  }
}

# FAIL: IAM policy with kms:* wildcard action on all resources (covers blocked actions)
resource "aws_iam_policy" "fail_kms_wildcard_action" {
  expect_failure = true
  attrs = {
    name = "kms-wildcard-action-policy"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"kms:*\",\"Resource\":\"*\"}]}"
  }
}

# PASS: IAM policy with kms:Encrypt (non-blocked action) on all resources
resource "aws_iam_policy" "pass_encrypt_wildcard" {
  attrs = {
    name = "compliant-encrypt-policy"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"kms:Encrypt\",\"Resource\":\"*\"}]}"
  }
}

# FAIL: IAM policy with kms:Decrypt in action list on all resources
resource "aws_iam_policy" "fail_decrypt_in_action_list" {
  expect_failure = true
  attrs = {
    name = "non-compliant-action-list-policy"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":[\"kms:Encrypt\",\"kms:Decrypt\",\"kms:DescribeKey\"],\"Resource\":\"*\"}]}"
  }
}

# FAIL: IAM policy with Resource as list containing "*"
resource "aws_iam_policy" "fail_wildcard_in_resource_list" {
  expect_failure = true
  attrs = {
    name = "non-compliant-resource-list-policy"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"kms:Decrypt\",\"Resource\":[\"*\"]}]}"
  }
}

# PASS: IAM policy with multiple statements, none violating
resource "aws_iam_policy" "pass_multiple_statements_compliant" {
  attrs = {
    name = "compliant-multiple-statements-policy"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"kms:Decrypt\",\"Resource\":\"arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012\"},{\"Effect\":\"Allow\",\"Action\":\"kms:Encrypt\",\"Resource\":\"*\"},{\"Effect\":\"Allow\",\"Action\":\"s3:GetObject\",\"Resource\":\"*\"}]}"
  }
}

# PASS: IAM policy with Deny effect (not checked per specification)
resource "aws_iam_policy" "pass_deny_effect_not_checked" {
  attrs = {
    name = "deny-statement-policy"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Deny\",\"Action\":\"kms:Decrypt\",\"Resource\":\"*\"}]}"
  }
}
