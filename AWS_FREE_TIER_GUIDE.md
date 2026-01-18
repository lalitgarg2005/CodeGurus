# AWS Free Tier Guide

## ✅ Free Tier Eligible Services

### 1. **RDS PostgreSQL** ✅ FREE TIER
- **Instance:** db.t3.micro (or db.t2.micro)
- **Free:** 750 hours/month for 12 months
- **Storage:** 20GB free (gp2)
- **Backups:** 7 days retention

### 2. **S3** ✅ FREE TIER
- **Storage:** 5GB free
- **Requests:** 20,000 GET requests/month
- **Data Transfer:** 100GB out/month

### 3. **CloudFront** ✅ FREE TIER
- **Data Transfer:** 50GB out/month
- **Requests:** 10,000,000 HTTP/HTTPS requests/month

### 4. **ECR** ✅ FREE TIER
- **Storage:** 500MB/month
- **Data Transfer:** 500MB/month

### 5. **App Runner** ⚠️ NOT FREE TIER
- **Cost:** ~$25/month (1 vCPU, 2GB RAM)
- **Alternative:** Use AWS Lambda + API Gateway (free tier available)

### 6. **EKS** ❌ NOT FREE TIER
- **Cost:** $0.10/hour for control plane (~$72/month)
- **Plus:** EC2 instances for nodes
- **Not recommended for free tier**

---

## 💰 Cost Comparison

### Current Setup (App Runner):
- **App Runner:** ~$25/month
- **RDS:** FREE (first 12 months)
- **S3:** FREE (within limits)
- **CloudFront:** FREE (within limits)
- **ECR:** FREE (within limits)
- **Total:** ~$25/month

### Alternative (Lambda + API Gateway):
- **Lambda:** FREE (1M requests/month)
- **API Gateway:** FREE (1M requests/month)
- **RDS:** FREE (first 12 months)
- **S3:** FREE (within limits)
- **CloudFront:** FREE (within limits)
- **Total:** ~$0/month (within free tier)

---

## 🎯 Recommendation: Keep App Runner

**Why App Runner over EKS:**
1. ✅ **Simpler:** No Kubernetes knowledge needed
2. ✅ **Cheaper:** $25/month vs $72+/month for EKS
3. ✅ **Easier:** Automatic scaling and deployment
4. ✅ **Faster:** No cluster management overhead

**Why App Runner over Lambda:**
1. ✅ **Better for FastAPI:** Full container support
2. ✅ **Easier debugging:** Standard HTTP server
3. ✅ **WebSocket support:** If needed later
4. ✅ **Long-running:** No 15-minute timeout

---

## 📋 Free Tier Limits to Watch

### RDS:
- ✅ 750 hours/month = ~31 days (enough for 24/7)
- ✅ 20GB storage (plenty for development)
- ⚠️ After 12 months: ~$15/month

### S3:
- ✅ 5GB storage
- ✅ 20,000 GET requests/month
- ⚠️ Exceeding: ~$0.023/GB storage, $0.0004/1000 requests

### CloudFront:
- ✅ 50GB data transfer/month
- ✅ 10M requests/month
- ⚠️ Exceeding: ~$0.085/GB

### ECR:
- ✅ 500MB storage/month
- ✅ 500MB data transfer/month
- ⚠️ Exceeding: ~$0.10/GB storage

---

## 🔧 Optimizing for Free Tier

1. **Use db.t3.micro** (not db.t4g.micro) - Free tier eligible
2. **Enable S3 lifecycle policies** - Move old files to cheaper storage
3. **Use CloudFront caching** - Reduce origin requests
4. **Monitor usage** - Set up billing alerts
5. **Consider Lambda** - If App Runner cost is too high

---

## 🚀 Next Steps

1. ✅ **RDS:** Create using workflow or Terraform (FREE)
2. ✅ **S3:** Already created (FREE)
3. ✅ **CloudFront:** Will be created automatically (FREE)
4. ✅ **ECR:** Already created (FREE)
5. ⚠️ **App Runner:** $25/month (or switch to Lambda)

---

## 💡 Cost-Saving Tips

1. **Stop RDS when not in use** (if not needed 24/7)
2. **Use S3 Intelligent-Tiering** (after free tier)
3. **Enable CloudFront compression**
4. **Set up billing alerts** at $10, $25, $50
5. **Review monthly costs** in AWS Cost Explorer

---

## 📊 Estimated Monthly Cost

### Year 1 (Free Tier):
- App Runner: $25
- RDS: $0 (free tier)
- S3: $0 (free tier)
- CloudFront: $0 (free tier)
- ECR: $0 (free tier)
- **Total: ~$25/month**

### Year 2+:
- App Runner: $25
- RDS: $15
- S3: $1-5 (depending on usage)
- CloudFront: $1-10 (depending on traffic)
- ECR: $0-1
- **Total: ~$42-56/month**

---

## 🆘 If You Need to Reduce Costs

### Option 1: Switch to Lambda + API Gateway
- Convert FastAPI to Lambda functions
- Use API Gateway for routing
- **Cost:** ~$0/month (within free tier)

### Option 2: Use EC2 instead of App Runner
- t2.micro instance (free tier eligible)
- Manual deployment
- **Cost:** $0/month (750 hours free)

### Option 3: Use AWS Lightsail
- Fixed pricing: $5-10/month
- Includes compute + database
- **Cost:** $5-10/month

---

## ✅ Current Setup is Free Tier Optimized!

Your current setup uses:
- ✅ RDS db.t3.micro (free tier)
- ✅ S3 (free tier)
- ✅ CloudFront (free tier)
- ✅ ECR (free tier)
- ⚠️ App Runner ($25/month - not free, but reasonable)

**Total cost: ~$25/month** (very reasonable for a production app!)
