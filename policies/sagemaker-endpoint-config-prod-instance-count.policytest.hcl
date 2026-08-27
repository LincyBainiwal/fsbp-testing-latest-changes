# Copyright IBM Corp. 2026

policytest {
    targets = [
        "sagemaker-endpoint-config-prod-instance-count.policy.hcl"
    ]
}

# Test 1: PASS - Single production variant with initial_instance_count = 2
resource "aws_sagemaker_endpoint_configuration" "pass_single_variant_count_2" {
  attrs = {
    name = "example-config"
    production_variants = [
      {
        variant_name = "variant-1"
        model_name = "example-model"
        initial_instance_count = 2
        instance_type = "ml.m5.large"
      }
    ]
  }
}

# Test 2: FAIL - Single production variant with initial_instance_count = 1
resource "aws_sagemaker_endpoint_configuration" "fail_single_variant_count_1" {
  expect_failure = true
  attrs = {
    name = "example-config"
    production_variants = [
      {
        variant_name = "variant-1"
        model_name = "example-model"
        initial_instance_count = 1
        instance_type = "ml.m5.large"
      }
    ]
  }
}

# Test 3: FAIL - Production variant missing initial_instance_count (defaults to 1)
resource "aws_sagemaker_endpoint_configuration" "fail_missing_instance_count" {
  expect_failure = true
  attrs = {
    name = "example-config"
    production_variants = [
      {
        variant_name = "variant-1"
        model_name = "example-model"
        instance_type = "ml.m5.large"
      }
    ]
  }
}

# Test 4: PASS - Serverless variant (exempt from requirement)
resource "aws_sagemaker_endpoint_configuration" "pass_serverless_variant" {
  attrs = {
    name = "example-config"
    production_variants = [
      {
        variant_name = "serverless-variant"
        model_name = "example-model"
        serverless_config = [
          {
            max_concurrency = 10
            memory_size_in_mb = 2048
          }
        ]
      }
    ]
  }
}

# Test 5: PASS - Multiple production variants, all with initial_instance_count > 1
resource "aws_sagemaker_endpoint_configuration" "pass_multiple_variants_all_compliant" {
  attrs = {
    name = "example-config"
    production_variants = [
      {
        variant_name = "variant-1"
        model_name = "model-1"
        initial_instance_count = 2
        instance_type = "ml.m5.large"
      },
      {
        variant_name = "variant-2"
        model_name = "model-2"
        initial_instance_count = 3
        instance_type = "ml.m5.xlarge"
      }
    ]
  }
}

# Test 6: FAIL - Multiple production variants, one with initial_instance_count = 1
resource "aws_sagemaker_endpoint_configuration" "fail_multiple_variants_one_non_compliant" {
  expect_failure = true
  attrs = {
    name = "example-config"
    production_variants = [
      {
        variant_name = "variant-1"
        model_name = "model-1"
        initial_instance_count = 2
        instance_type = "ml.m5.large"
      },
      {
        variant_name = "variant-2"
        model_name = "model-2"
        initial_instance_count = 1
        instance_type = "ml.m5.xlarge"
      }
    ]
  }
}

# Test 7: FAIL - Shadow production variant with initial_instance_count = 1
resource "aws_sagemaker_endpoint_configuration" "fail_shadow_variant_count_1" {
  expect_failure = true
  attrs = {
    name = "example-config"
    production_variants = [
      {
        variant_name = "main-variant"
        model_name = "main-model"
        initial_instance_count = 2
        instance_type = "ml.m5.large"
      }
    ]
    shadow_production_variants = [
      {
        variant_name = "shadow-variant"
        model_name = "shadow-model"
        initial_instance_count = 1
        instance_type = "ml.m5.large"
      }
    ]
  }
}

# Test 8: PASS - Shadow production variant with initial_instance_count = 3
resource "aws_sagemaker_endpoint_configuration" "pass_shadow_variant_count_3" {
  attrs = {
    name = "example-config"
    production_variants = [
      {
        variant_name = "main-variant"
        model_name = "main-model"
        initial_instance_count = 2
        instance_type = "ml.m5.large"
      }
    ]
    shadow_production_variants = [
      {
        variant_name = "shadow-variant"
        model_name = "shadow-model"
        initial_instance_count = 3
        instance_type = "ml.m5.large"
      }
    ]
  }
}

# Test 9: PASS - Mixed variants - instance-based (count=2) and serverless
resource "aws_sagemaker_endpoint_configuration" "pass_mixed_instance_and_serverless" {
  attrs = {
    name = "example-config"
    production_variants = [
      {
        variant_name = "instance-variant"
        model_name = "instance-model"
        initial_instance_count = 2
        instance_type = "ml.m5.large"
      },
      {
        variant_name = "serverless-variant"
        model_name = "serverless-model"
        serverless_config = [
          {
            max_concurrency = 10
            memory_size_in_mb = 2048
          }
        ]
      }
    ]
  }
}
