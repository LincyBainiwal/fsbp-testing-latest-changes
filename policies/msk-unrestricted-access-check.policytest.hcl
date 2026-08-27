# Copyright IBM Corp. 2026

policytest {
  targets = [
    "msk-unrestricted-access-check.policy.hcl"
  ]
}

# Pass: IAM authentication enabled, unauthenticated disabled, object-shaped nested blocks
resource "aws_msk_cluster" "iam_auth_object_shape_pass" {
  attrs = {
    cluster_name = "test-cluster-iam-object"
    kafka_version = "2.8.1"
    number_of_broker_nodes = 3
    client_authentication = {
      sasl = {
        iam = true
        scram = false
      }
      unauthenticated = false
    }
  }
}

# Pass: IAM authentication enabled, unauthenticated disabled
resource "aws_msk_cluster" "iam_auth_pass" {
  attrs = {
    cluster_name = "test-cluster-iam"
    kafka_version = "2.8.1"
    number_of_broker_nodes = 3
    client_authentication = [{
      sasl = [{
        iam = true
        scram = false
      }]
      unauthenticated = false
    }]
  }
}

# Pass: SASL/SCRAM authentication enabled, unauthenticated disabled
resource "aws_msk_cluster" "scram_auth_pass" {
  attrs = {
    cluster_name = "test-cluster-scram"
    kafka_version = "2.8.1"
    number_of_broker_nodes = 3
    client_authentication = [{
      sasl = [{
        iam = false
        scram = true
      }]
      unauthenticated = false
    }]
  }
}

# Pass: TLS authentication enabled, unauthenticated disabled
resource "aws_msk_cluster" "tls_auth_pass" {
  attrs = {
    cluster_name = "test-cluster-tls"
    kafka_version = "2.8.1"
    number_of_broker_nodes = 3
    client_authentication = [{
      tls = [{
        certificate_authority_arns = ["arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"]
      }]
      unauthenticated = false
    }]
  }
}

# Pass: Multiple authentication methods (IAM and SCRAM), unauthenticated disabled
resource "aws_msk_cluster" "multi_auth_pass" {
  attrs = {
    cluster_name = "test-cluster-multi"
    kafka_version = "2.8.1"
    number_of_broker_nodes = 3
    client_authentication = [{
      sasl = [{
        iam = true
        scram = true
      }]
      unauthenticated = false
    }]
  }
}

# Pass: IAM authentication enabled, unauthenticated not specified (defaults to false)
resource "aws_msk_cluster" "iam_auth_no_unauth_field_pass" {
  attrs = {
    cluster_name = "test-cluster-iam-no-unauth"
    kafka_version = "2.8.1"
    number_of_broker_nodes = 3
    client_authentication = [{
      sasl = [{
        iam = true
        scram = false
      }]
    }]
  }
}

# Fail: No client_authentication block (no explicit auth mechanism)
resource "aws_msk_cluster" "no_client_auth_fail" {
  expect_failure = true
  attrs = {
    cluster_name = "test-cluster-no-auth"
    kafka_version = "2.8.1"
    number_of_broker_nodes = 3
  }
}

# Fail: Unauthenticated access explicitly enabled
resource "aws_msk_cluster" "unauthenticated_enabled_fail" {
  expect_failure = true
  attrs = {
    cluster_name = "test-cluster-unauth-enabled"
    kafka_version = "2.8.1"
    number_of_broker_nodes = 3
    client_authentication = [{
      unauthenticated = true
    }]
  }
}

# Fail: Unauthenticated disabled but no authentication mechanisms enabled
resource "aws_msk_cluster" "no_auth_mechanism_fail" {
  expect_failure = true
  attrs = {
    cluster_name = "test-cluster-no-mechanism"
    kafka_version = "2.8.1"
    number_of_broker_nodes = 3
    client_authentication = [{
      sasl = [{
        iam = false
        scram = false
      }]
      unauthenticated = false
    }]
  }
}

# Fail: All authentication methods disabled
resource "aws_msk_cluster" "all_auth_disabled_fail" {
  expect_failure = true
  attrs = {
    cluster_name = "test-cluster-all-disabled"
    kafka_version = "2.8.1"
    number_of_broker_nodes = 3
    client_authentication = [{
      sasl = [{
        iam = false
        scram = false
      }]
      tls = [{
        certificate_authority_arns = []
      }]
      unauthenticated = false
    }]
  }
}
