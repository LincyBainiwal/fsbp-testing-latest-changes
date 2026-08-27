# Copyright IBM Corp. 2026

policytest {
  targets = ["iam-password-policy.policy.hcl"]
}

# Pass case: All required character settings plus reuse_prevention and max_password_age
# set to the policy's baked-in defaults (reuse >= 1, age 1..90).
resource "aws_iam_account_password_policy" "pass_all_required_settings" {
  attrs = {
    require_uppercase_characters = true
    require_lowercase_characters = true
    require_symbols = true
    require_numbers = true
    minimum_password_length = 8
    password_reuse_prevention = 1
    max_password_age = 90
  }
}

# Pass case: All required settings plus optional parameters configured correctly
resource "aws_iam_account_password_policy" "pass_with_optional_parameters" {
  attrs = {
    require_uppercase_characters = true
    require_lowercase_characters = true
    require_symbols = true
    require_numbers = true
    minimum_password_length = 14
    password_reuse_prevention = 12
    max_password_age = 90
  }
}

# Pass case: Optional parameters at maximum valid values
resource "aws_iam_account_password_policy" "pass_optional_max_values" {
  attrs = {
    require_uppercase_characters = true
    require_lowercase_characters = true
    require_symbols = true
    require_numbers = true
    minimum_password_length = 128
    password_reuse_prevention = 24
    max_password_age = 90
  }
}

# Fail case: Missing uppercase requirement
resource "aws_iam_account_password_policy" "fail_no_uppercase" {
  expect_failure = true
  attrs = {
    require_uppercase_characters = false
    require_lowercase_characters = true
    require_symbols = true
    require_numbers = true
    minimum_password_length = 8
  }
}

# Fail case: Missing lowercase requirement
resource "aws_iam_account_password_policy" "fail_no_lowercase" {
  expect_failure = true
  attrs = {
    require_uppercase_characters = true
    require_lowercase_characters = false
    require_symbols = true
    require_numbers = true
    minimum_password_length = 8
  }
}

# Fail case: Missing symbol requirement
resource "aws_iam_account_password_policy" "fail_no_symbols" {
  expect_failure = true
  attrs = {
    require_uppercase_characters = true
    require_lowercase_characters = true
    require_symbols = false
    require_numbers = true
    minimum_password_length = 8
  }
}

# Fail case: Missing number requirement
resource "aws_iam_account_password_policy" "fail_no_numbers" {
  expect_failure = true
  attrs = {
    require_uppercase_characters = true
    require_lowercase_characters = true
    require_symbols = true
    require_numbers = false
    minimum_password_length = 8
  }
}

# Fail case: Insufficient minimum length
resource "aws_iam_account_password_policy" "fail_insufficient_length" {
  expect_failure = true
  attrs = {
    require_uppercase_characters = true
    require_lowercase_characters = true
    require_symbols = true
    require_numbers = true
    minimum_password_length = 6
  }
}

# Fail case: password_reuse_prevention set but max_password_age missing
# (fails the max_password_age enforce: 0 > 0 is false).
resource "aws_iam_account_password_policy" "fail_missing_max_age" {
  expect_failure = true
  attrs = {
    require_uppercase_characters = true
    require_lowercase_characters = true
    require_symbols = true
    require_numbers = true
    minimum_password_length = 8
    password_reuse_prevention = 5
  }
}

# Fail case: password_reuse_prevention high but max_password_age missing.
resource "aws_iam_account_password_policy" "fail_missing_max_age_high_reuse" {
  expect_failure = true
  attrs = {
    require_uppercase_characters = true
    require_lowercase_characters = true
    require_symbols = true
    require_numbers = true
    minimum_password_length = 8
    password_reuse_prevention = 30
  }
}

# Fail case: max_password_age = 120 exceeds the IAM.7 default of 90 (also fails
# the reuse-prevention enforce because reuse defaults to 0 < 1).
resource "aws_iam_account_password_policy" "fail_max_age_too_high" {
  expect_failure = true
  attrs = {
    require_uppercase_characters = true
    require_lowercase_characters = true
    require_symbols = true
    require_numbers = true
    minimum_password_length = 8
    max_password_age = 120
  }
}

# Fail case: Multiple violations
resource "aws_iam_account_password_policy" "fail_multiple_violations" {
  expect_failure = true
  attrs = {
    require_uppercase_characters = false
    require_lowercase_characters = false
    require_symbols = true
    require_numbers = true
    minimum_password_length = 6
  }
}