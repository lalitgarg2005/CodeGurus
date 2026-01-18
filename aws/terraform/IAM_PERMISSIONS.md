# IAM Permissions Required for Terraform Deployment

## Problem

If you encounter errors like:
```
An error occurred (UnauthorizedOperation) when calling the CreateSecurityGroup operation: 
You are not authorized to perform this operation.
```

This means your IAM user/role doesn't have the necessary permissions to create AWS resources.

## Solution

You need to attach an IAM policy with the following permissions to your IAM user (`lalitgarg05`).

## Required IAM Policy

Create a new IAM policy with the following JSON and attach it to your user:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateSecurityGroup",
        "ec2:DeleteSecurityGroup",
        "ec2:DescribeSecurityGroups",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:AuthorizeSecurityGroupEgress",
        "ec2:RevokeSecurityGroupIngress",
        "ec2:RevokeSecurityGroupEgress",
        "ec2:DescribeVpcs",
        "ec2:DescribeSubnets",
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeAccountAttributes",
        "ec2:CreateTags",
        "ec2:DeleteTags",
        "ec2:DescribeTags"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "rds:CreateDBInstance",
        "rds:DeleteDBInstance",
        "rds:DescribeDBInstances",
        "rds:ModifyDBInstance",
        "rds:CreateDBSubnetGroup",
        "rds:DeleteDBSubnetGroup",
        "rds:DescribeDBSubnetGroups",
        "rds:AddTagsToResource",
        "rds:RemoveTagsFromResource",
        "rds:ListTagsForResource"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:CreateRepository",
        "ecr:DeleteRepository",
        "ecr:DescribeRepositories",
        "ecr:PutImageScanningConfiguration",
        "ecr:GetRepositoryPolicy",
        "ecr:SetRepositoryPolicy",
        "ecr:DeleteRepositoryPolicy",
        "ecr:ListImages",
        "ecr:TagResource",
        "ecr:UntagResource"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:CreateBucket",
        "s3:DeleteBucket",
        "s3:GetBucketLocation",
        "s3:GetBucketWebsite",
        "s3:PutBucketWebsite",
        "s3:GetBucketPublicAccessBlock",
        "s3:PutBucketPublicAccessBlock",
        "s3:PutBucketPolicy",
        "s3:GetBucketPolicy",
        "s3:DeleteBucketPolicy",
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:GetBucketTagging",
        "s3:PutBucketTagging"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudfront:CreateDistribution",
        "cloudfront:DeleteDistribution",
        "cloudfront:GetDistribution",
        "cloudfront:GetDistributionConfig",
        "cloudfront:UpdateDistribution",
        "cloudfront:CreateCloudFrontOriginAccessIdentity",
        "cloudfront:DeleteCloudFrontOriginAccessIdentity",
        "cloudfront:GetCloudFrontOriginAccessIdentity",
        "cloudfront:GetCloudFrontOriginAccessIdentityConfig",
        "cloudfront:UpdateCloudFrontOriginAccessIdentity",
        "cloudfront:ListDistributions",
        "cloudfront:ListCloudFrontOriginAccessIdentities",
        "cloudfront:TagResource",
        "cloudfront:UntagResource",
        "cloudfront:ListTagsForResource"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:PassRole"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "iam:PassedToService": [
            "ec2.amazonaws.com",
            "rds.amazonaws.com"
          ]
        }
      }
    }
  ]
}
```

## How to Fix the Issue

### Option 1: Using AWS Console (Recommended)

1. **Go to IAM Console:**
   - Navigate to: https://console.aws.amazon.com/iam/
   - Click on "Policies" in the left sidebar

2. **Create a New Policy:**
   - Click "Create policy"
   - Click the "JSON" tab
   - Paste the policy JSON above
   - Click "Next"
   - Name it: `TerraformDeploymentPolicy`
   - Add description: "Permissions for Terraform to deploy Nonprofit Learning Platform"
   - Click "Create policy"

3. **Attach Policy to Your User:**
   - Go to "Users" in the left sidebar
   - Click on your user: `lalitgarg05`
   - Click "Add permissions" → "Attach policies directly"
   - Search for `TerraformDeploymentPolicy`
   - Check the box and click "Add permissions"

### Option 2: Using AWS CLI

```bash
# Save the policy JSON to a file
cat > terraform-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateSecurityGroup",
        "ec2:DeleteSecurityGroup",
        "ec2:DescribeSecurityGroups",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:AuthorizeSecurityGroupEgress",
        "ec2:RevokeSecurityGroupIngress",
        "ec2:RevokeSecurityGroupEgress",
        "ec2:DescribeVpcs",
        "ec2:DescribeSubnets",
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeAccountAttributes",
        "ec2:CreateTags",
        "ec2:DeleteTags",
        "ec2:DescribeTags"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "rds:CreateDBInstance",
        "rds:DeleteDBInstance",
        "rds:DescribeDBInstances",
        "rds:ModifyDBInstance",
        "rds:CreateDBSubnetGroup",
        "rds:DeleteDBSubnetGroup",
        "rds:DescribeDBSubnetGroups",
        "rds:AddTagsToResource",
        "rds:RemoveTagsFromResource",
        "rds:ListTagsForResource"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:CreateRepository",
        "ecr:DeleteRepository",
        "ecr:DescribeRepositories",
        "ecr:PutImageScanningConfiguration",
        "ecr:GetRepositoryPolicy",
        "ecr:SetRepositoryPolicy",
        "ecr:DeleteRepositoryPolicy",
        "ecr:ListImages",
        "ecr:TagResource",
        "ecr:UntagResource"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:CreateBucket",
        "s3:DeleteBucket",
        "s3:GetBucketLocation",
        "s3:GetBucketWebsite",
        "s3:PutBucketWebsite",
        "s3:GetBucketPublicAccessBlock",
        "s3:PutBucketPublicAccessBlock",
        "s3:PutBucketPolicy",
        "s3:GetBucketPolicy",
        "s3:DeleteBucketPolicy",
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:GetBucketTagging",
        "s3:PutBucketTagging"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudfront:CreateDistribution",
        "cloudfront:DeleteDistribution",
        "cloudfront:GetDistribution",
        "cloudfront:GetDistributionConfig",
        "cloudfront:UpdateDistribution",
        "cloudfront:CreateCloudFrontOriginAccessIdentity",
        "cloudfront:DeleteCloudFrontOriginAccessIdentity",
        "cloudfront:GetCloudFrontOriginAccessIdentity",
        "cloudfront:GetCloudFrontOriginAccessIdentityConfig",
        "cloudfront:UpdateCloudFrontOriginAccessIdentity",
        "cloudfront:ListDistributions",
        "cloudfront:ListCloudFrontOriginAccessIdentities",
        "cloudfront:TagResource",
        "cloudfront:UntagResource",
        "cloudfront:ListTagsForResource"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:PassRole"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "iam:PassedToService": [
            "ec2.amazonaws.com",
            "rds.amazonaws.com"
          ]
        }
      }
    }
  ]
}
EOF

