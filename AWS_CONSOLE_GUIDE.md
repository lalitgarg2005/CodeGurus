# AWS Console Guide - Accessing Your Deployed Application

## 🎉 Deployment Successful!

Your application has been deployed to AWS. Here's how to verify everything and access it.

## 📍 Where to Check AWS Services

### 1. **ECR (Elastic Container Registry) - Backend Images**

**Location:** AWS Console → ECR → Repositories

**What to check:**
- Repository name: `nonprofit-learning-backend`
- Should see Docker images with tags (latest, and commit SHA)
- Image URI format: `ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/nonprofit-learning-backend:latest`

**Direct link:** https://console.aws.amazon.com/ecr/repositories?region=us-east-1

---

### 2. **App Runner - Backend Service**

**Location:** AWS Console → App Runner → Services

**What to check:**
- Service name: `nonprofit-learning-backend`
- Status: Should be "Running" (green)
- Service URL: This is your backend API endpoint!
  - Format: `https://xxxxx.us-east-1.awsapprunner.com`
- Check logs: Click on service → Logs tab

**Direct link:** https://console.aws.amazon.com/apprunner/home?region=us-east-1#/services

**To find your backend URL:**
1. Go to App Runner → Services
2. Click on `nonprofit-learning-backend`
3. Copy the "Service URL" (this is your API endpoint)
4. Test it: `https://YOUR-SERVICE-URL/health`

---

### 3. **S3 - Frontend Static Files**

**Location:** AWS Console → S3 → Buckets

**What to check:**
- Bucket name: `nonprofit-learning-frontend`
- Should contain files in folders: `_next/static`, `public/`, etc.
- Check bucket policy and public access settings

**Direct link:** https://s3.console.aws.amazon.com/s3/buckets?region=us-east-1

**To access frontend via S3:**
- S3 website endpoint: `http://nonprofit-learning-frontend.s3-website-us-east-1.amazonaws.com`
- Note: This may not work if CloudFront is configured

---

### 4. **CloudFront - CDN for Frontend**

**Location:** AWS Console → CloudFront → Distributions

**What to check:**
- Distribution status: Should be "Deployed"
- Domain name: This is your frontend URL!
  - Format: `d1234567890.cloudfront.net`
- Origin: Should point to S3 bucket
- Check if distribution is enabled

**Direct link:** https://console.aws.amazon.com/cloudfront/v3/home#/distributions

**To find your frontend URL:**
1. Go to CloudFront → Distributions
2. Find your distribution (or create one if missing)
3. Copy the "Domain name"
4. Access: `https://YOUR-CLOUDFRONT-DOMAIN.cloudfront.net`

---

### 5. **RDS - Database (if created)**

**Location:** AWS Console → RDS → Databases

**What to check:**
- Database identifier: `nonprofit-learning-db` (if created via Terraform)
- Status: Should be "Available"
- Endpoint: This is your DATABASE_URL host
- Security groups: Should allow App Runner access

**Direct link:** https://console.aws.amazon.com/rds/home?region=us-east-1#databases:

**To get DATABASE_URL:**
- Format: `postgresql://username:password@ENDPOINT:5432/nonprofit_learning`
- Endpoint format: `xxxxx.xxxxx.us-east-1.rds.amazonaws.com`

---

## 🌐 Accessing Your Application

### Backend API

1. **Find your App Runner service URL:**
   - Go to: App Runner → Services → `nonprofit-learning-backend`
   - Copy the "Service URL"

2. **Test endpoints:**
   - Health check: `https://YOUR-APP-RUNNER-URL/health`
   - API docs: `https://YOUR-APP-RUNNER-URL/api/v1/docs`
   - API health: `https://YOUR-APP-RUNNER-URL/api/v1/health`

### Frontend Application

1. **If CloudFront is set up:**
   - Use CloudFront domain: `https://YOUR-CLOUDFRONT-DOMAIN.cloudfront.net`

2. **If CloudFront is not set up:**
   - Use S3 website endpoint: `http://nonprofit-learning-frontend.s3-website-us-east-1.amazonaws.com`
   - Or set up CloudFront (see below)

---

## 🔧 Setting Up CloudFront (if not already done)

If you don't have a CloudFront distribution:

1. **Go to CloudFront Console:**
   - https://console.aws.amazon.com/cloudfront/v3/home#/distributions

2. **Create Distribution:**
   - Click "Create distribution"
   - Origin domain: Select your S3 bucket (`nonprofit-learning-frontend.s3.us-east-1.amazonaws.com`)
   - Origin access: Select "Origin access control settings (recommended)"
   - Default root object: `index.html`
   - Viewer protocol policy: "Redirect HTTP to HTTPS"
   - Click "Create distribution"

