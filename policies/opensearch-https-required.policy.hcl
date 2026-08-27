# Copyright IBM Corp. 2026

# Connections to OpenSearch domains should be encrypted using the latest TLS security policy

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9.0, < 7.0.0"
    }
  }
}

input "opensearch-https-required-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_opensearch_domain" "tls_policy_check" {
    enforcement_level = input.opensearch-https-required-enforcement-level
    locals {
        endpoint_options = core::try(attrs.domain_endpoint_options, null)
        has_endpoint_options = local.endpoint_options != null ? core::length(local.endpoint_options) > 0 : false

        enforce_https = local.has_endpoint_options ? core::try(local.endpoint_options[0].enforce_https, true) : false
        tls_policy = local.has_endpoint_options ? core::try(local.endpoint_options[0].tls_security_policy, "") : ""

        required_tls_policy = "Policy-Min-TLS-1-2-PFS-2023-10"
    }

    enforce {
        condition = local.has_endpoint_options
        error_message = "OpenSearch domain does not have 'domain_endpoint_options' configured. This block is required to enforce HTTPS and TLS security policy. Add 'domain_endpoint_options' block with 'enforce_https = true' and 'tls_security_policy = \"${local.required_tls_policy}\"'"
    }

    enforce {
        condition = local.enforce_https == true
        error_message = "OpenSearch domain does not have HTTPS enforcement enabled. Set 'domain_endpoint_options.enforce_https = true' to ensure all connections use HTTPS"
    }

    enforce {
        condition = local.tls_policy == local.required_tls_policy
        error_message = "OpenSearch domain is not using the latest TLS security policy. Required policy: '${local.required_tls_policy}'. Update 'domain_endpoint_options.tls_security_policy' to use the latest TLS 1.2 policy"
    }
}
