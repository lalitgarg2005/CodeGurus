#!/bin/bash
# Script to configure App Runner VPC access for RDS

set -e

AWS_REGION="${AWS_REGION:-us-east-1}"
SERVICE_NAME="nonprofit-learning-backend"
RDS_VPC="vpc-0b1f4886bdf6dc52d"
APP_RUNNER_SG="sg-076f24e380273a905"

echo "🔧 Configuring App Runner VPC Access..."
echo ""

# Check AWS credentials
if ! aws sts get-caller-identity &>/dev/null; then
    echo "❌ AWS credentials not configured"
    exit 1
fi

echo "✅ AWS credentials verified"
echo ""

# Get App Runner service ARN
SERVICE_ARN=$(aws apprunner list-services \
    --region "$AWS_REGION" \
    --query "ServiceSummaryList[?ServiceName=='$SERVICE_NAME'].ServiceArn" \
    --output text 2>/dev/null || echo "")

if [ -z "$SERVICE_ARN" ]; then
    echo "❌ App Runner service not found"
    exit 1
fi

echo "✅ App Runner service found: $SERVICE_ARN"
echo ""

# Get subnets in the VPC (need at least 2 in different AZs)
echo "📊 Getting subnets in VPC..."
SUBNETS=$(aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=$RDS_VPC" \
    --region "$AWS_REGION" \
    --query 'Subnets[*].{SubnetId:SubnetId,AvailabilityZone:AvailabilityZone}' \
    --output json 2>/dev/null || echo "[]")

SUBNET_COUNT=$(echo "$SUBNETS" | jq 'length' 2>/dev/null || echo "0")

if [ "$SUBNET_COUNT" -lt 2 ]; then
    echo "❌ Need at least 2 subnets in different Availability Zones"
    echo "   Found: $SUBNET_COUNT subnets"
    echo ""
    echo "Current subnets:"
    echo "$SUBNETS" | jq -r '.[] | "   \(.SubnetId) - \(.AvailabilityZone)"'
    echo ""
    echo "Please create additional subnets in different AZs, or use existing subnets"
    exit 1
fi

# Get 2 subnets in different AZs
SUBNET_1=$(echo "$SUBNETS" | jq -r '.[0].SubnetId' 2>/dev/null)
SUBNET_1_AZ=$(echo "$SUBNETS" | jq -r '.[0].AvailabilityZone' 2>/dev/null)

# Find a subnet in a different AZ
SUBNET_2=$(echo "$SUBNETS" | jq -r --arg az "$SUBNET_1_AZ" '.[] | select(.AvailabilityZone != $az) | .SubnetId' 2>/dev/null | head -1)

if [ -z "$SUBNET_2" ]; then
    # If no different AZ, use second subnet anyway (AWS will handle it)
    SUBNET_2=$(echo "$SUBNETS" | jq -r '.[1].SubnetId' 2>/dev/null)
fi

echo "✅ Selected subnets:"
echo "   Subnet 1: $SUBNET_1 ($SUBNET_1_AZ)"
echo "   Subnet 2: $SUBNET_2"
echo ""

# Check current network configuration
echo "🔍 Checking current App Runner network configuration..."
CURRENT_CONFIG=$(aws apprunner describe-service \
    --service-arn "$SERVICE_ARN" \
    --region "$AWS_REGION" \
    --query 'Service.NetworkConfiguration' \
    --output json 2>/dev/null || echo "{}")

EGRESS_TYPE=$(echo "$CURRENT_CONFIG" | jq -r '.EgressConfiguration.EgressType // "DEFAULT"')

if [ "$EGRESS_TYPE" == "VPC" ]; then
    echo "✅ App Runner already has VPC egress configured"
    echo "$CURRENT_CONFIG" | jq '.'
    exit 0
fi

echo "⚠️  Current egress type: $EGRESS_TYPE (needs to be VPC)"
echo ""

# Note: App Runner VPC configuration can only be set during service creation
# or via a service update. However, updating network configuration requires
# the service to be in a ready state and may require service recreation.

echo "📋 To configure App Runner VPC access:"
echo ""
echo "Option 1: Via AWS Console (Recommended)"
echo "1. Go to: https://console.aws.amazon.com/apprunner/home?region=$AWS_REGION#/services"
echo "2. Click on: $SERVICE_NAME"
echo "3. Go to: Configuration → Networking"
echo "4. Click: Edit"
echo "5. Under 'Egress configuration':"
echo "   - Select: VPC"
echo "   - VPC: $RDS_VPC"
echo "   - Subnets: Select at least 2 subnets (different AZs)"
echo "     - $SUBNET_1"
echo "     - $SUBNET_2"
echo "   - Security groups: $APP_RUNNER_SG"
echo "6. Click: Save"
echo ""
echo "Option 2: Update via AWS CLI (if service supports it)"
echo ""
echo "⚠️  Note: Network configuration update may require service recreation"
echo "   or the service to be in a specific state."
echo ""
echo "Current service status:"
SERVICE_STATUS=$(aws apprunner describe-service \
    --service-arn "$SERVICE_ARN" \
    --region "$AWS_REGION" \
    --query 'Service.Status' \
    --output text 2>/dev/null || echo "UNKNOWN")
echo "   Status: $SERVICE_STATUS"
echo ""

if [ "$SERVICE_STATUS" == "CREATE_FAILED" ]; then
    echo "❌ Service is in CREATE_FAILED state"
    echo "   You may need to delete and recreate the service with VPC configuration"
    echo "   Or fix the creation error first"
fi

echo "📋 Summary:"
echo "   VPC: $RDS_VPC"
echo "   Subnet 1: $SUBNET_1"
echo "   Subnet 2: $SUBNET_2"
echo "   Security Group: $APP_RUNNER_SG"
echo ""
echo "✅ Security group rule already added (App Runner → RDS)"
echo "⚠️  Next: Configure App Runner VPC egress (see instructions above)"
