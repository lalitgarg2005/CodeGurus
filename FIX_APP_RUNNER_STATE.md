# Fix App Runner "OPERATION_IN_PROGRESS" Error

## ❌ Error
```
InvalidStateException: Service cannot be updated in the current state: OPERATION_IN_PROGRESS
```

## 🔍 Problem

The App Runner service is currently being updated or started, so it can't accept another update request. This happens when:
- A previous deployment is still in progress
- The service is starting up
- An update operation is already running

## ✅ Solution

### Option 1: Wait and Retry (Recommended)

The workflow has been updated to automatically wait for the service to be ready. However, if you're seeing this error:

1. **Wait 5-10 minutes** for the current operation to complete
2. **Check service status:**
   ```bash
   aws apprunner describe-service \
     --service-arn YOUR_SERVICE_ARN \
     --region us-east-1 \
     --query 'Service.Status' \
     --output text
   ```

3. **Re-run the workflow** once status is `RUNNING`

### Option 2: Check Service Status in Console

1. **Go to App Runner Console:**
   - https://console.aws.amazon.com/apprunner/home?region=us-east-1#/services
   - Click on `nonprofit-learning-backend`

2. **Check Status:**
   - **RUNNING** ✅ - Ready for updates
   - **OPERATION_IN_PROGRESS** ⏳ - Wait for it to complete
   - **CREATE_FAILED** ❌ - Check logs for errors
   - **UPDATE_FAILED** ❌ - Check logs for errors

3. **Wait until status is RUNNING**, then re-run the workflow

### Option 3: Cancel and Retry (If Stuck)

If the service has been in `OPERATION_IN_PROGRESS` for more than 15 minutes:

1. **Check if it's actually stuck:**
   - App Runner Console → Your service → Logs
   - Look for errors or if it's making progress

2. **If truly stuck, you may need to:**
   - Wait for AWS to timeout the operation (can take up to 30 minutes)
   - Or contact AWS Support if it's stuck for hours

## 🔧 What Changed

The workflow has been updated to:
- ✅ **Check service status** before attempting update
- ✅ **Wait automatically** if service is `OPERATION_IN_PROGRESS`
- ✅ **Retry with exponential backoff** (waits up to 5 minutes)
- ✅ **Show clear status messages** during wait

## 📋 Service States

**Ready for Update:**
- `RUNNING` ✅
- `PAUSED` ✅
- `CREATE_FAILED` ✅ (can retry)
- `UPDATE_FAILED` ✅ (can retry)

**Not Ready (Wait):**
- `OPERATION_IN_PROGRESS` ⏳
- `CREATE_IN_PROGRESS` ⏳
- `UPDATE_IN_PROGRESS` ⏳

## ⏱️ Typical Wait Times

- **Service creation:** 5-10 minutes
- **Service update:** 3-8 minutes
- **Service start:** 2-5 minutes

## 🐛 If Service is Stuck

If the service has been in `OPERATION_IN_PROGRESS` for more than 30 minutes:

1. **Check logs:**
   - App Runner Console → Your service → Logs
   - Look for errors or warnings

2. **Check service health:**
   - App Runner Console → Your service → Health
   - See if health checks are failing

3. **Common causes:**
   - **Missing environment variables** - Check Runtime environment variables
   - **Port mismatch** - Should be port 8000
   - **Image pull failed** - Check ECR permissions
   - **Health check failing** - Check `/health` endpoint

## ✅ After Fix

Once the service is `RUNNING`:

1. **Re-run the deployment workflow**
2. **The workflow will now wait** if service is busy
3. **Update should succeed**

## 💡 Prevention

To avoid this in the future:
- **Don't trigger multiple deployments simultaneously**
- **Wait for one deployment to complete** before starting another
- **Use the updated workflow** which handles this automatically
