# Copyright IBM Corp. 2026

policytest {
  targets = [
    "ses-sending-tls-required.policy.hcl"
  ]
}

# Pass case: SES v1 with TLS set to 'Require'
resource "aws_ses_configuration_set" "ses_v1_pass_tls_require" {
  attrs = {
    name = "compliant-config-set"
    delivery_options = [
      {
        tls_policy = "Require"
      }
    ]
  }
}

# Fail case: SES v1 with TLS set to 'Optional'
resource "aws_ses_configuration_set" "ses_v1_fail_tls_optional" {
  expect_failure = true
  attrs = {
    name = "non-compliant-config-set"
    delivery_options = [
      {
        tls_policy = "Optional"
      }
    ]
  }
}

# Fail case: SES v1 without delivery_options block
resource "aws_ses_configuration_set" "ses_v1_fail_no_delivery_options" {
  expect_failure = true
  attrs = {
    name = "no-delivery-options-config-set"
  }
}

# Fail case: SES v1 with empty delivery_options (no tls_policy)
resource "aws_ses_configuration_set" "ses_v1_fail_empty_delivery_options" {
  expect_failure = true
  attrs = {
    name = "empty-delivery-options-config-set"
    delivery_options = [
      {}
    ]
  }
}

# ============================================================================
# Tests for aws_sesv2_configuration_set (SES v2)
# ============================================================================

# Pass case: SES v2 with TLS set to 'REQUIRE'
resource "aws_sesv2_configuration_set" "ses_v2_pass_tls_require" {
  attrs = {
    configuration_set_name = "compliant-v2-config-set"
    delivery_options = [
      {
        tls_policy = "REQUIRE"
      }
    ]
  }
}

# Fail case: SES v2 with TLS set to 'OPTIONAL'
resource "aws_sesv2_configuration_set" "ses_v2_fail_tls_optional" {
  expect_failure = true
  attrs = {
    configuration_set_name = "non-compliant-v2-config-set"
    delivery_options = [
      {
        tls_policy = "OPTIONAL"
      }
    ]
  }
}

# Fail case: SES v2 without delivery_options block
resource "aws_sesv2_configuration_set" "ses_v2_fail_no_delivery_options" {
  expect_failure = true
  attrs = {
    configuration_set_name = "no-delivery-options-v2-config-set"
  }
}

# Fail case: SES v2 with empty delivery_options (no tls_policy)
resource "aws_sesv2_configuration_set" "ses_v2_fail_empty_delivery_options" {
  expect_failure = true
  attrs = {
    configuration_set_name = "empty-delivery-options-v2-config-set"
    delivery_options = [
      {}
    ]
  }
}
