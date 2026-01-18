#!/bin/bash
# Script to check App Runner service status

set -e

AWS_REGION="${AWS_REGION:-us-east-1}"

echo "🔍 Checking App Runner Service..."
echo ""

# Check AWS credentials
if ! aws sts get-caller-identity &>/dev/null; then
    echo "❌ AWS credentials not configured"
    exit 1
fi

echo "✅ AWS credentials verified"
echo ""

# Try to list services
echo "📦 Checking App Runner services..."
if aws apprunner list-services --region "$AWS_REGION" &>/dev/null; then
    echo "✅ App Runner is enabled in your account"
    echo ""
    
    # Get service details
    SERVICE_INFO=$(aws apprunner list-services \
        --region "$AWS_REGION" \
        --query "ServiceSummaryList[?ServiceName=='nonprofit-learning-backend']" \
        --output json 2>/dev/null || echo "[]")
    
    if [ "$SERVICE_INFO" != "[]" ] && [ -n "$SERVICE_INFO" ]; then
        SERVICE_URL=$(echo "$SERVICE_INFO" | jq -r '.[0].ServiceUrl // "Unknown"')
        SERVICE_STATUS=$(echo "$SERVICE_INFO" | jq -r '.[0].Status // "Unknown"')
        SERVICE_ARN=$(echo "$SERVICE_INFO" | jq -r '.[0].ServiceArn // "Unknown"')
        
        echo "✅ Service found: nonprofit-learning-backend"
        echo "   Status: $SERVICE_STATUS"
        echo "   URL: $SERVICE_URL"
        echo ""
        
        if [ "$SERVICE_STATUS" == "RUNNING" ]; then
            echo "✅ Service is running!"
            echo ""
            echo "🧪 Testing service..."
            if curl -s -f "$SERVICE_URL/health" &>/dev/null; then
                echo "✅ Health check passed: $SERVICE_URL/health"
            else
                echo "⚠️  Health check failed (service might still be starting)"
            fi
        elif [ "$SERVICE_STATUS" == "OPERATION_IN_PROGRESS" ]; then
            echo "⏳ Service is starting/updating. Wait 5-10 minutes and check again."
        else
            echo "⚠️  Service status: $SERVICE_STATUS"
            echo "   Check AWS Console for details:"
            echo "   https://console.aws.amazon.com/apprunner/home?region=$AWS_REGION#/services"
        fi
    else
        echo "⚠️  Service 'nonprofit-learning-backend' not found"
        echo ""
        echo "Possible reasons:"
        echo "1. Backend hasn't been deployed yet"
        echo "2. Deployment failed"
        echo "3. Service was deleted"
        echo ""
        echo "To deploy:"
        echo "1. Go to GitHub Actions"
        echo "2. Run 'Deploy Backend' workflow"
        echo "3. Or check deployment logs for errors"
    fi
else
    ERROR=$(aws apprunner list-services --region "$AWS_REGION" 2>&1)
    
    if echo "$ERROR" | grep -q "SubscriptionRequiredException"; then
        echo "❌ App Runner is not enabled in your account"
        echo ""
        echo "Error: SubscriptionRequiredException"
        echo ""
        echo "Solutions:"
        echo "1. Contact AWS Support to enable App Runner"
        echo "2. Use an alternative backend hosting:"
        echo "   - Railway (free tier): https://railway.app"
        echo "   - Render (free tier): https://render.com"
        echo "   - Fly.io (free tier): https://fly.io"
        echo "   - AWS Lambda + API Gateway (serverless)"
        echo "   - AWS ECS Fargate (has free tier)"
        echo ""
        echo "3. Check AWS Console:"
        echo "   https://console.aws.amazon.com/apprunner/home?region=$AWS_REGION"
        echo "   If page doesn't load, App Runner isn't available"
    else
        echo "❌ Error checking App Runner:"
        echo "$ERROR"
    fi
fi

echo ""
echo "📋 Next Steps:"
echo "1. Check AWS Console: https://console.aws.amazon.com/apprunner/home?region=$AWS_REGION#/services"
echo "2. Check GitHub Actions logs for deployment errors"
echo "3. If App Runner isn't available, consider alternatives (see APP_RUNNER_TROUBLESHOOTING.md)"
