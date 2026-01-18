#!/bin/bash
# Script to create IAM role for App Runner to access ECR

set -e

AWS_REGION="${AWS_REGION:-us-east-1}"
ROLE_NAME="AppRunnerECRAccessRole"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo "🔧 Creating IAM Role for App Runner ECR Access..."
echo ""

# Check if role already exists
if aws iam get-role --role-name "$ROLE_NAME" &>/dev/null; then
    echo "✅ Role $ROLE_NAME already exists"
    ROLE_ARN=$(aws iam get-role --role-name "$ROLE_NAME" --query 'Role.Arn' --output text)
    echo "   ARN: $ROLE_ARN"
else
    echo "Creating IAM role: $ROLE_NAME"
    
    # Create trust policy for App Runner
    cat > /tmp/apprunner-trust-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "build.apprunner.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

    # Create role
    aws iam create-role \
        --role-name "$ROLE_NAME" \
        --assume-role-policy-document file:///tmp/apprunner-trust-policy.json \
        --description "Allows App Runner to access ECR repositories" \
        --output text > /dev/null

    echo "✅ Role created"
    
    # Attach ECR read policy
    echo "Attaching ECR read permissions..."
    aws iam attach-role-policy \
        --role-name "$ROLE_NAME" \
        --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly
    
    echo "✅ ECR read permissions attached"
    
    # Get role ARN
    ROLE_ARN=$(aws iam get-role --role-name "$ROLE_NAME" --query 'Role.Arn' --output text)
    echo ""
    echo "✅ Role ARN: $ROLE_ARN"
fi

echo ""
echo "📋 Next Steps:"
echo "1. Use this role ARN in App Runner service creation:"
echo "   $ROLE_ARN"
echo ""
echo "2. Or add to GitHub Secret: APP_RUNNER_ACCESS_ROLE_ARN"
echo "   Value: $ROLE_ARN"
echo ""
echo "3. Update the workflow to use this role in authentication configuration"
