# variables.tf

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "quicksight_user" {
 description = "QuickSight user name"
 type        = string
}

variable "athena_output_location" {
  description = "Location for Athena query results"
  type        = string
}

#variable "processed_bucket_name" {
 # description = "Name of the S3 bucket for processed data"
  #type        = string
#}

variable "create_table_sql_path" {
  description = "Path to the SQL file for creating Athena tables"
  type        = string
}

variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
}

variable "api_description" {
  description = "Description of the API Gateway"
  type        = string
}

variable "api_stage_name" {
  description = "Stage name of the API Gateway"
  type        = string
}

variable "athena_database_name" {
  description = "Name of the Athena database"
  type        = string
}

variable "athena_workgroup_name" {
  description = "Name of the Athena workgroup"
  type        = string
}

variable "processed_data_bucket_name" {
  description = "Name of the S3 bucket for processed data"
  type        = string
}

variable "analytics_bucket_name" {
  description = "Name of the S3 bucket for analytics data"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}

# S3 Buckets
variable "raw_data_bucket_name" {
  description = "Name of the S3 bucket for raw data"
  type        = string
}

variable "firehose_stream_name" {
  description = "Name of the Firehose stream"
  type        = string
}

variable "firehose_stream_arn" {
  description = "ARN of the Firehose stream"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "kinesis_stream_name" {
  description = "Name of the Kinesis stream"
  type        = string
}

variable "lambda_filename" {
  description = "Filename for the Lambda function"
  type        = string
}

variable "lambda_handler" {
  description = "Handler for the Lambda function"
  type        = string
}

variable "lambda_runtime" {
  description = "Runtime for the Lambda function"
  type        = string
}

variable "lambda_memory_size" {
  description = "Memory size for the Lambda function"
  type        = number
}

variable "lambda_timeout" {
  description = "Timeout for the Lambda function"
  type        = number
}

# variables.tf

variable "quicksight_user_email" {
  description = "Email address of the QuickSight user"
  type        = string
}

# variables.tf

variable "quicksight_policy" {
  description = "IAM policy for QuickSight"
  type        = string
}

# variables.tf

variable "quicksight_namespace" {
  description = "The QuickSight namespace."
  type        = string
}

variable "quicksight_user_role" {
  description = "The role of the QuickSight user (e.g., ADMIN, AUTHOR, READER)."
  type        = string
}

variable "quicksight_identity_type" {
  description = "The identity type for the QuickSight user (e.g., 'IAM' or 'QUICKSIGHT')."
  type        = string
}

# variables.tf

variable "processed_bucket_arn" {
  description = "ARN of the processed data S3 bucket"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

# Add any other missing variables here...


variable "raw_bucket_arn" {
  description = "ARN of the raw data S3 bucket"
  type        = string
}

variable "kinesis_stream_arn" {
  description = "ARN of the Kinesis stream"
  type        = string
}

# newest

variable "kinesis_retention_period" {
  description = "Retention period for the Kinesis stream in hours"
  type        = number
}

variable "storage_bucket_prefix" {
  description = "Prefix for storage buckets"
  type        = string
}

# newest

variable "kinesis_shard_count" {
  description = "Number of shards for the Kinesis stream"
  type        = number
}


variable "table_name" {
  description = "Name of the Athena/Glue table"
  type        = string
  default     = "my_ingested_data"
}