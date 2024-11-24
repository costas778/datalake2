output "raw_data_bucket_arn" {
  value       = aws_s3_bucket.raw_data.arn
  description = "ARN of the raw data bucket"
}

output "raw_data_bucket_name" {
  value       = aws_s3_bucket.raw_data.id
  description = "Name of the raw data bucket"
}

output "processed_data_bucket_arn" {
  value       = aws_s3_bucket.processed_data.arn
  description = "ARN of the processed data bucket"
}

output "analytics_data_bucket_arn" {
  value       = aws_s3_bucket.analytics_data.arn
  description = "ARN of the analytics data bucket"
}
