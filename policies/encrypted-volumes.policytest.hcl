# Copyright IBM Corp. 2026

policytest {
  targets = [
    "encrypted-volumes.policy.hcl"
  ]
}

# Pass: Encrypted EBS volume
resource "aws_ebs_volume" "encrypted" {
  attrs = {
    availability_zone = "us-east-1a"
    encrypted = true
    size = 100
    type = "gp3"
  }
}

# Fail: Unencrypted EBS volume
resource "aws_ebs_volume" "unencrypted" {
  expect_failure = true
  attrs = {
    availability_zone = "us-east-1a"
    encrypted = false
    size = 100
    type = "gp3"
  }
}

# Fail: Missing encrypted attribute (defaults to false)
resource "aws_ebs_volume" "no_encryption_attr" {
  expect_failure = true
  attrs = {
    availability_zone = "us-east-1a"
    size = 100
    type = "gp3"
  }
}

# ============================================================================
# Policy 2: aws_instance ebs_encryption_required (EBS block devices)
# ============================================================================

# Pass: Instance with encrypted EBS block device
resource "aws_instance" "encrypted_ebs" {
  attrs = {
    ami = "ami-12345678"
    instance_type = "t3.micro"
    ebs_block_device = [
      {
        device_name = "/dev/sdf"
        encrypted = true
        volume_size = 50
        volume_type = "gp3"
      }
    ]
  }
}

# Fail: Instance with unencrypted EBS block device
resource "aws_instance" "unencrypted_ebs" {
  expect_failure = true
  attrs = {
    ami = "ami-12345678"
    instance_type = "t3.micro"
    ebs_block_device = [
      {
        device_name = "/dev/sdf"
        encrypted = false
        volume_size = 50
        volume_type = "gp3"
      }
    ]
  }
}

# Fail: Instance with multiple EBS devices, one unencrypted
resource "aws_instance" "mixed_encryption" {
  expect_failure = true
  attrs = {
    ami = "ami-12345678"
    instance_type = "t3.micro"
    ebs_block_device = [
      {
        device_name = "/dev/sdf"
        encrypted = true
        volume_size = 50
        volume_type = "gp3"
      },
      {
        device_name = "/dev/sdg"
        encrypted = false
        volume_size = 100
        volume_type = "gp3"
      }
    ]
  }
}

# Pass: Instance without EBS block devices — condition short-circuits to true
# (!has_ebs_devices = true, so the whole condition passes).
resource "aws_instance" "no_ebs" {
  attrs = {
    ami           = "ami-12345678"
    instance_type = "t3.micro"
  }
}

# ============================================================================
# Policy 3: aws_instance root_encryption_required (Root block device)
# ============================================================================

# Pass: Instance with encrypted root block device
resource "aws_instance" "encrypted_root" {
  attrs = {
    ami = "ami-12345678"
    instance_type = "t3.micro"
    root_block_device = [
      {
        encrypted = true
        volume_size = 20
        volume_type = "gp3"
      }
    ]
  }
}

# Fail: Instance with unencrypted root block device
resource "aws_instance" "unencrypted_root" {
  expect_failure = true
  attrs = {
    ami = "ami-12345678"
    instance_type = "t3.micro"
    root_block_device = [
      {
        encrypted = false
        volume_size = 20
        volume_type = "gp3"
      }
    ]
  }
}

# Fail: Root block device without encrypted attribute
resource "aws_instance" "root_no_encryption_attr" {
  expect_failure = true
  attrs = {
    ami = "ami-12345678"
    instance_type = "t3.micro"
    root_block_device = [
      {
        volume_size = 20
        volume_type = "gp3"
      }
    ]
  }
}

# Pass: Instance without root block device configuration — condition short-circuits to true.
resource "aws_instance" "no_root_config" {
  attrs = {
    ami           = "ami-12345678"
    instance_type = "t3.micro"
  }
}

# ============================================================================
# Policy 4: aws_launch_template ebs_encryption_required
# ============================================================================

# Pass: Launch template with all EBS mappings encrypted
resource "aws_launch_template" "pass_lt_encrypted" {
  attrs = {
    name = "lt-encrypted"
    block_device_mappings = [
      {
        device_name = "/dev/xvda"
        ebs = [{ encrypted = true, volume_size = 20, volume_type = "gp3" }]
      }
    ]
  }
}

# Pass: Launch template with no block_device_mappings (short-circuits)
resource "aws_launch_template" "pass_lt_no_mappings" {
  attrs = {
    name          = "lt-no-mappings"
    instance_type = "t3.micro"
  }
}

# Fail: Launch template with an unencrypted EBS mapping
resource "aws_launch_template" "fail_lt_unencrypted" {
  expect_failure = true
  attrs = {
    name = "lt-unencrypted"
    block_device_mappings = [
      {
        device_name = "/dev/xvda"
        ebs = [{ encrypted = false, volume_size = 20, volume_type = "gp3" }]
      }
    ]
  }
}

# Fail: Launch template with missing encrypted attribute on EBS mapping
resource "aws_launch_template" "fail_lt_missing_encrypted" {
  expect_failure = true
  attrs = {
    name = "lt-missing-encrypted"
    block_device_mappings = [
      {
        device_name = "/dev/xvda"
        ebs = [{ volume_size = 20, volume_type = "gp3" }]
      }
    ]
  }
}

# Fail: Launch template with multiple mappings, one unencrypted
resource "aws_launch_template" "fail_lt_mixed_encryption" {
  expect_failure = true
  attrs = {
    name = "lt-mixed"
    block_device_mappings = [
      {
        device_name = "/dev/xvda"
        ebs = [{ encrypted = true, volume_size = 20, volume_type = "gp3" }]
      },
      {
        device_name = "/dev/xvdb"
        ebs = [{ encrypted = false, volume_size = 50, volume_type = "gp3" }]
      }
    ]
  }
}