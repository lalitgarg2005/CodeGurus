# AWS Credentials Setup

## Quick Setup

### Option 1: Interactive Configuration (Recommended)
```bash
aws configure
```
Enter:
- AWS Access Key ID
- AWS Secret Access Key  
- Default region: `us-east-1`
- Default output format: `json`

### Option 2: Environment Variables
```bash
export AWS_ACCESS_KEY_ID="your-access-key-id"
export AWS_SECRET_ACCESS_KEY="your-secret-access-key"
export AWS_DEFAULT_REGION="us-east-1"
```

### Option 3: AWS SSO
```bash
aws sso login
```

## Verify Credentials
```bash
aws sts get-caller-identity
```

## Get AWS Credentials

If you don't have AWS credentials:

1. **Go to AWS Console**: https://console.aws.amazon.com
2. **IAM → Users → Your User → Security Credentials**
3. **Create Access Key** (if you don't have one)
4. **Download or copy** the Access Key ID and Secret Access Key

⚠️ **Security Note**: Never commit AWS credentials to git!

## After Setting Credentials

1. Update `terraform.tfvars` with a secure database password
2. Run: `./setup-and-deploy.sh` or `terraform plan`

