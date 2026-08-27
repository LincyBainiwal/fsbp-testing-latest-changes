# Copyright IBM Corp. 2026

policytest {
  targets = ["glue-spark-job-supported-version.policy.hcl"]
}

# Test 1: Compliant Spark job with supported version 3.0
resource "aws_glue_job" "compliant_v3" {
  attrs = {
    name     = "test-spark-job-v3"
    role_arn = "arn:aws:iam::123456789012:role/GlueRole"
    command = [{
      name            = "glueetl"
      script_location = "s3://my-bucket/scripts/job.py"
    }]
    glue_version = "3.0"
  }
}

# Test 2: Compliant Spark job with version 4.0
resource "aws_glue_job" "compliant_v4" {
  attrs = {
    name     = "test-spark-job-v4"
    role_arn = "arn:aws:iam::123456789012:role/GlueRole"
    command = [{
      name            = "glueetl"
      script_location = "s3://my-bucket/scripts/job.py"
    }]
    glue_version = "4.0"
  }
}

# Test 3: Non-compliant Spark job with version 2.0
resource "aws_glue_job" "non_compliant_v2" {
  expect_failure = true
  attrs = {
    name     = "test-spark-job-v2"
    role_arn = "arn:aws:iam::123456789012:role/GlueRole"
    command = [{
      name            = "glueetl"
      script_location = "s3://my-bucket/scripts/job.py"
    }]
    glue_version = "2.0"
  }
}

# Test 4: Non-compliant Spark job with version 1.0
resource "aws_glue_job" "non_compliant_v1" {
  expect_failure = true
  attrs = {
    name     = "test-spark-job-v1"
    role_arn = "arn:aws:iam::123456789012:role/GlueRole"
    command = [{
      name            = "glueetl"
      script_location = "s3://my-bucket/scripts/job.py"
    }]
    glue_version = "1.0"
  }
}

# Test 5: Non-compliant Spark job missing glue_version
resource "aws_glue_job" "missing_version" {
  expect_failure = true
  attrs = {
    name     = "test-spark-job-no-version"
    role_arn = "arn:aws:iam::123456789012:role/GlueRole"
    command = [{
      name            = "glueetl"
      script_location = "s3://my-bucket/scripts/job.py"
    }]
  }
}

# Test 6: Python shell job without version (should pass - not a Spark job)
resource "aws_glue_job" "python_shell" {
  attrs = {
    name     = "test-python-shell-job"
    role_arn = "arn:aws:iam::123456789012:role/GlueRole"
    command = [{
      name            = "pythonshell"
      script_location = "s3://my-bucket/scripts/shell.py"
      python_version  = "3"
    }]
    max_capacity = 1.0
  }
}

# Test 7: Ray job without version check (should pass - not a Spark job)
resource "aws_glue_job" "ray_job" {
  attrs = {
    name     = "test-ray-job"
    role_arn = "arn:aws:iam::123456789012:role/GlueRole"
    command = [{
      name            = "glueray"
      script_location = "s3://my-bucket/scripts/ray.py"
      runtime         = "Ray2.4"
    }]
    glue_version = "4.0"
    worker_type  = "Z.2X"
  }
}

# Test 8: Streaming job without glue_version (Spark-based, should FAIL)
resource "aws_glue_job" "streaming_job" {
  expect_failure = true
  attrs = {
    name     = "test-streaming-job"
    role_arn = "arn:aws:iam::123456789012:role/GlueRole"
    command = [{
      name            = "gluestreaming"
      script_location = "s3://my-bucket/scripts/streaming.py"
    }]
  }
}

# Test 9: Compliant Spark job with version 3.5
resource "aws_glue_job" "compliant_v3_5" {
  attrs = {
    name     = "test-spark-job-v3-5"
    role_arn = "arn:aws:iam::123456789012:role/GlueRole"
    command = [{
      name            = "glueetl"
      script_location = "s3://my-bucket/scripts/job.py"
    }]
    glue_version = "3.5"
  }
}

# Test 10: Non-compliant Spark job with version 0.9
resource "aws_glue_job" "non_compliant_v0_9" {
  expect_failure = true
  attrs = {
    name     = "test-spark-job-v0-9"
    role_arn = "arn:aws:iam::123456789012:role/GlueRole"
    command = [{
      name            = "glueetl"
      script_location = "s3://my-bucket/scripts/job.py"
    }]
    glue_version = "0.9"
  }
}

# Test 11: Compliant streaming Spark job with version 3.0
resource "aws_glue_job" "compliant_streaming_v3" {
  attrs = {
    name     = "test-streaming-spark-v3"
    role_arn = "arn:aws:iam::123456789012:role/GlueRole"
    command = [{
      name            = "gluestreaming"
      script_location = "s3://my-bucket/scripts/streaming.py"
    }]
    glue_version = "3.0"
  }
}

# Test 12: Non-compliant streaming Spark job with version 2.0
resource "aws_glue_job" "non_compliant_streaming_v2" {
  expect_failure = true
  attrs = {
    name     = "test-streaming-spark-v2"
    role_arn = "arn:aws:iam::123456789012:role/GlueRole"
    command = [{
      name            = "gluestreaming"
      script_location = "s3://my-bucket/scripts/streaming.py"
    }]
    glue_version = "2.0"
  }
}
