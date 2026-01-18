# Quick Fix: Amplify Permissions Error

## Error
```
AccessDeniedException: User is not authorized to perform: amplify:StartJob
```

## ⚠️ Important: Check Your IAM Permissions First

If you get an error when trying to list or attach policies:
```
AccessDenied: User is not authorized to perform: iam:ListAttachedUserPolicies
```

**You need an AWS administrator to attach the policy for you.**

👉 **See [REQUEST_AMPLIFY_PERMISSIONS.md](./REQUEST_AMPLIFY_PERMISSIONS.md) for instructions on requesting permissions from your admin.**

## Solution (Choose One)

### Option 1: Using AWS Console (Easiest)

**Note:** If you don't have IAM permissions, you'll need an admin to do this.

1. **Go to IAM Console:**
   - https://console.aws.amazon.com/iam/home#/users/lalitgarg05

2. **Add Permissions:**
   - Click "Add permissions"
   - If this button is disabled or shows an error, you need admin help (see REQUEST_AMPLIFY_PERMISSIONS.md)
   - Select "Attach policies directly"
   - Search for: `AmplifyFullAccess`
   - Check the box next to it
   - Click "Next" → "Add permissions"

3. **Wait 1-2 minutes** for permissions to propagate

4. **Re-run the workflow** - it should work now!

### Option 2: Using AWS CLI (Fastest)

**Note:** This requires IAM permissions. If you get "AccessDenied", you need admin help.

```bash
# Make sure you're using the correct AWS credentials
aws sts get-caller-identity

# Try to attach Amplify permissions
aws iam attach-user-policy \
  --user-name lalitgarg05 \
  --policy-arn arn:aws:iam::aws:policy/AmplifyFullAccess

# If you get "AccessDenied", see REQUEST_AMPLIFY_PERMISSIONS.md
```

### Option 3: Using the Script

```bash
cd aws/terraform
./attach-amplify-permissions.sh
```

## Verify It Worked

After attaching the policy, test the permission:

```bash
# This should work without errors
aws amplify list-apps --region us-east-1 --max-items 1
```

If you get an error, wait another minute and try again (permissions can take a moment to propagate).

## After Fixing

1. **Re-run the Amplify deployment workflow**
2. It should now be able to trigger builds
3. Check the build status in AWS Amplify Console

## If You Still Get Errors

1. **Check if policy is attached:**
   ```bash
   aws iam list-attached-user-policies --user-name lalitgarg05
   ```

2. **Check for permission boundaries:**
   - IAM Console → Users → lalitgarg05 → Permissions boundaries
   - If there's a boundary, it might be limiting the permissions

3. **Wait longer:**
   - Sometimes permissions take 2-5 minutes to fully propagate

4. **Verify you're using the correct IAM user:**
   ```bash
   aws sts get-caller-identity
   ```
   Should show: `arn:aws:iam::283744739767:user/lalitgarg05`
