output "bucket_id" {
  description = "ID del bucket S3"
  value       = aws_s3_bucket.presigned_bucket.id
}

output "bucket_arn" {
  description = "ARN del bucket S3"
  value       = aws_s3_bucket.presigned_bucket.arn
}

output "bucket_bucket" {
  description = "ARN del bucket S3"
  value       = aws_s3_bucket.presigned_bucket.bucket
}