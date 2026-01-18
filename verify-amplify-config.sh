#!/bin/bash
# Script to verify Amplify configuration and secrets

set -e

AWS_REGION="${AWS_REGION:-us-east-1}"

echo "🔍 Verifying Amplify Configuration..."
echo ""

# Check AWS credentials
if ! aws sts get-caller-identity &>/dev/null; then
    echo "❌ AWS credentials not configured"
    exit 1
fi

echo "✅ AWS credentials verified"
echo ""

# Get Amplify App ID from GitHub Secrets (if available) or prompt
if [ -z "$AMPLIFY_APP_ID" ]; then
    echo "⚠️  AMPLIFY_APP_ID not set in environment"
    echo "Please provide your Amplify App ID (or set AMPLIFY_APP_ID env var):"
    read -p "Amplify App ID: " AMPLIFY_APP_ID
fi

if [ -z "$AMPLIFY_APP_ID" ]; then
    echo "❌ Amplify App ID is required"
    exit 1
fi

echo "📱 Checking Amplify App: $AMPLIFY_APP_ID"
echo ""

# Get Amplify app details
APP_INFO=$(aws amplify get-app --app-id "$AMPLIFY_APP_ID" --region "$AWS_REGION" 2>/dev/null || echo "")

if [ -z "$APP_INFO" ]; then
    echo "❌ Amplify app not found or access denied"
    exit 1
fi

# Extract app details
APP_NAME=$(echo "$APP_INFO" | jq -r '.app.name // "Unknown"')
DEFAULT_DOMAIN=$(echo "$APP_INFO" | jq -r '.app.defaultDomain // "Unknown"')
AMPLIFY_URL="https://main.$DEFAULT_DOMAIN"

echo "✅ App found: $APP_NAME"
echo "   URL: $AMPLIFY_URL"
echo ""

# Check branches
echo "🌿 Checking branches..."
BRANCHES=$(aws amplify list-branches --app-id "$AMPLIFY_APP_ID" --region "$AWS_REGION" --query 'branches[*].branchName' --output text 2>/dev/null || echo "")

if [ -n "$BRANCHES" ]; then
    echo "   Branches: $BRANCHES"
    if echo "$BRANCHES" | grep -q "main"; then
        echo "   ✅ main branch found"
    else
        echo "   ⚠️  main branch not found"
    fi
else
    echo "   ⚠️  No branches found"
fi
echo ""

# Check environment variables
echo "🔐 Checking Amplify Environment Variables..."
echo ""
echo "⚠️  IMPORTANT: Environment variables must be set in Amplify Console, not GitHub Secrets!"
echo ""
echo "Go to: AWS Amplify Console → Your App → App settings → Environment variables"
echo ""
echo "Required variables:"
echo ""

# Get environment variables from Amplify
ENV_VARS=$(aws amplify get-app --app-id "$AMPLIFY_APP_ID" --region "$AWS_REGION" --query 'app.environmentVariables' --output json 2>/dev/null || echo "{}")

# Check each required variable
REQUIRED_VARS=(
    "NEXT_PUBLIC_API_URL"
    "NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY"
    "NEXT_PUBLIC_CLERK_FRONTEND_API"
)

MISSING_VARS=()

for VAR in "${REQUIRED_VARS[@]}"; do
    VALUE=$(echo "$ENV_VARS" | jq -r ".[\"$VAR\"] // empty")
    if [ -z "$VALUE" ] || [ "$VALUE" == "null" ]; then
        echo "   ❌ $VAR: NOT SET"
        MISSING_VARS+=("$VAR")
    else
        # Mask sensitive values
        if [[ "$VAR" == *"KEY"* ]] || [[ "$VAR" == *"SECRET"* ]]; then
            MASKED="${VALUE:0:10}...${VALUE: -4}"
            echo "   ✅ $VAR: $MASKED"
        else
            echo "   ✅ $VAR: $VALUE"
        fi
    fi
done

echo ""

# Check recent builds
echo "🔨 Checking recent builds..."
JOBS=$(aws amplify list-jobs \
    --app-id "$AMPLIFY_APP_ID" \
    --branch-name main \
    --region "$AWS_REGION" \
    --max-results 3 \
    --query 'jobSummaries[*].{JobId:jobId,Status:jobStatus,Type:jobType}' \
    --output json 2>/dev/null || echo "[]")

if [ "$JOBS" != "[]" ]; then
    echo "$JOBS" | jq -r '.[] | "   \(.Type): \(.Status) (ID: \(.JobId))"'
else
    echo "   ⚠️  No builds found"
fi
echo ""

# Get App Runner URL for NEXT_PUBLIC_API_URL verification
echo "🔗 Checking Backend (App Runner)..."
APP_RUNNER_URL=$(aws apprunner list-services \
    --region "$AWS_REGION" \
    --query "ServiceSummaryList[?ServiceName=='nonprofit-learning-backend'].ServiceUrl" \
    --output text 2>/dev/null || echo "")

if [ -n "$APP_RUNNER_URL" ]; then
    echo "   ✅ Backend URL: $APP_RUNNER_URL"
    echo ""
    echo "   ⚠️  Verify NEXT_PUBLIC_API_URL in Amplify matches:"
    echo "      $APP_RUNNER_URL"
else
    echo "   ⚠️  App Runner service not found"
fi
echo ""

# Summary
echo "📋 Summary:"
echo ""

if [ ${#MISSING_VARS[@]} -gt 0 ]; then
    echo "❌ Missing environment variables in Amplify:"
    for VAR in "${MISSING_VARS[@]}"; do
        echo "   - $VAR"
    done
    echo ""
    echo "To fix:"
    echo "1. Go to AWS Amplify Console"
    echo "2. Select your app: $APP_NAME"
    echo "3. Go to: App settings → Environment variables"
    echo "4. Add the missing variables"
    echo "5. Redeploy: Branch (main) → Actions → Redeploy this version"
    echo ""
else
    echo "✅ All required environment variables are set"
    echo ""
fi

echo "🌐 Your Amplify URL: $AMPLIFY_URL"
echo ""
echo "💡 Troubleshooting if URL doesn't load:"
echo "1. Check build logs in Amplify Console"
echo "2. Verify environment variables are correct"
echo "3. Check browser console (F12) for errors"
echo "4. Verify CORS_ORIGINS in backend includes your Amplify URL"
echo "5. Check that NEXT_PUBLIC_API_URL points to your App Runner service"
