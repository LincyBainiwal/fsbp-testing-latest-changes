# Copyright IBM Corp. 2026

policytest {
    targets = [
        "redshift-cluster-kms-enabled.policy.hcl"
    ]
}

# Test 1: FAIL - Encryption disabled
resource "aws_redshift_cluster" "fail_encryption_disabled" {
  expect_failure = true
  attrs = {
    cluster_identifier = "test-cluster-no-encryption"
    node_type = "dc2.large"
    encrypted = false
    master_username = "admin"
    database_name = "mydb"
  }
}

# Test 2: PASS - Encryption enabled but no KMS key specified
resource "aws_redshift_cluster" "fail_encrypted_no_kms_key" {
  attrs = {
    cluster_identifier = "test-cluster-no-kms-key"
    node_type = "dc2.large"
    encrypted = true
    master_username = "admin"
    database_name = "mydb"
  }
}

# Test 3: PASS - Encryption enabled with empty KMS key string
resource "aws_redshift_cluster" "fail_encrypted_empty_kms" {
  attrs = {
    cluster_identifier = "test-cluster-empty-kms"
    node_type = "dc2.large"
    encrypted = true
    kms_key_id = ""
    master_username = "admin"
    database_name = "mydb"
  }
}
