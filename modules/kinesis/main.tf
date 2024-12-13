# Create IAM role for Firehose
resource "aws_iam_role" "firehose_role" {
  name = "firehose-delivery-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "firehose.amazonaws.com"
        }
      }
    ]
  })
}

# Create IAM policy for Firehose
resource "aws_iam_role_policy" "firehose_s3" {
  name = "firehose-s3-policy"
  role = aws_iam_role.firehose_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          var.raw_bucket_arn,
          "${var.raw_bucket_arn}/*"
        ]
      }
    ]
  })
}

# Single Kinesis Firehose delivery stream
resource "aws_kinesis_firehose_delivery_stream" "firehose" {
  name        = var.firehose_stream_name
  #name        = var.kinesis_stream_name
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = var.raw_bucket_arn
  }
}