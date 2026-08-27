# Copyright IBM Corp. 2026

policytest {
  targets = [
    "msk-connect-connector-encrypted.policy.hcl"
  ]
}
# Test 1: PASS - Connector with TLS encryption enabled
resource "aws_mskconnect_connector" "pass_tls_enabled" {
  attrs = {
    name                   = "compliant-connector"
    kafkaconnect_version   = "2.7.1"
    kafka_cluster_encryption_in_transit = [
      {
        encryption_type = "TLS"
      }
    ]
    capacity = [
      {
        autoscaling = []
        provisioned_capacity = [
          {
            mcu_count    = 2
            worker_count = 1
          }
        ]
      }
    ]
    connector_configuration = {
      "connector.class" = "com.example.Connector"
    }
    kafka_cluster = [
      {
        apache_kafka_cluster = [
          {
            bootstrap_servers = "broker-1:9092"
            vpc = [
              {
                security_groups = ["sg-12345"]
                subnets         = ["subnet-12345"]
              }
            ]
          }
        ]
      }
    ]
    kafka_cluster_client_authentication = [
      {
        authentication_type = "NONE"
      }
    ]
    plugin = [
      {
        custom_plugin = [
          {
            arn      = "arn:aws:kafkaconnect:us-east-1:123456789012:custom-plugin/example"
            revision = 1
          }
        ]
      }
    ]
    service_execution_role_arn = "arn:aws:iam::123456789012:role/service-role"
  }
}

# Test 2: FAIL - Connector with PLAINTEXT (no encryption)
resource "aws_mskconnect_connector" "fail_plaintext" {
  expect_failure = true
  attrs = {
    name                   = "non-compliant-connector"
    kafkaconnect_version   = "2.7.1"
    kafka_cluster_encryption_in_transit = [
      {
        encryption_type = "PLAINTEXT"
      }
    ]
    capacity = [
      {
        autoscaling = []
        provisioned_capacity = [
          {
            mcu_count    = 2
            worker_count = 1
          }
        ]
      }
    ]
    connector_configuration = {
      "connector.class" = "com.example.Connector"
    }
    kafka_cluster = [
      {
        apache_kafka_cluster = [
          {
            bootstrap_servers = "broker-1:9092"
            vpc = [
              {
                security_groups = ["sg-12345"]
                subnets         = ["subnet-12345"]
              }
            ]
          }
        ]
      }
    ]
    kafka_cluster_client_authentication = [
      {
        authentication_type = "NONE"
      }
    ]
    plugin = [
      {
        custom_plugin = [
          {
            arn      = "arn:aws:kafkaconnect:us-east-1:123456789012:custom-plugin/example"
            revision = 1
          }
        ]
      }
    ]
    service_execution_role_arn = "arn:aws:iam::123456789012:role/service-role"
  }
}

# Test 3: FILTERED - Connector without encryption_in_transit configuration
# This resource should be filtered out by the policy's filter clause
resource "aws_mskconnect_connector" "filtered_no_config" {
  attrs = {
    name                   = "no-encryption-config-connector"
    kafkaconnect_version   = "2.7.1"
    # kafka_cluster_encryption_in_transit is not set
    capacity = [
      {
        autoscaling = []
        provisioned_capacity = [
          {
            mcu_count    = 2
            worker_count = 1
          }
        ]
      }
    ]
    connector_configuration = {
      "connector.class" = "com.example.Connector"
    }
    kafka_cluster = [
      {
        apache_kafka_cluster = [
          {
            bootstrap_servers = "broker-1:9092"
            vpc = [
              {
                security_groups = ["sg-12345"]
                subnets         = ["subnet-12345"]
              }
            ]
          }
        ]
      }
    ]
    kafka_cluster_client_authentication = [
      {
        authentication_type = "NONE"
      }
    ]
    plugin = [
      {
        custom_plugin = [
          {
            arn      = "arn:aws:kafkaconnect:us-east-1:123456789012:custom-plugin/example"
            revision = 1
          }
        ]
      }
    ]
    service_execution_role_arn = "arn:aws:iam::123456789012:role/service-role"
  }
}

# Test 4: FAIL - Connector with empty encryption_in_transit block (defaults to PLAINTEXT)
resource "aws_mskconnect_connector" "fail_empty_config" {
  expect_failure = true
  attrs = {
    name                   = "empty-config-connector"
    kafkaconnect_version   = "2.7.1"
    kafka_cluster_encryption_in_transit = [
      {
        # encryption_type not specified, defaults to PLAINTEXT
      }
    ]
    capacity = [
      {
        autoscaling = []
        provisioned_capacity = [
          {
            mcu_count    = 2
            worker_count = 1
          }
        ]
      }
    ]
    connector_configuration = {
      "connector.class" = "com.example.Connector"
    }
    kafka_cluster = [
      {
        apache_kafka_cluster = [
          {
            bootstrap_servers = "broker-1:9092"
            vpc = [
              {
                security_groups = ["sg-12345"]
                subnets         = ["subnet-12345"]
              }
            ]
          }
        ]
      }
    ]
    kafka_cluster_client_authentication = [
      {
        authentication_type = "NONE"
      }
    ]
    plugin = [
      {
        custom_plugin = [
          {
            arn      = "arn:aws:kafkaconnect:us-east-1:123456789012:custom-plugin/example"
            revision = 1
          }
        ]
      }
    ]
    service_execution_role_arn = "arn:aws:iam::123456789012:role/service-role"
  }
}