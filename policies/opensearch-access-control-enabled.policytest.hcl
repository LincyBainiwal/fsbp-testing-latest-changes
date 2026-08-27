# Copyright IBM Corp. 2026

policytest {
    targets = [
        "opensearch-access-control-enabled.policy.hcl"
    ]
}

# Test 1: PASS - Domain with FGAC enabled
resource "aws_opensearch_domain" "pass_fgac_enabled" {
  attrs = {
    domain_name = "compliant-domain"
    engine_version = "OpenSearch_2.5"
    advanced_security_options = [
      {
        enabled = true
        internal_user_database_enabled = true
        master_user_options = [
          {
            master_user_name = "admin"
            master_user_password = "ComplexPassword123!"
          }
        ]
      }
    ]
  }
}

# Test 2: FAIL - Domain with FGAC explicitly disabled
resource "aws_opensearch_domain" "fail_fgac_disabled" {
  expect_failure = true
  attrs = {
    domain_name = "non-compliant-domain"
    engine_version = "OpenSearch_2.5"
    advanced_security_options = [
      {
        enabled = false
      }
    ]
  }
}

# Test 3: FAIL - Domain without advanced_security_options block
resource "aws_opensearch_domain" "fail_no_advanced_security_options" {
  expect_failure = true
  attrs = {
    domain_name = "missing-config-domain"
    engine_version = "OpenSearch_2.5"
  }
}

# Test 4: FAIL - Domain with advanced_security_options but enabled not set (defaults to false)
resource "aws_opensearch_domain" "fail_enabled_not_set" {
  expect_failure = true
  attrs = {
    domain_name = "enabled-not-set-domain"
    engine_version = "OpenSearch_2.5"
    advanced_security_options = [
      {
        internal_user_database_enabled = true
      }
    ]
  }
}

# Test 5: PASS - Domain with FGAC enabled and additional security settings
resource "aws_opensearch_domain" "pass_fgac_with_additional_security" {
  attrs = {
    domain_name = "fully-secured-domain"
    engine_version = "OpenSearch_2.5"
    advanced_security_options = [
      {
        enabled = true
        internal_user_database_enabled = true
        master_user_options = [
          {
            master_user_arn = "arn:aws:iam::123456789012:role/OpensearchMasterRole"
          }
        ]
      }
    ]
    domain_endpoint_options = [
      {
        enforce_https = true
      }
    ]
    node_to_node_encryption = [
      {
        enabled = true
      }
    ]
    encrypt_at_rest = [
      {
        enabled = true
      }
    ]
  }
}
