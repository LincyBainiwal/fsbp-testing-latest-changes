# Copyright IBM Corp. 2026

policytest {
    targets = [
        "opensearch-update-check.policy.hcl"
    ]
}

# Test 1: PASS - OpenSearch auto_updates are enabled
resource "aws_opensearch_domain" "auto_updates_enabled" {
  attrs = {
    domain_name = "compliant-domain"
    software_update_options = [{
      auto_software_update_enabled = true
    }]
  }
}

# Test 2: FAIL - OpenSearch auto_updates are disabled
resource "aws_opensearch_domain" "auto_updates_disabled" {
  expect_failure = true
  attrs = {
    domain_name = "noncompliant-domain-disabled"
    software_update_options = [{
      auto_software_update_enabled = false
    }]
  }
}

# Test 3: FAIL - OpenSearch auto_updates are missing (defaults to false)
resource "aws_opensearch_domain" "auto_updates_disabled" {
  expect_failure = true
  attrs = {
    domain_name = "noncompliant-domain-disabled"
    software_update_options = []
  }
}

# Test 4: FAIL - Missing software_update_options block
resource "aws_opensearch_domain" "auto_updates_not_configured" {
  expect_failure = true
  attrs = {
    domain_name = "noncompliant-domain-missing"
  }
}
