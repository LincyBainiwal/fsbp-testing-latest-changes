# Copyright IBM Corp. 2026

policytest {
    targets = [
        "rds-pgsql-cluster-copy-tags-to-snapshot-check.policy.hcl"
    ]
}

# Test 1: PASS - Aurora PostgreSQL cluster with copy_tags_to_snapshot enabled
resource "aws_rds_cluster" "pass_aurora_postgres_copy_tags_enabled" {
  attrs = {
    engine = "aurora-postgresql"
    cluster_identifier = "compliant-aurora-cluster"
    copy_tags_to_snapshot = true
    master_username = "admin"
    tags = {
      Environment = "staging"
    }
  }
}

# Test 2: FAIL - Aurora PostgreSQL cluster with copy_tags_to_snapshot disabled
resource "aws_rds_cluster" "fail_aurora_postgres_copy_tags_disabled" {
  expect_failure = true
  attrs = {
    engine = "aurora-postgresql"
    cluster_identifier = "non-compliant-aurora-cluster"
    copy_tags_to_snapshot = false
    master_username = "admin"
  }
}

# Test 3: FAIL - Aurora PostgreSQL cluster without copy_tags_to_snapshot attribute (defaults to false)
resource "aws_rds_cluster" "fail_aurora_postgres_copy_tags_missing" {
  expect_failure = true
  attrs = {
    engine = "aurora-postgresql"
    cluster_identifier = "missing-attribute-cluster"
    master_username = "admin"
    database_name = "mydb"
  }
}

# Test 4: SKIP - MySQL cluster should not be evaluated (passes because filtered out)
resource "aws_rds_cluster" "filter_mysql_cluster" {
  attrs = {
    engine = "aurora-mysql"
    cluster_identifier = "mysql-cluster"
    copy_tags_to_snapshot = false
    master_username = "admin"
  }
}
