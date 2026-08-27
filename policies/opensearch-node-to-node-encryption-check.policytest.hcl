# Copyright IBM Corp. 2026

policytest {
    targets = [
        "opensearch-node-to-node-encryption-check.policy.hcl"
    ]
}

# Test 1: PASS - Node-to-node encryption is enabled
resource "aws_opensearch_domain" "node_encryption_enabled" {
    attrs = {
        domain_name    = "ggkitty"
        engine_version = "Elasticsearch_7.1"
        node_to_node_encryption = [{
            enabled = true
        }]
    }
}

# Test 2: FAIL - Node-to-node encryption is disabled
resource "aws_opensearch_domain" "node_encryption_disabled" {
    expect_failure = true
    attrs = {
        domain_name    = "ggkitty"
        engine_version = "Elasticsearch_7.1"
        node_to_node_encryption = [{
            enabled = false
        }]
    }
}

# Test 3: FAIL - No node-to-node encryption configuration
resource "aws_opensearch_domain" "node_encryption_missing" {
    expect_failure = true
    attrs = {
        domain_name    = "ggkitty"
        engine_version = "Elasticsearch_7.1"
    }
}

# Test 4: SKIP - Invalid engine version
resource "aws_opensearch_domain" "node_encryption_invalid_version" {
    attrs = {
        domain_name    = "ggkitty"
        engine_version = "Elasticsearch_5.0"
        node_to_node_encryption = [{
            enabled = false
        }]
    }
}

# Test 5: FAIL - OpenSearch with node-to-node encryption disabled
resource "aws_opensearch_domain" "node_encryption_opensearch_disabled" {
    expect_failure = true
    attrs = {
        domain_name    = "ggkitty"
        engine_version = "OpenSearch_2.3"
        node_to_node_encryption = [{
            enabled = false
        }]
    }
}

# Test 6: PASS - OpenSearch with node-to-node encryption enabled
resource "aws_opensearch_domain" "node_encryption_opensearch_enabled" {
    attrs = {
        domain_name    = "ggkitty"
        engine_version = "OpenSearch_1.0"
        node_to_node_encryption = [{
            enabled = true
        }]
    }
}
