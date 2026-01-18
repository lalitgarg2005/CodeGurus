#!/bin/bash
# Script to check if IAM user has required permissions for Terraform deployment

set -e

echo "🔍 Checking AWS IAM Permissions for Terraform Deployment"
echo ""

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &>/dev/null; then
    echo "❌ AWS credentials not configured"
    echo "Please run: aws configure"
    exit 1
fi

echo "✅ AWS credentials configured"
IDENTITY=$(aws sts get-caller-identity)
echo "   User: $(echo $IDENTITY | jq -r '.Arn')"
echo ""

# Track permission checks
PASSED=0
FAILED=0

check_permission() {
    local service=$1
    local action=$2
    local description=$3
    
    echo -n "Checking $description... "
    
    if aws $service $action &>/dev/null; then
        echo "✅"
        ((PASSED++))
        return 0
    else
        echo "❌"
        ((FAILED++))
        return 1
    fi
}

echo "Testing required permissions:"
echo ""

# EC2 Permissions
check_permission "ec2" "describe-vpcs --max-items 1" "EC2: Describe VPCs"
check_permission "ec2" "describe-subnets --max-items 1" "EC2: Describe Subnets"
check_permission "ec2" "describe-security-groups --max-items 1" "EC2: Describe Security Groups"

# Test CreateSecurityGroup (this will fail if no permission, but we catch it)
echo -n "Checking EC2: Create Security Group... "
if aws ec2 create-security-group \
    --group-name "test-permission-check-$(date +%s)" \
    --description "Test permission check" \
    --vpc-id $(aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query 'Vpcs[0].VpcId' --output text) \
    &>/dev/null 2>&1; then
    echo "✅"
    # Clean up test security group
    SG_ID=$(aws ec2 describe-security-groups \
        --filters "Name=group-name,Values=test-permission-check-*" \
        --query 'SecurityGroups[0].GroupId' --output text 2>/dev/null || echo "")
    if [ ! -z "$SG_ID" ]; then
        aws ec2 delete-security-group --group-id "$SG_ID" &>/dev/null 2>&1 || true
    fi
    ((PASSED++))
else
    echo "❌ (This is the permission you're missing!)"
    ((FAILED++))
fi

# RDS Permissions
check_permission "rds" "describe-db-instances --max-items 1" "RDS: Describe DB Instances"
check_permission "rds" "describe-db-subnet-groups --max-items 1" "RDS: Describe DB Subnet Groups"

# ECR Permissions
check_permission "ecr" "describe-repositories --max-items 1" "ECR: Describe Repositories"

# S3 Permissions
check_permission "s3" "list-buckets" "S3: List Buckets"

# CloudFront Permissions
check_permission "cloudfront" "list-distributions --max-items 1" "CloudFront: List Distributions"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Results: $PASSED passed, $FAILED failed"
echo ""

if [ $FAILED -eq 0 ]; then
    echo "✅ All permissions are configured correctly!"
    echo "You can proceed with Terraform deployment."
    exit 0
else
    echo "❌ Some permissions are missing!"
    echo ""
    echo "To fix this:"
    echo "1. See IAM_PERMISSIONS.md for detailed instructions"
    echo "2. Attach the TerraformDeploymentPolicy to your IAM user"
    echo "3. Wait a few minutes for permissions to propagate"
    echo "4. Run this script again to verify"
    echo ""
    echo "Quick fix via AWS Console:"
    echo "  https://console.aws.amazon.com/iam/home#/users/$(echo $IDENTITY | jq -r '.Arn' | cut -d'/' -f2)"
    exit 1
fi
