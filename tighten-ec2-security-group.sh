#!/bin/bash
# Tighten EC2 security group rules for production
# Requires AWS CLI configured with permissions to modify security groups.

set -euo pipefail

AWS_REGION=${AWS_REGION:-us-east-1}

read -rp "EC2 Instance ID: " INSTANCE_ID
read -rp "SSH allowed CIDR (e.g., your IP/32): " SSH_CIDR
read -rp "App allowed CIDR for port 8000 (e.g., CloudFront/Amplify CIDR or your IP/32): " APP_CIDR

if [ -z "$INSTANCE_ID" ] || [ -z "$SSH_CIDR" ] || [ -z "$APP_CIDR" ]; then
  echo "❌ Missing required inputs."
  exit 1
fi

SG_ID=$(aws ec2 describe-instances \
  --instance-ids "$INSTANCE_ID" \
  --region "$AWS_REGION" \
  --query 'Reservations[0].Instances[0].SecurityGroups[0].GroupId' \
  --output text)

if [ -z "$SG_ID" ] || [ "$SG_ID" = "None" ]; then
  echo "❌ Could not find security group for instance."
  exit 1
fi

echo "🔒 Using Security Group: $SG_ID"

echo "🔁 Revoking broad inbound rules (0.0.0.0/0) for ports 22 and 8000..."
aws ec2 revoke-security-group-ingress \
  --group-id "$SG_ID" \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0 \
  --region "$AWS_REGION" 2>/dev/null || true

aws ec2 revoke-security-group-ingress \
  --group-id "$SG_ID" \
  --protocol tcp \
  --port 8000 \
  --cidr 0.0.0.0/0 \
  --region "$AWS_REGION" 2>/dev/null || true

echo "✅ Authorizing SSH from $SSH_CIDR"
aws ec2 authorize-security-group-ingress \
  --group-id "$SG_ID" \
  --protocol tcp \
  --port 22 \
  --cidr "$SSH_CIDR" \
  --region "$AWS_REGION"

echo "✅ Authorizing app access from $APP_CIDR"
aws ec2 authorize-security-group-ingress \
  --group-id "$SG_ID" \
  --protocol tcp \
  --port 8000 \
  --cidr "$APP_CIDR" \
  --region "$AWS_REGION"

echo "✅ Security group tightened."
