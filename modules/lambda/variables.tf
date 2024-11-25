variable "lambda_filename" {
  description = "Filename for the Lambda function"
  type        = string
}

variable "lambda_handler" {
  description = "Handler for the Lambda function"
  type        = string
  default     = "transform.lambda_handler"
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

variable "raw_bucket_arn" {
  description = "ARN of the raw data bucket"
  type        = string
}

variable "processed_bucket_arn" {
  description = "ARN of the processed data bucket"
  type        = string
}

variable "processed_bucket_name" {
  description = "Name of the processed data bucket"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}