#!/bin/bash
# Script to help set up AWS credentials for Terraform

set -e

echo "🔧 AWS Credentials Setup Helper"
echo ""

# Check if credentials file exists
if [ ! -f ~/.aws/credentials ]; then
    echo "Creating ~/.aws/credentials file..."
    mkdir -p ~/.aws
    touch ~/.aws/credentials
fi

echo "Current AWS profiles:"
aws configure list-profiles 2>/dev/null || echo "  (none configured)"
echo ""

echo "Choose an option:"
echo "1. Configure new permanent IAM user credentials (recommended for Terraform)"
echo "2. Update existing profile with new credentials"
echo "3. Test current credentials"
echo ""
read -p "Enter choice (1-3): " choice

case $choice in
    1)
        echo ""
        echo "📝 Setting up new AWS credentials"
        echo ""
        echo "You need:"
        echo "  - AWS Access Key ID"
        echo "  - AWS Secret Access Key"
        echo ""
        echo "To get these:"
        echo "  1. Go to: https://console.aws.amazon.com/iam/"
        echo "  2. Navigate to: Users → lalitgarg05 → Security credentials"
        echo "  3. Click 'Create access key'"
        echo "  4. Choose 'Command Line Interface (CLI)'"
        echo "  5. Copy the Access Key ID and Secret Access Key"
        echo ""
        read -p "Press Enter when you have the credentials ready..."
        
        read -p "Enter AWS Access Key ID: " access_key
        read -sp "Enter AWS Secret Access Key: " secret_key
        echo ""
        read -p "Enter AWS region [us-east-1]: " region
        region=${region:-us-east-1}
        
        read -p "Enter profile name [default]: " profile_name
        profile_name=${profile_name:-default}
        
        # Configure AWS
        aws configure set aws_access_key_id "$access_key" --profile "$profile_name"
        aws configure set aws_secret_access_key "$secret_key" --profile "$profile_name"
        aws configure set region "$region" --profile "$profile_name"
        aws configure set output json --profile "$profile_name"
        
        echo ""
        echo "✅ Credentials configured for profile: $profile_name"
        echo ""
        echo "Testing credentials..."
        export AWS_PROFILE="$profile_name"
        if aws sts get-caller-identity; then
            echo ""
            echo "✅ Credentials are valid!"
            echo ""
            echo "To use this profile:"
            echo "  export AWS_PROFILE=$profile_name"
            echo "  # or unset AWS_PROFILE to use default"
        else
            echo "❌ Credentials test failed. Please check your keys."
        fi
        ;;
    2)
        echo ""
        echo "Available profiles:"
        aws configure list-profiles
        echo ""
        read -p "Enter profile name to update: " profile_name
        
        read -p "Enter AWS Access Key ID: " access_key
        read -sp "Enter AWS Secret Access Key: " secret_key
        echo ""
        read -p "Enter AWS region [us-east-1]: " region
        region=${region:-us-east-1}
        
        aws configure set aws_access_key_id "$access_key" --profile "$profile_name"
        aws configure set aws_secret_access_key "$secret_key" --profile "$profile_name"
        aws configure set region "$region" --profile "$profile_name"
        
        echo ""
        echo "✅ Profile '$profile_name' updated"
        echo "Testing credentials..."
        export AWS_PROFILE="$profile_name"
        aws sts get-caller-identity && echo "✅ Credentials are valid!"
        ;;
    3)
        echo ""
        read -p "Enter profile name to test [default]: " profile_name
        profile_name=${profile_name:-default}
        
        echo "Testing profile: $profile_name"
        export AWS_PROFILE="$profile_name"
        if aws sts get-caller-identity; then
            echo "✅ Credentials are valid!"
        else
            echo "❌ Credentials are invalid or expired"
            echo "   Run option 1 or 2 to update credentials"
        fi
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "💡 Tip: To use a specific profile, run:"
echo "   export AWS_PROFILE=profile_name"
echo ""
echo "   Or unset it to use default:"
echo "   unset AWS_PROFILE"
