#!/bin/bash
# Script to help fix Amplify environment variables

set -e

AWS_REGION="${AWS_REGION:-us-east-1}"

echo "🔧 Amplify Environment Variables Fixer"
echo ""

# Check AWS credentials
if ! aws sts get-caller-identity &>/dev/null; then
    echo "❌ AWS credentials not configured"
    exit 1
fi

echo "✅ AWS credentials verified"
echo ""

# Get App Runner URL
echo "📦 Getting Backend (App Runner) URL..."
APP_RUNNER_URL=$(aws apprunner list-services \
    --region "$AWS_REGION" \
    --query "ServiceSummaryList[?ServiceName=='nonprofit-learning-backend'].ServiceUrl" \
    --output text 2>/dev/null || echo "")

if [ -z "$APP_RUNNER_URL" ]; then
    echo "⚠️  App Runner service 'nonprofit-learning-backend' not found"
    echo "   Make sure the backend is deployed first"
    echo ""
    read -p "Enter your App Runner URL manually (or press Enter to skip): " APP_RUNNER_URL
else
    echo "✅ Found: $APP_RUNNER_URL"
fi
echo ""

# Get Amplify App ID
if [ -z "$AMPLIFY_APP_ID" ]; then
    echo "📱 Getting Amplify App ID..."
    AMPLIFY_APP_ID=$(aws amplify list-apps \
        --region "$AWS_REGION" \
        --query 'apps[?name==`nonprofit-learning-frontend` || contains(name, `nonprofit`) || contains(name, `learning`)].appId' \
        --output text 2>/dev/null | head -1 || echo "")
    
    if [ -z "$AMPLIFY_APP_ID" ]; then
        echo "⚠️  Could not find Amplify app automatically"
        read -p "Enter your Amplify App ID: " AMPLIFY_APP_ID
    else
        echo "✅ Found: $AMPLIFY_APP_ID"
    fi
fi
echo ""

# Get current environment variables
echo "🔐 Current Amplify Environment Variables:"
ENV_VARS=$(aws amplify get-app --app-id "$AMPLIFY_APP_ID" --region "$AWS_REGION" \
    --query 'app.environmentVariables' --output json 2>/dev/null || echo "{}")

CURRENT_API_URL=$(echo "$ENV_VARS" | jq -r '.["NEXT_PUBLIC_API_URL"] // "NOT SET"')
CURRENT_CLERK_KEY=$(echo "$ENV_VARS" | jq -r '.["NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY"] // "NOT SET"')
CURRENT_CLERK_API=$(echo "$ENV_VARS" | jq -r '.["NEXT_PUBLIC_CLERK_FRONTEND_API"] // "NOT SET"')

echo "   NEXT_PUBLIC_API_URL: $CURRENT_API_URL"
if [ "$CURRENT_CLERK_KEY" != "NOT SET" ]; then
    MASKED_KEY="${CURRENT_CLERK_KEY:0:15}...${CURRENT_CLERK_KEY: -4}"
    echo "   NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY: $MASKED_KEY"
else
    echo "   NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY: $CURRENT_CLERK_KEY"
fi
echo "   NEXT_PUBLIC_CLERK_FRONTEND_API: $CURRENT_CLERK_API"
echo ""

# Check for issues
ISSUES=0

if [ "$CURRENT_API_URL" == "NOT SET" ] || [[ "$CURRENT_API_URL" == *"clerk"* ]] || [[ "$CURRENT_API_URL" == *"your-app"* ]]; then
    echo "❌ ISSUE: NEXT_PUBLIC_API_URL is incorrect!"
    echo "   Current: $CURRENT_API_URL"
    if [ -n "$APP_RUNNER_URL" ]; then
        echo "   Should be: $APP_RUNNER_URL"
    fi
    ISSUES=$((ISSUES + 1))
fi

if [ "$CURRENT_CLERK_KEY" == "NOT SET" ] || [[ "$CURRENT_CLERK_KEY" == *"placeholder"* ]]; then
    echo "❌ ISSUE: NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY is not set or is placeholder"
    ISSUES=$((ISSUES + 1))
fi

if [ "$CURRENT_CLERK_API" == "NOT SET" ] || [[ "$CURRENT_CLERK_API" == *"placeholder"* ]] || [[ "$CURRENT_CLERK_API" == *"your-app"* ]]; then
    echo "❌ ISSUE: NEXT_PUBLIC_CLERK_FRONTEND_API is not set or is placeholder"
    ISSUES=$((ISSUES + 1))
fi

echo ""

if [ $ISSUES -eq 0 ]; then
    echo "✅ All environment variables look correct!"
    echo ""
    echo "If your app still doesn't load, check:"
    echo "1. Build logs in Amplify Console"
    echo "2. Browser console (F12) for errors"
    echo "3. Backend is running and accessible"
    exit 0
fi

echo "📋 Correct Values:"
echo ""
echo "Required Amplify Environment Variables:"
echo ""

if [ -n "$APP_RUNNER_URL" ]; then
    echo "1. NEXT_PUBLIC_API_URL"
    echo "   ❌ Current: $CURRENT_API_URL"
    echo "   ✅ Should be: $APP_RUNNER_URL"
    echo ""
fi

echo "2. NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY"
echo "   Current: $([ "$CURRENT_CLERK_KEY" != "NOT SET" ] && echo "${CURRENT_CLERK_KEY:0:15}...${CURRENT_CLERK_KEY: -4}" || echo "NOT SET")"
echo "   Should be: Your Clerk publishable key (starts with pk_test_ or pk_live_)"
echo "   Get from: Clerk Dashboard → API Keys"
echo ""

echo "3. NEXT_PUBLIC_CLERK_FRONTEND_API"
echo "   ❌ Current: $CURRENT_CLERK_API"
echo "   ✅ Should be: Your Clerk frontend API URL"
echo "   Format: https://your-app-name.clerk.accounts.dev"
echo "   Get from: Clerk Dashboard → Configure → Frontend API"
echo ""

echo "🔧 How to Fix:"
echo ""
echo "1. Go to AWS Amplify Console:"
echo "   https://console.aws.amazon.com/amplify/home?region=$AWS_REGION#/$AMPLIFY_APP_ID"
echo ""
echo "2. Navigate to: App settings → Environment variables"
echo ""
echo "3. Update these variables:"
echo ""

if [ -n "$APP_RUNNER_URL" ]; then
    echo "   Variable: NEXT_PUBLIC_API_URL"
    echo "   Value: $APP_RUNNER_URL"
    echo ""
fi

echo "   Variable: NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY"
echo "   Value: (Get from Clerk Dashboard → API Keys)"
echo ""
echo "   Variable: NEXT_PUBLIC_CLERK_FRONTEND_API"
echo "   Value: (Get from Clerk Dashboard → Configure → Frontend API)"
echo "   Format: https://your-app-name.clerk.accounts.dev"
echo ""
echo "4. After updating, redeploy:"
echo "   - Go to your branch (main)"
echo "   - Click 'Actions' → 'Redeploy this version'"
echo ""

echo "💡 Quick Reference:"
echo "   Amplify Console: https://console.aws.amazon.com/amplify/home?region=$AWS_REGION#/$AMPLIFY_APP_ID"
if [ -n "$APP_RUNNER_URL" ]; then
    echo "   Backend URL: $APP_RUNNER_URL"
fi
echo "   Clerk Dashboard: https://dashboard.clerk.com"
