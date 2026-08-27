# Copyright IBM Corp. 2026

policytest {
  targets = [
    "dms-replication-task-sourcedb-logging.policy.hcl"
  ]
}

# --------------- PASS cases ---------------

# Test 1: PASS - Logging enabled with SOURCE_CAPTURE and SOURCE_UNLOAD at LOGGER_SEVERITY_DEFAULT
resource "aws_dms_replication_task" "pass_with_default_severity" {
  attrs = {
    replication_task_id      = "test-task-default"
    migration_type           = "full-load-and-cdc"
    replication_instance_arn = "arn:aws:dms:us-east-1:123456789012:rep:ABC123"
    source_endpoint_arn      = "arn:aws:dms:us-east-1:123456789012:endpoint:SOURCE"
    target_endpoint_arn      = "arn:aws:dms:us-east-1:123456789012:endpoint:TARGET"
    table_mappings           = "{\"rules\":[]}"
    replication_task_settings = "{\"Logging\":{\"EnableLogging\":true,\"LogComponents\":[{\"Id\":\"SOURCE_CAPTURE\",\"Severity\":\"LOGGER_SEVERITY_DEFAULT\"},{\"Id\":\"SOURCE_UNLOAD\",\"Severity\":\"LOGGER_SEVERITY_DEFAULT\"}]}}"
  }
}

# Test 2: PASS - Logging enabled with LOGGER_SEVERITY_DEBUG
resource "aws_dms_replication_task" "pass_with_debug_severity" {
  attrs = {
    replication_task_id      = "test-task-debug"
    migration_type           = "cdc"
    replication_instance_arn = "arn:aws:dms:us-east-1:123456789012:rep:ABC123"
    source_endpoint_arn      = "arn:aws:dms:us-east-1:123456789012:endpoint:SOURCE"
    target_endpoint_arn      = "arn:aws:dms:us-east-1:123456789012:endpoint:TARGET"
    table_mappings           = "{\"rules\":[]}"
    replication_task_settings = "{\"Logging\":{\"EnableLogging\":true,\"LogComponents\":[{\"Id\":\"SOURCE_CAPTURE\",\"Severity\":\"LOGGER_SEVERITY_DEBUG\"},{\"Id\":\"SOURCE_UNLOAD\",\"Severity\":\"LOGGER_SEVERITY_DEBUG\"}]}}"
  }
}

# Test 3: PASS - Logging enabled with LOGGER_SEVERITY_DETAILED_DEBUG
resource "aws_dms_replication_task" "pass_with_detailed_debug_severity" {
  attrs = {
    replication_task_id      = "test-task-detailed"
    migration_type           = "full-load"
    replication_instance_arn = "arn:aws:dms:us-east-1:123456789012:rep:ABC123"
    source_endpoint_arn      = "arn:aws:dms:us-east-1:123456789012:endpoint:SOURCE"
    target_endpoint_arn      = "arn:aws:dms:us-east-1:123456789012:endpoint:TARGET"
    table_mappings           = "{\"rules\":[]}"
    replication_task_settings = "{\"Logging\":{\"EnableLogging\":true,\"LogComponents\":[{\"Id\":\"SOURCE_CAPTURE\",\"Severity\":\"LOGGER_SEVERITY_DETAILED_DEBUG\"},{\"Id\":\"SOURCE_UNLOAD\",\"Severity\":\"LOGGER_SEVERITY_DETAILED_DEBUG\"}]}}"
  }
}

# --------------- FAIL cases ---------------

# Test 4: FAIL - EnableLogging is false
resource "aws_dms_replication_task" "fail_logging_disabled" {
  expect_failure = true
  attrs = {
    replication_task_id      = "test-task-disabled"
    migration_type           = "full-load-and-cdc"
    replication_instance_arn = "arn:aws:dms:us-east-1:123456789012:rep:ABC123"
    source_endpoint_arn      = "arn:aws:dms:us-east-1:123456789012:endpoint:SOURCE"
    target_endpoint_arn      = "arn:aws:dms:us-east-1:123456789012:endpoint:TARGET"
    table_mappings           = "{\"rules\":[]}"
    replication_task_settings = "{\"Logging\":{\"EnableLogging\":false,\"LogComponents\":[]}}"
  }
}

# Test 5: FAIL - Missing SOURCE_CAPTURE component
resource "aws_dms_replication_task" "fail_missing_source_capture" {
  expect_failure = true
  attrs = {
    replication_task_id      = "test-task-no-capture"
    migration_type           = "full-load-and-cdc"
    replication_instance_arn = "arn:aws:dms:us-east-1:123456789012:rep:ABC123"
    source_endpoint_arn      = "arn:aws:dms:us-east-1:123456789012:endpoint:SOURCE"
    target_endpoint_arn      = "arn:aws:dms:us-east-1:123456789012:endpoint:TARGET"
    table_mappings           = "{\"rules\":[]}"
    replication_task_settings = "{\"Logging\":{\"EnableLogging\":true,\"LogComponents\":[{\"Id\":\"SOURCE_UNLOAD\",\"Severity\":\"LOGGER_SEVERITY_DEFAULT\"}]}}"
  }
}

