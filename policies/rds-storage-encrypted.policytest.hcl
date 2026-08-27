# Copyright IBM Corp. 2026

policytest {
    targets = [
        "rds-storage-encrypted.policy.hcl"
    ]
}

# Test 1: PASS - storage_encrypted is true
resource "aws_db_instance" "pass_storage_encrypted_true" {
    attrs = {
        allocated_storage             = 10
        db_name                       = "mydb"
        engine                        = "mysql"
        engine_version                = "8.0"
        instance_class                = "db.t3.micro"
        username                      = "foo"
        storage_encrypted = true
    }
}

# Test 2: FAIL - storage_encrypted is false
resource "aws_db_instance" "fail_storage_encrypted_false" {
    expect_failure = true
    attrs = {
        allocated_storage             = 10
        db_name                       = "mydb"
        engine                        = "mysql"
        engine_version                = "8.0"
        instance_class                = "db.t3.micro"
        username                      = "foo"
        storage_encrypted = false
    }
}

# Test 3: FAIL - storage_encrypted is not present (default is false)
resource "aws_db_instance" "fail_storage_encrypted_missing" {
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
