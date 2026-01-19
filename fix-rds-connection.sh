#!/bin/bash
# Script to fix RDS connection from App Runner

set -e

AWS_REGION="${AWS_REGION:-us-east-1}"
RDS_INSTANCE="nonprofit-learning-db"
RDS_SG="sg-09390ba267d614433"

echo "🔧 Fixing RDS Connection for App Runner..."
echo ""

# Check AWS credentials
if ! aws sts get-caller-identity &>/dev/null; then
    echo "❌ AWS credentials not configured"
    exit 1
fi

echo "✅ AWS credentials verified"
echo ""

# Get RDS VPC
echo "📊 Getting RDS information..."
RDS_VPC=$(aws rds describe-db-instances \
    --db-instance-identifier "$RDS_INSTANCE" \
    --region "$AWS_REGION" \
    --query 'DBInstances[0].DBSubnetGroup.VpcId' \
    --output text 2>/dev/null || echo "")

if [ -z "$RDS_VPC" ]; then
    echo "❌ Could not get RDS VPC information"
    exit 1
fi

echo "✅ RDS VPC: $RDS_VPC"
echo ""

# Check current security group rules
echo "🔍 Checking RDS security group rules..."
CURRENT_RULES=$(aws ec2 describe-security-groups \
    --group-ids "$RDS_SG" \
    --region "$AWS_REGION" \
    --query 'SecurityGroups[0].IpPermissions[?FromPort==`5432`]' \
    --output json 2>/dev/null || echo "[]")

echo "Current PostgreSQL (5432) rules:"
echo "$CURRENT_RULES" | jq -r '.[] | "   From: \(.IpRanges[0].CidrIp // "N/A"), Port: \(.FromPort)"' 2>/dev/null || echo "   No rules found"
echo ""

# Check if App Runner security group exists
echo "🔍 Checking for App Runner security group..."
APP_RUNNER_SG=$(aws ec2 describe-security-groups \
    --filters "Name=group-name,Values=nonprofit-learning-apprunner-sg" "Name=vpc-id,Values=$RDS_VPC" \
    --region "$AWS_REGION" \
    --query 'SecurityGroups[0].GroupId' \
    --output text 2>/dev/null || echo "")

if [ -z "$APP_RUNNER_SG" ] || [ "$APP_RUNNER_SG" == "None" ]; then
    echo "⚠️  App Runner security group not found"
    echo "   Creating App Runner security group..."
    
    APP_RUNNER_SG=$(aws ec2 create-security-group \
        --group-name nonprofit-learning-apprunner-sg \
        --description "Security group for App Runner to access RDS" \
        --vpc-id "$RDS_VPC" \
        --region "$AWS_REGION" \
        --query 'GroupId' \
        --output text 2>/dev/null || echo "")
    
    if [ -n "$APP_RUNNER_SG" ]; then
        echo "✅ Created App Runner security group: $APP_RUNNER_SG"
    else
        echo "❌ Failed to create security group"
        exit 1
    fi
else
    echo "✅ App Runner security group exists: $APP_RUNNER_SG"
fi
echo ""

# Check if rule already exists
echo "🔍 Checking if App Runner can access RDS..."
RULE_EXISTS=$(aws ec2 describe-security-groups \
    --group-ids "$RDS_SG" \
    --region "$AWS_REGION" \
    --query "SecurityGroups[0].IpPermissions[?FromPort==\`5432\` && length(UserIdGroupPairs[?GroupId==\`$APP_RUNNER_SG\`]) > \`0\`]" \
    --output text 2>/dev/null || echo "")

if [ -n "$RULE_EXISTS" ] && [ "$RULE_EXISTS" != "None" ]; then
    echo "✅ App Runner security group already has access to RDS"
else
    echo "➕ Adding rule to allow App Runner access to RDS..."
    
    if aws ec2 authorize-security-group-ingress \
        --group-id "$RDS_SG" \
        --protocol tcp \
        --port 5432 \
        --source-group "$APP_RUNNER_SG" \
        --region "$AWS_REGION" 2>/dev/null; then
        echo "✅ Added rule: App Runner SG ($APP_RUNNER_SG) → RDS (port 5432)"
    else
        echo "⚠️  Failed to add rule (may already exist or permission denied)"
    fi
fi
echo ""

# Get App Runner service info
echo "📦 Checking App Runner service..."
SERVICE_ARN=$(aws apprunner list-services \
    --region "$AWS_REGION" \
    --query "ServiceSummaryList[?ServiceName=='nonprofit-learning-backend'].ServiceArn" \
    --output text 2>/dev/null || echo "")

if [ -n "$SERVICE_ARN" ]; then
    echo "✅ App Runner service found"
    
    # Check VPC configuration
    VPC_CONFIG=$(aws apprunner describe-service \
        --service-arn "$SERVICE_ARN" \
        --region "$AWS_REGION" \
        --query 'Service.NetworkConfiguration' \
        --output json 2>/dev/null || echo "{}")
    
    if [ "$VPC_CONFIG" != "{}" ] && [ "$VPC_CONFIG" != "null" ]; then
        echo "✅ App Runner has VPC configuration"
        echo "$VPC_CONFIG" | jq '.'
    else
        echo "⚠️  App Runner does NOT have VPC configuration"
        echo ""
        echo "❌ IMPORTANT: App Runner needs VPC configuration to access RDS"
        echo ""
        echo "To fix this, you need to:"
        echo "1. Get subnet IDs from your VPC (need at least 2 in different AZs)"
        echo "2. Update App Runner service with VPC configuration"
        echo ""
        echo "Get subnets:"
        echo "  aws ec2 describe-subnets --filters \"Name=vpc-id,Values=$RDS_VPC\" --query 'Subnets[*].{SubnetId:SubnetId,AvailabilityZone:AvailabilityZone}' --output table"
        echo ""
        echo "Then update App Runner service via AWS Console:"
        echo "  https://console.aws.amazon.com/apprunner/home?region=$AWS_REGION#/services"
        echo "  → Click on nonprofit-learning-backend"
        echo "  → Configuration → Networking → Edit"
        echo "  → Enable VPC connector"
        echo "  → Select VPC: $RDS_VPC"
        echo "  → Select subnets (at least 2)"
        echo "  → Select security group: $APP_RUNNER_SG"
        echo "  → Save"
    fi
else
    echo "⚠️  App Runner service not found"
fi

echo ""
echo "📋 Summary:"
echo "   RDS Security Group: $RDS_SG"
echo "   App Runner Security Group: $APP_RUNNER_SG"
echo "   VPC: $RDS_VPC"
echo ""
echo "✅ Security group rule added (if needed)"
echo ""
echo "⚠️  Next Step: Configure App Runner VPC Access"
echo "   See FIX_RDS_CONNECTION.md for detailed instructions"
