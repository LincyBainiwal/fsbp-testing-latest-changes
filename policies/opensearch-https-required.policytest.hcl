# Copyright IBM Corp. 2026

policytest {
    targets = [
        "opensearch-https-required.policy.hcl"
    ]
}

# Test 1: PASS - Compliant domain with HTTPS enforced and latest TLS policy
resource "aws_opensearch_domain" "compliant" {
  attrs = {
    domain_name = "compliant-domain"
    engine_version = "OpenSearch_2.5"
    domain_endpoint_options = [
      {
        enforce_https = true
        tls_security_policy = "Policy-Min-TLS-1-2-PFS-2023-10"
      }
    ]
  }
}

# Test 2: PASS - Compliant domain with HTTPS missing (defaults to true) and latest TLS policy
resource "aws_opensearch_domain" "compliant" {
  attrs = {
    domain_name = "compliant-domain"
    engine_version = "OpenSearch_2.5"
    domain_endpoint_options = [
      {
        tls_security_policy = "Policy-Min-TLS-1-2-PFS-2023-10"
      }
    ]
  }
}

# Test 3: FAIL - Missing domain_endpoint_options block
resource "aws_opensearch_domain" "no_endpoint_options" {
  expect_failure = true
  attrs = {
    domain_name = "no-endpoint-options"
    engine_version = "OpenSearch_2.5"
  }
}

# Test 4: FAIL - HTTPS not enforced
resource "aws_opensearch_domain" "no_https" {
  expect_failure = true
  attrs = {
    domain_name = "no-https-domain"
    engine_version = "OpenSearch_2.5"
    domain_endpoint_options = [
      {
        enforce_https = false
        tls_security_policy = "Policy-Min-TLS-1-2-PFS-2023-10"
      }
    ]
  }
}

# Test 5: FAIL - Using older TLS security policy
resource "aws_opensearch_domain" "old_tls" {
  expect_failure = true
  attrs = {
    domain_name = "old-tls-domain"
    engine_version = "OpenSearch_2.5"
    domain_endpoint_options = [
      {
        enforce_https = true
        tls_security_policy = "Policy-Min-TLS-1-0-2019-07"
      }
    ]
  }
}

# Test 6: FAIL - Missing tls_security_policy attribute
resource "aws_opensearch_domain" "no_tls_policy" {
  expect_failure = true
  attrs = {
    domain_name = "no-tls-policy-domain"
    engine_version = "OpenSearch_2.5"
    domain_endpoint_options = [
      {
        enforce_https = true
      }
    ]
  }
}
