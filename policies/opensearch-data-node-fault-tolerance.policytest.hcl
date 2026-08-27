# Copyright IBM Corp. 2026

policytest {
    targets = [
        "opensearch-data-node-fault-tolerance.policy.hcl"
    ]
}

# Test 1: PASS - 3 data nodes with zone awareness enabled
resource "aws_opensearch_domain" "pass_minimum_nodes_with_zone_awareness" {
  attrs = {
    domain_name = "compliant-domain"
    cluster_config = [
      {
        instance_count = 3
        zone_awareness_enabled = true
        instance_type = "t3.small.search"
      }
    ]
  }
}

# Test 2: PASS - 5 data nodes with zone awareness enabled
resource "aws_opensearch_domain" "pass_more_than_minimum_nodes" {
  attrs = {
    domain_name = "compliant-large-domain"
    cluster_config = [
      {
        instance_count = 5
        zone_awareness_enabled = true
        instance_type = "t3.medium.search"
      }
    ]
  }
}

# Test 3: FAIL - Only 2 data nodes (insufficient)
resource "aws_opensearch_domain" "fail_insufficient_nodes_two" {
  expect_failure = true
  attrs = {
    domain_name = "insufficient-nodes-domain"
    cluster_config = [
      {
        instance_count = 2
        zone_awareness_enabled = true
        instance_type = "t3.small.search"
      }
    ]
  }
}

# Test 4: FAIL - Only 1 data node (insufficient)
resource "aws_opensearch_domain" "fail_insufficient_nodes_one" {
  expect_failure = true
  attrs = {
    domain_name = "single-node-domain"
    cluster_config = [
      {
        instance_count = 1
        zone_awareness_enabled = true
        instance_type = "t3.small.search"
      }
    ]
  }
}

# Test 5: FAIL - 3 nodes but zone awareness disabled
resource "aws_opensearch_domain" "fail_zone_awareness_disabled" {
  expect_failure = true
  attrs = {
    domain_name = "no-zone-awareness-domain"
    cluster_config = [
      {
        instance_count = 3
        zone_awareness_enabled = false
        instance_type = "t3.small.search"
      }
    ]
  }
}

# Test 6: FAIL - 5 nodes but zone awareness disabled
resource "aws_opensearch_domain" "fail_many_nodes_no_zone_awareness" {
  expect_failure = true
  attrs = {
    domain_name = "many-nodes-no-za-domain"
    cluster_config = [
      {
        instance_count = 5
        zone_awareness_enabled = false
        instance_type = "t3.medium.search"
      }
    ]
  }
}

# Test 7: FAIL - Both conditions not met (2 nodes, no zone awareness)
resource "aws_opensearch_domain" "fail_both_conditions_not_met" {
  expect_failure = true
  attrs = {
    domain_name = "non-compliant-domain"
    cluster_config = [
      {
        instance_count = 2
        zone_awareness_enabled = false
        instance_type = "t3.small.search"
      }
    ]
  }
}

# Test 8: FAIL - instance_count not specified (defaults to 1)
resource "aws_opensearch_domain" "fail_default_instance_count" {
  expect_failure = true
  attrs = {
    domain_name = "default-count-domain"
    cluster_config = [
      {
        zone_awareness_enabled = true
        instance_type = "t3.small.search"
      }
    ]
  }
}

# Test 9: FAIL - zone_awareness_enabled not specified (defaults to false)
resource "aws_opensearch_domain" "fail_default_zone_awareness" {
  expect_failure = true
  attrs = {
    domain_name = "default-za-domain"
    cluster_config = [
      {
        instance_count = 3
        instance_type = "t3.small.search"
      }
    ]
  }
}

# Test 10: FAIL - No cluster_config attribute (defaults: instance_count=1, zone_awareness_enabled=false)
resource "aws_opensearch_domain" "fail_no_cluster_config" {
  expect_failure = true
  attrs = {
    domain_name = "no-cluster-config-domain"
  }
}

# Test 11: FAIL - Empty cluster_config list
resource "aws_opensearch_domain" "fail_empty_cluster_config" {
  expect_failure = true
  attrs = {
    domain_name = "empty-cluster-config-domain"
    cluster_config = [{}]
  }
}
