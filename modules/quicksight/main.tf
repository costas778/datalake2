# modules/quicksight/main.tf

data "aws_caller_identity" "current" {}

# New IAM role and policy for QuickSight
resource "aws_iam_role" "quicksight_role" {
  name = "${var.project_name}-quicksight-athena-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "quicksight.amazonaws.com",
            "athena.amazonaws.com"
          ]
        }
      }
    ]
  })

  tags = var.tags
}



resource "aws_iam_role_policy" "quicksight_policy" {
  name = "${var.project_name}-quicksight-athena-policy"
  role = aws_iam_role.quicksight_role.id

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
          "s3:DeleteObject"
        ]
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_iam_policy" "quicksight_management" {
  name        = "QuickSightManagementPolicy"
  description = "Policy to manage QuickSight users"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "athena:*",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:ListMultipartUploadParts",
          "s3:AbortMultipartUpload",
          "s3:CreateBucket",
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Resource = [
          "arn:aws:athena:*:${data.aws_caller_identity.current.account_id}:workgroup/*",
          "arn:aws:s3:::athena-query-results-${data.aws_caller_identity.current.account_id}",
          "arn:aws:s3:::athena-query-results-${data.aws_caller_identity.current.account_id}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "glue:GetTable",
          "glue:GetDatabase",
          "glue:GetPartition",
          "glue:GetPartitions",
          "glue:BatchGetPartition"
        ]
        Resource = [
          "arn:aws:glue:*:${data.aws_caller_identity.current.account_id}:catalog",
          "arn:aws:glue:*:${data.aws_caller_identity.current.account_id}:database/*",
          "arn:aws:glue:*:${data.aws_caller_identity.current.account_id}:table/*"
        ]
      }
    ]
  })
}

data "aws_iam_user" "quicksight_user" {
  user_name = contains(split("", var.iam_user), "/") ? split("/", var.iam_user)[1] : var.iam_user
}

resource "aws_iam_user_policy_attachment" "attach_quicksight_policy" {
  user       = data.aws_iam_user.quicksight_user.user_name
  policy_arn = aws_iam_policy.quicksight_management.arn
}

resource "aws_quicksight_user" "user" {
  aws_account_id = data.aws_caller_identity.current.account_id
  email          = var.quicksight_user_email
  identity_type  = "IAM"
  namespace      = "default"
  user_role      = "ADMIN"
  iam_arn        = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${var.iam_user}"

  depends_on = [
    aws_iam_user_policy_attachment.attach_quicksight_policy
  ]
}

resource "aws_athena_workgroup" "example" {
  name = "datalake_workgroup-7e6ab79a"

  configuration {
    result_configuration {
      output_location = "s3://athena-query-results-${data.aws_caller_identity.current.account_id}/query-results/"
    }
  }

  force_destroy = false
}



resource "aws_quicksight_data_source" "athena" {
  aws_account_id = data.aws_caller_identity.current.account_id
  data_source_id = "${var.project_name}-athena-ds"
  name           = "${var.project_name}-athena-ds"
  type           = "ATHENA"

  parameters {
    athena {
      work_group = "datalake_workgroup-7e6ab79a"
    }
  }

  permission {
    principal = aws_quicksight_user.user.arn
    actions   = [
      "quicksight:DescribeDataSource",
      "quicksight:DescribeDataSourcePermissions",
      "quicksight:PassDataSource",
      "quicksight:UpdateDataSource",
      "quicksight:DeleteDataSource",
      "quicksight:UpdateDataSourcePermissions"
    ]
  }

  tags = var.tags

  depends_on = [
    aws_iam_role_policy.quicksight_policy,
    aws_quicksight_user.user,
    var.athena_query_results_bucket
  ]
}



resource "aws_iam_role_policy" "quicksight_athena_results" {
  name = "quicksight-athena-results-access"
  role = aws_iam_role.quicksight_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts",
          "s3:ListBucketMultipartUploads"
        ]
        Resource = [
          "arn:aws:s3:::athena-query-results-${data.aws_caller_identity.current.account_id}",
          "arn:aws:s3:::athena-query-results-${data.aws_caller_identity.current.account_id}/*"
        ]
      }
    ]
  })
}

resource "aws_s3_bucket_policy" "athena_results" {
  bucket = "athena-query-results-${data.aws_caller_identity.current.account_id}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowQuickSightAndAthena"
        Effect = "Allow"
        Principal = {
          Service = ["quicksight.amazonaws.com", "athena.amazonaws.com"]
        }
        Action = [
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts",
          "s3:ListBucketMultipartUploads"
        ]
        Resource = [
          "arn:aws:s3:::athena-query-results-${data.aws_caller_identity.current.account_id}",
          "arn:aws:s3:::athena-query-results-${data.aws_caller_identity.current.account_id}/*"
        ]
      }
    ]
  })
}
