#!/bin/bash
# Setup and deployment script

set -e

echo "🚀 Nonprofit Learning Platform - AWS Deployment"
echo ""

# Check AWS credentials
echo "🔍 Checking AWS credentials..."
if ! aws sts get-caller-identity &>/dev/null; then
    echo "❌ AWS credentials not configured or invalid"
    echo ""
    echo "Please configure AWS credentials:"
    echo "  Option 1: aws configure"
    echo "  Option 2: Set environment variables:"
    echo "    export AWS_ACCESS_KEY_ID='your-key'"
    echo "    export AWS_SECRET_ACCESS_KEY='your-secret'"
    echo "    export AWS_DEFAULT_REGION='us-east-1'"
    echo ""
    read -p "Press Enter after configuring AWS credentials, or Ctrl+C to cancel..."
    
    # Check again
    if ! aws sts get-caller-identity &>/dev/null; then
        echo "❌ AWS credentials still not valid. Exiting."
        exit 1
    fi
fi

echo "✅ AWS credentials configured"
aws sts get-caller-identity
echo ""

# Check terraform.tfvars
if [ ! -f "terraform.tfvars" ]; then
    echo "📝 Creating terraform.tfvars..."
    cp terraform.tfvars.example terraform.tfvars
fi

# Check if password needs to be updated
if grep -q "CHANGE_ME_TO_SECURE_PASSWORD" terraform.tfvars; then
    echo "⚠️  Database password needs to be set in terraform.tfvars"
    echo ""
    echo "Please edit terraform.tfvars and set a secure db_password"
    echo "Then run this script again."
    exit 1
fi

echo "✅ terraform.tfvars configured"
echo ""

# Initialize Terraform if needed
if [ ! -d ".terraform" ]; then
    echo "🔧 Initializing Terraform..."
    terraform init
fi

# Validate
echo "✅ Validating configuration..."
terraform validate

# Plan
echo ""
echo "📋 Planning deployment..."
terraform plan -out=tfplan

# Confirm
echo ""
read -p "Do you want to apply these changes? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "Deployment cancelled."
    exit 0
fi

# Apply
echo ""
echo "🚀 Applying Terraform configuration..."
terraform apply tfplan

# Show outputs
echo ""
echo "✅ Deployment complete!"
echo ""
echo "📋 Important outputs:"
terraform output

# Save outputs
terraform output -json > outputs.json 2>/dev/null || terraform output > outputs.txt
echo ""
echo "📄 Outputs saved to outputs.json (or outputs.txt)"
echo ""
echo "🔔 Next steps:"
echo "1. Copy the RDS endpoint from outputs above"
echo "2. Update GitHub Secret: DATABASE_URL"
echo "   Format: postgresql://username:password@rds-endpoint:5432/nonprofit_learning"
echo "3. Trigger GitHub Actions deployment or run: git push"
