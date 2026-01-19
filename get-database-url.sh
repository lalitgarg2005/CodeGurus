#!/bin/bash
# Script to generate DATABASE_URL from RDS information

set -e

AWS_REGION="${AWS_REGION:-us-east-1}"
RDS_INSTANCE="nonprofit-learning-db"

echo "📊 Getting RDS Information for DATABASE_URL..."
echo ""

# Check AWS credentials
if ! aws sts get-caller-identity &>/dev/null; then
    echo "❌ AWS credentials not configured"
    exit 1
fi

# Get RDS information
ENDPOINT=$(aws rds describe-db-instances \
    --db-instance-identifier "$RDS_INSTANCE" \
    --region "$AWS_REGION" \
    --query 'DBInstances[0].Endpoint.Address' \
    --output text 2>/dev/null || echo "")

USERNAME=$(aws rds describe-db-instances \
    --db-instance-identifier "$RDS_INSTANCE" \
    --region "$AWS_REGION" \
    --query 'DBInstances[0].MasterUsername' \
    --output text 2>/dev/null || echo "postgres")

if [ -z "$ENDPOINT" ]; then
    echo "❌ Could not get RDS endpoint"
    exit 1
fi

echo "✅ RDS Information:"
echo "   Endpoint: $ENDPOINT"
echo "   Username: $USERNAME"
echo "   Database: nonprofit_learning"
echo "   Port: 5432"
echo ""

# Ask for password
read -sp "Enter RDS password (input hidden): " PASSWORD
echo ""
echo ""

if [ -z "$PASSWORD" ]; then
    echo "❌ Password cannot be empty"
    exit 1
fi

# URL encode password (handle common special characters)
ENCODED_PASSWORD=$(echo -n "$PASSWORD" | python3 -c "import sys, urllib.parse; print(urllib.parse.quote(sys.stdin.read(), safe=''))" 2>/dev/null || echo "$PASSWORD")

# Build DATABASE_URL
DATABASE_URL="postgresql://$USERNAME:${ENCODED_PASSWORD}@$ENDPOINT:5432/nonprofit_learning"

echo "📋 DATABASE_URL:"
echo ""
echo "$DATABASE_URL"
echo ""
echo "📋 Next Steps:"
echo "1. Copy the DATABASE_URL above"
echo "2. Go to GitHub → Repository → Settings → Secrets and variables → Actions"
echo "3. Update or create DATABASE_URL secret with the value above"
echo "4. Re-run your workflow"
echo ""
