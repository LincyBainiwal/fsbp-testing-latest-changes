# Copyright IBM Corp. 2026

policytest {
    targets = [
        "rds-db-instance-backup-enabled.policy.hcl"
    ]
}

# Test 1: PASS - Backup retention period equals default minimum (7 days)
resource "aws_db_instance" "pass_retention_equals_default" {
  attrs = {
    allocated_storage   = 10
    db_name             = "mydb"
    engine              = "mysql"
    engine_version      = "8.0"
    instance_class      = "db.t3.micro"
    username            = "foo"
    backup_retention_period = 7
  }
}

# Test 2: PASS - Backup retention period greater than default minimum (14 days)
resource "aws_db_instance" "pass_retention_14_days" {
  attrs = {
    allocated_storage   = 10
    db_name             = "mydb"
    engine              = "mysql"
    engine_version      = "8.0"
    instance_class      = "db.t3.micro"
    username            = "foo"
    backup_retention_period = 14
  }
}

# Test 3: PASS - Backup retention period at maximum (35 days)
resource "aws_db_instance" "pass_retention_max" {
  attrs = {
    allocated_storage   = 10
    db_name             = "mydb"
    engine              = "mysql"
    engine_version      = "8.0"
    instance_class      = "db.t3.micro"
    username            = "foo"
    backup_retention_period = 35
  }
}

# Test 4: FAIL - Backup retention period less than default minimum (6 days)
resource "aws_db_instance" "fail_retention_6_days" {
  expect_failure = true
  attrs = {
    allocated_storage   = 10
    db_name             = "mydb"
    engine              = "mysql"
    engine_version      = "8.0"
    instance_class      = "db.t3.micro"
    username            = "foo"
    backup_retention_period = 6
  }
}

# Test 5: FAIL - Backup retention period much less than default minimum (1 day)
resource "aws_db_instance" "fail_retention_1_day" {
  expect_failure = true
  attrs = {
    allocated_storage   = 10
    db_name             = "mydb"
    engine              = "mysql"
    engine_version      = "8.0"
    instance_class      = "db.t3.micro"
    username            = "foo"
    backup_retention_period = 1
  }
}

# Test 6: FAIL - Backup retention period is 0
resource "aws_db_instance" "fail_retention_0" {
  expect_failure = true
  attrs = {
    allocated_storage   = 10
    db_name             = "mydb"
    engine              = "mysql"
    engine_version      = "8.0"
    instance_class      = "db.t3.micro"
    username            = "foo"
    backup_retention_period = 0
  }
}

# Test 7: FAIL - Missing backup_retention_period (defaults to 0, less than default minimum 7)
resource "aws_db_instance" "fail_missing_retention" {
  expect_failure = true
  attrs = {
    allocated_storage   = 10
    db_name             = "mydb"
    engine              = "mysql"
    engine_version      = "8.0"
    instance_class      = "db.t3.micro"
    username            = "foo"
  }
}
