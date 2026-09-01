# Copyright IBM Corp. 2026

policytest {
    targets = [
        "elasticache-subnet-group-check.policy.hcl"
    ]
}

# Test 1: PASS - ElastiCache cluster with custom subnet group
resource "aws_elasticache_cluster" "pass_custom_subnet_group" {
  attrs = {
    cluster_id           = "my-redis-cluster"
    engine               = "redis"
    node_type            = "cache.t3.micro"
    num_cache_nodes      = 1
    parameter_group_name = "default.redis7"
    subnet_group_name    = "custom-subnet-group"
    port                 = 6379
  }
}

# Test 2: FAIL - ElastiCache cluster with explicit default subnet group
resource "aws_elasticache_cluster" "fail_explicit_default" {
  expect_failure = true
  attrs = {
    cluster_id           = "my-redis-cluster"
    engine               = "redis"
    node_type            = "cache.t3.micro"
    num_cache_nodes      = 1
    parameter_group_name = "default.redis7"
    subnet_group_name    = "default"
    port                 = 6379
  }
}

# Test 3: FAIL - ElastiCache cluster without subnet_group_name (implicit default)
resource "aws_elasticache_cluster" "fail_missing_subnet_group" {
  expect_failure = true
  attrs = {
    cluster_id           = "my-memcached-cluster"
    engine               = "memcached"
    node_type            = "cache.t3.micro"
    num_cache_nodes      = 2
    parameter_group_name = "default.memcached1.6"
    port                 = 11211
  }
}

# Test 4: PASS - ElastiCache cluster with custom subnet group
resource "aws_elasticache_subnet_group" "pass_custom_sg" {
  attrs = {
    name    = "custom-subnet-group"
  }
}

# Test 5: FAIL - ElastiCache cluster with explicit default subnet group
resource "aws_elasticache_cluster" "fail_explicit_default_sg" {
  expect_failure = true
  attrs = {
    name    = "default"
  }
}

# Test 6: FAIL - ElastiCache cluster without subnet_group_name (implicit default)
resource "aws_elasticache_cluster" "fail_missing_sg" {
  expect_failure = true
  attrs = {
    cluster_id = "my-memcached-cluster"
  }
}

# Test 7: PASS - ElastiCache replication group with a custom subnet group
resource "aws_elasticache_replication_group" "pass_rg_custom_subnet" {
  attrs = {
    replication_group_id = "my-rg-compliant"
    description          = "compliant replication group"
    subnet_group_name    = "custom-subnet-group"
  }
}

# Test 8: FAIL - ElastiCache replication group with explicit default subnet group
resource "aws_elasticache_replication_group" "fail_rg_explicit_default" {
  expect_failure = true
  attrs = {
    replication_group_id = "my-rg-default"
    description          = "non-compliant replication group"
    subnet_group_name    = "default"
  }
}

# Test 9: FAIL - ElastiCache replication group with no subnet_group_name (implicit default)
resource "aws_elasticache_replication_group" "fail_rg_missing_subnet" {
  expect_failure = true
  attrs = {
    replication_group_id = "my-rg-no-subnet"
    description          = "replication group without subnet group"
  }
}
