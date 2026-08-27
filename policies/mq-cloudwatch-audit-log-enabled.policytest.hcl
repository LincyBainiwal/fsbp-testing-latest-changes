# Copyright IBM Corp. 2026

policytest {
  targets = [
    "mq-cloudwatch-audit-log-enabled.policy.hcl"
  ]
}

resource "aws_mq_broker" "pass_audit_enabled" {
  attrs = {
    broker_name = "compliant-broker"
    engine_type = "ActiveMQ"
    engine_version = "5.17.6"
    host_instance_type = "mq.t3.micro"
    logs = [
      {
        audit = true
        general = true
      }
    ]
  }
}

resource "aws_mq_broker" "fail_audit_disabled" {
  expect_failure = true
  attrs = {
    broker_name = "non-compliant-broker"
    engine_type = "ActiveMQ"
    engine_version = "5.17.6"
    host_instance_type = "mq.t3.micro"
    logs = [
      {
        audit = false
        general = true
      }
    ]
  }
}

resource "aws_mq_broker" "fail_no_logs_config" {
  expect_failure = true
  attrs = {
    broker_name = "no-logs-broker"
    engine_type = "ActiveMQ"
    engine_version = "5.17.6"
    host_instance_type = "mq.t3.micro"
    logs = null
  }
}

resource "aws_mq_broker" "fail_audit_not_specified" {
  expect_failure = true
  attrs = {
    broker_name = "audit-missing-broker"
    engine_type = "ActiveMQ"
    engine_version = "5.17.6"
    host_instance_type = "mq.t3.micro"
    logs = [
      {
        general = true
      }
    ]
  }
}

resource "aws_mq_broker" "skip_rabbitmq_broker" {
  attrs = {
    broker_name = "rabbitmq-broker"
    engine_type = "RabbitMQ"
    engine_version = "3.11.20"
    host_instance_type = "mq.t3.micro"
    logs = null
  }
}