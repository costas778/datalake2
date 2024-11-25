resource "aws_lambda_function" "transform" {
  filename         = var.lambda_filename
  function_name    = "${var.project_name}-transform"
  role            = aws_iam_role.lambda.arn
  handler         = var.lambda_handler
  runtime         = var.lambda_runtime
  memory_size     = var.lambda_memory_size
  timeout         = var.lambda_timeout
  source_code_hash = filebase64sha256(var.lambda_filename)

  environment {
    variables = {
      RAW_BUCKET_ARN       = var.raw_bucket_arn
      PROCESSED_BUCKET = var.processed_bucket_name
    }
  }

  tags = var.tags
}

resource "aws_iam_role" "lambda" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda" {
  name = "${var.project_name}-lambda-policy"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ]
        Resource = [
          "${var.raw_bucket_arn}/*",
          "${var.processed_bucket_arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = ["arn:aws:logs:*:*:*"]
      }
    ]
  })
}

