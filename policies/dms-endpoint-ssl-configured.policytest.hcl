# Copyright IBM Corp. 2026

policytest {
  targets = ["dms-endpoint-ssl-configured.policy.hcl"]
}

# --------------- PASS cases ---------------

# Test 1: PASS - ssl_mode = "require" (no certificate needed)
resource "aws_dms_endpoint" "pass_ssl_require" {
  attrs = {
    endpoint_id   = "pass-ssl-require"
    endpoint_type = "source"
    engine_name   = "mysql"
    ssl_mode      = "require"
  }
}

# Test 2: PASS - ssl_mode = "verify-ca" with a certificate ARN
resource "aws_dms_endpoint" "pass_ssl_verify_ca_with_cert" {
  attrs = {
    endpoint_id     = "pass-ssl-verify-ca"
    endpoint_type   = "source"
    engine_name     = "postgres"
    ssl_mode        = "verify-ca"
    certificate_arn = "arn:aws:dms:us-east-1:123456789012:cert:CACERT123456"
  }
}

# Test 3: PASS - ssl_mode = "verify-full" with a certificate ARN
resource "aws_dms_endpoint" "pass_ssl_verify_full_with_cert" {
  attrs = {
    endpoint_id     = "pass-ssl-verify-full"
    endpoint_type   = "target"
    engine_name     = "redshift"
    ssl_mode        = "verify-full"
    certificate_arn = "arn:aws:dms:us-east-1:123456789012:cert:FULLCERT123456"
  }
}

# --------------- FAIL cases ---------------

# Test 4: FAIL - ssl_mode absent (defaults to "none")
resource "aws_dms_endpoint" "fail_ssl_mode_missing" {
  expect_failure = true
  attrs = {
    endpoint_id   = "fail-ssl-mode-missing"
    endpoint_type = "source"
    engine_name   = "mysql"
  }
}

# Test 5: FAIL - ssl_mode = "none" explicitly
resource "aws_dms_endpoint" "fail_ssl_mode_none" {
  expect_failure = true
  attrs = {
    endpoint_id   = "fail-ssl-mode-none"
    endpoint_type = "source"
    engine_name   = "mysql"
    ssl_mode      = "none"
  }
}

# Test 6: FAIL - ssl_mode = "none" even though certificate_arn is set
# A cert being present does NOT mean SSL is in use — ssl_mode controls that.
resource "aws_dms_endpoint" "fail_ssl_none_with_cert" {
  expect_failure = true
  attrs = {
    endpoint_id     = "fail-ssl-none-with-cert"
    endpoint_type   = "source"
    engine_name     = "mysql"
    ssl_mode        = "none"
    certificate_arn = "arn:aws:dms:us-east-1:123456789012:cert:IGNORED123456"
  }
}

# Test 7: FAIL - ssl_mode = "verify-ca" but no certificate_arn provided
resource "aws_dms_endpoint" "fail_verify_ca_no_cert" {
  expect_failure = true
  attrs = {
    endpoint_id   = "fail-verify-ca-no-cert"
    endpoint_type = "source"
    engine_name   = "postgres"
    ssl_mode      = "verify-ca"
  }
}

# Test 8: FAIL - ssl_mode = "verify-full" but no certificate_arn provided
resource "aws_dms_endpoint" "fail_verify_full_no_cert" {
  expect_failure = true
  attrs = {
    endpoint_id   = "fail-verify-full-no-cert"
    endpoint_type = "target"
    engine_name   = "oracle"
    ssl_mode      = "verify-full"
  }
}