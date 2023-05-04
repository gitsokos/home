provider "aws" {
  region = "eu-west-3"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.backend-prefix}-state"

  # Prevent accidental deletion of this S3 bucket
  lifecycle {
#    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption by default
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name = "${var.backend-prefix}-locks"

  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"
    attribute {
    name = "LockID"
    type = "S"
  }
}
