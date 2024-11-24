output "function_arn" {
  value       = aws_lambda_function.transform.arn
  description = "ARN of the Lambda function"
}

output "function_name" {
  value       = aws_lambda_function.transform.function_name
  description = "Name of the Lambda function"
}

output "role_arn" {
  value       = aws_iam_role.lambda.arn
  description = "ARN of the Lambda IAM role"
}

