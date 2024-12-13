output "database_name" {
  value       = aws_athena_database.main.name
  description = "Name of the Athena database"
}

output "workgroup_name" {
  value       = aws_athena_workgroup.main.name
  description = "Name of the Athena workgroup"
}

output "results_bucket_name" {
  value       = aws_s3_bucket.athena_results.bucket
  description = "Name of the S3 bucket storing Athena query results"
}

output "athena_role_arn" {
  description = "ARN of the IAM role for Athena access"
  value       = aws_iam_role.athena_role.arn
}

