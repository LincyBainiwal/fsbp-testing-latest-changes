# Copyright IBM Corp. 2026

policytest {
  targets = [
    "step-functions-state-machine-logging-enabled.policy.hcl"
  ]
}

inputs {
  cloudWatchLogGroupArns = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/stepfunctions/approved-a:*,arn:aws:logs:us-east-1:123456789012:log-group:/aws/stepfunctions/approved-b:*"
}

# Pass case: log_destination matches one of the allowed CloudWatch log group ARNs
resource "aws_sfn_state_machine" "pass_allowed_log_group" {
  attrs = {
    name = "example-state-machine-allowed-lg"
    role_arn = "arn:aws:iam::123456789012:role/StepFunctionsRole"
    definition = "{\"Comment\":\"A Hello World example\"}"
    logging_configuration = [
      {
        level = "ERROR"
        log_destination = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/stepfunctions/approved-a:*"
        include_execution_data = false
      }
    ]
  }
}

# Fail case: log_destination does not match any allowed CloudWatch log group ARN
resource "aws_sfn_state_machine" "fail_disallowed_log_group" {
  expect_failure = true
  attrs = {
    name = "example-state-machine-disallowed-lg"
    role_arn = "arn:aws:iam::123456789012:role/StepFunctionsRole"
    definition = "{\"Comment\":\"A Hello World example\"}"
    logging_configuration = [
      {
        level = "ERROR"
        log_destination = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/stepfunctions/other:*"
        include_execution_data = false
      }
    ]
  }
}
