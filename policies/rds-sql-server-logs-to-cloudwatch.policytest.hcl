# Copyright IBM Corp. 2026

policytest {
    targets = [
        "rds-sql-server-logs-to-cloudwatch.policy.hcl"
    ]
}

# Test 1: FAIL - SQL instance with only error logs enabled
resource "aws_db_instance" "pass_sql_logs_enabled" {
  expect_failure = true
  attrs = {
    engine = "sqlserver-ee"
    enabled_cloudwatch_logs_exports = ["error"]
    instance_class = "db.t3.micro"
    allocated_storage = 20
  }
}

# Test 2: FAIL - SQL with only agent logs enabled
resource "aws_db_instance" "pass_sql_versioned_engine" {
  expect_failure = true
  attrs = {
    engine = "sqlserver-se"
    enabled_cloudwatch_logs_exports = ["agent"]
    instance_class = "db.t3.micro"
    allocated_storage = 20
  }
}

# Test 3: FAIL - SQL instance without enabled_cloudwatch_logs_exports
resource "aws_db_instance" "fail_no_sql_logs_configured" {
  expect_failure = true
  attrs = {
    engine = "sqlserver-ex"
    instance_class = "db.t3.micro"
    allocated_storage = 20
  }
}

# Test 4: FAIL - SQL instance with empty enabled_cloudwatch_logs_exports
resource "aws_db_instance" "fail_empty_sql_logs_list" {
  expect_failure = true
  attrs = {
    engine = "sqlserver-web"
    enabled_cloudwatch_logs_exports = []
    instance_class = "db.t3.micro"
    allocated_storage = 20
  }
}

# Test 5: PASS - PostgreSQL instance with many log type
resource "aws_db_instance" "pass_sql_all_log_type" {
  attrs = {
    engine = "sqlserver-dev-ee"
    enabled_cloudwatch_logs_exports = ["agent", "error"]
    instance_class = "db.t3.micro"
    allocated_storage = 20
  }
}

# Test 6: SKIP - MySQL instance (non-PostgreSQL engine, filtered out by policy)
resource "aws_db_instance" "skip_mysql_instance" {
  attrs = {
    engine = "mysql"
    enabled_cloudwatch_logs_exports = ["error", "general"]
    instance_class = "db.t3.micro"
    allocated_storage = 20
  }
}
