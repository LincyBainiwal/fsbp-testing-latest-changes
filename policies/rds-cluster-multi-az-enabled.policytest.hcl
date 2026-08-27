# Copyright IBM Corp. 2026

policytest {
    targets = [
        "rds-cluster-multi-az-enabled.policy.hcl"
    ]
}

# Test 1: PASS - Aurora cluster with 2 AZs (minimum requirement)
resource "aws_rds_cluster" "aurora_cluster_with_2_azs_passes" {
  attrs = {
    availability_zones = ["us-east-1a", "us-east-1b"]
    engine = "aurora-mysql"
    cluster_identifier = "aurora-cluster-1"
  }
}

# Test 2: PASS - Aurora cluster with 3 AZs
resource "aws_rds_cluster" "aurora_cluster_with_3_azs_passes" {
  attrs = {
    availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
    engine = "aurora-postgresql"
    cluster_identifier = "aurora-cluster-2"
  }
}

# Test 3: PASS - Multi-AZ DB cluster with 3 AZs (exact requirement)
resource "aws_rds_cluster" "multi_az_cluster_with_3_azs_passes" {
  attrs = {
    availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
    engine = "mysql"
    db_cluster_instance_class = "db.r6gd.xlarge"
    cluster_identifier = "multi-az-cluster-1"
  }
}

# Test 4: FAIL - Aurora cluster with only 1 AZ
resource "aws_rds_cluster" "aurora_cluster_with_1_az_fails" {
  expect_failure = true
  attrs = {
    availability_zones = ["us-east-1a"]
    engine = "aurora-mysql"
    cluster_identifier = "aurora-single-az"
  }
}

# Test 5: FAIL - Aurora cluster with empty availability_zones
resource "aws_rds_cluster" "aurora_cluster_with_empty_azs_fails" {
  expect_failure = true
  attrs = {
    availability_zones = []
    engine = "aurora-postgresql"
    cluster_identifier = "aurora-no-azs"
  }
}

# Test 6: FAIL - Multi-AZ DB cluster with only 2 AZs
resource "aws_rds_cluster" "multi_az_cluster_with_2_azs_fails" {
  expect_failure = true
  attrs = {
    availability_zones = ["us-west-2a", "us-west-2b"]
    engine = "postgres"
    db_cluster_instance_class = "db.r6gd.xlarge"
    cluster_identifier = "multi-az-insufficient"
  }
}

# Test 7: FAIL - RDS cluster without availability_zones attribute (defaults to empty list via core::try)
resource "aws_rds_cluster" "cluster_without_azs_attribute_fails" {
  expect_failure = true
  attrs = {
    engine = "aurora-mysql"
    cluster_identifier = "no-azs-attr"
  }
}
