# Copyright IBM Corp. 2026

policytest {
  targets = [
    "msk-in-cluster-node-require-tls.policy.hcl"
  ]
}
resource "aws_msk_cluster" "pass_no_encryption_info_block" {
  attrs = {
    cluster_name = "test-cluster"
    kafka_version = "2.8.1"
    number_of_broker_nodes = 3
    broker_node_group_info = [{
      instance_type = "kafka.m5.large"
      client_subnets = ["subnet-123", "subnet-456", "subnet-789"]
      security_groups = ["sg-123"]
    }]
  }
}

resource "aws_msk_cluster" "pass_no_encryption_in_transit_block" {
  attrs = {
    cluster_name = "test-cluster"
    kafka_version = "2.8.1"
    number_of_broker_nodes = 3
    broker_node_group_info = [{
      instance_type = "kafka.m5.large"
      client_subnets = ["subnet-123", "subnet-456", "subnet-789"]
      security_groups = ["sg-123"]
    }]
    encryption_info = [{
      encryption_at_rest_kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
    }]
  }
}

resource "aws_msk_cluster" "pass_in_cluster_true" {
  attrs = {
    cluster_name = "test-cluster"
    kafka_version = "2.8.1"
    number_of_broker_nodes = 3
    broker_node_group_info = [{
      instance_type = "kafka.m5.large"
      client_subnets = ["subnet-123", "subnet-456", "subnet-789"]
      security_groups = ["sg-123"]
    }]
    encryption_info = [{
      encryption_in_transit = [{
        in_cluster = true
      }]
    }]
  }
}

resource "aws_msk_cluster" "fail_in_cluster_false" {
  expect_failure = true
  attrs = {
    cluster_name = "test-cluster"
    kafka_version = "2.8.1"
    number_of_broker_nodes = 3
    broker_node_group_info = [{
      instance_type = "kafka.m5.large"
      client_subnets = ["subnet-123", "subnet-456", "subnet-789"]
      security_groups = ["sg-123"]
    }]
    encryption_info = [{
      encryption_in_transit = [{
        in_cluster = false
      }]
    }]
  }
}

resource "aws_msk_cluster" "pass_in_cluster_not_specified" {
  attrs = {
    cluster_name = "test-cluster"
    kafka_version = "2.8.1"
    number_of_broker_nodes = 3
    broker_node_group_info = [{
      instance_type = "kafka.m5.large"
      client_subnets = ["subnet-123", "subnet-456", "subnet-789"]
      security_groups = ["sg-123"]
    }]
    encryption_info = [{
      encryption_in_transit = [{
        client_broker = "TLS"
      }]
    }]
  }
}

resource "aws_msk_cluster" "pass_full_encryption_config" {
  attrs = {
    cluster_name = "test-cluster"
    kafka_version = "2.8.1"
    number_of_broker_nodes = 3
    broker_node_group_info = [{
      instance_type = "kafka.m5.large"
      client_subnets = ["subnet-123", "subnet-456", "subnet-789"]
      security_groups = ["sg-123"]
    }]
    encryption_info = [{
      encryption_at_rest_kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
      encryption_in_transit = [{
        client_broker = "TLS"
        in_cluster = true
      }]
    }]
  }
}