3. **Wait for deployment:**
   - Status will change from "In Progress" to "Deployed" (takes 5-15 minutes)
   - Copy the domain name

4. **Update S3 bucket policy:**
   - Go to S3 → `nonprofit-learning-frontend` → Permissions
   - Add bucket policy to allow CloudFront access (AWS will provide this)

---

## 🌍 Setting Up a Custom Domain

### Option 1: Using CloudFront (Recommended)

1. **Get a Domain:**
   - Buy from Route 53, Namecheap, GoDaddy, etc.
   - Example: `learn-together.org`, `nonprofit-learning.com`

2. **Request SSL Certificate:**
   - Go to: AWS Console → Certificate Manager (ACM)
   - Region: **us-east-1** (required for CloudFront)
   - Click "Request certificate"
   - Domain name: `yourdomain.com` and `*.yourdomain.com` (wildcard)
   - Validation: DNS validation (recommended)
   - Follow DNS validation steps

3. **Add Domain to CloudFront:**
   - Go to CloudFront → Your distribution → General tab
   - Click "Edit"
   - Alternate domain names (CNAMEs): Add `yourdomain.com` and `www.yourdomain.com`
   - SSL certificate: Select your ACM certificate
   - Save changes

4. **Update DNS Records:**
   - Go to your domain registrar (Route 53, Namecheap, etc.)
   - Add CNAME record:
     - Name: `@` (or root domain)
     - Value: Your CloudFront domain (e.g., `d1234567890.cloudfront.net`)
   - Add another CNAME for www:
     - Name: `www`
     - Value: Same CloudFront domain

5. **Wait for DNS propagation:**
   - Usually takes 5-60 minutes
   - Test: `https://yourdomain.com`

### Option 2: Using Route 53 (AWS Native)

1. **Register/Buy Domain:**
   - Go to: Route 53 → Registered domains
   - Click "Register domain" or transfer existing domain

2. **Create Hosted Zone:**
   - Route 53 → Hosted zones
   - Create hosted zone for your domain

3. **Request Certificate:**
   - Same as Option 1, step 2

4. **Add CloudFront Distribution:**
   - Same as Option 1, step 3

5. **Create Route 53 Records:**
   - Route 53 → Hosted zones → Your domain
   - Create A record (Alias):
     - Name: (leave blank for root, or `www`)
     - Type: A - IPv4 address
     - Alias: Yes
     - Route traffic to: CloudFront distribution
     - Select your distribution

---

## 📝 Quick Checklist

### Verify Deployment:

- [ ] ECR repository exists with images
- [ ] App Runner service is "Running"
- [ ] Backend API responds at `/health`
- [ ] S3 bucket has frontend files
- [ ] CloudFront distribution is "Deployed" (if configured)
- [ ] Frontend is accessible via CloudFront URL
- [ ] RDS database is "Available" (if created)

### For Custom Domain:

- [ ] Domain purchased/registered
- [ ] SSL certificate requested and validated
- [ ] CloudFront distribution updated with domain
- [ ] DNS records configured
- [ ] Domain accessible via browser

---

## 🔗 Quick Links

- **ECR:** https://console.aws.amazon.com/ecr/repositories?region=us-east-1
- **App Runner:** https://console.aws.amazon.com/apprunner/home?region=us-east-1#/services
- **S3:** https://s3.console.aws.amazon.com/s3/buckets?region=us-east-1
- **CloudFront:** https://console.aws.amazon.com/cloudfront/v3/home#/distributions
- **RDS:** https://console.aws.amazon.com/rds/home?region=us-east-1#databases:
- **Route 53:** https://console.aws.amazon.com/route53/v2/home#Dashboard
- **Certificate Manager:** https://console.aws.amazon.com/acm/home?region=us-east-1#/certificates

---

## 🆘 Troubleshooting

### Backend not accessible:
- Check App Runner service status
- Check service logs in App Runner console
- Verify DATABASE_URL is set in App Runner environment variables
- Check security groups allow traffic

### Frontend not loading:
- Verify S3 bucket has files
- Check CloudFront distribution status
- Verify S3 bucket policy allows CloudFront
- Check browser console for errors

### Domain not working:
- Verify DNS records are correct
- Check SSL certificate is validated
- Wait for DNS propagation (can take up to 48 hours)
- Verify CloudFront has the domain in alternate domain names

---

## 📞 Next Steps

1. **Test your backend:** Access App Runner URL + `/health`
2. **Test your frontend:** Access CloudFront URL
3. **Update GitHub Secrets:** Add `NEXT_PUBLIC_API_URL` with your App Runner URL
4. **Set up domain:** Follow the custom domain steps above
5. **Monitor:** Set up CloudWatch alarms for monitoring
