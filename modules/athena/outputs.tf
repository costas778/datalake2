output "database_name" {
  value       = aws_athena_database.main.name
  description = "Name of the Athena database"
}

output "workgroup_name" {
  value       = aws_athena_workgroup.main.name
  description = "Name of the Athena workgroup"
}
