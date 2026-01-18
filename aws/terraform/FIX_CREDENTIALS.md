# Fix AWS Credentials Error

## Error Message
```
Error: The security token included in the request is invalid
```

This means your AWS credentials are expired, invalid, or not configured.

## Quick Fix

### Option 1: Reconfigure AWS Credentials (Recommended)

```bash
# Reconfigure AWS CLI
aws configure
```

You'll be prompted for:
1. **AWS Access Key ID**: Your IAM user access key
2. **AWS Secret Access Key**: Your IAM user secret key
3. **Default region**: `us-east-1`
4. **Default output format**: `json`

### Option 2: Set Environment Variables

```bash
export AWS_ACCESS_KEY_ID="your-access-key-id"
export AWS_SECRET_ACCESS_KEY="your-secret-access-key"
export AWS_DEFAULT_REGION="us-east-1"
```

### Option 3: Use AWS SSO (if configured)

```bash
aws sso login
```

## Get New AWS Credentials

If you don't have valid credentials:

1. **Go to AWS Console**: https://console.aws.amazon.com/iam/
2. **Navigate to**: IAM → Users → `lalitgarg05` → Security credentials
3. **Create Access Key**:
   - Click "Create access key"
   - Choose "Command Line Interface (CLI)"
   - Click "Next" → "Create access key"
   - **IMPORTANT**: Copy both:
     - Access key ID
     - Secret access key (shown only once!)

4. **Configure locally**:
   ```bash
   aws configure
   # Paste the Access Key ID and Secret Access Key when prompted
   ```

## Verify Credentials

After configuring, verify they work:

```bash
aws sts get-caller-identity
```

Should output something like:
```json
{
    "UserId": "AIDA...",
    "Account": "283744739767",
    "Arn": "arn:aws:iam::283744739767:user/lalitgarg05"
}
```

## For GitHub Actions

If GitHub Actions is also failing, you need to update GitHub Secrets:

1. **Go to GitHub**: Your repository → Settings → Secrets and variables → Actions
2. **Update these secrets**:
   - `AWS_ACCESS_KEY_ID` - Your new access key ID
   - `AWS_SECRET_ACCESS_KEY` - Your new secret access key

## Common Issues

### "Access key is disabled"
- The access key was disabled in IAM
- Create a new access key

### "Access key expired"
- Access keys don't expire, but they can be rotated
- Create a new access key if the old one was deleted

### "Invalid credentials"
- Double-check you copied the keys correctly
- Make sure there are no extra spaces or newlines
- Try creating a new access key

## After Fixing

1. **Test locally**:
   ```bash
   cd aws/terraform
   terraform plan
   ```

2. **If Terraform works, retry deployment**:
   ```bash
   terraform apply
   ```

3. **For GitHub Actions**: The next workflow run should work with updated secrets
