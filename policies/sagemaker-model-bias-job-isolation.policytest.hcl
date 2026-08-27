# Copyright IBM Corp. 2026

policytest {
    targets = [
        "sagemaker-model-bias-job-isolation.policy.hcl"
    ]
}

# Test 1: PASS - ModelBias monitoring with isolation enabled
resource "aws_sagemaker_monitoring_schedule" "pass_isolation_enabled" {
  attrs = {
    monitoring_schedule_config = [
      {
        monitoring_type = "ModelQuality"
        monitoring_job_definition = [
          {
            monitoring_app_specification = [
              {
                image_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/sagemaker-model-monitor-analyzer"
              }
            ]
            monitoring_inputs = [
              {
                endpoint_input = [
                  {
                    endpoint_name = "my-endpoint"
                    local_path = "/opt/ml/processing/input"
                  }
                ]
              }
            ]
            monitoring_output_config = [
              {
                monitoring_outputs = [
                  {
                    s3_output = [
                      {
                        s3_uri = "s3://my-bucket/monitoring-output"
                      }
                    ]
                  }
                ]
              }
            ]
            monitoring_resources = [
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
            network_config = [
              {
                enable_inter_container_traffic_encryption = false
                enable_network_isolation = true
              }
            ]
            role_arn = "arn:aws:iam::123456789012:role/SageMakerRole"
          }
        ]
      }
    ]
  }
}

# Test 2: FAIL - ModelBias monitoring with isolation disabled
resource "aws_sagemaker_monitoring_schedule" "fail_isolation_disabled" {
  expect_failure = true
  attrs = {
    monitoring_schedule_config = [
      {
        monitoring_type = "ModelBias"
        monitoring_job_definition = [
          {
            monitoring_app_specification = [
              {
                image_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/sagemaker-model-monitor-analyzer"
              }
            ]
            monitoring_inputs = [
              {
                endpoint_input = [
                  {
                    endpoint_name = "my-endpoint"
                    local_path = "/opt/ml/processing/input"
                  }
                ]
              }
            ]
            monitoring_output_config = [
              {
                monitoring_outputs = [
                  {
                    s3_output = [
                      {
                        s3_uri = "s3://my-bucket/monitoring-output"
                      }
                    ]
                  }
                ]
              }
            ]
            monitoring_resources = [
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
            network_config = [
              {
                enable_inter_container_traffic_encryption = false
                enable_network_isolation = false
              }
            ]
            role_arn = "arn:aws:iam::123456789012:role/SageMakerRole"
          }
        ]
      }
    ]
  }
}

# Test 3: FAIL - ModelBias monitoring without network_config
resource "aws_sagemaker_monitoring_schedule" "fail_model_bias_no_network_config" {
  expect_failure = true
  attrs = {
    monitoring_schedule_config = [
      {
        monitoring_type = "ModelBias"
        monitoring_job_definition = [
          {
            monitoring_app_specification = [
              {
                image_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/sagemaker-model-monitor-analyzer"
              }
            ]
            monitoring_inputs = [
              {
                endpoint_input = [
                  {
                    endpoint_name = "my-endpoint"
                    local_path = "/opt/ml/processing/input"
                  }
                ]
              }
            ]
            monitoring_output_config = [
              {
                monitoring_outputs = [
                  {
                    s3_output = [
                      {
                        s3_uri = "s3://my-bucket/monitoring-output"
                      }
                    ]
                  }
                ]
              }
            ]
            monitoring_resources = [
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
            role_arn = "arn:aws:iam::123456789012:role/SageMakerRole"
          }
        ]
      }
    ]
  }
}

# Test 4: PASS - DataQuality monitoring (not ModelQuality, should be ignored)
resource "aws_sagemaker_monitoring_schedule" "pass_data_quality_monitoring" {
  attrs = {
    monitoring_schedule_config = [
      {
        monitoring_type = "DataQuality"
        monitoring_job_definition = [
          {
            monitoring_app_specification = [
              {
                image_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/sagemaker-model-monitor-analyzer"
              }
            ]
            monitoring_inputs = [
              {
                endpoint_input = [
                  {
                    endpoint_name = "my-endpoint"
                    local_path = "/opt/ml/processing/input"
                  }
                ]
              }
            ]
            monitoring_output_config = [
              {
                monitoring_outputs = [
                  {
                    s3_output = [
                      {
                        s3_uri = "s3://my-bucket/monitoring-output"
                      }
                    ]
                  }
                ]
              }
            ]
            monitoring_resources = [
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
            role_arn = "arn:aws:iam::123456789012:role/SageMakerRole"
          }
        ]
      }
    ]
  }
}

# Test 5: PASS - Monitoring schedule without inline job definition
resource "aws_sagemaker_monitoring_schedule" "pass_no_inline_job_definition" {
  attrs = {
    monitoring_schedule_config = [
      {
        monitoring_type = "ModelBias"
        monitoring_job_definition_name = "existing-job-definition"
      }
    ]
  }
}