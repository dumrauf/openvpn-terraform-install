variable "aws_region" {
  description = "The AWS region to use"
  default     = "eu-west-2"
}

variable "shared_credentials_file" {
  description = "The location of the AWS shared credentials file (e.g. ~dominic/.aws/credentials)"
}

variable "profile" {
  description = "The profile to use"
}

variable "tag_name" {
  description = "The name to tag AWS resources with"
  default     = "OpenVPN"
}

variable "cidr_block" {
  description = "The CIDR block range to use for the OpenVPN VPC"
  default     = "10.0.0.0/16"
}

variable "instance_type" {
  description = "The instance type to use"
  default     = "t3.micro"
}

variable "instance_root_block_device_volume_size" {
  description = "The size of the root block device volume of the EC2 instance in GiB"
  default     = 8
}

variable "ec2_username" {
  description = "The user to connect to the EC2 as"
  default     = "ec2-user"
}

variable "openvpn_install_script_location" {
  description = "The location of an OpenVPN installation script compatible with https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh"
  default     = "https://raw.githubusercontent.com/dumrauf/openvpn-install/master/openvpn-install.sh"
}

variable "ssh_public_key_file" {
  # Generate via 'ssh-keygen -f openvpn -t rsa'
  description = "The public SSH key to store in the EC2 instance"
  default     = "settings/openvpn.pub"
}

variable "ssh_private_key_file" {
  # Generate via 'ssh-keygen -f openvpn -t rsa'
  description = "The private SSH key used to connect to the EC2 instance"
  default     = "settings/openvpn"
}

variable "ovpn_users" {
  type        = list(string)
  description = "The list of users to automatically provision with OpenVPN access"
}

variable "ovpn_config_directory" {
  description = "The name of the directory to eventually download the OVPN configuration files to"
  default     = "generated/ovpn-config"
}

