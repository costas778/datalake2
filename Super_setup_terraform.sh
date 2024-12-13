#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Navigate to the script's directory (project root)
cd "$(dirname "$0")" || { echo -e "${RED}Failed to change directory to script location.${NC}"; exit 1; }

# Get AWS region from AWS configuration if not explicitly set
if [ -z "$AWS_REGION" ]; then
    AWS_REGION=$(aws configure get region)
    if [ -z "$AWS_REGION" ]; then
        echo -e "${RED}Error: AWS_REGION is not set and could not be determined from AWS configuration${NC}"
        exit 1
    fi
fi

# Check if AWS_ACCOUNT_ID environment variable is set
AWS_ACCOUNT_ID=961109809677 # Replace with your AWS account ID
if [ -z "$AWS_ACCOUNT_ID" ]; then
    echo -e "${RED}Error: AWS_ACCOUNT_ID environment variable is not set${NC}"
    exit 1
fi

# Detect IAM user and export as environment variable
echo "Detecting IAM user..."
IAM_USER=$(aws iam get-user --query 'User.UserName' --output text)
echo "IAM user detected: $IAM_USER"
export TF_VAR_iam_user=$IAM_USER

# Generate unique identifiers
TIMESTAMP=$(date +%Y%m%d)
RANDOM_STRING=$(openssl rand -hex 6)

# Define all resource names
TERRAFORM_STATE_BUCKET="terraform-state-${AWS_ACCOUNT_ID}-${TIMESTAMP}-${RANDOM_STRING}"
RAW_DATA_BUCKET="raw-data-${AWS_ACCOUNT_ID}-${TIMESTAMP}-${RANDOM_STRING}"
PROCESSED_DATA_BUCKET="processed-data-${AWS_ACCOUNT_ID}-${TIMESTAMP}-${RANDOM_STRING}"
ANALYTICS_DATA_BUCKET="analytics-data-${AWS_ACCOUNT_ID}-${TIMESTAMP}-${RANDOM_STRING}"
FIREHOSE_STREAM="datalake-ingest-${TIMESTAMP}-${RANDOM_STRING}"
KINESIS_STREAM="kinesis-stream-${AWS_ACCOUNT_ID}-${TIMESTAMP}-${RANDOM_STRING}"

# Update these lines in Super_setup_terraform.sh
echo "Updating SQL table definition with correct bucket location..."
sed -i.bak "s|s3://analytics-data-[0-9]*-[0-9]*-[a-z0-9]*|s3://${ANALYTICS_DATA_BUCKET}|g" sql/create_table.sql

# Add verification
if grep -q "${ANALYTICS_DATA_BUCKET}" sql/create_table.sql; then
    echo "SQL file successfully updated with new bucket name"
else
    echo "Error: Failed to update SQL file with new bucket name"
    exit 1
fi

# Debug output
echo "Verifying SQL file update..."
cat sql/create_table.sql

# Debug output
echo "DEBUG: RAW_DATA_BUCKET = ${RAW_DATA_BUCKET}"
echo "DEBUG: PROCESSED_DATA_BUCKET = ${PROCESSED_DATA_BUCKET}"
echo "DEBUG: ANALYTICS_DATA_BUCKET = ${ANALYTICS_DATA_BUCKET}"
echo "DEBUG: TERRAFORM_STATE_BUCKET = ${TERRAFORM_STATE_BUCKET}"

# Navigate to Lambda directory and create zip
cd lambda || { echo -e "${RED}Lambda directory not found.${NC}"; exit 1; }
zip -r transform.zip transform.py

# Verify transform.zip creation
if [ ! -f "transform.zip" ]; then
    echo -e "${RED}Error: Failed to create transform.zip${NC}"
    exit 1
fi

chmod 644 transform.zip
cd .. || { echo -e "${RED}Failed to return to project root.${NC}"; exit 1; }

# Clean up any existing Terraform state
rm -rf .terraform
rm -f .terraform.lock.hcl

# Temporarily remove backend configuration from main.tf
sed -i.bak '/backend "s3" {/,/}/d' main.tf

# Create and configure Terraform state bucket
BUCKET_NAME="${TERRAFORM_STATE_BUCKET}"
if aws s3api head-bucket --bucket "${BUCKET_NAME}" 2>/dev/null; then
    echo -e "${GREEN}State bucket exists, using existing bucket${NC}"
else
    echo -e "${GREEN}Creating new state bucket${NC}"
    if ! aws s3api create-bucket --bucket "${BUCKET_NAME}" --region "${AWS_REGION}" $(if [ "$AWS_REGION" != "us-east-1" ]; then echo "--create-bucket-configuration LocationConstraint=${AWS_REGION}"; fi); then
        echo -e "${RED}Failed to create state bucket${NC}"
        exit 1
    fi
