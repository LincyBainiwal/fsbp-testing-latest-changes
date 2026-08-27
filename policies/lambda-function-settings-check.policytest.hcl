# Copyright IBM Corp. 2026

policytest {
  targets = [
    "lambda-function-settings-check.policy.hcl"
  ]
}

# PASS: supported Python runtime
resource "aws_lambda_function" "pass_python312" {
  attrs = {
    function_name = "test-python-function"
    role          = "arn:aws:iam::123456789012:role/lambda-role"
    runtime       = "python3.12"
    package_type  = "Zip"
    handler       = "index.handler"
  }
}

# PASS: supported Node.js runtime
resource "aws_lambda_function" "pass_nodejs20" {
  attrs = {
    function_name = "test-nodejs-function"
    role          = "arn:aws:iam::123456789012:role/lambda-role"
    runtime       = "nodejs22.x"
    package_type  = "Zip"
    handler       = "index.handler"
  }
}

# PASS: supported Java runtime
resource "aws_lambda_function" "pass_java21" {
  attrs = {
    function_name = "test-java-function"
    role          = "arn:aws:iam::123456789012:role/lambda-role"
    runtime       = "java21"
    package_type  = "Zip"
    handler       = "com.example.Handler"
  }
}

# PASS: supported Ruby runtime
resource "aws_lambda_function" "pass_ruby33" {
  attrs = {
    function_name = "test-ruby-function"
    role          = "arn:aws:iam::123456789012:role/lambda-role"
    runtime       = "ruby3.3"
    package_type  = "Zip"
    handler       = "lambda_function.handler"
  }
}

# PASS: supported .NET runtime
resource "aws_lambda_function" "pass_dotnet8" {
  attrs = {
    function_name = "test-dotnet-function"
    role          = "arn:aws:iam::123456789012:role/lambda-role"
    runtime       = "dotnet8"
    package_type  = "Zip"
    handler       = "Assembly::Namespace.ClassName::MethodName"
  }
}

# PASS: supported provided.al2023 runtime
resource "aws_lambda_function" "pass_provided_al2023" {
  attrs = {
    function_name = "test-provided-function"
    role          = "arn:aws:iam::123456789012:role/lambda-role"
    runtime       = "provided.al2023"
    package_type  = "Zip"
    handler       = "bootstrap"
  }
}

# PASS: package_type omitted defaults to Zip
resource "aws_lambda_function" "pass_default_package_type" {
  attrs = {
    function_name = "test-default-function"
    role          = "arn:aws:iam::123456789012:role/lambda-role"
    runtime       = "python3.11"
    handler       = "index.handler"
  }
}

# PASS (filtered): container image functions are out of scope for Lambda.2
resource "aws_lambda_function" "pass_image_filtered" {
  attrs = {
    function_name = "test-image-function"
    role          = "arn:aws:iam::123456789012:role/lambda-role"
    package_type  = "Image"
    image_uri     = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-function:latest"
  }
}

# FAIL: deprecated Python 3.7
resource "aws_lambda_function" "fail_python37_deprecated" {
  expect_failure = true
  attrs = {
    function_name = "test-deprecated-python-function"
    role          = "arn:aws:iam::123456789012:role/lambda-role"
    runtime       = "python3.7"
    package_type  = "Zip"
    handler       = "index.handler"
  }
}

# FAIL: deprecated Node.js 16.x
resource "aws_lambda_function" "fail_nodejs16_deprecated" {
  expect_failure = true
  attrs = {
    function_name = "test-deprecated-nodejs-function"
    role          = "arn:aws:iam::123456789012:role/lambda-role"
    runtime       = "nodejs16.x"
    package_type  = "Zip"
    handler       = "index.handler"
  }
}

# FAIL: very old Python 2.7
resource "aws_lambda_function" "fail_python27_deprecated" {
  expect_failure = true
  attrs = {
    function_name = "test-old-python-function"
    role          = "arn:aws:iam::123456789012:role/lambda-role"
    runtime       = "python2.7"
    package_type  = "Zip"
    handler       = "index.handler"
  }
}

# FAIL: deprecated Java 8 (non-AL2)
resource "aws_lambda_function" "fail_java8_deprecated" {
  expect_failure = true
  attrs = {
    function_name = "test-old-java-function"
    role          = "arn:aws:iam::123456789012:role/lambda-role"
    runtime       = "java8"
    package_type  = "Zip"
    handler       = "com.example.Handler"
  }
}