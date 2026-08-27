# Copyright IBM Corp. 2026

policytest {
  targets = [
    "step-functions-state-machine-logging-enabled.policy.hcl"
  ]
}

inputs {
  logLevel = "WARN"
}

# Fail case: Invalid logLevel input ("WARN" is not one of ALL/ERROR/FATAL)
resource "aws_sfn_state_machine" "fail_invalid_log_level_input" {
  expect_failure = true
  attrs = {
    name = "example-state-machine-invalid-input"
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
