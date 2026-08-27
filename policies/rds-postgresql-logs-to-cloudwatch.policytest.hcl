# Copyright IBM Corp. 2026

policytest {
    targets = [
        "rds-postgresql-logs-to-cloudwatch.policy.hcl"
    ]
}

# Test 1: FAIL - PostgreSQL instance with only postgresql logs enabled
resource "aws_db_instance" "pass_postgresql_logs_enabled" {
  expect_failure = true
  attrs = {
    engine = "postgres"
    enabled_cloudwatch_logs_exports = ["postgresql"]
    instance_class = "db.t3.micro"
    allocated_storage = 20
  }
}

# Test 2: FAIL - PostgreSQL with only upgrade logs enabled
resource "aws_db_instance" "pass_postgres_versioned_engine" {
  expect_failure = true
  attrs = {
    engine = "postgres"
    enabled_cloudwatch_logs_exports = ["upgrade"]
    instance_class = "db.t3.micro"
    allocated_storage = 20
  }
}

# Test 3: FAIL - PostgreSQL instance without enabled_cloudwatch_logs_exports
resource "aws_db_instance" "fail_no_logs_configured" {
  expect_failure = true
  attrs = {
    engine = "postgres"
    instance_class = "db.t3.micro"
    allocated_storage = 20
  }
}

# Test 4: FAIL - PostgreSQL instance with empty enabled_cloudwatch_logs_exports
resource "aws_db_instance" "fail_empty_logs_list" {
  expect_failure = true
  attrs = {
    engine = "postgres"
    enabled_cloudwatch_logs_exports = []
    instance_class = "db.t3.micro"
    allocated_storage = 20
  }
}

# Test 5: PASS - PostgreSQL instance with many log type
resource "aws_db_instance" "fail_wrong_log_type" {
  attrs = {
    engine = "postgres"
    enabled_cloudwatch_logs_exports = ["upgrade", "postgresql"]
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
