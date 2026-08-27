# Copyright IBM Corp. 2026

policytest {
  targets = [
    "step-functions-state-machine-logging-enabled.policy.hcl"
  ]
}

inputs {
  logLevel = "ERROR"
}

# Pass case: Required minimum is ERROR; state machine uses ERROR (meets minimum)
resource "aws_sfn_state_machine" "pass_custom_error_level" {
  attrs = {
    name = "example-state-machine-custom-error"
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

# Pass case: Required minimum is ERROR; state machine uses ALL (more verbose, satisfies minimum)
resource "aws_sfn_state_machine" "pass_more_verbose_than_required" {
  attrs = {
    name = "example-state-machine-all-meets-error"
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

# Fail case: Required minimum is ERROR; state machine uses FATAL (less verbose, does not meet minimum)
resource "aws_sfn_state_machine" "fail_below_required_level" {
  expect_failure = true
  attrs = {
    name = "example-state-machine-fatal-below-error"
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

# Fail case: log_destination missing required ":*" suffix
resource "aws_sfn_state_machine" "fail_log_destination_missing_suffix" {
  expect_failure = true
  attrs = {
    name = "example-state-machine-bad-suffix"
    role_arn = "arn:aws:iam::123456789012:role/StepFunctionsRole"
    definition = "{\"Comment\":\"A Hello World example\"}"
    logging_configuration = [
      {
        level = "ERROR"
        log_destination = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/stepfunctions/example"
        include_execution_data = false
      }
    ]
  }
}
