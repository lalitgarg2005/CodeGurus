# Custom Domain Setup Guide

## Quick Domain Setup Steps

### Step 1: Choose a Domain Name

**Recommended domain registrars:**
- **AWS Route 53** (easiest integration): https://console.aws.amazon.com/route53/home#DomainListing:
- **Namecheap**: https://www.namecheap.com
- **GoDaddy**: https://www.godaddy.com
- **Google Domains**: https://domains.google

**Domain suggestions:**
- `learn-together.org`
- `nonprofit-learning.org`
- `teach-together.com`
- `volunteer-learning.org`

**Cost:** Typically $10-15/year for .org or .com domains

---

### Step 2: Request SSL Certificate (AWS Certificate Manager)

1. **Go to Certificate Manager:**
   - https://console.aws.amazon.com/acm/home?region=us-east-1#/certificates
   - ⚠️ **Important:** Must be in **us-east-1** region for CloudFront

2. **Request Certificate:**
   - Click "Request certificate"
   - Choose "Request a public certificate"
   - Domain names:
     - `yourdomain.com`
     - `*.yourdomain.com` (wildcard for subdomains)
   - Validation method: **DNS validation** (recommended)
   - Click "Request"

3. **Validate Certificate:**
   - Click on your certificate
   - Under "Domains", click "Create record in Route 53" for each domain
   - Or manually add CNAME records to your DNS provider
   - Wait for validation (usually 5-30 minutes)

---

### Step 3: Update CloudFront Distribution

1. **Get your CloudFront Distribution ID:**
   ```bash
   aws cloudfront list-distributions \
     --query "DistributionList.Items[?contains(Origins.Items[0].DomainName, 'nonprofit-learning-frontend')].{Id:Id,DomainName:DomainName}" \
     --output table
   ```

2. **Add Custom Domain:**
   - Go to: CloudFront → Distributions
   - Click on your distribution
   - Go to "General" tab → Click "Edit"
   - **Alternate domain names (CNAMEs):**
     - Add: `yourdomain.com`
     - Add: `www.yourdomain.com`
   - **Custom SSL certificate:**
     - Select your ACM certificate
   - Click "Save changes"

3. **Wait for deployment:**
   - Status will show "In Progress"
   - Takes 5-15 minutes to deploy

---

### Step 4: Configure DNS Records

#### Option A: Using Route 53 (Easiest)

1. **Create Hosted Zone:**
   - Route 53 → Hosted zones → Create hosted zone
   - Domain name: `yourdomain.com`
   - Type: Public hosted zone

2. **Create A Record (Alias):**
   - Click "Create record"
   - Record name: (leave blank for root domain)
   - Record type: A - Routes traffic to an IPv4 address
   - Alias: **Yes**
   - Route traffic to: CloudFront distribution
   - Select your CloudFront distribution
   - Click "Create records"

3. **Create www Record:**
   - Same as above, but record name: `www`

#### Option B: Using External DNS Provider

1. **Get CloudFront Domain:**
   - From CloudFront console, copy your distribution domain
   - Format: `d1234567890.cloudfront.net`

2. **Add CNAME Records:**
   - Go to your domain registrar's DNS settings
   - Add CNAME:
     - Name: `@` (or root domain)
     - Value: `d1234567890.cloudfront.net`
     - TTL: 300 (or default)
   - Add another CNAME:
     - Name: `www`
     - Value: `d1234567890.cloudfront.net`
     - TTL: 300

---

### Step 5: Update Application Configuration

1. **Update GitHub Secrets:**
   - Go to: GitHub → Your repo → Settings → Secrets
   - Update `CORS_ORIGINS` to include your domain:
     ```
     https://yourdomain.com,https://www.yourdomain.com
     ```

2. **Update Frontend Environment:**
   - The frontend will automatically use the domain once DNS is configured
   - No code changes needed if using environment variables

3. **Update App Runner (if needed):**
   - App Runner → Your service → Configuration → Edit
   - Update `CORS_ORIGINS` environment variable
   - Save and deploy

---

### Step 6: Test Your Domain

1. **Wait for DNS propagation:**
   - Usually 5-60 minutes
   - Can take up to 48 hours in rare cases
   - Check: https://www.whatsmydns.net

2. **Test HTTPS:**
   - `https://yourdomain.com`
   - `https://www.yourdomain.com`
   - Should redirect to HTTPS automatically

3. **Verify SSL:**
   - Check SSL certificate: https://www.ssllabs.com/ssltest/
   - Should show valid certificate

---

## Quick Setup Script

Run this to get your CloudFront distribution ID:

```bash
# Get CloudFront distribution
aws cloudfront list-distributions \
  --query "DistributionList.Items[?contains(Origins.Items[0].DomainName, 'nonprofit-learning-frontend')].{Id:Id,DomainName:DomainName,Status:Status}" \
  --output table
```

---

## Cost Estimate

- **Domain:** $10-15/year
- **SSL Certificate:** Free (AWS ACM)
- **Route 53:** $0.50/month per hosted zone
- **CloudFront:** Pay per use (usually $1-10/month for small traffic)
- **Total:** ~$15-25/year + usage

---

## Troubleshooting

### Domain not resolving:
- Check DNS records are correct
- Wait for DNS propagation
- Verify CNAME points to CloudFront domain

### SSL certificate errors:
- Ensure certificate is in us-east-1 region
- Verify certificate is validated
- Check CloudFront has the certificate selected

### CloudFront not serving content:
- Verify distribution is "Deployed"
- Check S3 bucket policy allows CloudFront
- Verify origin is correct

---

## Next Steps After Domain Setup

1. ✅ Test domain accessibility
2. ✅ Update CORS_ORIGINS in GitHub Secrets
3. ✅ Update App Runner environment variables
4. ✅ Test full application flow
5. ✅ Set up monitoring and alerts
