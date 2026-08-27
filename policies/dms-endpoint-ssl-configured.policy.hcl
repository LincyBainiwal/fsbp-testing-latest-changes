# Copyright IBM Corp. 2026

# DMS endpoints should use SSL

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "dms-endpoint-ssl-configured-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "aws_dms_endpoint" "ssl_mode_required" {
  enforcement_level = input.dms-endpoint-ssl-configured-enforcement-level
  locals {
    ssl_mode = core::try(attrs.ssl_mode, "none")

    # "require", "verify-ca", and "verify-full" all enforce an encrypted
    # connection. "none" and any other value are non-compliant.
    secure_ssl_modes     = ["require", "verify-ca", "verify-full"]
    has_secure_ssl_mode  = core::contains(local.secure_ssl_modes, local.ssl_mode)

    # verify-ca and verify-full additionally require a certificate ARN.
    certificate_arn      = core::try(attrs.certificate_arn, "")
    needs_certificate    = local.ssl_mode == "verify-ca" || local.ssl_mode == "verify-full"
    has_required_cert    = !local.needs_certificate || local.certificate_arn != ""
  }

  enforce {
    condition     = local.has_secure_ssl_mode
    error_message = "DMS endpoint 'ssl_mode' must be one of [require, verify-ca, verify-full], got '${local.ssl_mode}'. Set ssl_mode to a secure value to encrypt the connection."
  }

  enforce {
    condition     = local.has_required_cert
    error_message = "DMS endpoint ssl_mode='${local.ssl_mode}' requires a 'certificate_arn' to be set but none was provided."
  }
}