# Fix App Runner VPC Configuration for RDS Access

## ❌ Current Issue

1. **App Runner service is in `CREATE_FAILED` state**
2. **App Runner uses DEFAULT egress** (not VPC), so it can't access RDS
3. **RDS connection times out** because App Runner isn't in the VPC

## ✅ Solution: Recreate App Runner with VPC Configuration

### Step 1: Delete Failed Service

The service is in `CREATE_FAILED` state, so we need to delete it first:

**Via AWS Console:**
1. Go to: https://console.aws.amazon.com/apprunner/home?region=us-east-1#/services
2. Click on `nonprofit-learning-backend`
3. Click **Delete** (top right)
4. Confirm deletion

**Via AWS CLI:**
```bash
SERVICE_ARN=$(aws apprunner list-services \
  --region us-east-1 \
  --query "ServiceSummaryList[?ServiceName=='nonprofit-learning-backend'].ServiceArn" \
  --output text)

aws apprunner delete-service \
  --service-arn "$SERVICE_ARN" \
  --region us-east-1
```

### Step 2: Get VPC Information

You already have:
- **VPC ID:** `vpc-0b1f4886bdf6dc52d`
- **Subnets:** 
  - `subnet-06a02eb54e41d9a6b` (us-east-1b)
  - `subnet-06cf85a4d9aa28756` (us-east-1f)
- **App Runner Security Group:** `sg-076f24e380273a905`
- **RDS Security Group:** `sg-09390ba267d614433`

### Step 3: Create App Runner Service with VPC Configuration

**Option A: Via AWS Console (Easiest)**

1. **Go to App Runner Console:**
   - https://console.aws.amazon.com/apprunner/home?region=us-east-1#/services
   - Click **Create service**

2. **Source configuration:**
   - Source: **Container registry**
   - Provider: **Amazon ECR**
   - Container image URI: Your ECR URI (e.g., `283744739767.dkr.ecr.us-east-1.amazonaws.com/nonprofit-learning-backend:latest`)
   - Deployment trigger: **Automatic**

3. **Service settings:**
   - Service name: `nonprofit-learning-backend`
   - Virtual CPU: **1 vCPU**
   - Memory: **2 GB**

4. **Networking (IMPORTANT):**
   - **Egress configuration:** Select **VPC**
   - **VPC:** `vpc-0b1f4886bdf6dc52d`
   - **Subnets:** Select at least 2 subnets:
     - `subnet-06a02eb54e41d9a6b` (us-east-1b)
     - `subnet-06cf85a4d9aa28756` (us-east-1f)
   - **Security groups:** `sg-076f24e380273a905`

5. **Environment variables:**
   - Add all required variables (DATABASE_URL, CLERK keys, etc.)

6. **Access role:**
   - Use: `arn:aws:iam::283744739767:role/AppRunnerECRAccessRole`

7. **Click Create service**

**Option B: Update Workflow to Include VPC**

The workflow will be updated to include VPC configuration automatically.

### Step 4: Verify Connection

After service is created:

1. **Wait for service to be RUNNING** (5-10 minutes)
2. **Test database connection:**
   - Check App Runner logs for connection errors
   - Test the `/health` endpoint

## 🔧 What's Already Done

✅ **Security group created:** `sg-076f24e380273a905`  
✅ **Security group rule added:** App Runner SG → RDS (port 5432)  
✅ **Subnets identified:** 2+ subnets in different AZs  
✅ **VPC identified:** `vpc-0b1f4886bdf6dc52d`

## 📋 Quick Reference

**VPC Configuration:**
- VPC: `vpc-0b1f4886bdf6dc52d`
- Subnet 1: `subnet-06a02eb54e41d9a6b` (us-east-1b)
- Subnet 2: `subnet-06cf85a4d9aa28756` (us-east-1f)
- Security Group: `sg-076f24e380273a905`

**Direct Links:**
- App Runner Console: https://console.aws.amazon.com/apprunner/home?region=us-east-1#/services
- EC2 Security Groups: https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#SecurityGroups:

## ⚠️ Important Notes

1. **Service must be deleted first** (it's in CREATE_FAILED state)
2. **VPC configuration can only be set during creation** (or via update if service supports it)
3. **Need at least 2 subnets** in different Availability Zones ✅ (you have 6)
4. **Security group rule is already set** ✅

## 🚀 After Fixing

Once the service is recreated with VPC configuration:

1. **Service will be able to access RDS**
2. **Migrations will work**
3. **Backend will connect to database**
4. **Health checks will pass**
