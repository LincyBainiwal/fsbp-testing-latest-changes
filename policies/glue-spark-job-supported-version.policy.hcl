# Copyright IBM Corp. 2026

# AWS Glue Spark jobs should run on supported versions of AWS Glue

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "glue-spark-job-supported-version-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_glue_job" "glue_spark_version_check" {
  enforcement_level = input.glue-spark-job-supported-version-enforcement-level
 
  filter = attrs.command != null && core::length(attrs.command) > 0

  locals {
    
    minimum_supported_version = "3.0"

    # Extract command configuration
    command_config = core::try(attrs.command[0], null)
    command_name   = core::try(local.command_config.name, "glueetl")

    # AWS Glue Spark-based job command types in scope for Glue.4:
    # - glueetl       : Apache Spark ETL
    # - gluestreaming : Apache Spark Streaming
    # Out of scope: pythonshell (Python), glueray (Ray)
    is_spark_job = local.command_name == "glueetl" || local.command_name == "gluestreaming"

    # Extract glue_version with safe access
    glue_version = core::try(attrs.glue_version, null)
    has_version  = local.glue_version != null

    # Parse "X.Y" version strings into integers for numeric comparison.
    glue_parts = local.has_version ? core::split(".", local.glue_version) : ["0", "0"]
    glue_major = local.has_version ? core::try(core::parseint(local.glue_parts[0], 10), 0) : 0
    glue_minor = local.has_version && core::length(local.glue_parts) > 1 ? core::try(core::parseint(local.glue_parts[1], 10), 0) : 0

    min_parts = core::split(".", local.minimum_supported_version)
    min_major = core::try(core::parseint(local.min_parts[0], 10), 3)
    min_minor = core::length(local.min_parts) > 1 ? core::try(core::parseint(local.min_parts[1], 10), 0) : 0

    # Version is compliant if it exists and is >= the minimum supported version.
    version_compliant = local.has_version && (
      local.glue_major > local.min_major ||
      (local.glue_major == local.min_major && local.glue_minor >= local.min_minor)
    )

    # Use a resource-native identifier for error messages
    job_name = core::try(attrs.name, "AWS Glue Spark job")

    # Safe version string for error messages
    version_string = local.has_version ? local.glue_version : "not specified"
  }

  # Enforce: Spark jobs must have glue_version specified
  enforce {
    condition     = !local.is_spark_job || local.has_version
    error_message = "AWS Glue Spark job '${local.job_name}' must have the 'glue_version' property specified. GlueVersion is null or missing in the job configuration. Add the GlueVersion property to the job's configuration with a value of 3.0 or greater"
  }

  # Enforce: Spark jobs must use a version >= minimumSupportedGlueVersion
  enforce {
    condition     = !local.is_spark_job || local.version_compliant
    error_message = "AWS Glue Spark job '${local.job_name}' is configured with glue_version '${local.version_string}', which is earlier than the minimum supported version 3.0. Update the job to use AWS Glue version 3.0 or greater for optimized performance, security, and access to the latest features"
  }
}
