terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region = var.aws_region
}

module "storage" {
  source = "./modules/storage"
  raw_data_bucket_name = var.raw_data_bucket_name
  processed_data_bucket_name = var.processed_data_bucket_name
  analytics_bucket_name = var.analytics_bucket_name
  tags = var.tags
}

module "api_gateway" {
  source = "./modules/api_gateway"
  api_name = var.api_name
  api_description = var.api_description
  api_stage_name = var.api_stage_name
  kinesis_stream_arn = var.kinesis_stream_arn
  tags = var.tags
}

module "kinesis" {
  source = "./modules/kinesis"
  project_name = var.project_name
  raw_bucket_arn = var.raw_bucket_arn
  tags = var.tags
}

module "lambda" {
  source = "./modules/lambda"
  project_name = var.project_name
  lambda_filename = var.lambda_filename
  lambda_handler = var.lambda_handler
  lambda_runtime = var.lambda_runtime
  lambda_memory_size = var.lambda_memory_size
  lambda_timeout = var.lambda_timeout
  raw_bucket_arn = var.raw_bucket_arn
  processed_bucket_arn = var.processed_bucket_arn
  processed_bucket_name = var.processed_bucket_name
  tags = var.tags
}

module "athena" {
  source = "./modules/athena"
  database_name = var.athena_database_name
  workgroup_name = var.athena_workgroup_name
  analytics_bucket_name = var.analytics_bucket_name
  create_table_sql_path = var.create_table_sql_path
  tags = var.tags
}

module "quicksight" {
  source = "./modules/quicksight"
  project_name = var.project_name
  athena_workgroup_name = var.athena_workgroup_name
  quicksight_user = var.quicksight_user
  tags = var.tags
}

