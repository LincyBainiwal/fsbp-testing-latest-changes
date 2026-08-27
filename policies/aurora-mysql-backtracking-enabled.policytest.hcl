# Copyright IBM Corp. 2026

policytest {
    targets = [
        "aurora-mysql-backtracking-enabled.policy.hcl"
    ]
}

# Test 1: PASS - Aurora MySQL with backtracking enabled (24 hours)
resource "aws_rds_cluster" "pass_backtracking_24h" {
    attrs = {
        cluster_identifier      = "aurora-cluster-demo"
        engine                  = "aurora-mysql"
        engine_version          = "5.7.mysql_aurora.2.11.2"
        master_username         = "admin"
        master_password         = "password123"
        backtrack_window        = 86400
    }
}

# Test 2: PASS - Aurora MySQL with backtracking enabled (72 hours - maximum)
resource "aws_rds_cluster" "pass_backtracking_72h" {
    attrs = {
        cluster_identifier      = "aurora-cluster-max"
        engine                  = "aurora-mysql"
        engine_version          = "5.7.mysql_aurora.2.11.2"
        master_username         = "admin"
        master_password         = "password123"
        backtrack_window        = 259200
    }
}

# Test 3: FAIL - Aurora MySQL with backtracking disabled (0)
resource "aws_rds_cluster" "fail_backtracking_disabled" {
    expect_failure = true
    attrs = {
        cluster_identifier      = "aurora-cluster-no-backtrack"
        engine                  = "aurora-mysql"
        engine_version          = "5.7.mysql_aurora.2.11.2"
        master_username         = "admin"
        master_password         = "password123"
        backtrack_window        = 0
    }
}

# Test 4: FAIL - Aurora MySQL without backtracking window (defaults to 0)
resource "aws_rds_cluster" "fail_backtracking_missing" {
    expect_failure = true
    attrs = {
        cluster_identifier      = "aurora-cluster-missing"
        engine                  = "aurora-mysql"
        engine_version          = "5.7.mysql_aurora.2.11.2"
        master_username         = "admin"
        master_password         = "password123"
    }
}

# Test 5: FAIL - Aurora MySQL with backtracking window exceeding maximum
resource "aws_rds_cluster" "fail_backtracking_exceeds_max" {
    expect_failure = true
    attrs = {
        cluster_identifier      = "aurora-cluster-exceed"
        engine                  = "aurora-mysql"
        engine_version          = "5.7.mysql_aurora.2.11.2"
        master_username         = "admin"
        master_password         = "password123"
        backtrack_window        = 259201
    }
}

# Test 6: SKIP - Aurora PostgreSQL (filter excludes non-aurora-mysql)
resource "aws_rds_cluster" "skip_aurora_postgresql" {
    attrs = {
        cluster_identifier      = "aurora-postgres-cluster"
        engine                  = "aurora-postgresql"
        engine_version          = "14.6"
        master_username         = "admin"
        master_password         = "password123"
    }
}
