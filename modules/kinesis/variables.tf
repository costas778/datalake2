variable "project_name" {
  type        = string
  description = "Name of the project"
}

variable "kinesis_stream_arn" {
  description = "ARN of the Kinesis stream"
  type        = string
  default     = ""  # Adding default empty string
}

variable "kinesis_stream_name" {
  description = "Name of the Kinesis stream"
  type        = string
  default     = ""  # Adding default empty string
}

variable "raw_bucket_arn" {
  type        = string
  description = "ARN of the raw S3 bucket"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
}



variable "firehose_stream_name" {
  description = "Name of the Firehose delivery stream"
  type        = string
}
