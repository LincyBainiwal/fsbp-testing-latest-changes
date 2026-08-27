# Copyright IBM Corp. 2026

policytest {
    targets = [
        "rds-sqlserver-encrypted-in-transit.policy.hcl"
    ]
}

# Test 1: PASS - SQL Server DB instance with parameter group that has rds.force_ssl = 1
resource "aws_db_parameter_group" "sqlserver_pg_ssl_enabled" {
  skip = true
  attrs = {
    name = "sqlserver-pg-ssl-enabled"
    family = "sqlserver-se-15.0"
    parameter = [
      {
        name = "rds.force_ssl"
        value = "1"
        apply_method = "immediate"
      }
    ]
  }
}

resource "aws_db_instance" "sqlserver_ssl_enabled" {
  attrs = {
    engine = "sqlserver-se"
    parameter_group_name = "sqlserver-pg-ssl-enabled"
    identifier = "test-sqlserver-db"
  }
}

# Test 2: FAIL - SQL Server DB instance with parameter group that has rds.force_ssl = 0
resource "aws_db_parameter_group" "sqlserver_pg_ssl_disabled" {
  skip = true
  expect_failure = true
  attrs = {
    name = "sqlserver-pg-ssl-disabled"
    family = "sqlserver-se-15.0"
    parameter = [
      {
        name = "rds.force_ssl"
        value = "0"
        apply_method = "immediate"
      }
    ]
  }
}

resource "aws_db_instance" "sqlserver_ssl_disabled" {
  expect_failure = true
  attrs = {
    engine = "sqlserver-se"
    parameter_group_name = "sqlserver-pg-ssl-disabled"
    identifier = "test-sqlserver-db-disabled"
  }
}

# Test 3: FAIL - SQL Server DB instance with parameter group missing rds.force_ssl
resource "aws_db_parameter_group" "sqlserver_pg_no_ssl" {
  skip = true
  attrs = {
    name = "sqlserver-pg-no-ssl"
    family = "sqlserver-se-15.0"
    parameter = [
      {
        name = "other_parameter"
        value = "some_value"
        apply_method = "immediate"
      }
    ]
  }
}

resource "aws_db_instance" "sqlserver_ssl_not_configured" {
  expect_failure = true
  attrs = {
    engine = "sqlserver-se"
    parameter_group_name = "sqlserver-pg-no-ssl"
    identifier = "test-sqlserver-db-no-ssl"
  }
}

# Test 4: PASS - SQL Server parameter group without rds.force_ssl (not explicitly disabled)
resource "aws_db_parameter_group" "sqlserver_pg_web_default" {
  skip = true
  attrs = {
    name = "sqlserver-pg-web-default"
    family = "sqlserver-web-15.0"
    parameter = [
      {
        name = "other_parameter"
        value = "value"
        apply_method = "immediate"
      }
    ]
  }
}

# Test 5: SKIP - Non-SQL Server DB instance (MySQL) should be filtered out
resource "aws_db_instance" "mysql_instance" {
  attrs = {
    engine = "mysql"
    parameter_group_name = "mysql-pg"
    identifier = "test-mysql-db"
  }
}

# Test 6: PASS - SQL Server Express Edition with SSL enabled
resource "aws_db_parameter_group" "sqlserver_pg_ex_ssl_enabled" {
  skip = true
  attrs = {
    name = "sqlserver-ex-pg"
    family = "sqlserver-ex-15.0"
    parameter = [
      {
        name = "rds.force_ssl"
        value = "1"
        apply_method = "immediate"
      }
    ]
  }
}

resource "aws_db_instance" "sqlserver_ex_ssl_enabled" {
  attrs = {
    engine = "sqlserver-ex"
    parameter_group_name = "sqlserver-ex-pg"
    identifier = "test-sqlserver-ex-db"
  }
}

# Test 7: PASS - SQL Server Web Edition with SSL enabled
resource "aws_db_parameter_group" "sqlserver_pg_web_ssl_enabled" {
  skip = true
  attrs = {
    name = "sqlserver-web-pg"
    family = "sqlserver-web-16.0"
    parameter = [
      {
        name = "rds.force_ssl"
        value = "1"
        apply_method = "immediate"
      }
    ]
  }
}

resource "aws_db_instance" "sqlserver_web_ssl_enabled" {
  attrs = {
    engine = "sqlserver-web"
    parameter_group_name = "sqlserver-web-pg"
    identifier = "test-sqlserver-web-db"
  }
}

# Test 8: PASS - SQL Server Enterprise Edition with SSL enabled and other parameters
resource "aws_db_parameter_group" "sqlserver_pg_ee_ssl_with_other_params" {
  skip = true
  attrs = {
    name = "sqlserver-ee-pg"
    family = "sqlserver-ee-16.0"
    parameter = [
      {
        name = "rds.force_ssl"
        value = "1"
        apply_method = "immediate"
      },
      {
        name = "max_connections"
        value = "100"
        apply_method = "pending-reboot"
      },
      {
        name = "backup_retention_period"
        value = "7"
        apply_method = "immediate"
      }
    ]
  }
}

resource "aws_db_instance" "sqlserver_ee_ssl_with_other_params" {
  attrs = {
    engine = "sqlserver-ee"
    parameter_group_name = "sqlserver-ee-pg"
    identifier = "test-sqlserver-ee-db"
  }
}
