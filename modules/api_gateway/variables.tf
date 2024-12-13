variable "api_name" {
  type        = string
  description = "Name of the API Gateway"
}

variable "api_description" {
  type        = string
  description = "Description of the API Gateway"
}

variable "api_stage_name" {
  type        = string
  description = "Name of the API Gateway stage"
}

variable "aws_region" {
  type        = string
  description = "AWS Region"
}

variable "firehose_stream_name" {
  type        = string
  description = "Name of the Kinesis Firehose delivery stream"
}

variable "firehose_stream_arn" {
  type        = string
  description = "ARN of the Kinesis Firehose delivery stream"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
}

variable "kinesis_stream_arn" {
  description = "ARN of the Kinesis stream"
  type        = string
}

variable "kinesis_stream_name" {
  description = "Name of the Kinesis stream"
  type        = string
}
