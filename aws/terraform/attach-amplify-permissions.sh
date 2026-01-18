#!/bin/bash
# Quick script to attach Amplify permissions to IAM user

set -e

USER_NAME="lalitgarg05"
ACCOUNT_ID="283744739767"

echo "🔧 Attaching Amplify permissions to IAM user: $USER_NAME"
echo ""

# Check if AWS credentials are configured
if ! aws sts get-caller-identity &>/dev/null; then
    echo "❌ AWS credentials not configured"
    echo "Please run: aws configure"
    exit 1
fi

echo "✅ AWS credentials configured"
echo ""

# Attach AmplifyFullAccess policy
echo "Attaching AmplifyFullAccess policy..."
if aws iam attach-user-policy \
    --user-name "$USER_NAME" \
    --policy-arn arn:aws:iam::aws:policy/AmplifyFullAccess; then
    echo "✅ AmplifyFullAccess policy attached successfully!"
else
    echo "❌ Failed to attach policy"
    echo ""
    echo "Possible reasons:"
    echo "1. You don't have permission to attach policies"
    echo "2. Policy is already attached"
    echo "3. User doesn't exist"
    echo ""
    echo "Check if policy is already attached:"
    echo "  aws iam list-attached-user-policies --user-name $USER_NAME"
    exit 1
fi

echo ""
echo "✅ Amplify permissions added!"
echo ""
echo "📋 Next steps:"
echo "1. Wait 1-2 minutes for permissions to propagate"
echo "2. Re-run the Amplify deployment workflow"
echo "3. The workflow should now be able to trigger Amplify builds"
echo ""
echo "To verify permissions:"
echo "  aws amplify list-apps --region us-east-1 --max-items 1"
