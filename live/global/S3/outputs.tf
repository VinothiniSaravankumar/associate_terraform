output "s3_bucket_arn" {
    value = aws_s3_bucket.s3_bkt_4_statefile.arn
    description = "The ARN of the S3 bucket"  
}

output "s3_bucket_out" {
    value = aws_s3_bucket.s3_bkt_4_statefile.region
    description = "The region of s3_bucket"
  
}
output "dynamodb_table_name" {
    value = aws_dynamodb_table.terraform_locks.name
    description = "name of synamo db table"
  
}