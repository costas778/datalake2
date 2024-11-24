output "data_source_arn" {
  value       = aws_quicksight_data_source.athena.arn
  description = "ARN of the QuickSight data source"
}

output "data_source_id" {
  value       = aws_quicksight_data_source.athena.data_source_id
  description = "ID of the QuickSight data source"
}