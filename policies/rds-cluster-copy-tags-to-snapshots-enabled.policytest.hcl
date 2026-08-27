# Copyright IBM Corp. 2026

policytest {
    targets = [
        "rds-cluster-copy-tags-to-snapshots-enabled.policy.hcl"
    ]
}

# Test 1: PASS - copy_tags_to_snapshot is true
resource "aws_rds_cluster" "pass_copy_tags_to_snapshot" {
    attrs = {
        cluster_identifier      = "aurora-cluster-demo"
        engine                  = "aurora-postgresql"
        availability_zones      = ["us-west-2a", "us-west-2b", "us-west-2c"]
        database_name           = "mydb"
        master_username         = "foo"
        copy_tags_to_snapshot = true
    }
}

# Test 2: FAIL - copy_tags_to_snapshot is false
resource "aws_rds_cluster" "fail_copy_tags_to_sanpshot" {
    expect_failure = true
    attrs = {
        cluster_identifier      = "aurora-cluster-demo"
        engine                  = "aurora-postgresql"
        availability_zones      = ["us-west-2a", "us-west-2b", "us-west-2c"]
        database_name           = "mydb"
        master_username         = "foo"
        copy_tags_to_snapshot = false
    }
}

# Test 3: PASS - copy_tags_to_snapshot is missing (defaults to false)
resource "aws_rds_cluster" "fail_missing_copy_tags_to_snapshot" {
    expect_failure = true
    attrs = {
        cluster_identifier      = "aurora-cluster-demo"
        engine                  = "aurora-postgresql"
        availability_zones      = ["us-west-2a", "us-west-2b", "us-west-2c"]
        database_name           = "mydb"
        master_username         = "foo"
    }
}
