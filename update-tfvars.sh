
#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

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

# Update terraform.tfvars
sed -i "s/XXXXXXXX/raw-data-${AWS_ACCOUNT_ID}-${TIMESTAMP}-${RANDOM_STRING}/" terraform.tfvars
sed -i "s/XXXXXXXXXXXXXX/processed-data-${AWS_ACCOUNT_ID}-${TIMESTAMP}-${RANDOM_STRING}/" terraform.tfvars
sed -i "s/XXXXXXXXX/analytics-data-${AWS_ACCOUNT_ID}-${TIMESTAMP}-${RANDOM_STRING}/" terraform.tfvars

echo -e "${GREEN}Successfully updated terraform.tfvars with the following values:${NC}"
echo "Raw data bucket: raw-data-${AWS_ACCOUNT_ID}-${TIMESTAMP}-${RANDOM_STRING}"
echo "Processed data bucket: processed-data-${AWS_ACCOUNT_ID}-${TIMESTAMP}-${RANDOM_STRING}"
echo "Analytics data bucket: analytics-data-${AWS_ACCOUNT_ID}-${TIMESTAMP}-${RANDOM_STRING}"

echo -e "\n${GREEN}You can now run:${NC}"
echo "terraform plan"
echo "terraform apply"
