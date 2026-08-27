# Copyright IBM Corp. 2026

policytest {
    targets = [
        "rds-no-default-ports.policy.hcl"
    ]
}

# Test 1: PASS - MySQL instance with custom port
resource "aws_db_instance" "mysql_custom_port_pass" {
  attrs = {
    engine = "mysql"
    port = 3307
    identifier = "test-mysql-db"
    instance_class = "db.t3.micro"
    allocated_storage = 20
  }
}

# Test 2: FAIL - MySQL instance with no port specified (AWS assigns default 3306)
resource "aws_db_instance" "mysql_no_port_fail" {
  expect_failure = true
  attrs = {
    engine = "mysql"
    port = 3306  # AWS assigns this when not specified in config
    identifier = "test-mysql-db"
    instance_class = "db.t3.micro"
    allocated_storage = 20
  }
}

# Test 3: FAIL - MySQL instance with default port 3306
resource "aws_db_instance" "mysql_default_port_fail" {
  expect_failure = true
  attrs = {
    engine = "mysql"
    port = 3306
    identifier = "test-mysql-db"
    instance_class = "db.t3.micro"
    allocated_storage = 20
  }
}

# Test 4: PASS - PostgreSQL instance with custom port
resource "aws_db_instance" "postgres_custom_port_pass" {
  attrs = {
    engine = "postgres"
    port = 5433
    identifier = "test-postgres-db"
    instance_class = "db.t3.micro"
    allocated_storage = 20
  }
}

# Test 5: FAIL - PostgreSQL instance with no port specified (AWS assigns default 5432)
resource "aws_db_instance" "postgres_no_port_fail" {
  expect_failure = true
  attrs = {
    engine = "postgres"
    port = 5432  # AWS assigns this when not specified in config
    identifier = "test-postgres-db"
    instance_class = "db.t3.micro"
    allocated_storage = 20
  }
}

# Test 6: PASS - Oracle SE2 instance with custom port
resource "aws_db_instance" "oracle_custom_port_pass" {
  attrs = {
    engine = "oracle-se2"
    port = 1522
    identifier = "test-oracle-db"
    instance_class = "db.t3.micro"
    allocated_storage = 20
  }
}

# Test 7: FAIL - Oracle SE2 instance with default port 1521
resource "aws_db_instance" "oracle_default_port_fail" {
  expect_failure = true
  attrs = {
    engine = "oracle-se2"
    port = 1521
    identifier = "test-oracle-db"
    instance_class = "db.t3.micro"
    allocated_storage = 20
  }
}

# Test 8: PASS - SQL Server Express instance with custom port
resource "aws_db_instance" "sqlserver_custom_port_pass" {
  attrs = {
    engine = "sqlserver-ex"
    port = 1434
    identifier = "test-sqlserver-db"
    instance_class = "db.t3.micro"
    allocated_storage = 20
  }
}

# Test 9: FAIL - SQL Server Express instance with no port specified (AWS assigns default 1433)
resource "aws_db_instance" "sqlserver_no_port_fail" {
  expect_failure = true
  attrs = {
    engine = "sqlserver-ex"
    port = 1433  # AWS assigns this when not specified in config
    identifier = "test-sqlserver-db"
    instance_class = "db.t3.micro"
    allocated_storage = 20
  }
}

# Test 10: PASS - Aurora MySQL cluster with custom port
resource "aws_rds_cluster" "aurora_mysql_custom_port_pass" {
  attrs = {
    engine = "mysql"
    port = 3307
    cluster_identifier = "test-aurora-mysql-cluster"
    master_username = "admin"
  }
}

# Test 11: FAIL - Aurora MySQL cluster with no port specified (AWS assigns default 3306)
resource "aws_rds_cluster" "aurora_mysql_no_port_fail" {
  expect_failure = true
  attrs = {
    engine = "mysql"
    port = 3306  # AWS assigns this when not specified in config
    cluster_identifier = "test-aurora-mysql-cluster"
    master_username = "admin"
  }
}

# Test 12: PASS - Aurora PostgreSQL cluster with custom port
resource "aws_rds_cluster" "aurora_postgres_custom_port_pass" {
  attrs = {
    engine = "aurora-postgresql"
    port = 5433
    cluster_identifier = "test-aurora-postgres-cluster"
    master_username = "admin"
  }
}

# Test 13: FAIL - Aurora PostgreSQL cluster with default port 5432
resource "aws_rds_cluster" "aurora_postgres_default_port_fail" {
  expect_failure = true
  attrs = {
    engine = "aurora-postgresql"
    port = 5432
    cluster_identifier = "test-aurora-postgres-cluster"
    master_username = "admin"
  }
}
