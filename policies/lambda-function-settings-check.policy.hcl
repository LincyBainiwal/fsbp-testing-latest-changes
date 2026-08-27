# Copyright IBM Corp. 2026

# Lambda functions should use supported runtimes

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "lambda-function-settings-check-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_lambda_function" "lambda_supported_runtimes" {
    enforcement_level = input.lambda-function-settings-check-enforcement-level
    filter = core::try(attrs.package_type, "Zip") == "Zip"

    locals {
        supported_runtimes = [
            "nodejs24.x", "nodejs22.x",
            "python3.14", "python3.13", "python3.12", "python3.11", "python3.10",
            "java25", "java21", "java17", "java11", "java8.al2",
            "dotnet10", "dotnet8",
            "ruby4.0", "ruby3.4", "ruby3.3",
            "provided.al2023", "provided.al2"
        ]
    }

    enforce {
        condition     = core::contains(local.supported_runtimes, core::try(attrs.runtime, ""))
        error_message = "Lambda function uses an unsupported runtime. Update the 'runtime' argument to one of the supported values configured for this policy"
    }
}