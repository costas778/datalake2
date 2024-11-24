variable "project_name" {
  type        = string
  description = "Name of the project"
}

variable "raw_bucket_arn" {
  type        = string
  description = "ARN of the raw data bucket"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
}

