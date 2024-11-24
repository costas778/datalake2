#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo "Setting up Terraform backend infrastructure..."

# Clean up any existing state
rm -rf .terraform
rm -f .terraform.lock.hcl

# Initialize and apply backend setup
terraform init
terraform apply -auto-approve

# Get the generated bucket name
BUCKET_NAME=$(terraform output -raw s3_bucket_name)

# Create backend.hcl
cat > backend.hcl << EOF
bucket         = "${BUCKET_NAME}"
key            = "environment_serverless1/dev/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "terraform-locks"
encrypt        = true
EOF

echo -e "${GREEN}Backend infrastructure created successfully!${NC}"
echo -e "S3 Bucket: ${GREEN}$BUCKET_NAME${NC}"
echo -e "DynamoDB Table: ${GREEN}terraform-locks${NC}"

# Uncomment the backend configuration in main.tf
sed -i 's/# backend "s3" {}/backend "s3" {}/' main.tf

# Initialize main Terraform configuration with backend
echo "Initializing main Terraform configuration..."
terraform init -backend-config=backend.hcl

# Uncomment the provider configuration in main.tf
sed -i 's/# provider "aws"/provider "aws"/' main.tf

echo -e "${GREEN}Setup complete!${NC}"
echo "You can now run terraform plan and terraform apply for your main configuration."
