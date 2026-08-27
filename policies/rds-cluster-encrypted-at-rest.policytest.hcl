# Copyright IBM Corp. 2026

policytest {
    targets = [
        "rds-cluster-encrypted-at-rest.policy.hcl"
    ]
}

# Test 1: PASS - Provisioned cluster with encryption enabled
resource "aws_rds_cluster" "provisioned_encrypted_true" {
    attrs = {
        engine_mode = "provisioned"
        storage_encrypted = true
    }
}

# Test 2: FAIL - Provisioned cluster with encryption disabled
resource "aws_rds_cluster" "provisioned_encrypted_false" {
    expect_failure = true
    attrs = {
        engine_mode = "provisioned"
        storage_encrypted = false
    }
}

# Test 3: FAIL - Provisioned cluster with no storage_encrypted attribute
resource "aws_rds_cluster" "provisioned_no_encryption_attr" {
    expect_failure = true
    attrs = {
        engine_mode = "provisioned"
    }
}

# Test 4: PASS - Serverless cluster with encryption enabled
resource "aws_rds_cluster" "serverless_encrypted_true" {
    attrs = {
        engine_mode = "serverless"
        storage_encrypted = true
    }
}

# Test 5: FAIL - Serverless cluster with encryption disabled
resource "aws_rds_cluster" "serverless_encrypted_false" {
    expect_failure = true
    attrs = {
        engine_mode = "serverless"
        storage_encrypted = false
    }
}

# Test 6: PASS - Serverless cluster with no storage_encrypted attribute
resource "aws_rds_cluster" "serverless_no_encryption_attr" {
    attrs = {
        engine_mode = "serverless"
    }
}
