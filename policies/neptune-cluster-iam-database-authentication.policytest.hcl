# Copyright IBM Corp. 2026

policytest {
    targets = [
        "neptune-cluster-iam-database-authentication.policy.hcl"
    ]
}

# Test 1: PASS - IAM database authentication is enabled
resource "aws_neptune_cluster" "pass_iam_auth_enabled" {
    attrs = {
        iam_database_authentication_enabled = true
        engine = "neptune"
    }
}

# Test 2: FAIL - IAM database authentication is disabled
resource "aws_neptune_cluster" "fail_iam_auth_disabled" {
    expect_failure = true
    attrs = {
        iam_database_authentication_enabled = false
        engine = "neptune"
    }
}

# Test 3: FAIL - Missing enable_iam_database_authentication defaults to false
resource "aws_neptune_cluster" "fail_iam_auth_missing" {
    expect_failure = true
    attrs = {
        engine = "neptune"
    }
}
