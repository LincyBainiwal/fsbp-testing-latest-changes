# Copyright IBM Corp. 2026

policytest {
    targets =[
        "transfer-connector-logging-enabled.policy.hcl"
    ]
}


# Test 1: PASS - Transfer connector with logging_role configured
resource "aws_transfer_connector" "pass_connector_with_logging_role" {
    attrs = {
        access_role  = "arn:aws:iam::123456789012:role/TransferAccessRole"
        logging_role = "arn:aws:iam::123456789012:role/TransferLoggingRole"
        url          = "https://partner.example.com"
        as2_config = [{
            compression           = "ZLIB"
            encryption_algorithm  = "AES128_CBC"
            signing_algorithm     = "SHA256"
            mdn_signing_algorithm = "SHA256"
            message_subject       = "AS2 Message"
        }]
    }
}

# Test 2: FAIL - Transfer connector without logging_role
resource "aws_transfer_connector" "fail_connector_without_logging_role" {
    expect_failure = true
    
    attrs = {
        access_role = "arn:aws:iam::123456789012:role/TransferAccessRole"
        url         = "https://partner.example.com"
        as2_config = [{
            compression           = "ZLIB"
            encryption_algorithm  = "AES128_CBC"
            signing_algorithm     = "SHA256"
            mdn_signing_algorithm = "SHA256"
            message_subject       = "AS2 Message"
        }]
    }
}

# Test 3: FAIL - Transfer connector with empty logging_role
resource "aws_transfer_connector" "fail_connector_with_empty_logging_role" {
    expect_failure = true
    
    attrs = {
        access_role  = "arn:aws:iam::123456789012:role/TransferAccessRole"
        logging_role = ""
        url          = "https://partner.example.com"
        as2_config = [{
            compression           = "ZLIB"
            encryption_algorithm  = "AES128_CBC"
            signing_algorithm     = "SHA256"
            mdn_signing_algorithm = "SHA256"
            message_subject       = "AS2 Message"
        }]
    }
}

# Test 4: PASS - AS2 connector with logging_role configured
resource "aws_transfer_connector" "pass_as2_connector_with_logging" {
    attrs = {
        access_role  = "arn:aws:iam::123456789012:role/TransferAccessRole"
        logging_role = "arn:aws:iam::123456789012:role/TransferLoggingRole"
        url          = "https://as2-partner.example.com"
        as2_config = [{
            compression           = "ZLIB"
            encryption_algorithm  = "AES256_CBC"
            signing_algorithm     = "SHA512"
            mdn_signing_algorithm = "SHA512"
            message_subject       = "AS2 Transfer"
            local_profile_id      = "p-1234567890abcdef0"
            partner_profile_id    = "p-0987654321fedcba0"
        }]
    }
}

# Test 5: PASS - SFTP connector with logging_role configured
resource "aws_transfer_connector" "pass_sftp_connector_with_logging" {
    attrs = {
        access_role  = "arn:aws:iam::123456789012:role/TransferAccessRole"
        logging_role = "arn:aws:iam::123456789012:role/TransferLoggingRole"
        url          = "sftp://sftp-partner.example.com"
        sftp_config = [{
            user_secret_id = "arn:aws:secretsmanager:us-east-1:123456789012:secret:sftp-credentials"
            trusted_host_keys = [
                "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC..."
            ]
        }]
    }
}
