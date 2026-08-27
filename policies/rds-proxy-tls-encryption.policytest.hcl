# Copyright IBM Corp. 2026

policytest {
    targets = [
        "rds-proxy-tls-encryption.policy.hcl"
    ]
}

# Test 1: PASS - TLS encryption is enabled
resource "aws_db_proxy" "tls_required" {
  attrs = {
    name           = "secure-proxy"
    engine_family  = "POSTGRESQL"
    require_tls    = true
    role_arn       = "arn:aws:iam::123456789012:role/rds-proxy-role"
    vpc_subnet_ids = ["subnet-12345678", "subnet-87654321"]
  }
}

# Test 2: FAIL - TLS encryption is disabled
resource "aws_db_proxy" "tls_not_required" {
  expect_failure = true
  attrs = {
    name           = "insecure-proxy"
    engine_family  = "MYSQL"
    require_tls    = false
    role_arn       = "arn:aws:iam::123456789012:role/rds-proxy-role"
    vpc_subnet_ids = ["subnet-11111111", "subnet-22222222"]
  }
}

# Test 3: FAIL - Missing require_tls attribute (defaults to false)
resource "aws_db_proxy" "tls_missing" {
  expect_failure = true
  attrs = {
    name           = "default-proxy"
    engine_family  = "SQLSERVER"
    role_arn       = "arn:aws:iam::123456789012:role/rds-proxy-role"
    vpc_subnet_ids = ["subnet-33333333", "subnet-44444444"]
  }
}
