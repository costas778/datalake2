output "firehose_arn" {
  value = aws_kinesis_firehose_delivery_stream.firehose.arn
}

output "firehose_name" {
  value = aws_kinesis_firehose_delivery_stream.firehose.name
}

output "role_arn" {
  value = aws_iam_role.firehose_role.arn
}