# Copyright IBM Corp. 2026

policytest {
    targets = [
        "opensearch-encrypted-at-rest.policy.hcl"
    ]
}

# Test 1: PASS - Encryption at rest enabled
resource "aws_opensearch_domain" "pass_encrypted" {
    attrs = {
        domain_name    = "ggkitty"
        engine_version = "Elasticsearch_7.1"
        encrypt_at_rest = [{
            enabled = true
        }]
    }
}

# Test 2: FAIL - Encryption at rest disabled
resource "aws_opensearch_domain" "fail_not_encrypted" {
    expect_failure = true
    attrs = {
        domain_name    = "ggkitty"
        engine_version = "Elasticsearch_7.1"
        encrypt_at_rest = [{
            enabled = false
        }]
    }
}

# Test 3: FAIL - No encryption at rest configuration
resource "aws_opensearch_domain" "fail_no_config" {
    expect_failure = true
    attrs = {
        domain_name    = "ggkitty"
        engine_version = "Elasticsearch_7.1"
    }
}

# Test 4: SKIP - Invalid engine version
resource "aws_opensearch_domain" "fail_invalid_version" {
    attrs = {
        domain_name    = "ggkitty"
        engine_version = "Elasticsearch_4.0"
        encrypt_at_rest = [{
            enabled = true
        }]
    }
}

# Test 5: FAIL - OpenSearch with encryption at rest disabled
resource "aws_opensearch_domain" "fail_opensearch_not_encrypted" {
    expect_failure = true
    attrs = {
        domain_name    = "ggkitty"
        engine_version = "OpenSearch_2.3"
        encrypt_at_rest = [{
            enabled = false
        }]
    }
}

# Test 6: PASS - OpenSearch with encryption at rest enabled
resource "aws_opensearch_domain" "pass_opensearch_encrypted" {
    attrs = {
        domain_name    = "ggkitty"
        engine_version = "OpenSearch_1.0"
        encrypt_at_rest = [{
            enabled = true
        }]
    }
}
