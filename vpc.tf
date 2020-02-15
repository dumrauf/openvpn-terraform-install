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
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.local_ip_address]
  }
}

