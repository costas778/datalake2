# modules/lambda/variables.tf

variable "project_name" {
  description = "Name of the project"
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

variable "raw_data_bucket_name" {
#variable "raw_bucket_arn"
  description = "ARN of the raw data bucket"
  type        = string
}

variable "processed_data_bucket_name" {
# variable "processed_bucket_arn" 
  description = "ARN of the processed data bucket"
  type        = string
}

variable "tags" {
  description = "Tags for resources"
  type        = map(string)
}

variable "raw_bucket_arn" {
  description = "ARN of the raw data S3 bucket"
  type        = string
}

variable "processed_bucket_arn" {
  description = "ARN of the processed data S3 bucket"
  type        = string
}