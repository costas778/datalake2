variable "bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "key" {
  description = "Path within the S3 bucket for the Terraform state file"
  type        = string
  default     = "environment_serverless1/dev/terraform.tfstate"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "datalake"
}

variable "storage_bucket_prefix" {
  description = "Prefix for storage buckets"
  type        = string
  default     = "data-lake"
}

variable "raw_data_bucket_name" {
  description = "Name of the raw data bucket"
  type        = string
}

variable "processed_data_bucket_name" {
  description = "Name of the processed data bucket"
  type        = string
}

variable "analytics_bucket_name" {
  description = "Name of the analytics data bucket"
  type        = string
}

variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
  default     = "data-ingestion-api"
}

variable "api_description" {
  description = "Description of the API Gateway"
  type        = string
  default     = "API for data ingestion"
}

variable "api_stage_name" {
  description = "Name of the API Gateway stage"
  type        = string
  default     = "dev"
}

variable "kinesis_stream_arn" {
  description = "ARN of the Kinesis stream"
  type        = string
}

variable "kinesis_stream_name" {
  description = "Name of the Kinesis stream"
  type        = string
  default     = "data-stream"
}

variable "kinesis_retention_period" {
  description = "Retention period for the Kinesis stream"
  type        = number
  default     = 24
}

variable "kinesis_shard_count" {
  description = "Shard count for the Kinesis stream"
  type        = number
  default     = 1
}

variable "lambda_runtime" {
  description = "Runtime for the Lambda function"
  type        = string
  default     = "python3.9"
}

variable "lambda_memory_size" {
  description = "Memory size for the Lambda function"
  type        = number
  default     = 128
}

variable "lambda_timeout" {
  description = "Timeout for the Lambda function"
  type        = number
  default     = 30
}

variable "lambda_handler" {
  description = "Handler for the Lambda function"
  type        = string
  default     = "transform.handler"
}

variable "lambda_filename" {
  description = "Filename for the Lambda function"
  type        = string
}

variable "athena_database_name" {
  description = "Name of the Athena database"
  type        = string
  default     = "analytics_db"
}

variable "athena_output_location" {
  description = "Output location for Athena queries"
  type        = string
  default     = "athena-results"
}

variable "athena_workgroup_name" {
  description = "Name of the Athena workgroup"
  type        = string
  default     = "primary"
}

variable "create_table_sql_path" {
  description = "Path to the SQL file for creating tables"
  type        = string
}

variable "quicksight_namespace" {
  description = "Namespace for QuickSight"
  type        = string
  default     = "default"
}

variable "quicksight_user_role" {
  description = "User role for QuickSight"
  type        = string
  default     = "AUTHOR"
}

variable "quicksight_identity_type" {
  description = "Identity type for QuickSight"
  type        = string
  default     = "IAM"
}

variable "quicksight_user" {
  description = "QuickSight user"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "datalake"
    ManagedBy   = "terraform"
  }
}