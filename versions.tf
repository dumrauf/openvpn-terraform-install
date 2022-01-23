
terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket         = "openvpn-to-the-moon"
    key            = "terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "openvpn"
    encrypt        = true
  }
}
