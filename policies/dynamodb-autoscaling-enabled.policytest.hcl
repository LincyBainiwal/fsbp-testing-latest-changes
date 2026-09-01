# Copyright IBM Corp. 2026

policytest {
  targets = [
    "dynamodb-autoscaling-enabled.policy.hcl"
  ]
}

# --------------- PASS cases ---------------

# Test 1: PASS - On-demand (PAY_PER_REQUEST) table — filtered out, always compliant
resource "aws_dynamodb_table" "pass_on_demand_table" {
  attrs = {
    name         = "on-demand-table"
    billing_mode = "PAY_PER_REQUEST"
    hash_key     = "id"
    attribute = [
      { name = "id", type = "S" }
    ]
  }
}

# Test 2: PASS - PROVISIONED table with both read and write autoscaling targets
resource "aws_dynamodb_table" "pass_provisioned_with_autoscaling" {
  attrs = {
    name           = "autoscaled-table"
    billing_mode   = "PROVISIONED"
    read_capacity  = 5
    write_capacity = 5
    hash_key       = "id"
    attribute = [
      { name = "id", type = "S" }
    ]
  }
}

resource "aws_appautoscaling_target" "pass_read_target" {
  attrs = {
    resource_id        = "table/autoscaled-table"
    scalable_dimension = "dynamodb:table:ReadCapacityUnits"
    service_namespace  = "dynamodb"
    min_capacity       = 1
    max_capacity       = 100
  }
}

resource "aws_appautoscaling_target" "pass_write_target" {
  attrs = {
    resource_id        = "table/autoscaled-table"
    scalable_dimension = "dynamodb:table:WriteCapacityUnits"
    service_namespace  = "dynamodb"
    min_capacity       = 1
    max_capacity       = 100
  }
}

# Test 3: PASS - Default billing_mode (resolves to PROVISIONED) with autoscaling targets
resource "aws_dynamodb_table" "pass_default_billing_with_autoscaling" {
  attrs = {
    name           = "default-billing-autoscaled"
    read_capacity  = 5
    write_capacity = 5
    hash_key       = "id"
    attribute = [
      { name = "id", type = "S" }
    ]
  }
}

resource "aws_appautoscaling_target" "pass_default_read_target" {
  attrs = {
    resource_id        = "table/default-billing-autoscaled"
    scalable_dimension = "dynamodb:table:ReadCapacityUnits"
    service_namespace  = "dynamodb"
    min_capacity       = 1
    max_capacity       = 50
  }
}

resource "aws_appautoscaling_target" "pass_default_write_target" {
  attrs = {
    resource_id        = "table/default-billing-autoscaled"
    scalable_dimension = "dynamodb:table:WriteCapacityUnits"
    service_namespace  = "dynamodb"
    min_capacity       = 1
    max_capacity       = 50
  }
}

# --------------- FAIL cases ---------------

# Test 4: FAIL - PROVISIONED table with NO autoscaling targets at all
resource "aws_dynamodb_table" "fail_no_autoscaling" {
  expect_failure = true
  attrs = {
    name           = "no-autoscaling-table"
    billing_mode   = "PROVISIONED"
    read_capacity  = 5
    write_capacity = 5
    hash_key       = "id"
    attribute = [
      { name = "id", type = "S" }
    ]
  }
}

# Test 5: FAIL - PROVISIONED table with only READ autoscaling (missing write target)
resource "aws_dynamodb_table" "fail_read_only_autoscaling" {
  expect_failure = true
  attrs = {
    name           = "read-only-autoscaled-table"
    billing_mode   = "PROVISIONED"
    read_capacity  = 5
    write_capacity = 5
    hash_key       = "id"
    attribute = [
      { name = "id", type = "S" }
    ]
  }
}

resource "aws_appautoscaling_target" "fail_read_only_target" {
  attrs = {
    resource_id        = "table/read-only-autoscaled-table"
    scalable_dimension = "dynamodb:table:ReadCapacityUnits"
    service_namespace  = "dynamodb"
    min_capacity       = 1
    max_capacity       = 100
  }
}

# Test 6: FAIL - PROVISIONED table with only WRITE autoscaling (missing read target)
resource "aws_dynamodb_table" "fail_write_only_autoscaling" {
  expect_failure = true
  attrs = {
    name           = "write-only-autoscaled-table"
    billing_mode   = "PROVISIONED"
    read_capacity  = 5
    write_capacity = 5
    hash_key       = "id"
    attribute = [
      { name = "id", type = "S" }
    ]
  }
}

resource "aws_appautoscaling_target" "fail_write_only_target" {
  attrs = {
    resource_id        = "table/write-only-autoscaled-table"
    scalable_dimension = "dynamodb:table:WriteCapacityUnits"
    service_namespace  = "dynamodb"
    min_capacity       = 1
    max_capacity       = 100
  }
}

# --------------- Parameter range validation tests ---------------
# A value of 0 means "not provided" and must always pass.

# Test 7: FAIL - invalid minProvisionedReadCapacity (value > 40000)
resource "aws_dynamodb_table" "fail_invalid_min_read_capacity" {
  expect_failure = true
  attrs = {
    name           = "invalid-min-read-cap-table"
    billing_mode   = "PROVISIONED"
    read_capacity  = 5
    write_capacity = 5
    hash_key       = "id"
    attribute      = [{ name = "id", type = "S" }]
  }
}

# Test 8: FAIL - invalid targetReadUtilization (value > 90)
resource "aws_dynamodb_table" "fail_invalid_target_read_util" {
  expect_failure = true
  attrs = {
    name           = "invalid-target-read-util-table"
    billing_mode   = "PROVISIONED"
    read_capacity  = 5
    write_capacity = 5
    hash_key       = "id"
    attribute      = [{ name = "id", type = "S" }]
  }
}

# Test 9: FAIL - invalid minProvisionedWriteCapacity (value > 40000)
resource "aws_dynamodb_table" "fail_invalid_min_write_capacity" {
  expect_failure = true
  attrs = {
    name           = "invalid-min-write-cap-table"
    billing_mode   = "PROVISIONED"
    read_capacity  = 5
    write_capacity = 5
    hash_key       = "id"
    attribute      = [{ name = "id", type = "S" }]
  }
}

# Test 10: FAIL - invalid targetWriteUtilization (value > 90)
resource "aws_dynamodb_table" "fail_invalid_target_write_util" {
  expect_failure = true
  attrs = {
    name           = "invalid-target-write-util-table"
    billing_mode   = "PROVISIONED"
    read_capacity  = 5
    write_capacity = 5
    hash_key       = "id"
    attribute      = [{ name = "id", type = "S" }]
  }
}