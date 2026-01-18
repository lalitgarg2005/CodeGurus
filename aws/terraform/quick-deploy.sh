#!/bin/bash
# Quick deployment helper

echo "🔍 Checking prerequisites..."

# Check AWS CLI
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI not found. Install with: brew install awscli"
    exit 1
fi

# Check Terraform
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform not found. Install with: brew install terraform"
    exit 1
fi

# Check AWS credentials
if ! aws sts get-caller-identity &>/dev/null; then
    echo "❌ AWS credentials not configured"
    echo "Run: aws configure"
    exit 1
fi

echo "✅ Prerequisites check passed!"
echo ""

# Check terraform.tfvars
if [ ! -f "terraform.tfvars" ]; then
    echo "📝 Creating terraform.tfvars..."
    cp terraform.tfvars.example terraform.tfvars
    echo ""
    echo "⚠️  IMPORTANT: Edit terraform.tfvars and set:"
    echo "   - db_username (e.g., 'postgres')"
    echo "   - db_password (use a secure password!)"
    echo ""
    read -p "Press Enter after editing terraform.tfvars, or Ctrl+C to cancel..."
fi

# Initialize and deploy
echo "🚀 Starting deployment..."
terraform init
terraform validate
terraform plan
echo ""
read -p "Apply these changes? (yes/no): " confirm
if [ "$confirm" = "yes" ]; then
    terraform apply
    echo ""
    echo "✅ Deployment complete!"
    echo ""
    echo "📋 Next steps:"
    echo "1. Copy the RDS endpoint from outputs above"
    echo "2. Update GitHub Secret: DATABASE_URL"
    echo "3. Trigger GitHub Actions deployment"
else
    echo "Deployment cancelled."
fi
