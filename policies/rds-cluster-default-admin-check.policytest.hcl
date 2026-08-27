# Copyright IBM Corp. 2026

policytest {
    targets = [
        "rds-cluster-default-admin-check.policy.hcl"
    ]
}

# Test 1: PASS - Custom administrator username
resource "aws_rds_cluster" "pass_custom_username" {
    attrs = {
        cluster_identifier      = "aurora-cluster-custom"
        engine                  = "aurora-mysql"
        engine_version          = "5.7.mysql_aurora.2.11.2"
        master_username         = "dbadmin"
        master_password         = "password123"
    }
}

# Test 2: PASS - Another custom administrator username
resource "aws_rds_cluster" "pass_custom_username_2" {
    attrs = {
        cluster_identifier      = "aurora-cluster-custom-2"
        engine                  = "aurora-postgresql"
        engine_version          = "14.6"
        master_username         = "mydbuser"
        master_password         = "password123"
    }
}

# Test 3: FAIL - Default username "postgres"
resource "aws_rds_cluster" "fail_default_postgres" {
    expect_failure = true
    attrs = {
        cluster_identifier      = "aurora-cluster-postgres"
        engine                  = "aurora-postgresql"
        engine_version          = "14.6"
        master_username         = "postgres"
        master_password         = "password123"
    }
}

# Test 4: FAIL - Default username "admin"
resource "aws_rds_cluster" "fail_default_admin" {
    expect_failure = true
    attrs = {
        cluster_identifier      = "aurora-cluster-admin"
        engine                  = "aurora-mysql"
        engine_version          = "5.7.mysql_aurora.2.11.2"
        master_username         = "admin"
        master_password         = "password123"
    }
}

# Test 5: FAIL - Missing master_username
resource "aws_rds_cluster" "fail_missing_username" {
    expect_failure = true
    attrs = {
        cluster_identifier      = "aurora-cluster-missing"
        engine                  = "aurora-mysql"
        engine_version          = "5.7.mysql_aurora.2.11.2"
        master_password         = "password123"
    }
}
