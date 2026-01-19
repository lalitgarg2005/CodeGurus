#!/bin/bash
# Script to check App Runner service logs and status

set -e

AWS_REGION="${AWS_REGION:-us-east-1}"
SERVICE_NAME="nonprofit-learning-backend"

echo "📊 Checking App Runner Service Status..."
echo ""

# Check AWS credentials
if ! aws sts get-caller-identity &>/dev/null; then
    echo "❌ AWS credentials not configured"
    exit 1
fi

# Get service ARN
SERVICE_ARN=$(aws apprunner list-services \
    --region "$AWS_REGION" \
    --query "ServiceSummaryList[?ServiceName=='$SERVICE_NAME'].ServiceArn" \
    --output text 2>/dev/null || echo "")

if [ -z "$SERVICE_ARN" ]; then
    echo "❌ App Runner service not found: $SERVICE_NAME"
    exit 1
fi

echo "✅ Service found: $SERVICE_ARN"
echo ""

# Get service status
STATUS=$(aws apprunner describe-service \
    --service-arn "$SERVICE_ARN" \
    --region "$AWS_REGION" \
    --query 'Service.Status' \
    --output text 2>/dev/null || echo "UNKNOWN")

STATUS_MSG=$(aws apprunner describe-service \
    --service-arn "$SERVICE_ARN" \
    --region "$AWS_REGION" \
    --query 'Service.StatusMessage' \
    --output text 2>/dev/null || echo "")

SERVICE_URL=$(aws apprunner describe-service \
    --service-arn "$SERVICE_ARN" \
    --region "$AWS_REGION" \
    --query 'Service.ServiceUrl' \
    --output text 2>/dev/null || echo "")

echo "📋 Service Information:"
echo "   Status: $STATUS"
if [ -n "$STATUS_MSG" ] && [ "$STATUS_MSG" != "None" ]; then
    echo "   Status Message: $STATUS_MSG"
fi
if [ -n "$SERVICE_URL" ] && [ "$SERVICE_URL" != "None" ]; then
    echo "   Service URL: $SERVICE_URL"
fi
echo ""

# Check logs (if we have permission)
echo "📋 Viewing Recent Logs..."
echo "   (If you see permission errors, check logs in AWS Console)"
echo ""

LOG_GROUP="/aws/apprunner/$SERVICE_NAME/service"
if aws logs describe-log-groups --log-group-name-prefix "$LOG_GROUP" --region "$AWS_REGION" &>/dev/null; then
    echo "Recent log events:"
    aws logs tail "$LOG_GROUP" \
        --since 30m \
        --region "$AWS_REGION" \
        --format short 2>&1 | tail -30 || echo "   Could not fetch logs (check AWS Console)"
else
    echo "   ⚠️  Log group not found or no permission to access"
    echo "   View logs in AWS Console:"
    echo "   https://console.aws.amazon.com/apprunner/home?region=$AWS_REGION#/services"
fi

echo ""
echo "🔗 Direct Links:"
echo "   Service: https://console.aws.amazon.com/apprunner/home?region=$AWS_REGION#/services/$SERVICE_ARN"
echo "   Logs: https://console.aws.amazon.com/apprunner/home?region=$AWS_REGION#/services/$SERVICE_ARN/logs"
