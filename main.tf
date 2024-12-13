# main.tf

data "aws_caller_identity" "current" {}

terraform {
  required_version = ">= 0.12"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  profile = "default"
}




module "storage" {
  source                     = "./modules/storage"
  raw_data_bucket_name       = var.raw_data_bucket_name
  processed_data_bucket_name = var.processed_data_bucket_name  # Ensure this matches the variable defined
  analytics_bucket_name      = var.analytics_bucket_name
  tags                       = var.tags
  account_id = data.aws_caller_identity.current.account_id
  }

module "api_gateway" {
  source               = "./modules/api_gateway"
  api_name             = var.api_name
  api_description      = var.api_description
  api_stage_name       = var.api_stage_name
  aws_region           = var.aws_region
  firehose_stream_name = var.firehose_stream_name
  firehose_stream_arn  = var.firehose_stream_arn
  kinesis_stream_name  = ""  # Adding empty string temporarily
  kinesis_stream_arn   = ""  # Adding empty string temporarily
  tags                 = var.tags
}

module "kinesis" {
  source         = "./modules/kinesis"
  project_name   = var.project_name
  raw_bucket_arn = local.raw_bucket_arn
  firehose_stream_name = var.firehose_stream_name
  tags           = var.tags
}

module "lambda" {
  source                     = "./modules/lambda"
  project_name               = var.project_name
  lambda_filename            = var.lambda_filename
  lambda_handler             = var.lambda_handler
  lambda_runtime             = var.lambda_runtime
  lambda_memory_size         = var.lambda_memory_size
  lambda_timeout             = var.lambda_timeout
  raw_data_bucket_name       = var.raw_data_bucket_name
  processed_data_bucket_name = var.processed_data_bucket_name
  raw_bucket_arn             = local.raw_bucket_arn
  processed_bucket_arn       = local.processed_bucket_arn
  tags                       = var.tags
}

module "athena" {
  source                = "./modules/athena"
  athena_database_name  = var.athena_database_name
  athena_workgroup_name = var.athena_workgroup_name
  analytics_bucket_name = var.analytics_bucket_name
  create_table_sql_path = var.create_table_sql_path
  tags                  = var.tags
  table_name           = var.table_name
}



module "quicksight" {
  source                   = "./modules/quicksight"
  project_name             = var.project_name
  athena_workgroup_name    = module.athena.workgroup_name
  quicksight_namespace     = var.quicksight_namespace
  quicksight_user_role     = var.quicksight_user_role
  quicksight_identity_type = var.quicksight_identity_type
  quicksight_user = var.quicksight_user
  quicksight_user_email    = var.quicksight_user_email
  quicksight_policy        = var.quicksight_policy
  tags                     = var.tags
  iam_user               = "workshop" 
  athena_query_results_bucket = module.storage.athena_query_results_bucket
  depends_on                  = [module.athena, module.storage]
}

locals {
  raw_bucket_arn       = "arn:aws:s3:::${var.raw_data_bucket_name}"
  processed_bucket_arn = "arn:aws:s3:::${var.processed_data_bucket_name}"
  analytics_bucket_arn = "arn:aws:s3:::${var.analytics_bucket_name}"
}


resource "aws_s3_bucket" "processed_data" {
  bucket = var.processed_data_bucket_name
  # Remove acl argument here
  # acl    = "private"

  tags = var.tags
}

#resource "aws_s3_bucket_acl" "processed_data_acl" {
 # bucket = aws_s3_bucket.processed_data.id
  #acl    = "private"
#}

resource "aws_s3_bucket" "analytics" {
  bucket = var.analytics_bucket_name
  # Remove acl argument here
  # acl    = "private"

  tags = var.tags
}

#resource "aws_s3_bucket_acl" "analytics_acl" {
 # bucket = aws_s3_bucket.analytics.id
  #acl    = "private"
#}

resource "aws_s3_bucket" "raw_data" {
  bucket = var.raw_data_bucket_name
  # Remove acl argument here
  # acl    = "private"

  tags = var.tags
}

#resource "aws_s3_bucket_acl" "raw_data_acl" {
 # bucket = aws_s3_bucket.raw_data.id
  #acl    = "private"
#}