variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
}

# Add these new variables
variable "api_name" {
  type        = string
  description = "Name of the API Gateway"
  default     = "clickstream-ingest-poc"
}

variable "api_description" {
  type        = string
  description = "Description of the API Gateway"
  default     = "API for clickstream data ingestion"
}

variable "api_stage_name" {
  type        = string
  description = "Name of the API Gateway stage"
  default     = "dev"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default = {
    Environment = "dev"
    Project     = "clickstream"
  }
}