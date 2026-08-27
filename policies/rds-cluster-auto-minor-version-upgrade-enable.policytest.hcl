# Copyright IBM Corp. 2026

policytest {
    targets = [
        "rds-cluster-auto-minor-version-upgrade-enable.policy.hcl"
    ]
}

# Test 1: PASS - auto_minor_version_upgrade explicitly set to true
resource "aws_rds_cluster_instance" "pass_explicit_true" {
  attrs = {
    auto_minor_version_upgrade = true
    cluster_identifier = "test-cluster"
    instance_class = "db.r5.large"
    engine = "aurora-postgresql"
  }
}

# Test 2: PASS - auto_minor_version_upgrade not specified (defaults to true)
resource "aws_rds_cluster_instance" "pass_default_true" {
  attrs = {
    cluster_identifier = "test-cluster"
    instance_class = "db.r5.large"
    engine = "aurora-mysql"
  }
}

# Test 3: FAIL - auto_minor_version_upgrade explicitly set to false
resource "aws_rds_cluster_instance" "fail_explicit_false" {
  expect_failure = true
  attrs = {
    auto_minor_version_upgrade = false
    cluster_identifier = "test-cluster"
    instance_class = "db.r5.large"
    engine = "aurora-postgresql"
  }
}
