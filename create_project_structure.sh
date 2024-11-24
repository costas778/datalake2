
#!/bin/bash

# Set color codes for output
GREEN='\033[0;32m'
NC='\033[0m'

echo "Starting project structure creation..."

# Create main directory
mkdir -p environment_serverless1
cd environment_serverless1

# Create root level files
echo "Creating root level files..."
touch main.tf variables.tf outputs.tf

# Create lambda directory and file
echo "Creating lambda directory and files..."
mkdir -p lambda
touch lambda/transform.py

# Create SQL directory and file
echo "Creating SQL directory and files..."
mkdir -p sql
touch sql/create_table.sql

# Create tests directory and file
echo "Creating tests directory and files..."
mkdir -p tests
touch tests/api_payloads.json

# Create modules directory
echo "Creating modules and their files..."
mkdir -p modules

# List of modules to create
modules=("api_gateway" "kinesis" "lambda" "storage" "athena" "quicksight")

# Create module directories and their files
for module in "${modules[@]}"; do
    echo "Creating module: $module"
    mkdir -p "modules/$module"
    touch "modules/$module/main.tf"
    touch "modules/$module/variables.tf"
    touch "modules/$module/outputs.tf"
done

# Initialize git repository
echo "Initializing git repository..."
git init

# Create .gitignore
echo "Creating .gitignore..."
cat > .gitignore << EOL
# Local .terraform directories
**/.terraform/*

# .tfstate files
*.tfstate
*.tfstate.*

# Crash log files
crash.log
crash.*.log

# Exclude all .tfvars files
*.tfvars
*.tfvars.json

# Ignore override files
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Ignore CLI configuration files
.terraformrc
terraform.rc

# Ignore backend configuration
backend.hcl
EOL

# Display the created structure
echo -e "${GREEN}Project structure created successfully!${NC}"
echo "Directory structure:"
if command -v tree &> /dev/null; then
    tree
else
    find . -type d -o -type f | sort | sed 's/[^/]*\//  /g'
fi

echo -e "\n${GREEN}You can now proceed to add your Terraform configurations to these files.${NC}"

# Give permisssions to the bash script.