# Copyright IBM Corp. 2026

policytest {
    targets = [
        "rds-cluster-deletion-protection-enabled.policy.hcl"
    ]
}

# Test 1: PASS - deletion_protection is true
resource "aws_rds_cluster" "pass_cluster_deletion_protection" {
    attrs = {
        cluster_identifier      = "aurora-cluster-demo"
        engine                  = "aurora-mysql"
        engine_version          = "5.7.mysql_aurora.2.03.2"
        database_name           = "mydb"
        master_username         = "foo"
        deletion_protection = true
    }
}

# Test 2: FAIL - deletion_protection is false
resource "aws_rds_cluster" "fail_cluster_deletion_protection" {
    expect_failure = true
    attrs = {
        cluster_identifier      = "aurora-cluster-demo"
        engine                  = "aurora-mysql"
        engine_version          = "5.7.mysql_aurora.2.03.2"
        database_name           = "mydb"
        master_username         = "foo"
        deletion_protection = false
    }
}

# Test 3: FAIL - deletion_protection is not present (default is false)
resource "aws_rds_cluster" "fail_cluster_deletion_protection_missing" {
    expect_failure = true
    attrs = {
        cluster_identifier      = "aurora-cluster-demo"
        engine                  = "aurora-mysql"
        engine_version          = "5.7.mysql_aurora.2.03.2"
        database_name           = "mydb"
        master_username         = "foo"
    }
}
