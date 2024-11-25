#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Print the current working directory
echo "Current working directory: $(pwd)"

# Change to the script's directory
cd "$(dirname "$0")"

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

# Update backend.tfvars
sed -i "s|bucket = \"\"|bucket = \"${STATE_BUCKET}\"|" backend.tfvars
sed -i "s|key    = \"\"|key    = \"${STATE_KEY}\"|" backend.tfvars


# Update terraform.tfvars
sed -i "s/your-bucket-name/raw-data-${AWS_ACCOUNT_ID}-${TIMESTAMP}-${RANDOM_STRING}/" terraform.tfvars
sed -i "s/processed-data-bucket/processed-data-${AWS_ACCOUNT_ID}-${TIMESTAMP}-${RANDOM_STRING}/" terraform.tfvars
sed -i "s/analytics-data-bucket/analytics-data-${AWS_ACCOUNT_ID}-${TIMESTAMP}-${RANDOM_STRING}/" terraform.tfvars

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
echo "Raw data bucket: raw-data-${AWS_ACCOUNT_ID}-${TIMESTAMP}-${RANDOM_STRING}"
echo "Processed data bucket: processed-data-${AWS_ACCOUNT_ID}-${TIMESTAMP}-${RANDOM_STRING}"
echo "Analytics data bucket: analytics-data-${AWS_ACCOUNT_ID}-${TIMESTAMP}-${RANDOM_STRING}"

echo -e "\n${GREEN}You can now run:${NC}"
echo "terraform plan"
echo "terraform apply"