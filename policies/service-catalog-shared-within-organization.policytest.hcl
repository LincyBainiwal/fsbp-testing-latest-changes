# Copyright IBM Corp. 2026

policytest {
  targets = ["service-catalog-shared-within-organization.policy.hcl"]
}

# Pass Case 1: ORGANIZATION_MEMBER_ACCOUNT (recommended type)
resource "aws_servicecatalog_portfolio_share" "pass_organization_member_account" {
  attrs = {
    portfolio_id = "port-12345678"
    principal_id = "123456789012"
    type = "ORGANIZATION_MEMBER_ACCOUNT"
    share_principals = true
  }
}

# Pass Case 2: ORGANIZATIONAL_UNIT
resource "aws_servicecatalog_portfolio_share" "pass_organizational_unit" {
  attrs = {
    portfolio_id = "port-12345678"
    principal_id = "ou-abcd-12345678"
    type = "ORGANIZATIONAL_UNIT"
    share_principals = true
  }
}

# Pass Case 3: ORGANIZATION
resource "aws_servicecatalog_portfolio_share" "pass_organization" {
  attrs = {
    portfolio_id = "port-12345678"
    principal_id = "o-abcdefghij"
    type = "ORGANIZATION"
    share_principals = true
  }
}

# Fail Case 1: ACCOUNT (external account sharing - non-compliant)
resource "aws_servicecatalog_portfolio_share" "fail_external_account" {
  expect_failure = true
  attrs = {
    portfolio_id = "port-12345678"
    principal_id = "999999999999"
    type = "ACCOUNT"
    share_principals = false
  }
}

# Fail Case 2: Invalid share type
resource "aws_servicecatalog_portfolio_share" "fail_invalid_type" {
  expect_failure = true
  attrs = {
    portfolio_id = "port-12345678"
    principal_id = "123456789012"
    type = "INVALID_TYPE"
    share_principals = true
  }
}

# Fail Case 3: Missing type attribute (empty string from core::try default)
resource "aws_servicecatalog_portfolio_share" "fail_missing_type" {
  expect_failure = true
  attrs = {
    portfolio_id = "port-12345678"
    principal_id = "123456789012"
    share_principals = true
  }
}
