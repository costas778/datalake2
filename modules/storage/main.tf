data "aws_caller_identity" "current" {}


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

# Add the bucket policy here, right after the analytics_data bucket
resource "aws_s3_bucket_policy" "analytics_data" {
  bucket = aws_s3_bucket.analytics_data.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowQuickSightAndAthenaAccess"
        Effect = "Allow"
        Principal = {
          Service = ["quicksight.amazonaws.com", "athena.amazonaws.com"]
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.analytics_data.arn,
          "${aws_s3_bucket.analytics_data.arn}/*"
        ]
      },
      {
        Sid    = "AllowAthenaUserAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.account_id}:root"
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.analytics_data.arn,
          "${aws_s3_bucket.analytics_data.arn}/*"
        ]
      }
    ]
  })
}

# Enable versioning for each bucket
resource "aws_s3_bucket_versioning" "raw_data_versioning" {
  bucket = aws_s3_bucket.raw_data.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "processed_data_versioning" {
  bucket = aws_s3_bucket.processed_data.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "analytics_versioning" {
  bucket = aws_s3_bucket.analytics_data.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Add Athena query results bucket
resource "aws_s3_bucket" "athena_query_results" {
  bucket = "athena-query-results-${var.account_id}"
  tags   = var.tags
}

# Add bucket policy for Athena
resource "aws_s3_bucket_policy" "athena_query_results" {
  bucket = aws_s3_bucket.athena_query_results.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowAthenaAndQuickSightAccess"
        Effect = "Allow"
        Principal = {
          Service = ["athena.amazonaws.com", "quicksight.amazonaws.com"]
        }
        Action = [
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Resource = [
          aws_s3_bucket.athena_query_results.arn,
          "${aws_s3_bucket.athena_query_results.arn}/*"
        ]
      },
      {
        Sid    = "AllowIAMUserAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.account_id}:root"
        }
        Action = [
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Resource = [
          aws_s3_bucket.athena_query_results.arn,
          "${aws_s3_bucket.athena_query_results.arn}/*"
        ]
      }
    ]
  })
}


# Add output for the new bucket
output "athena_query_results_bucket" {
  value = aws_s3_bucket.athena_query_results.id
}
