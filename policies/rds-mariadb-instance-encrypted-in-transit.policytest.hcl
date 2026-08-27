# Copyright IBM Corp. 2026

policytest {
    targets = [
        "rds-mariadb-instance-encrypted-in-transit.policy.hcl"
    ]
}

# Test 1: PASS - MariaDB 10.5 with require_secure_transport = '1'
resource "aws_db_parameter_group" "secure_10_5" {
  skip = true
  attrs = {
    name = "mariadb-secure-10-5"
    family = "mariadb10.5"
    parameter = [
      {
        name = "require_secure_transport"
        value = "1"
        apply_method = "immediate"
      }
    ]
  }
}

resource "aws_db_instance" "pass_10_5_transport_1" {
  attrs = {
    engine = "mariadb"
    engine_version = "10.5.12"
    parameter_group_name = "mariadb-secure-10-5"
  }
}

# Test 2: PASS - MariaDB 10.6 with require_secure_transport = '1'
resource "aws_db_parameter_group" "secure_10_6" {
  skip = true
  attrs = {
    name = "mariadb-secure-10-6"
    family = "mariadb10.6"
    parameter = [
      {
        name = "require_secure_transport"
        value = "1"
        apply_method = "immediate"
      }
    ]
  }
}

resource "aws_db_instance" "pass_10_6_transport_on" {
  attrs = {
    engine = "mariadb"
    engine_version = "10.6.8"
    parameter_group_name = "mariadb-secure-10-6"
  }
}

# Test 3: FAIL - MariaDB 10.5 with require_secure_transport = '0'
resource "aws_db_parameter_group" "insecure_10_5" {
  skip = true
  expect_failure = true
  attrs = {
    name = "mariadb-insecure-10-5"
    family = "mariadb10.5"
    parameter = [
      {
        name = "require_secure_transport"
        value = "0"
        apply_method = "immediate"
      }
    ]
  }
}

resource "aws_db_instance" "fail_10_5_transport_disabled" {
  expect_failure = true
  attrs = {
    engine = "mariadb"
    engine_version = "10.5.12"
    parameter_group_name = "mariadb-insecure-10-5"
  }
}

# Test 4: FAIL - MariaDB 10.5 without require_secure_transport parameter
resource "aws_db_parameter_group" "default_10_5" {
  skip = true
  expect_failure = true
  attrs = {
    name = "mariadb-default-10-5"
    family = "mariadb10.5"
    parameter = []
  }
}

resource "aws_db_instance" "fail_10_5_missing_param" {
  expect_failure = true
  attrs = {
    engine = "mariadb"
    engine_version = "10.5.12"
    parameter_group_name = "mariadb-default-10-5"
  }
}

# Test 5: PASS - MariaDB 10.4 without require_secure_transport (version < 10.5)
resource "aws_db_parameter_group" "default_10_4" {
  skip = true
  attrs = {
    name = "mariadb-default-10-4"
    family = "mariadb10.4"
    parameter = []
  }
}

resource "aws_db_instance" "pass_10_4_not_applicable" {
  attrs = {
    engine = "mariadb"
    engine_version = "10.4.21"
    parameter_group_name = "mariadb-default-10-4"
  }
}

# Test 6: PASS - MariaDB 11.0 with require_secure_transport = '1'
resource "aws_db_parameter_group" "secure_11_0" {
  skip = true
  attrs = {
    name = "mariadb-secure-11-0"
    family = "mariadb11.0"
    parameter = [
      {
        name = "require_secure_transport"
        value = "1"
        apply_method = "immediate"
      }
    ]
  }
}

resource "aws_db_instance" "pass_11_0_transport_enabled" {
  attrs = {
    engine = "mariadb"
    engine_version = "11.0.2"
    parameter_group_name = "mariadb-secure-11-0"
  }
}

# Test 7: FAIL - MariaDB 11.0 without require_secure_transport parameter
resource "aws_db_parameter_group" "default_11_0" {
  skip = true
  expect_failure = true
  attrs = {
    name = "mariadb-default-11-0"
    family = "mariadb11.0"
    parameter = []
  }
}

resource "aws_db_instance" "fail_11_0_missing_param" {
  expect_failure = true
  attrs = {
    engine = "mariadb"
    engine_version = "11.0.2"
    parameter_group_name = "mariadb-default-11-0"
  }
}
