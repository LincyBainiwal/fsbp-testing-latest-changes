# Copyright IBM Corp. 2026

policytest {
    targets = [
        "rds-instance-iam-authentication-enabled.policy.hcl"
    ]
}

# Test 1: PASS - IAM authentication enabled for mysql engine
resource "aws_db_instance" "mysql_iam_auth_enabled" {
  attrs = {
    engine                              = "mysql"
    iam_database_authentication_enabled = true
  }
}

# Test 2: FAIL - IAM authentication disabled for postgres engine
resource "aws_db_instance" "postgres_iam_auth_disabled" {
  expect_failure = true
  attrs = {
    engine                              = "postgres"
    iam_database_authentication_enabled = false
  }
}

# Test 3: PASS - IAM authentication not applicable for sqlserver-ee engine
resource "aws_db_instance" "sqlserver_out_of_scope" {
  attrs = {
    engine                              = "sqlserver-ee"
    iam_database_authentication_enabled = false
  }
}
