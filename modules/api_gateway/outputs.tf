output "api_endpoint" {
  value       = "${aws_api_gateway_stage.main.invoke_url}/poc"
  description = "The API Gateway endpoint URL"
}

output "api_id" {
  value       = aws_api_gateway_rest_api.main.id
  description = "The API Gateway ID"
}

output "stage_name" {
  value       = aws_api_gateway_stage.main.stage_name
  description = "The API Gateway stage name"
}