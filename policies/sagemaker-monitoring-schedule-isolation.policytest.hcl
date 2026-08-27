# Copyright IBM Corp. 2026

policytest {
    targets = [
        "sagemaker-monitoring-schedule-isolation.policy.hcl"
    ]
}

# Test 1: PASS - Monitoring schedule with inline job definition - network isolation enabled
resource "aws_sagemaker_monitoring_schedule" "monitoring_schedule_inline_enabled" {
  attrs = {
    monitoring_schedule_config = [
      {
        monitoring_job_definition = [
          {
            network_config = [
              {
                enable_network_isolation = true
              }
            ]
          }
        ]
      }
    ]
  }
}

# Test 2: FAIL - Monitoring schedule with inline job definition - network isolation disabled
resource "aws_sagemaker_monitoring_schedule" "monitoring_schedule_inline_disabled" {
  expect_failure = true
  attrs = {
    monitoring_schedule_config = [
      {
        monitoring_job_definition = [
          {
            network_config = [
              {
                enable_network_isolation = false
              }
            ]
          }
        ]
      }
    ]
  }
}

# Test 3: FAIL - Monitoring schedule with inline job definition - no network_config
resource "aws_sagemaker_monitoring_schedule" "monitoring_schedule_inline_no_config" {
  expect_failure = true
  attrs = {
    monitoring_schedule_config = [
      {
        monitoring_job_definition = [
          {
            # No network_config defined
          }
        ]
      }
    ]
  }
}

# Test 4: PASS - Data quality job definition - network isolation enabled
resource "aws_sagemaker_data_quality_job_definition" "data_quality_enabled" {
  attrs = {
    network_config = [
      {
        enable_network_isolation = true
      }
    ]
  }
}

# Test 5: FAIL - Data quality job definition - network isolation disabled
resource "aws_sagemaker_data_quality_job_definition" "data_quality_disabled" {
  expect_failure = true
  attrs = {
    network_config = [
      {
        enable_network_isolation = false
      }
    ]
  }
}

# Test 6: FAIL - Data quality job definition - no network_config
resource "aws_sagemaker_data_quality_job_definition" "data_quality_no_config" {
  expect_failure = true
  attrs = {
    name = "my-data-quality-job-definition"
    # No network_config defined
  }
}
