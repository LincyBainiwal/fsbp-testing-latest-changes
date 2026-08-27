# Copyright IBM Corp. 2026

policytest {
    targets = [
        "redshift-cluster-public-access-check.policy.hcl"
    ]
}

# Test 1: PASS - Cluster with publicly_accessible explicitly set to false
resource "aws_redshift_cluster" "pass_explicit_false" {
  attrs = {
    cluster_identifier = "my-private-cluster"
    node_type = "dc2.large"
    publicly_accessible = false
    master_username = "admin"
    database_name = "mydb"
  }
}

# Test 2: PASS - Cluster without publicly_accessible attribute (defaults to false)
resource "aws_redshift_cluster" "pass_default_false" {
  attrs = {
    cluster_identifier = "my-default-cluster"
    node_type = "dc2.large"
    master_username = "admin"
    database_name = "mydb"
  }
}

# Test 3: FAIL - Cluster with publicly_accessible set to true
resource "aws_redshift_cluster" "fail_public_access_enabled" {
  expect_failure = true
  attrs = {
    cluster_identifier = "my-public-cluster"
    node_type = "dc2.large"
    publicly_accessible = true
    master_username = "admin"
    database_name = "mydb"
  }
}