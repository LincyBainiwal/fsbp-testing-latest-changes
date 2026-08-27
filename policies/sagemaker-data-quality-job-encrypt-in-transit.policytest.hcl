# Copyright IBM Corp. 2026

policytest {
    targets = [
        "sagemaker-data-quality-job-encrypt-in-transit.policy.hcl"
    ]
}

# Test 1: PASS - Inter-container traffic encryption enabled
resource "aws_sagemaker_data_quality_job_definition" "encryption_enabled" {
  attrs = {
    name = "data-quality-job-encrypted"
    role_arn = "arn:aws:iam::123456789012:role/SageMakerRole"
    data_quality_app_specification = [{
      image_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/sagemaker-model-monitor-analyzer"
    }]
    data_quality_job_input = [{
      endpoint_input = [{
        endpoint_name = "my-endpoint"
        local_path = "/opt/ml/processing/input"
      }]
    }]
    data_quality_job_output_config = [{
      monitoring_outputs = [{
        s3_output = [{
          s3_uri = "s3://my-bucket/monitoring-output"
          local_path = "/opt/ml/processing/output"
        }]
      }]
    }]
    job_resources = [{
      cluster_config = [{
        instance_count = 1
        instance_type = "ml.m5.xlarge"
        volume_size_in_gb = 20
      }]
    }]
    network_config = [{
      enable_inter_container_traffic_encryption = true
      enable_network_isolation = false
    }]
  }
}

# Test 2: FAIL - Inter-container traffic encryption explicitly disabled
resource "aws_sagemaker_data_quality_job_definition" "encryption_disabled" {
  expect_failure = true
  attrs = {
    name = "data-quality-job-not-encrypted"
    role_arn = "arn:aws:iam::123456789012:role/SageMakerRole"
    data_quality_app_specification = [{
      image_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/sagemaker-model-monitor-analyzer"
    }]
    data_quality_job_input = [{
      endpoint_input = [{
        endpoint_name = "my-endpoint"
        local_path = "/opt/ml/processing/input"
      }]
    }]
    data_quality_job_output_config = [{
      monitoring_outputs = [{
        s3_output = [{
          s3_uri = "s3://my-bucket/monitoring-output"
          local_path = "/opt/ml/processing/output"
        }]
      }]
    }]
    job_resources = [{
      cluster_config = [{
        instance_count = 1
        instance_type = "ml.m5.xlarge"
        volume_size_in_gb = 20
      }]
    }]
    network_config = [{
      enable_inter_container_traffic_encryption = false
      enable_network_isolation = true
    }]
  }
}

# Test 3: SKIP - No network_config defined (policy filter excludes this)
resource "aws_sagemaker_data_quality_job_definition" "no_network_config" {
  attrs = {
    name = "data-quality-job-no-network"
    role_arn = "arn:aws:iam::123456789012:role/SageMakerRole"
    data_quality_app_specification = [{
      image_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/sagemaker-model-monitor-analyzer"
    }]
    data_quality_job_input = [{
      endpoint_input = [{
        endpoint_name = "my-endpoint"
        local_path = "/opt/ml/processing/input"
      }]
    }]
    data_quality_job_output_config = [{
      monitoring_outputs = [{
        s3_output = [{
          s3_uri = "s3://my-bucket/monitoring-output"
          local_path = "/opt/ml/processing/output"
        }]
      }]
    }]
    job_resources = [{
      cluster_config = [{
        instance_count = 1
        instance_type = "ml.m5.xlarge"
        volume_size_in_gb = 20
      }]
    }]
  }
}

# Test 4: FAIL - network_config exists but encryption setting not specified (defaults to false)
resource "aws_sagemaker_data_quality_job_definition" "encryption_not_set" {
  expect_failure = true
  attrs = {
    name = "data-quality-job-encryption-unset"
    role_arn = "arn:aws:iam::123456789012:role/SageMakerRole"
    data_quality_app_specification = [{
      image_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/sagemaker-model-monitor-analyzer"
    }]
    data_quality_job_input = [{
      endpoint_input = [{
        endpoint_name = "my-endpoint"
        local_path = "/opt/ml/processing/input"
      }]
    }]
    data_quality_job_output_config = [{
      monitoring_outputs = [{
        s3_output = [{
          s3_uri = "s3://my-bucket/monitoring-output"
          local_path = "/opt/ml/processing/output"
        }]
      }]
    }]
    job_resources = [{
      cluster_config = [{
        instance_count = 1
        instance_type = "ml.m5.xlarge"
        volume_size_in_gb = 20
      }]
    }]
    network_config = [{
      enable_network_isolation = true
    }]
  }
}
