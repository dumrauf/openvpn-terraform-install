# Build an S3 bucket to store TF state
resource "aws_s3_bucket" "state_bucket" {
  bucket = "openvpn-to-the-moon"

  # Tells AWS to encrypt the S3 bucket at rest by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  # Tells AWS to keep a version history of the state file
  versioning {
    enabled = true
  }

  lifecycle_rule {
    id = "state bucket lifecycle"
    enabled = true
    abort_incomplete_multipart_upload_days = 1
    noncurrent_version_transition {
      days = 1
      storage_class = "INTELLIGENT_TIERING"      
    }

    transition {
      storage_class = "INTELLIGENT_TIERING"
    }
  }  
}

# Build a DynamoDB Table to use for Terraform state locking
resource "aws_dynamodb_table" "tf_lock_state" {
  name = "openvpn"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}