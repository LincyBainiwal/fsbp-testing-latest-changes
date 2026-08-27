# Copyright IBM Corp. 2026

policytest {
    targets = [
        "rds-logging-enabled.policy.hcl"
    ]
}

# Test 1: PASS - CloudWatch logs exports enabled for all types in mysql engine
resource "aws_db_instance" "mysql_compliant" {
  attrs = {
    engine = "mysql"
    enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
  }
}

# Test 2: FAIL - CloudWatch logs exports enabled for 2 types in mysql engine
resource "aws_db_instance" "mysql_missing_required_logs" {
  expect_failure = true
  attrs = {
    engine = "mysql"
    enabled_cloudwatch_logs_exports = ["error", "general"]
  }
}

# Test 3: PASS - CloudWatch logs exports enabled for all types in postgres engine
resource "aws_db_instance" "postgres_compliant" {
  attrs = {
    engine = "postgres"
    enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  }
}

# Test 4: FAIL - CloudWatch logs exports missing 2 types for postgres engine
resource "aws_db_instance" "postgres_missing_upgrade" {
  expect_failure = true
  attrs = {
    engine = "postgres"
    enabled_cloudwatch_logs_exports = ["postgresql"]
  }
}

# Test 5: PASS - CloudWatch logs exports enabled for all types in sqlserver-ee engine
resource "aws_db_instance" "sqlserver_compliant" {
  attrs = {
    engine = "sqlserver-ee"
    enabled_cloudwatch_logs_exports = ["error", "agent"]
  }
}

# Test 6: FAIL - CloudWatch logs exports omitted for sqlserver-ee engine
resource "aws_db_instance" "sqlserver_exports_omitted" {
  expect_failure = true
  attrs = {
    engine = "sqlserver-ee"
  }
}
