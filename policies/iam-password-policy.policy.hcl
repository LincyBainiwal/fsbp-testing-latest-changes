# Copyright IBM Corp. 2026

# Password policies for IAM users should have strong configurations

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "iam-password-policy-enforcement-level" {
  type = string
  default = "advisory"
}

input "RequireUppercaseCharacters" {
    type = string
    default = "true"
}

input "RequireLowercaseCharacters" {
    type = string
    default = "true"
}

input "RequireSymbols" {
    type = string
    default = "true"
}

input "RequireNumbers" {
    type = string
    default = "true"
}

input "MinimumPasswordLength" {
    type = number
    default = 8
}

input "PasswordReusePrevention" {
    type = number
    default = 0
}

input "MaxPasswordAge" {
    type = number
    default = 0
}

resource_policy "aws_iam_account_password_policy" "iam7_password_policy" {
    enforcement_level = input.iam-password-policy-enforcement-level
    locals {
        account_name = "AWS account password policy"

        required_uppercase = input.RequireUppercaseCharacters == "true"
        required_lowercase = input.RequireLowercaseCharacters == "true"
        required_symbols = input.RequireSymbols == "true"
        required_numbers = input.RequireNumbers == "true"

        require_uppercase = core::try(attrs.require_uppercase_characters, false)
        require_lowercase = core::try(attrs.require_lowercase_characters, false)
        require_symbols = core::try(attrs.require_symbols, false)
        require_numbers = core::try(attrs.require_numbers, false)
        min_password_length = core::try(attrs.minimum_password_length, 0)
        
        password_reuse_prevention = core::try(attrs.password_reuse_prevention, 0)
        max_password_age = core::try(attrs.max_password_age, 0)
        
        has_uppercase = !local.required_uppercase || local.require_uppercase
        has_lowercase = !local.required_lowercase || local.require_lowercase
        has_symbols   = !local.required_symbols   || local.require_symbols
        has_numbers   = !local.required_numbers   || local.require_numbers
        has_min_length = local.min_password_length >= input.MinimumPasswordLength

        # Bake in IAM.7 defaults so optional enforces fire even when inputs
        # are left at their tfpolicy defaults (no operator opt-in required).
        # AWS recommends password_reuse_prevention >= 24; we use the input when
        # set, otherwise the minimum of 1 (so any reuse-prevention configuration counts).
        required_reuse_prevention = input.PasswordReusePrevention > 0 ? input.PasswordReusePrevention : 1
        # AWS recommends max_password_age <= 90 days; use the input when set,
        # otherwise default to 90.
        max_password_age_required = input.MaxPasswordAge > 0 ? input.MaxPasswordAge : 90

        password_reuse_ok   = local.password_reuse_prevention >= local.required_reuse_prevention
        max_password_age_ok = local.max_password_age > 0 && local.max_password_age <= local.max_password_age_required
    }

    enforce {
        condition = local.has_uppercase
        error_message = "AWS account password policy must require uppercase characters"
    }

    enforce {
        condition = local.has_lowercase
        error_message = "AWS account password policy must require lowercase characters"
    }

    enforce {
        condition = local.has_symbols
        error_message = "AWS account password policy must require symbols"
    }

    enforce {
        condition = local.has_numbers
        error_message = "AWS account password policy must require numbers"
    }

    enforce {
        condition = local.has_min_length
        error_message = "AWS account password policy minimum_password_length is below the required threshold"
    }

    enforce {
        condition = local.password_reuse_ok
        error_message = "AWS account password policy must set password_reuse_prevention to the required minimum"
    }

    enforce {
        condition = local.max_password_age_ok
        error_message = "AWS account password policy must set max_password_age within the allowed range"
    }
}