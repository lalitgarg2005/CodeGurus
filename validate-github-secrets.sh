#!/bin/bash
# Script to validate GitHub Secrets are set correctly

echo "🔍 Validating GitHub Secrets..."
echo ""
echo "⚠️  Note: This script can't directly access GitHub Secrets."
echo "Please verify these secrets are set in:"
echo "   GitHub → Settings → Secrets and variables → Actions"
echo ""

echo "📋 Required Secrets for Backend Deployment:"
echo ""

REQUIRED_SECRETS=(
    "CLERK_SECRET_KEY"
    "CLERK_PUBLISHABLE_KEY"
    "CLERK_FRONTEND_API"
    "DATABASE_URL"
    "CORS_ORIGINS"
    "AWS_ACCESS_KEY_ID"
    "AWS_SECRET_ACCESS_KEY"
    "APP_RUNNER_ACCESS_ROLE_ARN"
)

OPTIONAL_SECRETS=(
    "NEXT_PUBLIC_API_URL"
    "CLOUDFRONT_DISTRIBUTION_ID"
    "AMPLIFY_APP_ID"
)

echo "✅ Required Secrets:"
for secret in "${REQUIRED_SECRETS[@]}"; do
    echo "   - $secret"
done

echo ""
echo "📝 Optional Secrets:"
for secret in "${OPTIONAL_SECRETS[@]}"; do
    echo "   - $secret"
done

echo ""
echo "🔑 Secret Value Formats:"
echo ""
echo "CLERK_SECRET_KEY:"
echo "   Format: sk_test_xxxxx or sk_live_xxxxx"
echo "   Get from: Clerk Dashboard → API Keys → Secret key"
echo ""
echo "CLERK_PUBLISHABLE_KEY:"
echo "   Format: pk_test_xxxxx or pk_live_xxxxx"
echo "   Get from: Clerk Dashboard → API Keys → Publishable key"
echo ""
echo "CLERK_FRONTEND_API:"
echo "   Format: https://your-app-name.clerk.accounts.dev"
echo "   Get from: Clerk Dashboard → Configure → Frontend API"
echo ""
echo "DATABASE_URL:"
echo "   Format: postgresql://username:password@host:5432/database"
echo "   Example: postgresql://postgres:password@rds-endpoint.rds.amazonaws.com:5432/nonprofit_learning"
echo ""
echo "CORS_ORIGINS:"
echo "   Format: https://domain1.com,https://domain2.com"
echo "   Example: https://main.xxxxx.amplifyapp.com,https://your-backend-url.us-east-1.awsapprunner.com"
echo ""
echo "APP_RUNNER_ACCESS_ROLE_ARN:"
echo "   Format: arn:aws:iam::ACCOUNT_ID:role/AppRunnerECRAccessRole"
echo "   Value: arn:aws:iam::283744739767:role/AppRunnerECRAccessRole"
echo ""

echo "✅ Verification Checklist:"
echo ""
echo "Go to GitHub → Settings → Secrets and variables → Actions"
echo "and verify each secret:"
echo ""
for secret in "${REQUIRED_SECRETS[@]}"; do
    echo "   [ ] $secret is set and not empty"
done

echo ""
echo "💡 Common Issues:"
echo ""
echo "1. Secret name typo:"
echo "   - Check for extra spaces or wrong capitalization"
echo "   - Must match exactly: CLERK_SECRET_KEY (not clerk_secret_key)"
echo ""
echo "2. Empty values:"
echo "   - Secrets can't be empty strings"
echo "   - Make sure you copied the full value"
echo ""
echo "3. Wrong format:"
echo "   - CLERK_SECRET_KEY should start with 'sk_test_' or 'sk_live_'"
echo "   - CLERK_PUBLISHABLE_KEY should start with 'pk_test_' or 'pk_live_'"
echo "   - CLERK_FRONTEND_API should be a full URL starting with 'https://'"
echo ""
