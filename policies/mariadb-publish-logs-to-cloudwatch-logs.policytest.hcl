# Copyright IBM Corp. 2026

policytest {
    targets = [
        "mariadb-publish-logs-to-cloudwatch-logs.policy.hcl"
    ]
}

# Test 1: PASS - MariaDB with audit and error logs enabled
resource "aws_db_instance" "pass_with_required_logs" {
  attrs = {
    engine = "mariadb"
    engine_version = "10.6"
    instance_class = "db.t3.micro"
    enabled_cloudwatch_logs_exports = ["audit", "error"]
  }
}

# Test 2: PASS - MariaDB with all logs enabled
resource "aws_db_instance" "pass_with_all_logs" {
  attrs = {
    engine = "mariadb"
    engine_version = "10.6"
    instance_class = "db.t3.micro"
    enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
  }
}

# Test 3: PASS - MariaDB with audit logs enabled
resource "aws_db_instance" "pass_audit_logs" {
  attrs = {
    engine = "mariadb"
    engine_version = "10.6"
    instance_class = "db.t3.micro"
    enabled_cloudwatch_logs_exports = ["audit"]
  }
}

# Test 4: PASS - MariaDB with error log type
resource "aws_db_instance" "pass_error_logs" {
  attrs = {
    engine = "mariadb"
    engine_version = "10.6"
    instance_class = "db.t3.micro"
    enabled_cloudwatch_logs_exports = ["error"]
  }
}

# Test 5: FAIL - MariaDB without enabled_cloudwatch_logs_exports
resource "aws_db_instance" "fail_no_sql_logs_configured" {
  expect_failure = true
  attrs = {
    engine = "mariadb"
    engine_version = "10.6"
    instance_class = "db.t3.micro"
  }
}

# Test 6: FAIL - MariaDB with empty log exports
resource "aws_db_instance" "fail_empty_logs" {
  expect_failure = true
  attrs = {
    engine = "mariadb"
    engine_version = "10.6"
    instance_class = "db.t3.micro"
    enabled_cloudwatch_logs_exports = []
  }
}

# Test 7: SKIP - Non-MariaDB instance (filtered out by policy)
resource "aws_db_instance" "skip_non_mariadb_engine" {
  attrs = {
    engine = "mysql"
    engine_version = "8.0"
    instance_class = "db.t3.micro"
  }
}

# Test 8: FAIL - MariaDB instance with only optional logs (missing required)
resource "aws_db_instance" "fail_wrong_logs_only" {
  expect_failure = true
  attrs = {
    engine = "mariadb"
    engine_version = "10.6"
    instance_class = "db.t3.micro"
    enabled_cloudwatch_logs_exports = ["general", "slowquery"]
  }
}
