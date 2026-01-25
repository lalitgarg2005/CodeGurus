# Deploy Backend to EKS (High-Level Guide)

EKS setup is more complex than EC2. Use EC2 if you want the fastest path. If you still want EKS, follow this guide and I can add automation once the cluster exists.

## ✅ Prerequisites

1. **EKS Cluster**
   - Create via AWS Console or `eksctl`.
2. **kubectl + awscli configured**
3. **ECR repository**
4. **IAM roles** for EKS node group to pull from ECR

## 🚀 Manual Deployment Flow

1. Build and push the backend image to ECR (already done by GitHub Actions).
2. Create a Kubernetes `Deployment` and `Service`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nonprofit-learning-backend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
        - name: backend
          image: <ECR_URI>:latest
          ports:
            - containerPort: 8000
          env:
            - name: DATABASE_URL
              value: "..."
            - name: CLERK_SECRET_KEY
              value: "..."
            - name: CLERK_PUBLISHABLE_KEY
              value: "..."
            - name: CLERK_FRONTEND_API
              value: "..."
            - name: CORS_ORIGINS
              value: "..."
---
apiVersion: v1
kind: Service
metadata:
  name: backend-service
spec:
  type: LoadBalancer
  selector:
    app: backend
  ports:
    - port: 80
      targetPort: 8000
```

3. Apply:
```bash
kubectl apply -f backend.yaml
```

4. Get LoadBalancer URL:
```bash
kubectl get svc backend-service
```

## ✅ Next Steps

If you want EKS automated:
- Tell me your cluster name, region, and kubeconfig setup.
- I will add a GitHub Actions workflow to deploy manifests.
