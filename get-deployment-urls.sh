#!/bin/bash
# Script to get deployment URLs from AWS

set -e

AWS_REGION="${AWS_REGION:-us-east-1}"

echo "🔍 Finding your deployment URLs..."
echo ""

# Check AWS credentials
if ! aws sts get-caller-identity &>/dev/null; then
    echo "❌ AWS credentials not configured"
    echo "Run: aws configure"
    exit 1
fi

echo "✅ AWS credentials verified"
echo ""

# Get App Runner Service URL
echo "📦 Backend (App Runner):"
APP_RUNNER_URL=$(aws apprunner list-services \
    --region $AWS_REGION \
    --query "ServiceSummaryList[?ServiceName=='nonprofit-learning-backend'].ServiceUrl" \
    --output text 2>/dev/null || echo "")

if [ -n "$APP_RUNNER_URL" ]; then
    echo "   Service URL: $APP_RUNNER_URL"
    echo "   Health check: $APP_RUNNER_URL/health"
    echo "   API docs: $APP_RUNNER_URL/api/v1/docs"
else
    echo "   ⚠️  App Runner service not found"
fi
echo ""

# Get CloudFront Distribution
echo "🌐 Frontend (CloudFront):"
CLOUDFRONT_DOMAIN=$(aws cloudfront list-distributions \
    --query "DistributionList.Items[?Comment=='Nonprofit Learning Frontend' || contains(Origins.Items[0].DomainName, 'nonprofit-learning-frontend')].DomainName" \
    --output text 2>/dev/null | head -1 || echo "")

if [ -n "$CLOUDFRONT_DOMAIN" ]; then
    echo "   Domain: https://$CLOUDFRONT_DOMAIN"
else
    echo "   ⚠️  CloudFront distribution not found"
    echo "   S3 website: http://nonprofit-learning-frontend.s3-website-$AWS_REGION.amazonaws.com"
fi
echo ""

# Get ECR Repository
echo "🐳 Container Registry (ECR):"
ECR_REPO=$(aws ecr describe-repositories \
    --repository-names nonprofit-learning-backend \
    --region $AWS_REGION \
    --query "repositories[0].repositoryUri" \
    --output text 2>/dev/null || echo "")

if [ -n "$ECR_REPO" ]; then
    echo "   Repository URI: $ECR_REPO"
    IMAGE_COUNT=$(aws ecr list-images \
        --repository-name nonprofit-learning-backend \
        --region $AWS_REGION \
        --query "length(imageIds)" \
        --output text 2>/dev/null || echo "0")
    echo "   Images: $IMAGE_COUNT"
else
    echo "   ⚠️  ECR repository not found"
fi
echo ""

# Get RDS Endpoint
echo "🗄️  Database (RDS):"
RDS_ENDPOINT=$(aws rds describe-db-instances \
    --db-instance-identifier nonprofit-learning-db \
    --region $AWS_REGION \
    --query "DBInstances[0].Endpoint.Address" \
    --output text 2>/dev/null || echo "")

if [ -n "$RDS_ENDPOINT" ] && [ "$RDS_ENDPOINT" != "None" ]; then
    RDS_PORT=$(aws rds describe-db-instances \
        --db-instance-identifier nonprofit-learning-db \
        --region $AWS_REGION \
        --query "DBInstances[0].Endpoint.Port" \
        --output text 2>/dev/null || echo "5432")
    echo "   Endpoint: $RDS_ENDPOINT:$RDS_PORT"
    echo "   Status: $(aws rds describe-db-instances --db-instance-identifier nonprofit-learning-db --region $AWS_REGION --query 'DBInstances[0].DBInstanceStatus' --output text 2>/dev/null || echo 'Unknown')"
else
    echo "   ⚠️  RDS database not found"
    echo "   Create it using Terraform or AWS Console"
fi
echo ""

echo "📋 Summary:"
echo "   Backend API: $APP_RUNNER_URL"
echo "   Frontend: https://${CLOUDFRONT_DOMAIN:-nonprofit-learning-frontend.s3-website-$AWS_REGION.amazonaws.com}"
echo ""
echo "💡 To update GitHub Secrets:"
if [ -n "$APP_RUNNER_URL" ]; then
    echo "   NEXT_PUBLIC_API_URL=$APP_RUNNER_URL"
fi
if [ -n "$RDS_ENDPOINT" ] && [ "$RDS_ENDPOINT" != "None" ]; then
    echo "   DATABASE_URL=postgresql://username:password@$RDS_ENDPOINT:5432/nonprofit_learning"
fi
