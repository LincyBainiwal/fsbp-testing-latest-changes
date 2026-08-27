# Copyright IBM Corp. 2026

# Test cases for RedshiftServerless.2 - Require SSL for Redshift Serverless Workgroups

# Specify which policy to test
policytest {
  targets = ["redshift-serverless-workgroup-encrypted-in-transit.policy.hcl"]
}

# Test 1: PASS - Workgroup with require_ssl set to 'true'
resource "aws_redshiftserverless_workgroup" "pass_ssl_enabled" {
  attrs = {
    workgroup_name = "compliant-workgroup"
    namespace_name = "test-namespace"
    config_parameter = [
      {
        parameter_key   = "require_ssl"
        parameter_value = "true"
      }
    ]
  }
}

# Test 2: FAIL - Workgroup with require_ssl set to 'false'
resource "aws_redshiftserverless_workgroup" "fail_ssl_disabled" {
  expect_failure = true
  attrs = {
    workgroup_name = "non-compliant-workgroup"
    namespace_name = "test-namespace"
    config_parameter = [
      {
        parameter_key   = "require_ssl"
        parameter_value = "false"
      }
    ]
  }
}

# Test 3: FAIL - Workgroup without config_parameter block
resource "aws_redshiftserverless_workgroup" "fail_no_config_parameter" {
  expect_failure = true
  attrs = {
    workgroup_name = "no-config-workgroup"
    namespace_name = "test-namespace"
  }
}

# Test 4: FAIL - Workgroup with config_parameter but without require_ssl
resource "aws_redshiftserverless_workgroup" "fail_missing_require_ssl" {
  expect_failure = true
  attrs = {
    workgroup_name = "missing-ssl-workgroup"
    namespace_name = "test-namespace"
    config_parameter = [
      {
        parameter_key   = "enable_user_activity_logging"
        parameter_value = "true"
      }
    ]
  }
}

# Test 5: PASS - Workgroup with multiple config_parameter entries including require_ssl='true'
resource "aws_redshiftserverless_workgroup" "pass_multiple_config_params" {
  attrs = {
    workgroup_name = "multiple-params-workgroup"
    namespace_name = "test-namespace"
    config_parameter = [
      {
        parameter_key   = "enable_user_activity_logging"
        parameter_value = "true"
      },
      {
        parameter_key   = "require_ssl"
        parameter_value = "true"
      },
      {
        parameter_key   = "use_fips_ssl"
        parameter_value = "false"
      }
    ]
  }
}