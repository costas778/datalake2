variable "project_name" {
  type        = string
  description = "Name of the project"
}

variable "lambda_filename" {
  type        = string
  description = "Path to the Lambda deployment package"
}

variable "lambda_handler" {
  type        = string
  description = "Lambda function handler"
}

variable "lambda_runtime" {
  type        = string
  description = "Lambda function runtime"
}

variable "lambda_memory_size" {
  type        = number
  description = "Amount of memory in MB for the Lambda function"
}

variable "lambda_timeout" {
  type        = number
  description = "Timeout in seconds for the Lambda function"
}

variable "raw_bucket_arn" {
  type        = string
  description = "ARN of the raw data bucket"
}

variable "processed_bucket_arn" {
  type        = string
  description = "ARN of the processed data bucket"
}

variable "processed_bucket_name" {
  type        = string
  description = "Name of the processed data bucket"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
}
