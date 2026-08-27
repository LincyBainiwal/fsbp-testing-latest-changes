# Copyright IBM Corp. 2026

policytest {
    targets = [
        "rds-enhanced-monitoring-enabled.policy.hcl"
    ]
}

# Test 1: PASS - monitoring_interval is set to valid value (60 seconds)
resource "aws_db_instance" "pass_monitoring_60" {
    attrs = {
        allocated_storage    = 10
        db_name              = "mydb"
        engine               = "mysql"
        engine_version       = "8.0"
        instance_class       = "db.t3.micro"
        username             = "admin"
        monitoring_interval  = 60
        monitoring_role_arn  = "arn:aws:iam::123456789012:role/rds-monitoring-role"
    }
}

# Test 2: PASS - monitoring_interval is set to valid value (1 second)
resource "aws_db_instance" "pass_monitoring_1" {
    attrs = {
        allocated_storage    = 10
        db_name              = "mydb"
        engine               = "postgres"
        engine_version       = "14.0"
        instance_class       = "db.t3.micro"
        username             = "admin"
        monitoring_interval  = 1
        monitoring_role_arn  = "arn:aws:iam::123456789012:role/rds-monitoring-role"
    }
}

# Test 3: FAIL - monitoring_interval is 0 (disabled)
resource "aws_db_instance" "fail_monitoring_disabled" {
    expect_failure = true
    attrs = {
        allocated_storage    = 10
        db_name              = "mydb"
        engine               = "mysql"
        engine_version       = "8.0"
        instance_class       = "db.t3.micro"
        username             = "admin"
        monitoring_interval  = 0
    }
}

# Test 4: FAIL - monitoring_interval is missing (defaults to 0)
resource "aws_db_instance" "fail_monitoring_missing" {
    expect_failure = true
    attrs = {
        allocated_storage    = 10
        db_name              = "mydb"
        engine               = "mysql"
        engine_version       = "8.0"
        instance_class       = "db.t3.micro"
        username             = "admin"
    }
}

# Test 5: FAIL - monitoring_interval is invalid value (not in valid list)
resource "aws_db_instance" "fail_monitoring_invalid" {
    expect_failure = true
    attrs = {
        allocated_storage    = 10
        db_name              = "mydb"
        engine               = "mysql"
        engine_version       = "8.0"
        instance_class       = "db.t3.micro"
        username             = "admin"
        monitoring_interval  = 20
        monitoring_role_arn  = "arn:aws:iam::123456789012:role/rds-monitoring-role"
    }
}
