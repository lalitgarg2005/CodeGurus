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

# Get Amplify App URL
echo "🌐 Frontend (Amplify):"
AMPLIFY_APP_ID=$(aws amplify list-apps \
    --region $AWS_REGION \
    --query 'apps[?name==`nonprofit-learning-frontend` || contains(name, `nonprofit`) || contains(name, `learning`)].appId' \
    --output text 2>/dev/null | head -1 || echo "")

if [ -n "$AMPLIFY_APP_ID" ]; then
    AMPLIFY_URL=$(aws amplify get-app \
        --app-id "$AMPLIFY_APP_ID" \
        --region $AWS_REGION \
        --query 'app.defaultDomain' \
        --output text 2>/dev/null || echo "")
    
    if [ -n "$AMPLIFY_URL" ]; then
        echo "   App ID: $AMPLIFY_APP_ID"
        echo "   URL: https://main.$AMPLIFY_URL"
        echo "   Direct: https://console.aws.amazon.com/amplify/home?region=$AWS_REGION#/$AMPLIFY_APP_ID"
    else
        echo "   App ID: $AMPLIFY_APP_ID"
        echo "   ⚠️  Could not get URL. Check AWS Console:"
        echo "   https://console.aws.amazon.com/amplify/home?region=$AWS_REGION"
    fi
else
    echo "   ⚠️  Amplify app not found"
    echo "   Check AWS Console: https://console.aws.amazon.com/amplify/home?region=$AWS_REGION"
fi
echo ""

# Get CloudFront Distribution (if using CloudFront instead of Amplify)
echo "🌐 Frontend (CloudFront - if configured):"
CLOUDFRONT_DOMAIN=$(aws cloudfront list-distributions \
    --query "DistributionList.Items[?Comment=='Nonprofit Learning Frontend' || contains(Origins.Items[0].DomainName, 'nonprofit-learning-frontend')].DomainName" \
    --output text 2>/dev/null | head -1 || echo "")

if [ -n "$CLOUDFRONT_DOMAIN" ]; then
    echo "   Domain: https://$CLOUDFRONT_DOMAIN"
else
    echo "   ⚠️  CloudFront distribution not found (using Amplify instead)"
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
echo "   Backend API: ${APP_RUNNER_URL:-Not found}"
if [ -n "$AMPLIFY_URL" ]; then
    echo "   Frontend (Amplify): https://main.$AMPLIFY_URL"
elif [ -n "$CLOUDFRONT_DOMAIN" ]; then
    echo "   Frontend (CloudFront): https://$CLOUDFRONT_DOMAIN"
else
    echo "   Frontend: Not found (check AWS Console)"
fi
echo ""
echo "💡 To update GitHub Secrets:"
if [ -n "$APP_RUNNER_URL" ]; then
    echo "   NEXT_PUBLIC_API_URL=$APP_RUNNER_URL"
fi
if [ -n "$RDS_ENDPOINT" ] && [ "$RDS_ENDPOINT" != "None" ]; then
    echo "   DATABASE_URL=postgresql://username:password@$RDS_ENDPOINT:5432/nonprofit_learning"
fi
