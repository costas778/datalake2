terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.0"

  backend "s3" {}  # Comment this out temporarily
}

# Remove or comment out this provider block
# provider "aws" {
#   region = var.aws_region
# }

# Add module blocks for each component:

module "storage" {
  source = "./modules/storage"
  # Add required variables
}

module "api_gateway" {
  source = "./modules/api_gateway"
  
  api_name        = "clickstream-ingest-poc"
  api_description = "API for clickstream data ingestion"
  api_stage_name  = "dev"
  aws_region      = var.aws_region
  
  firehose_stream_name = module.kinesis.firehose_stream_name
  firehose_stream_arn  = module.kinesis.firehose_stream_arn
  
  tags = {
    Environment = "dev"
    Project     = "clickstream"
  }
}

module "kinesis" {
  source = "./modules/kinesis"
  # Add required variables
}

module "lambda" {
  source = "./modules/lambda"
  # Add required variables
}

module "athena" {
  source = "./modules/athena"
  # Add required variables
}

module "quicksight" {
  source = "./modules/quicksight"
  # Add required variables
}

