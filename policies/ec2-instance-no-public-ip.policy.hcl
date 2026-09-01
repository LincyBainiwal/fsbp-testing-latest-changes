# Copyright IBM Corp. 2026

# Amazon EC2 instances should not have a public IPv4 address

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "ec2-instance-no-public-ip-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_instance" "no_public_ipv4" {
  enforcement_level = input.ec2-instance-no-public-ip-enforcement-level
  locals {
    # Explicit instance-level public IP setting
    has_public_ip_setting = core::try(attrs.associate_public_ip_address, null)
    explicitly_public     = local.has_public_ip_setting == true

    # Check for network_interface blocks with public IP association enabled
    network_interfaces = core::try(attrs.network_interface, [])
    public_network_interfaces = [
      for ni in local.network_interfaces :
      ni if core::try(ni.associate_public_ip_address, false) == true
    ]
    has_public_ni = core::length(local.public_network_interfaces) > 0

    # When associate_public_ip_address is not explicitly set, the instance
    # inherits the subnet's map_public_ip_on_launch setting. Resolve the
    # subnet and check that attribute.
    # KNOWN LIMITATION: When associate_public_ip_address is unset and subnet_id
    # is also absent (e.g. the instance uses a default subnet resolved at apply
    # time), should_check_subnet = false and the instance passes this check even
    # if it would land in a public subnet. This cannot be resolved at plan time
    # without subnet data
    subnet_id           = core::try(attrs.subnet_id, "")
    should_check_subnet = !local.explicitly_public && local.subnet_id != ""
    subnet_data         = local.should_check_subnet ? core::getresources("aws_subnet", { id = local.subnet_id }) : []
    subnet_config       = core::length(local.subnet_data) > 0 ? local.subnet_data[0] : null
    subnet_auto_assigns_public = local.subnet_config != null ? core::try(local.subnet_config.map_public_ip_on_launch, false) : false

    is_compliant = !local.explicitly_public && !local.has_public_ni && !local.subnet_auto_assigns_public
  }

  enforce {
    condition     = local.is_compliant
    error_message = "EC2 instance must not have a public IPv4 address. 'associate_public_ip_address' must not be true, no network_interface may have public IP enabled, and the instance's subnet must not have 'map_public_ip_on_launch = true'."
  }
}
