#!/bin/bash
# Deployment script for AWS infrastructure using Terraform

set -e

echo "🚀 Starting AWS Infrastructure Deployment"
echo ""

# Check if AWS credentials are configured
if ! aws sts get-caller-identity &>/dev/null; then
    echo "❌ AWS credentials not configured or expired"
    echo "Please run: aws configure"
    exit 1
fi

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    echo "📝 Creating terraform.tfvars from example..."
    cp terraform.tfvars.example terraform.tfvars
    echo ""
    echo "⚠️  Please edit terraform.tfvars with your values:"
    echo "   - db_username"
    echo "   - db_password (use a secure password!)"
    echo "   - aws_region (if different from us-east-1)"
    echo ""
    read -p "Press Enter after editing terraform.tfvars..."
fi

# Initialize Terraform
echo "🔧 Initializing Terraform..."
terraform init

# Validate configuration
echo "✅ Validating Terraform configuration..."
terraform validate

# Plan deployment
echo "📋 Planning deployment..."
terraform plan -out=tfplan

# Ask for confirmation
echo ""
read -p "Do you want to apply these changes? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "Deployment cancelled."
    exit 0
fi

# Apply changes
echo "🚀 Applying Terraform configuration..."
terraform apply tfplan

# Show outputs
echo ""
echo "✅ Deployment complete! Outputs:"
terraform output

# Save outputs to file
terraform output -json > outputs.json
echo ""
echo "📄 Outputs saved to outputs.json"
