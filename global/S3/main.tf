terraform {
   backend "s3" {
    key = "global/s3/terraform.tfstate"     
   } 

}
provider "aws" {
    region = "us-east-2"
}

resource "aws_s3_bucket" "s3_bkt_4_statefile" {
  bucket = "statefilestore"
  
  # prevent accidental deletion of this S3 bucket
  # commented the below lifecycle config and added force_destory to execute terraform destroy
  # For force_destroy to take effect, execute terraform_apply and then execute terraform destroy
  lifecycle {
    prevent_destroy = true
  }
# force_destroy = true
}

# enable versioning so that you can see the full revision history of your state files
resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.s3_bkt_4_statefile.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# enable server side encryption by default
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
    bucket = aws_s3_bucket.s3_bkt_4_statefile.id
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  
}

# Restrict public access
resource "aws_s3_bucket_public_access_block" "public_access" {
    bucket = aws_s3_bucket.s3_bkt_4_statefile.id
    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true 
}

# create dynamo DB table for locking with TF
resource "aws_dynamodb_table" "terraform_locks" {
  name = "s3_bkt_locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}


