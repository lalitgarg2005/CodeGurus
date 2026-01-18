#!/bin/bash
# Script to check App Runner service status and wait if needed

set -e

AWS_REGION="${AWS_REGION:-us-east-1}"
SERVICE_NAME="nonprofit-learning-backend"

echo "🔍 Checking App Runner Service Status..."
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
    echo "⚠️  Service '$SERVICE_NAME' not found"
    exit 1
fi

echo "✅ Service found: $SERVICE_NAME"
echo "   ARN: $SERVICE_ARN"
echo ""

# Get current status
SERVICE_STATUS=$(aws apprunner describe-service \
    --service-arn "$SERVICE_ARN" \
    --region "$AWS_REGION" \
    --query 'Service.Status' \
    --output text 2>/dev/null || echo "UNKNOWN")

SERVICE_URL=$(aws apprunner describe-service \
    --service-arn "$SERVICE_ARN" \
    --region "$AWS_REGION" \
    --query 'Service.ServiceUrl' \
    --output text 2>/dev/null || echo "Unknown")

echo "📊 Current Status: $SERVICE_STATUS"
echo "   URL: https://$SERVICE_URL"
echo ""

# Check if ready for update
if [ "$SERVICE_STATUS" == "RUNNING" ] || [ "$SERVICE_STATUS" == "PAUSED" ]; then
    echo "✅ Service is ready for updates!"
    echo ""
    echo "You can now:"
    echo "1. Re-run the deployment workflow"
    echo "2. Or update the service manually"
elif [ "$SERVICE_STATUS" == "OPERATION_IN_PROGRESS" ] || [ "$SERVICE_STATUS" == "CREATE_IN_PROGRESS" ] || [ "$SERVICE_STATUS" == "UPDATE_IN_PROGRESS" ]; then
    echo "⏳ Service is currently in progress"
    echo ""
    echo "Please wait for the operation to complete."
    echo "Typical wait time: 5-10 minutes"
    echo ""
    echo "To monitor:"
    echo "1. Check AWS Console: https://console.aws.amazon.com/apprunner/home?region=$AWS_REGION#/services"
    echo "2. Or run this script again in a few minutes"
    echo ""
    echo "Would you like to wait and check again? (y/n)"
    read -t 5 -n 1 WAIT_ANSWER || WAIT_ANSWER="n"
    
    if [ "$WAIT_ANSWER" == "y" ] || [ "$WAIT_ANSWER" == "Y" ]; then
        echo ""
        echo "Waiting and checking every 30 seconds (max 10 minutes)..."
        MAX_WAIT=600
        WAIT_TIME=0
        SLEEP_INTERVAL=30
        
        while [ $WAIT_TIME -lt $MAX_WAIT ]; do
            sleep $SLEEP_INTERVAL
            WAIT_TIME=$((WAIT_TIME + SLEEP_INTERVAL))
            
            CURRENT_STATUS=$(aws apprunner describe-service \
                --service-arn "$SERVICE_ARN" \
                --region "$AWS_REGION" \
                --query 'Service.Status' \
                --output text 2>/dev/null || echo "UNKNOWN")
            
            echo "   Status after ${WAIT_TIME}s: $CURRENT_STATUS"
            
            if [ "$CURRENT_STATUS" == "RUNNING" ] || [ "$CURRENT_STATUS" == "PAUSED" ]; then
                echo ""
                echo "✅ Service is now ready!"
                exit 0
            fi
            
            if [ "$CURRENT_STATUS" != "OPERATION_IN_PROGRESS" ] && [ "$CURRENT_STATUS" != "CREATE_IN_PROGRESS" ] && [ "$CURRENT_STATUS" != "UPDATE_IN_PROGRESS" ]; then
                echo ""
                echo "⚠️  Service status changed to: $CURRENT_STATUS"
                break
            fi
        done
        
        if [ $WAIT_TIME -ge $MAX_WAIT ]; then
            echo ""
            echo "⏱️  Maximum wait time reached (${MAX_WAIT}s)"
            echo "   Current status: $CURRENT_STATUS"
            echo "   Please check manually or contact support"
        fi
    fi
elif [ "$SERVICE_STATUS" == "CREATE_FAILED" ] || [ "$SERVICE_STATUS" == "UPDATE_FAILED" ]; then
    echo "❌ Service is in failed state: $SERVICE_STATUS"
    echo ""
    echo "Check logs in AWS Console for errors:"
    echo "   https://console.aws.amazon.com/apprunner/home?region=$AWS_REGION#/services"
    echo ""
    echo "You can try to update the service to retry."
else
    echo "⚠️  Service status: $SERVICE_STATUS"
    echo "   Check AWS Console for details"
fi

echo ""
echo "🔗 Direct Links:"
echo "   Console: https://console.aws.amazon.com/apprunner/home?region=$AWS_REGION#/services"
echo "   Service URL: https://$SERVICE_URL"
