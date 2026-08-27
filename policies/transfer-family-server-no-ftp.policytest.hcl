# Copyright IBM Corp. 2026

policytest {
  targets = ["transfer-family-server-no-ftp.policy.hcl"]
}

# Test 1: Pass - No protocols specified (defaults to SFTP)
resource "aws_transfer_server" "pass_default_sftp" {
  attrs = {
    endpoint_type = "PUBLIC"
    identity_provider_type = "SERVICE_MANAGED"
  }
}

# Test 2: Pass - SFTP protocol only
resource "aws_transfer_server" "pass_sftp_only" {
  attrs = {
    protocols = ["SFTP"]
    endpoint_type = "PUBLIC"
    identity_provider_type = "SERVICE_MANAGED"
  }
}

# Test 3: Pass - FTPS protocol only
resource "aws_transfer_server" "pass_ftps_only" {
  attrs = {
    protocols = ["FTPS"]
    endpoint_type = "PUBLIC"
    identity_provider_type = "SERVICE_MANAGED"
    certificate = "arn:aws:acm:us-east-1:123456789012:certificate/abcd1234"
  }
}

# Test 4: Pass - AS2 protocol only
resource "aws_transfer_server" "pass_as2_only" {
  attrs = {
    protocols = ["AS2"]
    endpoint_type = "PUBLIC"
    identity_provider_type = "SERVICE_MANAGED"
  }
}

# Test 5: Pass - Multiple secure protocols (SFTP and FTPS)
resource "aws_transfer_server" "pass_multiple_secure" {
  attrs = {
    protocols = ["SFTP", "FTPS"]
    endpoint_type = "PUBLIC"
    identity_provider_type = "SERVICE_MANAGED"
    certificate = "arn:aws:acm:us-east-1:123456789012:certificate/abcd1234"
  }
}

# Test 6: Fail - FTP protocol only
resource "aws_transfer_server" "fail_ftp_only" {
  expect_failure = true
  attrs = {
    protocols = ["FTP"]
    endpoint_type = "PUBLIC"
    identity_provider_type = "SERVICE_MANAGED"
  }
}

# Test 7: Fail - FTP with secure protocols (FTP and SFTP)
resource "aws_transfer_server" "fail_ftp_with_secure" {
  expect_failure = true
  attrs = {
    protocols = ["FTP", "SFTP"]
    endpoint_type = "PUBLIC"
    identity_provider_type = "SERVICE_MANAGED"
  }
}
