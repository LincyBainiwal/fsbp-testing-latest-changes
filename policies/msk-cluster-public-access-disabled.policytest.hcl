# Copyright IBM Corp. 2026

policytest {
  targets = [
    "msk-cluster-public-access-disabled.policy.hcl"
  ]
}
# Pass case 1: Public access explicitly disabled
resource "aws_msk_cluster" "pass_explicit_disabled" {
  attrs = {
    cluster_name = "test-cluster-explicit-disabled"
    kafka_version = "2.8.1"
    number_of_broker_nodes = 3
    broker_node_group_info = [
      {
        instance_type = "kafka.m5.large"
        client_subnets = ["subnet-12345", "subnet-67890", "subnet-abcde"]
        security_groups = ["sg-12345"]
        connectivity_info = [
          {
            public_access = [
              {
                type = "DISABLED"
              }
            ]
          }
        ]
      }
    ]
  }
}

# Pass case 2: No public_access block (defaults to disabled)
resource "aws_msk_cluster" "pass_no_public_access_block" {
  attrs = {
    cluster_name = "test-cluster-default"
    kafka_version = "2.8.1"
    number_of_broker_nodes = 3
    broker_node_group_info = [
      {
        instance_type = "kafka.m5.large"
        client_subnets = ["subnet-12345", "subnet-67890", "subnet-abcde"]
        security_groups = ["sg-12345"]
        connectivity_info = [
          {
            # No public_access block - defaults to disabled
          }
        ]
      }
    ]
  }
}

# Pass case 3: No connectivity_info block (defaults to disabled)
resource "aws_msk_cluster" "pass_no_connectivity_info" {
  attrs = {
    cluster_name = "test-cluster-no-connectivity"
    kafka_version = "2.8.1"
    number_of_broker_nodes = 3
    broker_node_group_info = [
      {
        instance_type = "kafka.m5.large"
        client_subnets = ["subnet-12345", "subnet-67890", "subnet-abcde"]
        security_groups = ["sg-12345"]
        # No connectivity_info block - defaults to disabled
      }
    ]
  }
}

# Fail case: Public access enabled
resource "aws_msk_cluster" "fail_public_access_enabled" {
  expect_failure = true
  attrs = {
    cluster_name = "test-cluster-public"
    kafka_version = "2.8.1"
    number_of_broker_nodes = 3
    broker_node_group_info = [
      {
        instance_type = "kafka.m5.large"
        client_subnets = ["subnet-12345", "subnet-67890", "subnet-abcde"]
        security_groups = ["sg-12345"]
        connectivity_info = [
          {
            public_access = [
              {
                type = "SERVICE_PROVIDED_EIPS"
              }
            ]
          }
        ]
      }
    ]
  }
}