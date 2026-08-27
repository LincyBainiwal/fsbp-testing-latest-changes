# Copyright IBM Corp. 2026

policytest {
    targets = [
        "rds-instance-default-admin-check.policy.hcl"
    ]
}

# Test 1: PASS - Custom administrator username
resource "aws_db_instance" "pass_custom_username" {
    attrs = {
        allocated_storage    = 10
        db_name              = "mydb"
        engine               = "mysql"
        engine_version       = "8.0"
        instance_class       = "db.t3.micro"
        username             = "dbadmin"
    }
}

# Test 2: PASS - Another custom administrator username
resource "aws_db_instance" "pass_custom_username_2" {
    attrs = {
        allocated_storage    = 10
        db_name              = "mydb"
        engine               = "postgres"
        engine_version       = "14.0"
        instance_class       = "db.t3.micro"
        username             = "mydbuser"
    }
}

# Test 3: FAIL - Default username "postgres"
resource "aws_db_instance" "fail_default_postgres" {
    expect_failure = true
    attrs = {
        allocated_storage    = 10
        db_name              = "mydb"
        engine               = "postgres"
        engine_version       = "14.0"
        instance_class       = "db.t3.micro"
        username             = "postgres"
    }
}

# Test 4: FAIL - Default username "admin"
resource "aws_db_instance" "fail_default_admin" {
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

# Test 5: FAIL - Missing username
resource "aws_db_instance" "fail_missing_username" {
    expect_failure = true
    attrs = {
        allocated_storage    = 10
        db_name              = "mydb"
        engine               = "mysql"
        engine_version       = "8.0"
        instance_class       = "db.t3.micro"
    }
}
