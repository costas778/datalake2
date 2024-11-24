output "firehose_arn" {
  value       = aws_kinesis_firehose_delivery_stream.main.arn
  description = "ARN of the Kinesis Firehose delivery stream"
}

output "firehose_name" {
  value       = aws_kinesis_firehose_delivery_stream.main.name
  description = "Name of the Kinesis Firehose delivery stream"
}

output "role_arn" {
  value       = aws_iam_role.firehose.arn
  description = "ARN of the Firehose IAM role"
}