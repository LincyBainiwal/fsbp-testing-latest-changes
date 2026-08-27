# Copyright IBM Corp. 2026

# RDS DB proxies should require TLS encryption for connections

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "rds-proxy-tls-encryption-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_db_proxy" "require_tls_enabled" {
    enforcement_level = input.rds-proxy-tls-encryption-enforcement-level
    enforce {
        condition = core::try(attrs.require_tls, false) == true
        error_message = "RDS DB proxy must set require_tls = true to require TLS encryption for connections"
    }
}
