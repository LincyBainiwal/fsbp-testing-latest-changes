# Copyright IBM Corp. 2026

policytest {
  targets = ["rds-instance-public-access-check.policy.hcl"]
}

# PASS: publicly_accessible explicitly set to false
resource "aws_db_instance" "pass_publicly_accessible_false" {
  attrs = {
    identifier          = "private-rds-instance"
    instance_class      = "db.t3.micro"
    engine              = "mysql"
    allocated_storage   = 20
    publicly_accessible = false
  }
}

# FAIL: publicly_accessible explicitly set to true
resource "aws_db_instance" "fail_publicly_accessible_true" {
  expect_failure = true
  attrs = {
    identifier          = "public-rds-instance"
    instance_class      = "db.t3.micro"
    engine              = "mysql"
    allocated_storage   = 20
    publicly_accessible = true
  }
}

# PASS: publicly_accessible attribute absent (defaults to false)
resource "aws_db_instance" "pass_publicly_accessible_absent" {
  attrs = {
    identifier        = "default-rds-instance"
    instance_class    = "db.t3.micro"
    engine            = "postgres"
    allocated_storage = 20
  }
}

# PASS: publicly_accessible set to null (core::try defaults to false)
resource "aws_db_instance" "pass_publicly_accessible_null" {
  attrs = {
    identifier          = "null-accessible-rds"
    instance_class      = "db.t3.micro"
    engine              = "mysql"
    allocated_storage   = 20
    publicly_accessible = null
  }
}