fi

# Ensure versioning is enabled regardless of bucket existence
if ! aws s3api put-bucket-versioning --bucket "${BUCKET_NAME}" --versioning-configuration Status=Enabled; then
    echo -e "${RED}Failed to enable versioning on state bucket${NC}"
    exit 1
fi


# Check S3 buckets existence
for BUCKET in "${RAW_DATA_BUCKET}" "${PROCESSED_DATA_BUCKET}" "${ANALYTICS_DATA_BUCKET}"; do
    if aws s3 ls "s3://${BUCKET}" >/dev/null 2>&1; then
        echo -e "${GREEN}Bucket '${BUCKET}' already exists.${NC}"
    else
        echo -e "${GREEN}Bucket '${BUCKET}' does not exist. It will be created by Terraform.${NC}"
    fi
done

# Check QuickSight policy attachments
echo "Checking QuickSight policy attachments..."
if aws iam get-policy --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/QuickSightManagementPolicy &>/dev/null; then
    echo "Found existing QuickSightManagementPolicy. Checking attachments..."
    ATTACHED_USERS=$(aws iam list-entities-for-policy --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/QuickSightManagementPolicy --query 'PolicyUsers[*].UserName' --output text)
    
    if [ ! -z "$ATTACHED_USERS" ]; then
        echo "Detaching policy from users..."
        for user in $ATTACHED_USERS; do
            echo "Detaching from user: $user"
            if ! aws iam detach-user-policy --user-name "$user" --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/QuickSightManagementPolicy; then
                echo -e "${RED}Failed to detach policy from user: $user${NC}"
                exit 1
            fi
        done
    fi
fi

# Create backend.hcl
cat > backend.hcl <<EOF
bucket         = "${TERRAFORM_STATE_BUCKET}"
key            = "environment_serverless1/dev/terraform.tfstate"
region         = "${AWS_REGION}"
dynamodb_table = "terraform-locks"
encrypt        = true
EOF

# Create or update terraform.tfvars
cat > terraform.tfvars <<EOF
# General Settings
environment  = "dev"
project_name = "datalake"

# Storage Module Variables
storage_bucket_prefix = "data-lake"
raw_data_bucket_name = "${RAW_DATA_BUCKET}"
processed_data_bucket_name = "${PROCESSED_DATA_BUCKET}"
analytics_bucket_name = "${ANALYTICS_DATA_BUCKET}"

# API Gateway Module Variables
api_name = "datalake-api"
api_description = "API for data ingestion"
api_stage_name = "dev"

# Kinesis Module Variables
kinesis_retention_period = 24
kinesis_shard_count = 1

# Lambda Module Variables
lambda_runtime = "python3.8"
lambda_memory_size = 128
lambda_timeout = 30
lambda_handler = "transform.lambda_handler"
lambda_filename = "lambda/transform.zip"

# Athena Module Variables
athena_database_name = "datalake_db"
athena_output_location = "s3://athena-query-results/"
athena_workgroup_name = "datalake_workgroup-7e6ab79a"
create_table_sql_path = "sql/create_table.sql"

# QuickSight Configuration
quicksight_namespace = "default"
quicksight_user_role = "AUTHOR"
quicksight_identity_type = "IAM"
quicksight_user = "arn:aws:iam::${AWS_ACCOUNT_ID}:user/${IAM_USER}"
quicksight_user_email = "costas778@gmail.com"

# QuickSight Policy
quicksight_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "quicksight:RegisterUser",
        "quicksight:DescribeNamespace",
        "quicksight:ListUsers",
        "quicksight:UpdateUser",
        "quicksight:DeleteUser"
      ],
      "Resource": "*"
    }
  ]
}
POLICY

# Tags
tags = {
  Environment = "dev"
  Project     = "datalake"
}

# S3 Bucket ARNs
raw_bucket_arn = "arn:aws:s3:::${RAW_DATA_BUCKET}"
processed_bucket_arn = "arn:aws:s3:::${PROCESSED_DATA_BUCKET}"

# Firehose Configuration
firehose_stream_name = "${FIREHOSE_STREAM}"
firehose_stream_arn = "arn:aws:firehose:${AWS_REGION}:${AWS_ACCOUNT_ID}:deliverystream/${FIREHOSE_STREAM}"

# Kinesis Configuration
kinesis_stream_name = "${KINESIS_STREAM}"
kinesis_stream_arn = "arn:aws:kinesis:${AWS_REGION}:${AWS_ACCOUNT_ID}:stream/${KINESIS_STREAM}"
EOF

# Clean up backup files
rm -f terraform.tfvars.bak
rm -f main.tf.bak

echo -e "${GREEN}Setup complete. You can now run terraform init and terraform apply.${NC}"