# Create the policy (requires admin permissions)
aws iam create-policy \
  --policy-name TerraformDeploymentPolicy \
  --policy-document file://terraform-policy.json \
  --description "Permissions for Terraform to deploy Nonprofit Learning Platform"

# Note: Replace ACCOUNT_ID with your AWS account ID (283744739767)
# Attach the policy to your user
aws iam attach-user-policy \
  --user-name lalitgarg05 \
  --policy-arn arn:aws:iam::283744739767:policy/TerraformDeploymentPolicy
```

### Option 3: Quick Fix - Use AWS Managed Policies (Less Secure)

If you have admin access or can request it, you can attach these AWS managed policies:

```bash
# Attach AWS managed policies (broader permissions)
aws iam attach-user-policy \
  --user-name lalitgarg05 \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess

aws iam attach-user-policy \
  --user-name lalitgarg05 \
  --policy-arn arn:aws:iam::aws:policy/AmazonRDSFullAccess

aws iam attach-user-policy \
  --user-name lalitgarg05 \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess

aws iam attach-user-policy \
  --user-name lalitgarg05 \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess

aws iam attach-user-policy \
  --user-name lalitgarg05 \
  --policy-arn arn:aws:iam::aws:policy/CloudFrontFullAccess
```

⚠️ **Note**: AWS managed policies grant broader permissions than necessary. The custom policy above is more secure and follows the principle of least privilege.

## Verify Permissions

After attaching the policy, verify your permissions:

```bash
# Check your current identity
aws sts get-caller-identity

# Test EC2 permissions
aws ec2 describe-vpcs

# Test RDS permissions
aws rds describe-db-instances

# Test if you can describe security groups
aws ec2 describe-security-groups --max-items 1
```

## After Fixing Permissions

1. **Retry Terraform deployment:**
   ```bash
   cd aws/terraform
   terraform plan
   terraform apply
   ```

2. **If you still get errors**, wait a few minutes for IAM permissions to propagate (usually instant, but can take up to 5 minutes).

## Troubleshooting

### Still Getting Permission Errors?

1. **Check if policy is attached:**
   ```bash
   aws iam list-attached-user-policies --user-name lalitgarg05
   ```

2. **Check policy contents:**
   ```bash
   aws iam get-policy --policy-arn arn:aws:iam::283744739767:policy/TerraformDeploymentPolicy
   ```

3. **Verify you're using the correct AWS credentials:**
   ```bash
   aws sts get-caller-identity
   ```
   Should show: `arn:aws:iam::283744739767:user/lalitgarg05`

4. **Check for permission boundaries:**
   - IAM users can have permission boundaries that limit even attached policies
   - Check in IAM Console → Users → lalitgarg05 → Permissions boundaries

### Need Help?

If you don't have permission to create/attach IAM policies:
- Contact your AWS account administrator
- Request them to attach the policy above to your user
- Or ask for temporary admin access to set it up

## Security Best Practices

1. **Use the custom policy** (Option 1 or 2) instead of full access policies
2. **Scope resources** if possible (e.g., restrict to specific VPCs, buckets)
3. **Use IAM roles** instead of users for programmatic access when possible
4. **Rotate access keys** regularly
5. **Enable MFA** for IAM users with elevated permissions
