#!/bin/bash
# Script to reset RDS master password and generate new DATABASE_URL

set -e

AWS_REGION="${AWS_REGION:-us-east-1}"
RDS_INSTANCE="nonprofit-learning-db"
DB_USERNAME="postgres"
DB_NAME="nonprofit_learning"

echo "🔐 RDS Password Reset Tool"
echo ""

# Check AWS credentials
if ! aws sts get-caller-identity &>/dev/null; then
    echo "❌ AWS credentials not configured"
    exit 1
fi

echo "✅ AWS credentials verified"
echo ""

# Get RDS endpoint
echo "📊 Getting RDS information..."
ENDPOINT=$(aws rds describe-db-instances \
    --db-instance-identifier "$RDS_INSTANCE" \
    --region "$AWS_REGION" \
    --query 'DBInstances[0].Endpoint.Address' \
    --output text 2>/dev/null || echo "")

if [ -z "$ENDPOINT" ]; then
    echo "❌ Could not get RDS endpoint"
    exit 1
fi

echo "✅ RDS Endpoint: $ENDPOINT"
echo ""

# Generate a secure random password
NEW_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
# Ensure it has required characters for RDS
NEW_PASSWORD="${NEW_PASSWORD}A1!"

echo "🔑 Generated new password (25 characters, alphanumeric + special)"
echo ""

# Ask for confirmation
read -p "Do you want to reset the RDS master password? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "❌ Password reset cancelled"
    exit 0
fi

echo ""
echo "🔄 Resetting RDS master password..."
echo "   This will take 5-10 minutes..."

if aws rds modify-db-instance \
    --db-instance-identifier "$RDS_INSTANCE" \
    --master-user-password "$NEW_PASSWORD" \
    --apply-immediately \
    --region "$AWS_REGION" 2>&1; then
    echo "✅ Password reset initiated"
    echo ""
    echo "⏳ Waiting for modification to complete..."
    echo "   This may take 5-10 minutes"
    echo ""
    echo "   Check status with:"
    echo "   aws rds describe-db-instances --db-instance-identifier $RDS_INSTANCE --query 'DBInstances[0].DBInstanceStatus'"
else
    echo "❌ Failed to reset password"
    exit 1
fi

echo ""
echo "📋 New DATABASE_URL:"
echo ""
echo "postgresql://$DB_USERNAME:${NEW_PASSWORD}@$ENDPOINT:5432/$DB_NAME"
echo ""
echo "⚠️  IMPORTANT:"
echo "1. Save this password securely (it won't be shown again)"
echo "2. Update GitHub Secret DATABASE_URL with the connection string above"
echo "3. Wait for RDS modification to complete before testing connection"
echo ""
echo "🔗 Update GitHub Secret:"
echo "   Repository → Settings → Secrets and variables → Actions"
echo "   → Update DATABASE_URL"
echo ""
