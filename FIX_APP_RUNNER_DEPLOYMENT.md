# Fix App Runner Deployment Failure

## ❌ Error
```
[AppRunner] Successfully pulled your application image from ECR.
[AppRunner] Failed to deploy your application image.
```

Service status: `CREATE_FAILED`

## 🔍 Common Causes

1. **Application startup failure** - App crashes on startup
2. **Database connection timeout** - Can't reach RDS (VPC issue)
3. **Missing environment variables** - Required vars not set
4. **Health check failure** - `/health` endpoint not responding
5. **Port mismatch** - App not listening on port 8000

## ✅ Solution Steps

### Step 1: Check App Runner Logs

**Via AWS Console:**
1. Go to: https://console.aws.amazon.com/apprunner/home?region=us-east-1#/services
2. Click on `nonprofit-learning-backend`
3. Go to **Logs** tab
4. Look for error messages

**Via AWS CLI:**
```bash
aws logs tail /aws/apprunner/nonprofit-learning-backend/service \
  --since 30m \
  --region us-east-1 \
  --format short
```

### Step 2: Verify Environment Variables

Check that all required environment variables are set in App Runner:

1. **Go to App Runner Console:**
   - Configuration → Environment variables

2. **Required variables:**
   - `DATABASE_URL` - PostgreSQL connection string
   - `CLERK_SECRET_KEY` - Clerk secret key
   - `CLERK_PUBLISHABLE_KEY` - Clerk publishable key
   - `CLERK_FRONTEND_API` - Clerk frontend API URL
   - `ENVIRONMENT` - Should be `production`
   - `CORS_ORIGINS` - Allowed CORS origins

### Step 3: Check Database Connection

The entrypoint script waits for the database. If RDS is not accessible:

1. **Check if RDS is publicly accessible:**
   ```bash
   aws rds describe-db-instances \
     --db-instance-identifier nonprofit-learning-db \
     --query 'DBInstances[0].PubliclyAccessible'
   ```

2. **If not accessible, make it public** (or configure VPC):
   - See `FIX_RDS_PUBLIC_ACCESS.md`

### Step 4: Make Entrypoint More Resilient

The entrypoint script may be too strict. Update it to:
- Continue even if database check fails initially
- Log errors instead of exiting
- Allow app to start and handle DB errors gracefully

### Step 5: Check Health Endpoint

Verify the `/health` endpoint works:
- Should return: `{"status": "healthy"}`
- Should be accessible at: `http://localhost:8000/health`

## 🔧 Quick Fixes

### Fix 1: Update Entrypoint to Be More Resilient

If database connection is the issue, update `backend/entrypoint.sh` to:
- Not exit on database connection failure
- Allow app to start and retry connections
- Log warnings instead of errors

### Fix 2: Verify Port Configuration

Ensure App Runner is configured for port 8000:
- Image configuration → Port: `8000`
- Health check → Path: `/health`

### Fix 3: Check Application Logs

Look for Python errors in logs:
- Import errors
- Configuration errors
- Database connection errors

## 📋 Diagnostic Checklist

- [ ] Check App Runner logs for specific errors
- [ ] Verify all environment variables are set
- [ ] Check RDS is accessible (public or VPC)
- [ ] Verify DATABASE_URL format is correct
- [ ] Check health endpoint responds
- [ ] Verify port 8000 is configured
- [ ] Check for Python/application errors in logs

## 🐛 Common Errors and Fixes

### Error: "Database connection failed"
**Fix:** 
- Make RDS publicly accessible, OR
- Configure App Runner VPC access
- Verify DATABASE_URL is correct

### Error: "Missing environment variable"
**Fix:**
- Add missing variable in App Runner configuration
- Check GitHub Secrets are set

### Error: "Health check failed"
**Fix:**
- Verify `/health` endpoint exists and works
- Check app is listening on port 8000
- Increase health check timeout

### Error: "Application crashed"
**Fix:**
- Check application logs for Python errors
- Verify all dependencies are installed
- Check for missing files or configuration

## 🚀 After Fixing

1. **Delete failed service** (if needed):
   ```bash
   aws apprunner delete-service \
     --service-arn <SERVICE_ARN> \
     --region us-east-1
   ```

2. **Recreate service** with correct configuration

3. **Monitor logs** during deployment

4. **Test health endpoint** once running
