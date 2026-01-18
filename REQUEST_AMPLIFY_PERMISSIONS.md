# Request Amplify Permissions

## Problem
Your IAM user `lalitgarg05` doesn't have permission to:
- List attached policies (`iam:ListAttachedUserPolicies`)
- Attach policies (`iam:AttachUserPolicy`)
- Perform Amplify operations (`amplify:StartJob`)

This means you need an **AWS administrator** to attach the permissions for you.

## What to Request

Ask your AWS administrator to attach the **AmplifyFullAccess** policy to your IAM user.

### Request Template

**Subject:** Request: Attach AmplifyFullAccess Policy to IAM User `lalitgarg05`

**Message:**
```
Hi,

I need Amplify permissions for my IAM user to deploy the frontend application.

User: lalitgarg05
Account: 283744739767
Region: us-east-1

Please attach the following AWS managed policy:
- Policy ARN: arn:aws:iam::aws:policy/AmplifyFullAccess

Or if you prefer a custom policy with minimal permissions, I need:
- amplify:StartJob
- amplify:GetJob
- amplify:ListJobs
- amplify:GetApp
- amplify:ListApps
- amplify:GetBranch
- amplify:ListBranches

This is needed for GitHub Actions to trigger Amplify builds.

Thanks!
```

## Alternative: AWS Console

If you have console access (even without CLI permissions), you might be able to:

1. **Go to AWS Console:**
   - https://console.aws.amazon.com/iam/home#/users/lalitgarg05

2. **Try to add permissions:**
   - Click "Add permissions"
   - If this option is available, you can attach `AmplifyFullAccess` yourself
   - If it's grayed out or shows an error, you'll need admin help

## What the Admin Needs to Do

### Option 1: Attach Managed Policy (Easiest)

```bash
aws iam attach-user-policy \
  --user-name lalitgarg05 \
  --policy-arn arn:aws:iam::aws:policy/AmplifyFullAccess
```

### Option 2: Update Existing Policy

If you have a custom policy (like `TerraformDeploymentPolicy`), the admin can add Amplify permissions to it:

1. Go to IAM → Policies → Your Policy
2. Edit the JSON
3. Add the Amplify permissions section (see `aws/terraform/IAM_PERMISSIONS.md`)
4. Save

### Option 3: Create Custom Policy

The admin can create a minimal Amplify policy with just the permissions you need:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "amplify:StartJob",
        "amplify:GetJob",
        "amplify:ListJobs",
        "amplify:GetApp",
        "amplify:ListApps",
        "amplify:GetBranch",
        "amplify:ListBranches"
      ],
      "Resource": "*"
    }
  ]
}
```

## After Permissions Are Added

1. **Wait 1-2 minutes** for permissions to propagate
2. **Verify permissions:**
   ```bash
   # This should work after permissions are added
   aws amplify list-apps --region us-east-1 --max-items 1
   ```
3. **Re-run the Amplify deployment workflow**

## If You're the Account Owner

If you own the AWS account (283744739767), you can:

1. **Log in as root user** (the email used to create the account)
2. **Attach the policy** via IAM Console
3. **Or create an admin user** and use that to manage permissions

## Quick Reference

- **Policy ARN:** `arn:aws:iam::aws:policy/AmplifyFullAccess`
- **User:** `lalitgarg05`
- **Account:** `283744739767`
- **Required Permission:** `amplify:StartJob` (minimum)
