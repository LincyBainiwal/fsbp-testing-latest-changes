# Copyright IBM Corp. 2026

policytest {
    targets = [
        "rds-instance-copy-tags-to-snapshots-enabled.policy.hcl"
    ]
}

# Test 1: PASS - copy_tags_to_snapshot is true
resource "aws_db_instance" "pass_copy_tags_to_snapshot" {
    attrs = {
        allocated_storage   = 10
        db_name             = "mydb"
        engine              = "mysql"
        engine_version      = "8.0"
        instance_class      = "db.t3.micro"
        username            = "foo"
        copy_tags_to_snapshot = true
    }
}

# Test 2: FAIL - copy_tags_to_snapshot is false
resource "aws_db_instance" "fail_copy_tags_to_sanpshot" {
    expect_failure = true
    attrs = {
        allocated_storage   = 10
        db_name             = "mydb"
        engine              = "mysql"
        engine_version      = "8.0"
        instance_class      = "db.t3.micro"
        username            = "foo"
        copy_tags_to_snapshot = false
    }
}

# Test 3: PASS - copy_tags_to_snapshot is missing (defaults to false)
resource "aws_db_instance" "fail_missing_copy_tags_to_snapshot" {
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