# Test 6: FAIL - Missing SOURCE_UNLOAD component
resource "aws_dms_replication_task" "fail_missing_source_unload" {
  expect_failure = true
  attrs = {
    replication_task_id      = "test-task-no-unload"
    migration_type           = "full-load-and-cdc"
    replication_instance_arn = "arn:aws:dms:us-east-1:123456789012:rep:ABC123"
    source_endpoint_arn      = "arn:aws:dms:us-east-1:123456789012:endpoint:SOURCE"
    target_endpoint_arn      = "arn:aws:dms:us-east-1:123456789012:endpoint:TARGET"
    table_mappings           = "{\"rules\":[]}"
    replication_task_settings = "{\"Logging\":{\"EnableLogging\":true,\"LogComponents\":[{\"Id\":\"SOURCE_CAPTURE\",\"Severity\":\"LOGGER_SEVERITY_DEFAULT\"}]}}"
  }
}

# Test 7: FAIL - Invalid severity for SOURCE_CAPTURE
resource "aws_dms_replication_task" "fail_invalid_source_capture_severity" {
  expect_failure = true
  attrs = {
    replication_task_id      = "test-task-bad-capture-severity"
    migration_type           = "full-load-and-cdc"
    replication_instance_arn = "arn:aws:dms:us-east-1:123456789012:rep:ABC123"
    source_endpoint_arn      = "arn:aws:dms:us-east-1:123456789012:endpoint:SOURCE"
    target_endpoint_arn      = "arn:aws:dms:us-east-1:123456789012:endpoint:TARGET"
    table_mappings           = "{\"rules\":[]}"
    replication_task_settings = "{\"Logging\":{\"EnableLogging\":true,\"LogComponents\":[{\"Id\":\"SOURCE_CAPTURE\",\"Severity\":\"LOGGER_SEVERITY_INFO\"},{\"Id\":\"SOURCE_UNLOAD\",\"Severity\":\"LOGGER_SEVERITY_DEFAULT\"}]}}"
  }
}

# Test 8: FAIL - Invalid severity for SOURCE_UNLOAD
resource "aws_dms_replication_task" "fail_invalid_source_unload_severity" {
  expect_failure = true
  attrs = {
    replication_task_id      = "test-task-bad-unload-severity"
    migration_type           = "full-load-and-cdc"
    replication_instance_arn = "arn:aws:dms:us-east-1:123456789012:rep:ABC123"
    source_endpoint_arn      = "arn:aws:dms:us-east-1:123456789012:endpoint:SOURCE"
    target_endpoint_arn      = "arn:aws:dms:us-east-1:123456789012:endpoint:TARGET"
    table_mappings           = "{\"rules\":[]}"
    replication_task_settings = "{\"Logging\":{\"EnableLogging\":true,\"LogComponents\":[{\"Id\":\"SOURCE_CAPTURE\",\"Severity\":\"LOGGER_SEVERITY_DEFAULT\"},{\"Id\":\"SOURCE_UNLOAD\",\"Severity\":\"LOGGER_SEVERITY_WARNING\"}]}}"
  }
}

# Test 9: FAIL - No replication_task_settings at all
resource "aws_dms_replication_task" "fail_no_settings" {
  expect_failure = true
  attrs = {
    replication_task_id      = "test-task-no-settings"
    migration_type           = "full-load-and-cdc"
    replication_instance_arn = "arn:aws:dms:us-east-1:123456789012:rep:ABC123"
    source_endpoint_arn      = "arn:aws:dms:us-east-1:123456789012:endpoint:SOURCE"
    target_endpoint_arn      = "arn:aws:dms:us-east-1:123456789012:endpoint:TARGET"
    table_mappings           = "{\"rules\":[]}"
  }
}

# Test 10: FAIL - Empty LogComponents array
resource "aws_dms_replication_task" "fail_empty_log_components" {
  expect_failure = true
  attrs = {
    replication_task_id      = "test-task-empty-components"
    migration_type           = "full-load-and-cdc"
    replication_instance_arn = "arn:aws:dms:us-east-1:123456789012:rep:ABC123"
    source_endpoint_arn      = "arn:aws:dms:us-east-1:123456789012:endpoint:SOURCE"
    target_endpoint_arn      = "arn:aws:dms:us-east-1:123456789012:endpoint:TARGET"
    table_mappings           = "{\"rules\":[]}"
    replication_task_settings = "{\"Logging\":{\"EnableLogging\":true,\"LogComponents\":[]}}"
  }
}

# Test 11: FAIL - settings is "{}" empty JSON object
resource "aws_dms_replication_task" "fail_empty_json_settings" {
  expect_failure = true
  attrs = {
    replication_task_id      = "test-task-empty-json"
    migration_type           = "cdc"
    replication_instance_arn = "arn:aws:dms:us-east-1:123456789012:rep:ABC123"
    source_endpoint_arn      = "arn:aws:dms:us-east-1:123456789012:endpoint:SOURCE"
    target_endpoint_arn      = "arn:aws:dms:us-east-1:123456789012:endpoint:TARGET"
    table_mappings           = "{\"rules\":[]}"
    replication_task_settings = "{}"
  }
}