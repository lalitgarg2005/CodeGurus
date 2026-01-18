# Fix Missing Clerk Secrets Error

## ❌ Error
```
ValidationError: 3 validation errors for Settings
CLERK_SECRET_KEY - Field required
CLERK_PUBLISHABLE_KEY - Field required
CLERK_FRONTEND_API - Field required
```

## 🔍 Problem

The backend requires these Clerk environment variables, but they're not being passed to App Runner. This means:

1. **The secrets might not be set in GitHub**, OR
2. **The secret names might be incorrect**, OR
3. **The secrets might be empty**

## ✅ Solution

### Step 1: Verify Secrets in GitHub

1. **Go to GitHub:**
   - Your repository → **Settings** → **Secrets and variables** → **Actions**

2. **Check these secrets exist:**
   - ✅ `CLERK_SECRET_KEY`
   - ✅ `CLERK_PUBLISHABLE_KEY`
   - ✅ `CLERK_FRONTEND_API`

3. **Verify they're not empty:**
   - Click on each secret to view (you'll see `••••••` if set)
   - If you see "No value set", the secret is empty

### Step 2: Get Correct Values from Clerk

If secrets are missing or incorrect:

1. **Go to Clerk Dashboard:**
   - https://dashboard.clerk.com
   - Select your application

2. **Get CLERK_SECRET_KEY:**
   - Go to: **API Keys** (left sidebar)
   - Copy the **Secret key** (starts with `sk_test_` or `sk_live_`)

3. **Get CLERK_PUBLISHABLE_KEY:**
   - Still in **API Keys**
   - Copy the **Publishable key** (starts with `pk_test_` or `pk_live_`)

4. **Get CLERK_FRONTEND_API:**
   - Go to: **Configure** → **Frontend API**
   - Copy the URL (format: `https://your-app-name.clerk.accounts.dev`)
   - Or check the **Domains** section

### Step 3: Add/Update Secrets in GitHub

1. **Go to GitHub Secrets:**
   - Repository → Settings → Secrets and variables → Actions

2. **For each secret:**

   **Secret 1: CLERK_SECRET_KEY**
   - Click **New repository secret** (or **Update** if exists)
   - Name: `CLERK_SECRET_KEY`
   - Value: Your Clerk secret key (from Step 2)
   - Click **Add secret**

   **Secret 2: CLERK_PUBLISHABLE_KEY**
   - Click **New repository secret** (or **Update** if exists)
   - Name: `CLERK_PUBLISHABLE_KEY`
   - Value: Your Clerk publishable key (from Step 2)
   - Click **Add secret**

   **Secret 3: CLERK_FRONTEND_API**
   - Click **New repository secret** (or **Update** if exists)
   - Name: `CLERK_FRONTEND_API`
   - Value: Your Clerk frontend API URL (from Step 2)
   - Click **Add secret**

### Step 4: Verify Secret Names

**Important:** Secret names must match exactly (case-sensitive):

- ✅ `CLERK_SECRET_KEY` (correct)
- ❌ `clerk_secret_key` (wrong - lowercase)
- ❌ `CLERK_SECRET` (wrong - missing _KEY)
- ❌ `CLERK_SECRET_KEY ` (wrong - trailing space)

### Step 5: Re-run Deployment

After adding/updating secrets:

1. **Go to Actions:**
   - Your repository → **Actions** tab

2. **Re-run the workflow:**
   - Find the failed workflow run
   - Click **Re-run all jobs**
   - OR trigger a new deployment

## 🔍 Validation Script

Run this to check what secrets you need:

```bash
./validate-github-secrets.sh
```

This will show you:
- Required secrets list
- Expected formats
- Common issues

## 📋 Complete Secret Checklist

Make sure ALL these secrets are set:

**Required for Backend:**
- [ ] `CLERK_SECRET_KEY` - Starts with `sk_test_` or `sk_live_`
- [ ] `CLERK_PUBLISHABLE_KEY` - Starts with `pk_test_` or `pk_live_`
- [ ] `CLERK_FRONTEND_API` - Full URL like `https://xxx.clerk.accounts.dev`
- [ ] `DATABASE_URL` - PostgreSQL connection string
- [ ] `CORS_ORIGINS` - Comma-separated URLs
- [ ] `AWS_ACCESS_KEY_ID` - Your AWS access key
- [ ] `AWS_SECRET_ACCESS_KEY` - Your AWS secret key
- [ ] `APP_RUNNER_ACCESS_ROLE_ARN` - `arn:aws:iam::283744739767:role/AppRunnerECRAccessRole`

**Optional:**
- [ ] `NEXT_PUBLIC_API_URL` - For frontend builds
- [ ] `CLOUDFRONT_DISTRIBUTION_ID` - If using CloudFront
- [ ] `AMPLIFY_APP_ID` - If using Amplify

## 🐛 Common Issues

### Issue 1: Secret Name Typo
**Symptom:** Secret exists but workflow can't find it

**Fix:**
- Check exact spelling and capitalization
- No spaces before/after the name
- Must be: `CLERK_SECRET_KEY` (all caps, underscores)

### Issue 2: Empty Secret
**Symptom:** Secret exists but value is empty

**Fix:**
- Delete the secret and recreate it
- Make sure you copy the full value (no truncation)

### Issue 3: Wrong Format
**Symptom:** Secret is set but backend still fails

**Check formats:**
- `CLERK_SECRET_KEY`: Should start with `sk_test_` or `sk_live_`
- `CLERK_PUBLISHABLE_KEY`: Should start with `pk_test_` or `pk_live_`
- `CLERK_FRONTEND_API`: Should be a full URL starting with `https://`

## ✅ After Fixing

1. **Re-run the deployment workflow**
2. **Check the logs** - should see "✅ All required secrets are set"
3. **Verify App Runner service** starts successfully
4. **Test the backend URL** - `/health` endpoint should work

## 📖 Updated Workflow

The workflow has been updated to:
- ✅ Validate secrets before deployment
- ✅ Fail early if secrets are missing
- ✅ Show clear error messages

This will help catch missing secrets before the backend tries to start.
