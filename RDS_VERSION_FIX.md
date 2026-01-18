# RDS PostgreSQL Version Fix

## Problem
The RDS creation was failing with:
```
Cannot find version 14.9 for postgres
```

## Root Cause
PostgreSQL version **14.9** is no longer available for new RDS instance creation in AWS. AWS has moved it to `NO_CREATE` status as newer minor versions (14.18, 14.19, etc.) have been released.

## Solution Applied

### 1. Updated GitHub Actions Workflow (`.github/workflows/create-rds.yml`)
- Changed from hardcoded `14.9` to `"14"` which lets AWS automatically select the latest available 14.x version
- Added fallback to `14.18` if the generic `"14"` fails
- Improved error messages with troubleshooting steps

### 2. Updated Terraform Configuration (`aws/terraform/main.tf`)
- Changed `engine_version = "14.9"` to `engine_version = "14"`
- Terraform will now use the latest available PostgreSQL 14.x version in your region

## How It Works Now

### GitHub Actions Workflow
1. **First attempt**: Uses `--engine-version "14"` (AWS picks latest 14.x)
2. **Fallback**: If that fails, tries `--engine-version "14.18"` (specific version)
3. **Error handling**: Provides clear troubleshooting steps if both fail

### Terraform
- Uses `engine_version = "14"` which Terraform resolves to the latest available 14.x version
- More reliable than hardcoding a specific minor version

## Testing

After these changes, the RDS creation should work. The workflow will:
1. Try PostgreSQL 14 (latest available)
2. Fall back to 14.18 if needed
3. Provide clear error messages if both fail

## Available Versions

To check what PostgreSQL versions are available in your region:
```bash
aws rds describe-db-engine-versions \
  --engine postgres \
  --region us-east-1 \
  --query "DBEngineVersions[*].EngineVersion" \
  --output table
```

## Notes

- **PostgreSQL 14** (major version) is still supported until **February 2027**
- Only specific minor versions (like 14.9) have been deprecated
- Using `"14"` ensures you always get a supported version
- The latest 14.x versions (14.18, 14.19) include security patches and bug fixes

## Next Steps

1. **Re-run the workflow**: The RDS creation should now succeed
2. **Monitor the creation**: RDS takes 5-10 minutes to become available
3. **Get the endpoint**: Once available, get the endpoint and add to `DATABASE_URL` secret

## If You Still Get Errors

If you encounter other errors, they might be related to:
1. **IAM Permissions**: Ensure your IAM user has RDS creation permissions
2. **VPC/Subnet Issues**: Verify default VPC and subnets exist
3. **Security Group**: Check that security group creation succeeded
4. **Region**: Ensure you're using the correct AWS region

Check the workflow logs for specific error messages and refer to `DEPLOYMENT_TROUBLESHOOTING.md` for more help.
