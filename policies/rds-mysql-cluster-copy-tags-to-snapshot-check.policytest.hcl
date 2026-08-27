# Copyright IBM Corp. 2026

policytest {
    targets = [
        "rds-mysql-cluster-copy-tags-to-snapshot-check.policy.hcl"
    ]
}

# Test 1: PASS - Aurora MySQL cluster with copy_tags_to_snapshot = true
resource "aws_rds_cluster" "compliant" {
  attrs = {
    engine                  = "aurora-mysql"
    engine_version          = "5.7.mysql_aurora.2.10.1"
    cluster_identifier      = "compliant-aurora-cluster"
    copy_tags_to_snapshot   = true
    database_name           = "mydb"
    master_username         = "admin"
  }
}

# Test 2: FAIL - Aurora MySQL cluster with copy_tags_to_snapshot = false
resource "aws_rds_cluster" "non_compliant" {
  expect_failure = true
  attrs = {
    engine                  = "aurora-mysql"
    engine_version          = "5.7.mysql_aurora.2.10.1"
    cluster_identifier      = "non-compliant-aurora-cluster"
    copy_tags_to_snapshot   = false
    database_name           = "mydb"
    master_username         = "admin"
  }
}

# Test 3: FAIL - Aurora MySQL cluster without copy_tags_to_snapshot (defaults to false)
resource "aws_rds_cluster" "missing_attribute" {
  expect_failure = true
  attrs = {
    engine                  = "aurora-mysql"
    engine_version          = "8.0.mysql_aurora.3.02.0"
    cluster_identifier      = "missing-attribute-cluster"
    database_name           = "mydb"
    master_username         = "admin"
  }
}

# Test 4: Pass (filtered out) - Aurora PostgreSQL cluster (non-MySQL engine)
resource "aws_rds_cluster" "postgres" {
  attrs = {
    engine                  = "aurora-postgresql"
    engine_version          = "13.7"
    cluster_identifier      = "postgres-cluster"
    copy_tags_to_snapshot   = false
    database_name           = "mydb"
    master_username         = "admin"
  }
}
