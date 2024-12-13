# modules/athena/main.tf

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_athena_database" "main" {
  name   = "datalake_db" 
  bucket = aws_s3_bucket.athena_results.bucket
}

resource "aws_s3_bucket" "athena_results" {
  bucket        = "athena-query-results-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
  tags          = var.tags
}

resource "aws_s3_bucket_versioning" "athena_versioning" {
  bucket = aws_s3_bucket.athena_results.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "athena_lifecycle" {
  bucket = aws_s3_bucket.athena_results.id

  rule {
    id     = "delete_old_results"
    status = "Enabled"

    expiration {
      days = 30  # Increased from 1 to 30 days for better retention
    }

    noncurrent_version_expiration {
      noncurrent_days = 7  # Increased from 1 to 7 days
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }
}

resource "aws_athena_workgroup" "main" {
    name          = var.athena_workgroup_name
  force_destroy = true

  configuration {
    result_configuration {
      output_location = "s3://${aws_s3_bucket.athena_results.bucket}/query-results/"
      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }

    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true
  }

  depends_on = [aws_s3_bucket.athena_results]
  tags       = var.tags
}



#resource "aws_athena_named_query" "create_table" {
 # name      = "create-table-query"
  #database  = aws_athena_database.main.name
  #query     = file(var.create_table_sql_path)
  #workgroup = aws_athena_workgroup.main.name
#}

resource "aws_glue_catalog_table" "analytics_table" {
  name          = "my_ingested_data"
  database_name = "datalake_db"
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    "projection.enabled"              = "true"
    "projection.datehour.type"       = "date"
    "projection.datehour.format"     = "yyyy/MM/dd/HH"
    "projection.datehour.range"      = "2021/01/01/00,NOW"
    "projection.datehour.interval"   = "1"
    "projection.datehour.interval.unit" = "HOURS"
    "storage.location.template" = "s3://analytics-data-961109809677-20241208-36dd79aae713/$${datehour}/"
  }

  storage_descriptor {
    location      = "s3://analytics-data-961109809677-20241208-36dd79aae713/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.IgnoreKeyTextOutputFormat"

    ser_de_info {
      name                  = "JsonSerDe"
      serialization_library = "org.openx.data.jsonserde.JsonSerDe"
      parameters = {
        "paths" = "element_clicked, time_spent, source_menu, created_at"
      }
    }

    columns {
      name = "element_clicked"
      type = "string"
    }
    columns {
      name = "time_spent"
      type = "int"
    }
    columns {
      name = "source_menu"
      type = "string"
    }
    columns {
      name = "created_at"
      type = "string"
    }
  }

  partition_keys {
    name = "datehour"
    type = "string"
  }
}



# Add IAM role for Athena access
resource "aws_iam_role" "athena_role" {
  name = "athena-quicksight-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = ["athena.amazonaws.com", "quicksight.amazonaws.com"]
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
      }
    ]
  })
}

# Add IAM policy for Athena access
resource "aws_iam_role_policy" "athena_policy" {
  name = "athena-quicksight-access-policy"
  role = aws_iam_role.athena_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "athena:*",
          "glue:GetTable",
          "glue:GetDatabase",
          "glue:GetPartition",
          "glue:GetPartitions",
          "glue:BatchGetPartition",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:GetBucketAcl",
          "s3:ListMultipartUploadParts",
          "s3:ListBucketMultipartUploads",
          "s3:AbortMultipartUpload",
          "s3:CreateBucket"
        ]
        Resource = [
          "arn:aws:athena:*:${data.aws_caller_identity.current.account_id}:workgroup/*",
          "arn:aws:s3:::athena-query-results-${data.aws_caller_identity.current.account_id}",
          "arn:aws:s3:::athena-query-results-${data.aws_caller_identity.current.account_id}/*",
          "arn:aws:glue:*:${data.aws_caller_identity.current.account_id}:catalog",
          "arn:aws:glue:*:${data.aws_caller_identity.current.account_id}:database/*",
          "arn:aws:glue:*:${data.aws_caller_identity.current.account_id}:table/*"
        ]
      }
    ]
  })
}

resource "aws_s3_bucket_policy" "athena_results" {
  bucket = aws_s3_bucket.athena_results.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowQuickSightAccess"
        Effect = "Allow"
        Principal = {
          Service = "quicksight.amazonaws.com"
        }
        Action = [
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          aws_s3_bucket.athena_results.arn,
          "${aws_s3_bucket.athena_results.arn}/*"
        ]
      }
    ]
  })
}
