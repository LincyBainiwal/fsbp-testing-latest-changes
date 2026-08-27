# Copyright IBM Corp. 2026

policytest {
    targets = [
        "redshift-enhanced-vpc-routing-enabled.policy.hcl"
    ]
}

# Test 1: Pass - Redshift cluster with enhanced_vpc_routing = true
resource "aws_redshift_cluster" "pass_explicit_true" {
  attrs = {
    cluster_identifier = "compliant-cluster"
    node_type = "dc2.large"
    enhanced_vpc_routing = true
    vpc_security_group_ids = ["sg-12345678"]
    cluster_subnet_group_name = "my-subnet-group"
    master_username = "admin"
    database_name = "mydb"
  }
}

# Test 2: Fail - Redshift cluster with enhanced_vpc_routing = false
resource "aws_redshift_cluster" "fail_explicit_false" {
  expect_failure = true
  attrs = {
    cluster_identifier = "non-compliant-cluster"
    node_type = "dc2.large"
    enhanced_vpc_routing = false
    vpc_security_group_ids = ["sg-12345678"]
    cluster_subnet_group_name = "my-subnet-group"
    master_username = "admin"
    database_name = "mydb"
  }
}

# Test 3: Fail - Redshift cluster without enhanced_vpc_routing attribute (defaults to false)
resource "aws_redshift_cluster" "fail_default_false" {
  expect_failure = true
  attrs = {
    cluster_identifier = "missing-attribute-cluster"
    node_type = "dc2.large"
    vpc_security_group_ids = ["sg-12345678"]
    cluster_subnet_group_name = "my-subnet-group"
    master_username = "admin"
    database_name = "mydb"
  }
}