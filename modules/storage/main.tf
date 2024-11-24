resource "aws_s3_bucket" "raw_data" {
  bucket = var.raw_data_bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket" "processed_data" {
  bucket = var.processed_data_bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket" "analytics_data" {
  bucket = var.analytics_bucket_name
  tags   = var.tags
}

# Enable versioning
resource "aws_s3_bucket_versioning" "raw_data" {
  bucket = aws_s3_bucket.raw_data.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "processed_data" {
  bucket = aws_s3_bucket.processed_data.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "analytics_data" {
  bucket = aws_s3_bucket.analytics_data.id
  versioning_configuration {
    status = "Enabled"
  }
}

