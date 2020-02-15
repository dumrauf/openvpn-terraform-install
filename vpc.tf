resource "aws_vpc" "openvpn" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = var.tag_name
    Provisioner = "Terraform"
  }
}

resource "aws_subnet" "openvpn" {
  vpc_id     = aws_vpc.openvpn.id
  cidr_block = cidrsubnet(var.cidr_block, 8, 0)

  tags = {
    Name        = var.tag_name
    Provisioner = "Terraform"
  }
}

resource "aws_internet_gateway" "openvpn" {
  vpc_id = aws_vpc.openvpn.id

  tags = {
    Name        = var.tag_name
    Provisioner = "Terraform"
  }
}

resource "aws_route_table" "openvpn" {
  vpc_id = aws_vpc.openvpn.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.openvpn.id
  }
}

resource "aws_route_table_association" "openvpn" {
  subnet_id      = aws_subnet.openvpn.id
  route_table_id = aws_route_table.openvpn.id
}

resource "aws_security_group" "openvpn" {
  name        = "openvpn"
  description = "Allow inbound UDP access to OpenVPN and unrestricted egress"

  vpc_id = aws_vpc.openvpn.id

  tags = {
    Name        = var.tag_name
    Provisioner = "Terraform"
  }

  ingress {
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ssh_from_local" {
  name        = "ssh-from-local"
  description = "Allow SSH access only from local machine"

  vpc_id = aws_vpc.openvpn.id

  tags = {
    Name        = var.tag_name
    Provisioner = "Terraform"
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
    # force an interpolation expression to be interpreted as a list by wrapping it
    # in an extra set of list brackets. That form was supported for compatibilty in
    # v0.11, but is no longer supported in Terraform v0.12.
    #
    # If the expression in the following list itself returns a list, remove the
    # brackets to avoid interpretation as a list of lists. If the expression
    # returns a single list item then leave it as-is and remove this TODO comment.
    cidr_blocks = [local.local_ip_address]
  }
}

