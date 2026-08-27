# Copyright IBM Corp. 2026

policytest {
    targets = [
        "neptune-cluster-snapshot-encrypted.policy.hcl"
    ]
}

# Test 1: PASS - Snapshot is encrypted at rest
resource "aws_neptune_cluster_snapshot" "pass_snapshot_encrypted" {
  attrs = {
    db_cluster_snapshot_identifier = "neptune-snapshot-encrypted"
    storage_encrypted              = true
  }
}

# Test 2: FAIL - Snapshot is not encrypted at rest
resource "aws_neptune_cluster_snapshot" "fail_snapshot_not_encrypted" {
  expect_failure = true
  attrs = {
    db_cluster_snapshot_identifier = "neptune-snapshot-unencrypted"
    storage_encrypted              = false
  }
}

# Test 3: FAIL - Missing storage_encrypted defaults to false
resource "aws_neptune_cluster_snapshot" "fail_snapshot_missing_encryption" {
  expect_failure = true
  attrs = {
    db_cluster_snapshot_identifier = "neptune-snapshot-missing-encryption"
  }
}

