# Copyright IBM Corp. 2026

policytest {
    targets = [
        "sagemaker-model-explainability-job-encrypt-in-transit.policy.hcl"
    ]
}

# Test 1: PASS - ModelExplainability monitoring schedule with inter-container traffic encryption enabled
resource "aws_sagemaker_monitoring_schedule" "pass_encryption_enabled" {
  attrs = {
    name = "test-schedule-dummy-pass"
    monitoring_schedule_config = [
      {
        monitoring_type = "ModelExplainability"
        monitoring_job_definition = [
          {
            role_arn = "arn:aws:iam::999999999999:role/TestSageMakerRole"
            monitoring_app_specification = [
              {
                image_uri = "999999999999.dkr.ecr.fake-region.amazonaws.com/fake-explainability-image:dummy"
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
                        s3_uri = "s3://my-bucket/explainability-output"
                        local_path = "/opt/ml/processing/output"
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
                    volume_size_in_gb = 30
                  }
                ]
              }
            ]
            network_config = [
              {
                enable_inter_container_traffic_encryption = true
                enable_network_isolation = false
              }
            ]
          }
        ]
      }
    ]
  }
}

# Test 2: FAIL - ModelExplainability monitoring schedule with inter-container traffic encryption explicitly disabled
resource "aws_sagemaker_monitoring_schedule" "fail_encryption_disabled" {
  expect_failure = true
  attrs = {
    name = "test-schedule-dummy-fail"
    monitoring_schedule_config = [
      {
        monitoring_type = "ModelExplainability"
        monitoring_job_definition = [
          {
            role_arn = "arn:aws:iam::999999999999:role/TestSageMakerRole"
            monitoring_app_specification = [
              {
                image_uri = "999999999999.dkr.ecr.fake-region.amazonaws.com/fake-explainability-image:dummy"
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
                        s3_uri = "s3://my-bucket/explainability-output"
                        local_path = "/opt/ml/processing/output"
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
                    volume_size_in_gb = 30
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
          }
        ]
      }
    ]
  }
}

# Test 3: FAIL - ModelExplainability monitoring schedule with network_config but encryption setting not specified (defaults to false)
resource "aws_sagemaker_monitoring_schedule" "fail_encryption_not_specified" {
  expect_failure = true
  attrs = {
    name = "test-schedule-dummy-no-encryption"
    monitoring_schedule_config = [
      {
        monitoring_type = "ModelExplainability"
        monitoring_job_definition = [
          {
            role_arn = "arn:aws:iam::999999999999:role/TestSageMakerRole"
            monitoring_app_specification = [
              {
                image_uri = "999999999999.dkr.ecr.fake-region.amazonaws.com/fake-explainability-image:dummy"
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
                        s3_uri = "s3://my-bucket/explainability-output"
                        local_path = "/opt/ml/processing/output"
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
                    volume_size_in_gb = 30
                  }
                ]
              }
            ]
            network_config = [
              {
                enable_network_isolation = true
                vpc_config = [
                  {
                    security_group_ids = ["sg-dummytest123"]
                    subnets = ["subnet-dummytest123"]
                  }
                ]
              }
            ]
          }
        ]
      }
    ]
  }
}

# Test 4: PASS - Uses monitoring_job_definition_name (not inline) - filtered by different monitoring type
resource "aws_sagemaker_monitoring_schedule" "filtered_no_inline_job_definition" {
  attrs = {
    name = "test-schedule-dummy-filtered"
    monitoring_schedule_config = [
      {
        monitoring_type = "ModelBias"
        monitoring_job_definition_name = "test-job-def-dummy"
      }
    ]
  }
}

# Test 5: PASS - Different monitoring type (DataQuality) should be filtered out
resource "aws_sagemaker_monitoring_schedule" "filtered_different_type" {
  attrs = {
    name = "test-schedule-dummy-dataquality"
    monitoring_schedule_config = [
      {
        monitoring_type = "DataQuality"
        monitoring_job_definition = [
          {
            role_arn = "arn:aws:iam::999999999999:role/TestSageMakerRole"
            monitoring_app_specification = [
              {
                image_uri = "999999999999.dkr.ecr.fake-region.amazonaws.com/fake-dataquality-image:dummy"
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
                        s3_uri = "s3://dummy-bucket-test/dq-output"
                        local_path = "/opt/ml/processing/output"
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
                    volume_size_in_gb = 30
                  }
                ]
              }
            ]
            network_config = [
              {
                enable_inter_container_traffic_encryption = false
              }
            ]
          }
        ]
      }
    ]
  }
}
