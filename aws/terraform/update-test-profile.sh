#!/bin/bash
# Script to update the test profile with new permanent credentials

set -e

echo "🔧 Updating AWS 'test' profile with new credentials"
echo ""
echo "You need your new AWS Access Key ID and Secret Access Key"
echo ""

read -p "Enter your new AWS Access Key ID: " access_key
read -sp "Enter your new AWS Secret Access Key: " secret_key
echo ""

# Update the test profile
aws configure set aws_access_key_id "$access_key" --profile test
aws configure set aws_secret_access_key "$secret_key" --profile test
aws configure set region us-east-1 --profile test
aws configure set output json --profile test

# Remove session token if it exists (for permanent credentials)
# We'll use sed to remove the aws_session_token line from the credentials file
if grep -q "aws_session_token" ~/.aws/credentials; then
    echo "Removing session token (using permanent credentials instead)..."
    # Create a backup
    cp ~/.aws/credentials ~/.aws/credentials.backup
    
    # Remove session token line from test profile
    awk '
    /\[test\]/ { in_test=1; print; next }
    in_test && /^\[/ { in_test=0 }
    in_test && /aws_session_token/ { next }
    { print }
    ' ~/.aws/credentials > ~/.aws/credentials.tmp && mv ~/.aws/credentials.tmp ~/.aws/credentials
    
    echo "✅ Session token removed"
fi

echo ""
echo "✅ Test profile updated!"
echo ""
echo "Testing credentials..."
export AWS_PROFILE=test
if aws sts get-caller-identity; then
    echo ""
    echo "✅ SUCCESS! Credentials are working!"
    echo ""
    echo "You can now run:"
    echo "  cd aws/terraform"
    echo "  terraform plan"
else
    echo ""
    echo "❌ Credentials test failed"
    echo "Please verify:"
    echo "  1. Access Key ID is correct"
    echo "  2. Secret Access Key is correct (no extra spaces)"
    echo "  3. The IAM user has proper permissions"
fi
