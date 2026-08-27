# Copyright IBM Corp. 2026

policytest {
    targets = [
        "opensearch-in-vpc-only.policy.hcl"
    ]
}

# Test 1: PASS - Domain with VPC options and subnet IDs configured
resource "aws_opensearch_domain" "pass_domain_with_vpc_and_subnets" {
  attrs = {
    domain_name = "compliant-domain"
    engine_version = "OpenSearch_2.5"
    vpc_options = [
      {
        subnet_ids = ["subnet-12345678", "subnet-87654321"]
        security_group_ids = ["sg-12345678"]
      }
    ]
  }
}

# Test 2: PASS - Domain with VPC options and multiple subnets
resource "aws_opensearch_domain" "pass_domain_with_multiple_subnets" {
  attrs = {
    domain_name = "multi-subnet-domain"
    engine_version = "OpenSearch_2.7"
    vpc_options = [
      {
        subnet_ids = ["subnet-1", "subnet-2", "subnet-3"]
        security_group_ids = ["sg-1", "sg-2"]
      }
    ]
  }
}

# Test 3: FAIL - Domain without VPC options (public endpoint)
resource "aws_opensearch_domain" "fail_domain_without_vpc_options" {
  expect_failure = true
  attrs = {
    domain_name = "public-domain"
    engine_version = "OpenSearch_2.5"
    cluster_config = [
      {
        instance_type = "t3.small.search"
        instance_count = 1
      }
    ]
  }
}

# Test 4: FAIL - Domain with VPC options but empty subnet_ids
resource "aws_opensearch_domain" "fail_domain_with_empty_subnet_ids" {
  expect_failure = true
  attrs = {
    domain_name = "empty-subnets-domain"
    engine_version = "OpenSearch_2.5"
    vpc_options = [
      {
        subnet_ids = []
        security_group_ids = ["sg-12345678"]
      }
    ]
  }
}

# Test 5: FAIL - Domain with vpc_options set to null
resource "aws_opensearch_domain" "fail_domain_with_null_vpc_options" {
  expect_failure = true
  attrs = {
    domain_name = "null-vpc-domain"
    engine_version = "OpenSearch_2.5"
    vpc_options = null
  }
}
