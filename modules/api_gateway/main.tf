resource "aws_api_gateway_rest_api" "main" {
  name        = var.api_name
  description = var.api_description
  tags        = var.tags
}

resource "aws_api_gateway_resource" "poc" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "poc"
}

resource "aws_api_gateway_method" "poc_post" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.poc.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "firehose" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.poc.id
  http_method             = aws_api_gateway_method.poc_post.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.aws_region}:firehose:action/PutRecord"
  credentials            = aws_iam_role.api_gateway.arn
  
  request_templates = {
    "application/json" = <<EOF
{
    "DeliveryStreamName": "${var.firehose_stream_name}",
    "Record": {
        "Data": "$util.base64Encode($util.escapeJavaScript($input.json('$')).replace('\\', ''))"
    }
}
EOF
  }
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.poc.id
  http_method = aws_api_gateway_method.poc_post.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "firehose" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.poc.id
  http_method = aws_api_gateway_method.poc_post.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code
}

resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  
  depends_on = [
    aws_api_gateway_integration.firehose
  ]
}

resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id  = aws_api_gateway_rest_api.main.id
  stage_name   = var.api_stage_name
}

# IAM role for API Gateway
resource "aws_iam_role" "api_gateway" {
  name = "${var.api_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "api_gateway" {
  name = "${var.api_name}-policy"
  role = aws_iam_role.api_gateway.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "firehose:PutRecord"
        ]
        Resource = [var.firehose_stream_arn]
      }
    ]
  })
}
