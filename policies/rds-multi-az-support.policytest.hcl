# Copyright IBM Corp. 2026

policytest {
    targets = [
        "rds-multi-az-support.policy.hcl"
    ]
}

# Test 1: PASS - multi_az is true
resource "aws_db_instance" "pass_multi_az_true" {
    attrs = {
        allocated_storage   = 10
        db_name             = "mydb"
        engine              = "mysql"
        engine_version      = "8.0"
        instance_class      = "db.t3.micro"
        username            = "foo"
        multi_az            = true
    }
}

# Test 2: FAIL - multi_az is false
resource "aws_db_instance" "fail_multi_az_false" {
    expect_failure = true
    attrs = {
        allocated_storage             = 10
        db_name                       = "mydb"
        engine                        = "mysql"
        engine_version                = "8.0"
        instance_class                = "db.t3.micro"
        username                      = "foo"
        multi_az = false
    }
}

# Test 3: FAIL - multi_az is not present (default is false)
resource "aws_db_instance" "fail_multi_az_missing" {
    expect_failure = true
    attrs = {
        allocated_storage             = 10
        db_name                       = "mydb"
        engine                        = "mysql"
        engine_version                = "8.0"
        instance_class                = "db.t3.micro"
        username                      = "foo"
    }
}
