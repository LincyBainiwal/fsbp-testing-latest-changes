# Copyright IBM Corp. 2026

policytest {
    targets = [
        "rds-automatic-minor-version-upgrade-enabled.policy.hcl"
    ]
}

# Test 1: PASS - auto_minor_version_upgrade is true
resource "aws_db_instance" "pass_version_upgrade_enabled" {
    attrs = {
        allocated_storage   = 10
        db_name             = "mydb"
        engine              = "mysql"
        engine_version      = "8.0"
        instance_class      = "db.t3.micro"
        username            = "foo"
        auto_minor_version_upgrade = true
    }
}

# Test 2: FAIL - auto_minor_version_upgrade is false
resource "aws_db_instance" "fail_version_upgrade_disabled" {
    expect_failure = true
    attrs = {
        allocated_storage   = 10
        db_name             = "mydb"
        engine              = "mysql"
        engine_version      = "8.0"
        instance_class      = "db.t3.micro"
        username            = "foo"
        auto_minor_version_upgrade = false
    }
}

# Test 3: PASS - auto_minor_version_upgrade is missing (defaults to true)
resource "aws_db_instance" "pass_version_upgrade_missing" {
    attrs = {
        allocated_storage   = 10
        db_name             = "mydb"
        engine              = "mysql"
        engine_version      = "8.0"
        instance_class      = "db.t3.micro"
        username            = "foo"
    }
}
