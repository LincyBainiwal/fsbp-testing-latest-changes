# Copyright IBM Corp. 2026

policytest {
    targets = [
        "rds-snapshots-public-prohibited.policy.hcl"
    ]
}

# Test 1: PASS - aws_db_snapshot with no shared_accounts (private by default)
resource "aws_db_snapshot" "private_snapshot" {
  attrs = {
    db_instance_identifier = "mydb"
    db_snapshot_identifier = "mydb-snapshot-001"
  }
}

# Test 2: PASS - aws_db_snapshot with specific account IDs
resource "aws_db_snapshot" "shared_snapshot" {
  attrs = {
    db_instance_identifier = "mydb"
    db_snapshot_identifier = "mydb-snapshot-002"
    shared_accounts = ["123456789012", "987654321098"]
  }
}

# Test 3: FAIL - aws_db_snapshot with 'all' in shared_accounts
resource "aws_db_snapshot" "public_snapshot" {
  expect_failure = true
  attrs = {
    db_instance_identifier = "mydb"
    db_snapshot_identifier = "mydb-snapshot-003"
    shared_accounts = ["all"]
  }
}

# Test 4: PASS - aws_db_cluster_snapshot with no shared_accounts
resource "aws_db_cluster_snapshot" "private_cluster_snapshot" {
  attrs = {
    db_cluster_identifier = "mycluster"
    db_cluster_snapshot_identifier = "mycluster-snapshot-001"
  }
}

# Test 5: PASS - aws_db_cluster_snapshot with specific account IDs
resource "aws_db_cluster_snapshot" "shared_cluster_snapshot" {
  attrs = {
    db_cluster_identifier = "mycluster"
    db_cluster_snapshot_identifier = "mycluster-snapshot-002"
    shared_accounts = ["123456789012"]
  }
}

# Test 6: FAIL - aws_db_cluster_snapshot with 'all' in shared_accounts
resource "aws_db_cluster_snapshot" "public_cluster_snapshot" {
  expect_failure = true
  attrs = {
    db_cluster_identifier = "mycluster"
    db_cluster_snapshot_identifier = "mycluster-snapshot-003"
    shared_accounts = ["all"]
  }
}

# Test 7: FAIL - aws_db_snapshot with 'all' mixed with other accounts
resource "aws_db_snapshot" "mixed_public_snapshot" {
  expect_failure = true
  attrs = {
    db_instance_identifier = "mydb"
    db_snapshot_identifier = "mydb-snapshot-004"
    shared_accounts = ["123456789012", "all", "987654321098"]
  }
}
