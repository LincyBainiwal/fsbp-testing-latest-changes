# Copyright IBM Corp. 2026

policytest {
  targets = ["redshift-serverless-publish-logs-to-cloudwatch.policy.hcl"]
}

resource "aws_redshiftserverless_namespace" "compliant_namespace" {
  attrs = {
    namespace_name = "compliant-namespace"
    log_exports = ["connectionlog", "userlog"]
  }
}

resource "aws_redshiftserverless_namespace" "missing_userlog" {
  expect_failure = true
  attrs = {
    namespace_name = "missing-userlog"
    log_exports = ["connectionlog"]
  }
}

resource "aws_redshiftserverless_namespace" "missing_connectionlog" {
  expect_failure = true
  attrs = {
    namespace_name = "missing-connectionlog"
    log_exports = ["userlog"]
  }
}

resource "aws_redshiftserverless_namespace" "missing_all_logs" {
  expect_failure = true
  attrs = {
    namespace_name = "missing-all-logs"
    log_exports = []
  }
}
