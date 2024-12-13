variable "raw_data_bucket_name" {
  type        = string
  description = "Name of the S3 bucket for raw data"
}

variable "processed_data_bucket_name" {
  type        = string
  description = "Name of the S3 bucket for processed data"
}

variable "analytics_bucket_name" {
  type        = string
  description = "Name of the S3 bucket for analytics data"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
}

variable "account_id" {
  type        = string
  description = "AWS Account ID"
}


