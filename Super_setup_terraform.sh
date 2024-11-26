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
terraform init -backend-config=backend.hcl
terraform apply -auto-approve -var-file=backend.tfvars

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

# Set AWS account ID directly in the script
AWS_ACCOUNT_ID=590184104031

# Check if AWS account ID environment variable is set
if [ -z "$AWS_ACCOUNT_ID" ]; then
    echo -e "${RED}Error: AWS_ACCOUNT_ID environment variable is not set${NC}"
    exit 1
fi

# Get AWS region from AWS configuration if not explicitly set
if [ -z "$AWS_REGION" ]; then
    AWS_REGION=$(aws configure get region)
fi

# Generate unique identifiers for bucket names
TIMESTAMP=$(date +%Y%m%d)
RANDOM_STRING=$(openssl rand -hex 4)

# Define bucket names
RAW_DATA_BUCKET="raw-data-${AWS_ACCOUNT_ID}-${TIMESTAMP}-${RANDOM_STRING}"
PROCESSED_DATA_BUCKET="processed-data-${AWS_ACCOUNT_ID}-${TIMESTAMP}-${RANDOM_STRING}"
ANALYTICS_DATA_BUCKET="analytics-data-${AWS_ACCOUNT_ID}-${TIMESTAMP}-${RANDOM_STRING}"

# Update terraform.tfvars
sed -i "s/your-bucket-name/${RAW_DATA_BUCKET}/" terraform.tfvars
sed -i "s/processed-data-bucket/${PROCESSED_DATA_BUCKET}/" terraform.tfvars
sed -i "s/analytics-data-bucket/${ANALYTICS_DATA_BUCKET}/" terraform.tfvars

# Check if create_table.sql exists
if [ -f "../datalake2/sql/create_table.sql" ]; then
    # Update create_table.sql
    sed -i "s|s3://costasbackend778/|s3://${ANALYTICS_DATA_BUCKET}/|" ../datalake2/sql/create_table.sql
    sed -i "s|s3://costasbackend778/\${datehour}/|s3://${ANALYTICS_DATA_BUCKET}/\${datehour}/|" ../datalake2/sql/create_table.sql
    echo -e "${GREEN}Successfully updated create_table.sql with the new bucket names.${NC}"
else
    echo -e "${RED}Error: ../datalake2/sql/create_table.sql not found.${NC}"
fi

# Optionally update kinesis_stream_arn if it needs to be dynamic
sed -i "s|arn:aws:kinesis:us-east-1:123456789012:stream/data-stream|arn:aws:kinesis:${AWS_REGION}:${AWS_ACCOUNT_ID}:stream/data-stream|" terraform.tfvars

echo -e "${GREEN}Successfully updated terraform.tfvars with the following values:${NC}"
echo "Raw data bucket: ${RAW_DATA_BUCKET}"
echo "Processed data bucket: ${PROCESSED_DATA_BUCKET}"
echo "Analytics data bucket: ${ANALYTICS_DATA_BUCKET}"

echo -e "\n${GREEN}You can now run:${NC}"
echo "terraform plan"
echo "terraform apply"

echo -e "${GREEN}Setup complete!${NC}"
echo "You can now run terraform plan and terraform apply for your main configuration."