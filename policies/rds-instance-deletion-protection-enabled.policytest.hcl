# Copyright IBM Corp. 2026

policytest {
    targets = [
        "rds-instance-deletion-protection-enabled.policy.hcl"
    ]
}


# Test 1: PASS - deletion_protection is true
resource "aws_db_instance" "pass_deletion_protection" {
    attrs = {
        allocated_storage   = 10
        db_name             = "mydb"
        engine              = "mysql"
        engine_version      = "8.0"
        instance_class      = "db.t3.micro"
        username            = "foo"
        deletion_protection = true
    }
}

# Test 2: FAIL - deletion_protection is false
resource "aws_db_instance" "fail_deletion_protection" {
    expect_failure = true
    attrs = {
        allocated_storage   = 10
        db_name             = "mydb"
        engine              = "mysql"
        engine_version      = "8.0"
        instance_class      = "db.t3.micro"
        username            = "foo"
        deletion_protection = false
    }
}

# Test 3: FAIL - deletion_protection is not present (default is false)
resource "aws_db_instance" "fail_deletion_protection_missing" {
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
