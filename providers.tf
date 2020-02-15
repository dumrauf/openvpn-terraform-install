provider "aws" {
  version = "~> 2.7"

  region                  = var.aws_region
  shared_credentials_file = var.shared_credentials_file
  profile                 = var.profile
}

