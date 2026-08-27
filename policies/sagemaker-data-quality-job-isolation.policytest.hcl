# Copyright IBM Corp. 2026

policytest {
    targets = [
        "sagemaker-data-quality-job-isolation.policy.hcl"
    ]
}

# Test 1: PASS - Network isolation explicitly enabled
resource "aws_sagemaker_data_quality_job_definition" "pass_with_network_isolation_enabled" {
  attrs = {
    name = "compliant-data-quality-job"
    role_arn = "arn:aws:iam::123456789012:role/SageMakerRole"
    network_config = [
      {
        enable_network_isolation = true
        enable_inter_container_traffic_encryption = false
      }
    ]
    data_quality_app_specification = [
      {
        image_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/sagemaker-model-monitor-analyzer"
      }
    ]
    data_quality_job_input = [
      {
        endpoint_input = [
          {
            endpoint_name = "my-endpoint"
            local_path = "/opt/ml/processing/input"
          }
        ]
      }
    ]
    data_quality_job_output_config = [
      {
        monitoring_outputs = [
          {
            s3_output = [
              {
                s3_uri = "s3://my-bucket/monitoring-output"
                local_path = "/opt/ml/processing/output"
              }
            ]
          }
        ]
      }
    ]
    job_resources = [
      {
        cluster_config = [
          {
            instance_count = 1
            instance_type = "ml.m5.xlarge"
            volume_size_in_gb = 20
          }
        ]
      }
    ]
  }
}

# Test 2: FAIL - Network isolation explicitly disabled
resource "aws_sagemaker_data_quality_job_definition" "fail_with_network_isolation_disabled" {
  expect_failure = true
  attrs = {
    name = "non-compliant-data-quality-job"
    role_arn = "arn:aws:iam::123456789012:role/SageMakerRole"
    network_config = [
      {
        enable_network_isolation = false
        enable_inter_container_traffic_encryption = false
      }
    ]
    data_quality_app_specification = [
      {
        image_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/sagemaker-model-monitor-analyzer"
      }
    ]
    data_quality_job_input = [
      {
        endpoint_input = [
          {
            endpoint_name = "my-endpoint"
            local_path = "/opt/ml/processing/input"
          }
        ]
      }
    ]
    data_quality_job_output_config = [
      {
        monitoring_outputs = [
          {
            s3_output = [
              {
                s3_uri = "s3://my-bucket/monitoring-output"
                local_path = "/opt/ml/processing/output"
              }
            ]
          }
        ]
      }
    ]
    job_resources = [
      {
        cluster_config = [
          {
            instance_count = 1
            instance_type = "ml.m5.xlarge"
            volume_size_in_gb = 20
          }
        ]
      }
    ]
  }
}

# Test 3: FAIL - No network_config block at all
resource "aws_sagemaker_data_quality_job_definition" "fail_without_network_config" {
  expect_failure = true
  attrs = {
    name = "non-compliant-data-quality-job-no-config"
    role_arn = "arn:aws:iam::123456789012:role/SageMakerRole"
    data_quality_app_specification = [
      {
        image_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/sagemaker-model-monitor-analyzer"
      }
    ]
    data_quality_job_input = [
      {
        endpoint_input = [
          {
            endpoint_name = "my-endpoint"
            local_path = "/opt/ml/processing/input"
          }
        ]
      }
    ]
    data_quality_job_output_config = [
      {
        monitoring_outputs = [
          {
            s3_output = [
              {
                s3_uri = "s3://my-bucket/monitoring-output"
                local_path = "/opt/ml/processing/output"
              }
            ]
          }
        ]
      }
    ]
    job_resources = [
      {
        cluster_config = [
          {
            instance_count = 1
            instance_type = "ml.m5.xlarge"
            volume_size_in_gb = 20
          }
        ]
      }
    ]
  }
}

# Test 4: FAIL - Network config exists but enable_network_isolation attribute is missing
resource "aws_sagemaker_data_quality_job_definition" "fail_with_network_config_but_missing_attribute" {
  expect_failure = true
  attrs = {
    name = "non-compliant-data-quality-job-partial"
    role_arn = "arn:aws:iam::123456789012:role/SageMakerRole"
    network_config = [
      {
        enable_inter_container_traffic_encryption = true
        vpc_config = [
          {
            security_group_ids = ["sg-12345678"]
            subnets = ["subnet-12345678"]
          }
        ]
      }
    ]
    data_quality_app_specification = [
      {
        image_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/sagemaker-model-monitor-analyzer"
      }
    ]
    data_quality_job_input = [
      {
        endpoint_input = [
          {
            endpoint_name = "my-endpoint"
            local_path = "/opt/ml/processing/input"
          }
        ]
      }
    ]
    data_quality_job_output_config = [
      {
        monitoring_outputs = [
          {
            s3_output = [
              {
                s3_uri = "s3://my-bucket/monitoring-output"
                local_path = "/opt/ml/processing/output"
              }
            ]
          }
        ]
      }
    ]
    job_resources = [
      {
        cluster_config = [
          {
            instance_count = 1
            instance_type = "ml.m5.xlarge"
            volume_size_in_gb = 20
          }
        ]
      }
    ]
  }
}