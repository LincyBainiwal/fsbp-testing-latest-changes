# Copyright IBM Corp. 2026

policytest {
  targets = [
    "redshift-serverless-default-admin-check.policy.hcl"
  ]
}
# Pass: Custom username 'dbadmin'
resource "aws_redshiftserverless_namespace" "pass_custom_username_dbadmin" {
  attrs = {
    namespace_name = "test-namespace"
    admin_username = "dbadmin"
    admin_user_password = "SecurePassword123!"
  }
}

# Fail: Explicit admin username 'admin'
resource "aws_redshiftserverless_namespace" "fail_explicit_admin_username" {
  expect_failure = true
  attrs = {
    namespace_name = "test-namespace"
    admin_username = "admin"
    admin_user_password = "SecurePassword123!"
  }
}

# Fail: Missing admin_username (defaults to 'admin')
resource "aws_redshiftserverless_namespace" "fail_missing_admin_username" {
  expect_failure = true
  attrs = {
    namespace_name = "test-namespace"
    admin_user_password = "SecurePassword123!"
    # admin_username not specified, defaults to "admin"
  }
}

# Pass: Custom username 'customadmin'
resource "aws_redshiftserverless_namespace" "pass_custom_username_customadmin" {
  attrs = {
    namespace_name = "test-namespace-2"
    admin_username = "customadmin"
    admin_user_password = "SecurePassword456!"
  }
}

# Pass: Case-sensitive check with 'Administrator'
resource "aws_redshiftserverless_namespace" "pass_case_sensitive_Administrator" {
  attrs = {
    namespace_name = "test-namespace-3"
    admin_username = "Administrator"
    admin_user_password = "SecurePassword789!"
  }
}