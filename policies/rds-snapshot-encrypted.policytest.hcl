# Copyright IBM Corp. 2026

policytest {
    targets = [
        "rds-snapshot-encrypted.policy.hcl"
    ]
}

# Test 1: PASS - Encrypted snapshot
resource "aws_db_snapshot" "pass_encrypted" {
    attrs = {
        db_snapshot_identifier = "testsnapshot1234"
        db_instance_identifier = "testdbinstance"
        encrypted = true
    }
}

# Test 2: FAIL - Unencrypted snapshot
resource "aws_db_snapshot" "fail_unencrypted" {
    expect_failure = true
    attrs = {
        db_snapshot_identifier = "testsnapshot1234"
        db_instance_identifier = "testdbinstance"
        encrypted = false
    }
}

# Test 3: FAIL - Snapshot with no encryption attribute
resource "aws_db_snapshot" "missing_unencrypted" {
    expect_failure = true
    attrs = {
        db_snapshot_identifier = "testsnapshot1234"
        db_instance_identifier = "testdbinstance"
    }
}

# Test 4: PASS - Cluster snapshot is encrypted
resource "aws_db_cluster_snapshot" "pass_cluster_encrypted" {
    attrs = {
        db_cluster_identifier = "testcluster1234"
        db_cluster_snapshot_identifier = "testclustersnapshot1234"
        storage_encrypted = true
    }
}

# Test 5: FAIL - Cluster snapshot is not encrypted
resource "aws_db_cluster_snapshot" "fail_cluster_unencrypted" {
    expect_failure = true
    attrs = {
        db_cluster_identifier = "testcluster1234"
        db_cluster_snapshot_identifier = "testclustersnapshot1234"
        storage_encrypted = false
    }
}

# Test 6: FAIL - Cluster snapshot with no encryption attribute
resource "aws_db_cluster_snapshot" "missing_cluster_unencrypted" {
    expect_failure = true
    attrs = {
        db_cluster_identifier = "testcluster1234"
        db_cluster_snapshot_identifier = "testclustersnapshot1234"
    }
}
