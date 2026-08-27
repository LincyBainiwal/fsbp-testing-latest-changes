# Copyright IBM Corp. 2026

policytest {
  targets = ["iam-root-access-key-check.policy.hcl"]
}

resource "aws_iam_access_key" "standard_user_key" {
  attrs = {
    user = "app-user"
    status = "Active"
  }
}

resource "aws_iam_access_key" "root_user_key" {
  expect_failure = true
  attrs = {
    user = "root"
    status = "Active"
  }
}

resource "aws_iam_access_key" "missing_user_attribute" {
  attrs = {
    status = "Inactive"
  }
}
