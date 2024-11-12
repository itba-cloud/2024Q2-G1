# Definición del bucket S3
resource "aws_s3_bucket" "presigned_bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = "Presigned URL Bucket"
    Environment = var.environment
  }
}

# Configuración de acceso público del bucket
resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket                  = aws_s3_bucket.presigned_bucket.id
  block_public_acls       = true
  block_public_policy     = false
}

# Política del bucket para permitir acceso de lectura/escritura desde URLs presignadas
resource "aws_s3_bucket_policy" "presigned_policy" {
  bucket = aws_s3_bucket.presigned_bucket.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "AllowPresignedUrlUploads",
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "s3:GetObject",
          "s3:PutObject"
        ],
        "Resource": "arn:aws:s3:::${var.bucket_name}/*",
        "Condition": {
          "StringEquals": {
            "aws:RequestTag/AllowPresignedUrl": "true"
          }
        }
      },
      {
        "Sid": "AllowPublicReadAccess",
        "Effect": "Allow",
        "Principal": "*",
        "Action": "s3:GetObject",
        "Resource": "arn:aws:s3:::${var.bucket_name}/*"
      }
    ]
  })
}


# Configuración de CORS del bucket
resource "aws_s3_bucket_cors_configuration" "cors" {
  bucket = aws_s3_bucket.presigned_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "GET", "POST", "DELETE"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag", "x-amz-request-id", "x-amz-id-2", "x-amz-security-token"]
  }
}
