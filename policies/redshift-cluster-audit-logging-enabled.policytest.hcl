# Copyright IBM Corp. 2026

policytest {
  targets = [
    "redshift-cluster-audit-logging-enabled.policy.hcl"
  ]
}

# Pass Case 1: S3 audit logging properly configured
resource "aws_redshift_logging" "s3_logging" {
  attrs = {
    cluster_identifier = "test-cluster-s3"
    log_destination_type = "s3"
    bucket_name = "my-audit-logs-bucket"
    s3_key_prefix = "redshift-logs/"
  }
}

resource "aws_redshift_cluster" "compliant_s3" {
  skip = true
  attrs = {
    cluster_identifier = "test-cluster-s3"
    node_type = "dc2.large"
    master_username = "admin"
  }
}

# Pass Case 2: CloudWatch audit logging properly configured with all log types
resource "aws_redshift_logging" "cloudwatch_logging" {
  attrs = {
    cluster_identifier = "test-cluster-cw"
    log_destination_type = "cloudwatch"
    log_exports = ["connectionlog", "useractivitylog", "userlog"]
  }
}

resource "aws_redshift_cluster" "compliant_cloudwatch" {
  skip = true
  attrs = {
    cluster_identifier = "test-cluster-cw"
    node_type = "dc2.large"
    master_username = "admin"
  }
}

# Pass Case 3: CloudWatch logging with single log export type
resource "aws_redshift_logging" "cloudwatch_single" {
  attrs = {
    cluster_identifier = "test-cluster-cw-single"
    log_destination_type = "cloudwatch"
    log_exports = ["connectionlog"]
  }
}

resource "aws_redshift_cluster" "compliant_cw_single" {
  skip = true
  attrs = {
    cluster_identifier = "test-cluster-cw-single"
    node_type = "dc2.large"
    master_username = "admin"
  }
}

# Fail Case 1: S3 logging with missing bucket_name
resource "aws_redshift_logging" "s3_incomplete" {
  expect_failure = true
  attrs = {
    cluster_identifier = "test-cluster-s3-incomplete"
    log_destination_type = "s3"
    bucket_name = ""
  }
}

resource "aws_redshift_cluster" "non_compliant_s3_incomplete" {
  skip = true
  attrs = {
    cluster_identifier = "test-cluster-s3-incomplete"
    node_type = "dc2.large"
    master_username = "admin"
  }
}

# Fail Case 2: CloudWatch logging with empty log_exports
resource "aws_redshift_logging" "cloudwatch_incomplete" {
  expect_failure = true
  attrs = {
    cluster_identifier = "test-cluster-cw-incomplete"
    log_destination_type = "cloudwatch"
    log_exports = []
  }
}

resource "aws_redshift_cluster" "non_compliant_cw_incomplete" {
  skip = true
  attrs = {
    cluster_identifier = "test-cluster-cw-incomplete"
    node_type = "dc2.large"
    master_username = "admin"
  }
}

# Fail Case 3: Invalid log destination type
resource "aws_redshift_logging" "invalid_destination" {
  expect_failure = true
  attrs = {
    cluster_identifier = "test-cluster-invalid"
    log_destination_type = "invalid"
    bucket_name = ""
  }
}

resource "aws_redshift_cluster" "non_compliant_invalid" {
  skip = true
  attrs = {
    cluster_identifier = "test-cluster-invalid"
    node_type = "dc2.large"
    master_username = "admin"
  }
}