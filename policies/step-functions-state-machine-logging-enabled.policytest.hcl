# Copyright IBM Corp. 2026

policytest {
  targets = [
    "step-functions-state-machine-logging-enabled.policy.hcl"
  ]
}
# Pass case: Logging enabled with level ALL and valid log destination
resource "aws_sfn_state_machine" "pass_with_all_level" {
  attrs = {
    name = "example-state-machine"
    role_arn = "arn:aws:iam::123456789012:role/StepFunctionsRole"
    definition = "{\"Comment\":\"A Hello World example\"}"
    logging_configuration = [
      {
        level = "ALL"
        log_destination = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/stepfunctions/example:*"
        include_execution_data = true
      }
    ]
  }
}

# Pass case: Logging enabled with level ERROR and valid log destination
resource "aws_sfn_state_machine" "pass_with_error_level" {
  attrs = {
    name = "example-state-machine"
    role_arn = "arn:aws:iam::123456789012:role/StepFunctionsRole"
    definition = "{\"Comment\":\"A Hello World example\"}"
    logging_configuration = [
      {
        level = "ERROR"
        log_destination = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/stepfunctions/example:*"
        include_execution_data = false
      }
    ]
  }
}

# Pass case: Logging enabled with level FATAL and valid log destination
resource "aws_sfn_state_machine" "pass_with_fatal_level" {
  attrs = {
    name = "example-state-machine"
    role_arn = "arn:aws:iam::123456789012:role/StepFunctionsRole"
    definition = "{\"Comment\":\"A Hello World example\"}"
    logging_configuration = [
      {
        level = "FATAL"
        log_destination = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/stepfunctions/example:*"
        include_execution_data = false
      }
    ]
  }
}

# Fail case: Logging level set to OFF
resource "aws_sfn_state_machine" "fail_with_off_level" {
  expect_failure = true
  attrs = {
    name = "example-state-machine"
    role_arn = "arn:aws:iam::123456789012:role/StepFunctionsRole"
    definition = "{\"Comment\":\"A Hello World example\"}"
    logging_configuration = [
      {
        level = "OFF"
        log_destination = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/stepfunctions/example:*"
        include_execution_data = false
      }
    ]
  }
}

# Fail case: Missing log_destination
resource "aws_sfn_state_machine" "fail_missing_log_destination" {
  expect_failure = true
  attrs = {
    name = "example-state-machine"
    role_arn = "arn:aws:iam::123456789012:role/StepFunctionsRole"
    definition = "{\"Comment\":\"A Hello World example\"}"
    logging_configuration = [
      {
        level = "ALL"
        log_destination = ""
        include_execution_data = false
      }
    ]
  }
}

# Fail case: No logging_configuration block
resource "aws_sfn_state_machine" "fail_no_logging_config" {
  expect_failure = true
  attrs = {
    name = "example-state-machine"
    role_arn = "arn:aws:iam::123456789012:role/StepFunctionsRole"
    definition = "{\"Comment\":\"A Hello World example\"}"
  }
}

# Fail case: Empty logging_configuration block
resource "aws_sfn_state_machine" "fail_empty_logging_config" {
  expect_failure = true
  attrs = {
    name = "example-state-machine"
    role_arn = "arn:aws:iam::123456789012:role/StepFunctionsRole"
    definition = "{\"Comment\":\"A Hello World example\"}"
    logging_configuration = []
  }
}
