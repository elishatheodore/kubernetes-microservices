# Azure Kubernetes Service (AKS) Deployment Guide

This guide provides comprehensive instructions for deploying the Cloud Asset Management Platform (CAMP) to Azure Kubernetes Service (AKS).

## 📋 Prerequisites

### Required Tools
- **Azure CLI** - Install from [Microsoft Docs](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- **kubectl** - Install with `az aks install-cli`
- **Docker** - For building and pushing images
- **Git** - For version control

### Azure Requirements
- Azure subscription with Owner role
- Resource group permissions
- Container registry access

## 🚀 Quick Start

### 1. Clone and Prepare
```bash
git clone <your-repo-url>
cd kubernetes-microservices/k8s
chmod +x deploy.sh cleanup.sh
```

### 2. Configure Variables
Edit `deploy.sh` and update these variables:
```bash
CLUSTER_NAME="camp-aks-cluster"
RESOURCE_GROUP="camp-rg"
LOCATION="eastus"
DNS_NAME="camp.yourdomain.com"  # Update with your domain
```

### 3. Deploy to AKS
```bash
./deploy.sh
```

## 📁 Kubernetes Manifests

### Core Resources
- **namespace.yaml** - Isolated namespace for CAMP
- **configmap.yaml** - Application configuration
- **secret.yaml** - Sensitive data (passwords, tokens)
- **persistent-volumes.yaml** - Storage for uploads and database

### Application Deployments
- **backend-deployment.yaml** - FastAPI backend service
- **web-frontend-deployment.yaml** - Main web application
- **auth-frontend-deployment.yaml** - Authentication service

### Networking
- **ingress.yaml** - External access with SSL/TLS
- **network-policy.yaml** - Network security rules

### Scaling & Resources
- **horizontal-pod-autoscaler.yaml** - Auto-scaling policies
- **resource-quota.yaml** - Resource limits and quotas

### Monitoring
- **monitoring.yaml** - Prometheus monitoring setup
- **kustomization.yaml** - Kustomize configuration

## 🔧 Configuration

### Environment Variables
| Variable | Description | Default |
|----------|-------------|---------|
| `DATABASE_URL` | SQLite database path | `sqlite:///./camp.db` |
| `DEBUG` | Debug mode | `false` |
| `LOG_LEVEL` | Logging level | `info` |
| `SECRET_KEY` | Application secret | Base64 encoded |
| `JWT_SECRET` | JWT signing secret | Base64 encoded |

### Resource Allocation
| Component | CPU Request | Memory Request | CPU Limit | Memory Limit |
|-----------|-------------|----------------|-----------|-------------|
| Backend | 250m | 256Mi | 500m | 512Mi |
| Web Frontend | 100m | 128Mi | 200m | 256Mi |
| Auth Frontend | 100m | 128Mi | 200m | 256Mi |

### Storage
- **Uploads PVC**: 10Gi for file storage
- **Database PVC**: 1Gi for SQLite database

## 🌐 Access URLs

After deployment, access the application at:
- **Main Application**: `http://<ingress-ip>`
- **Auth Frontend**: `http://<ingress-ip>/auth`
- **Backend API**: `http://<ingress-ip>/api`
- **API Documentation**: `http://<ingress-ip>/api/docs`

## 📊 Monitoring & Logging

### Prometheus Metrics
All services expose metrics on `/metrics` endpoint:
- Request count and duration
- Error rates
- Resource usage
- Custom business metrics

### Logs
```bash
# View all logs
kubectl logs -f -n camp deployment/camp-backend

# View specific pod logs
kubectl logs -f -n camp <pod-name>

# View previous logs
kubectl logs -p -n camp deployment/camp-backend
```

### Health Checks
- **Liveness Probe**: `/test` endpoint
- **Readiness Probe**: `/health` endpoint
- **Startup Probe**: Container startup verification

## 🔒 Security

### Network Policies
- Default deny all traffic
- Allow intra-namespace communication
- Allow ingress from nginx controller
- Allow DNS and HTTPS egress

### Secrets Management
- Base64 encoded secrets in Kubernetes
- Separate secret for sensitive data
- No secrets in ConfigMaps

### RBAC
- Namespace isolation
- Resource quotas
- Network segmentation

## 🚀 Scaling

### Horizontal Pod Autoscaling
- **Backend**: 2-10 replicas based on CPU/Memory
- **Frontend**: 2-5 replicas based on CPU
- **Auth**: 2-5 replicas based on CPU

### Manual Scaling
```bash
# Scale backend to 5 replicas
kubectl scale deployment camp-backend --replicas=5 -n camp

# Scale all services
kubectl scale deployment --all --replicas=3 -n camp
```

### Cluster Autoscaling
AKS cluster auto-scales from 2 to 5 nodes based on pod resource requests.

## 🔄 Updates & Deployments

### Rolling Updates
```bash
# Update image version
kubectl set image deployment/camp-backend camp-backend=ghcr.io/elishatheodore/kubernetes-microservices/camp-backend:v1.1.0 -n camp

# Apply configuration changes
kubectl apply -k .
```

### Rollback
```bash
# View rollout history
kubectl rollout history deployment/camp-backend -n camp

# Rollback to previous version
kubectl rollout undo deployment/camp-backend -n camp
```

### Blue-Green Deployment
```bash
# Deploy new version
kubectl apply -f new-version.yaml

# Switch traffic
kubectl patch service camp-backend-service -p '{"spec":{"selector":{"version":"v2"}}}' -n camp
```

## 🛠 Troubleshooting

### Common Issues

#### Pod Not Starting
```bash
# Check pod status
kubectl get pods -n camp -o wide

# Describe pod
kubectl describe pod <pod-name> -n camp

# Check logs
kubectl logs <pod-name> -n camp
```

#### Service Not Accessible
```bash
# Check service endpoints
kubectl get endpoints -n camp

# Check ingress
kubectl describe ingress camp-ingress -n camp

# Check nginx logs
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller
```

#### Storage Issues
```bash
# Check PVC status
kubectl get pvc -n camp

# Check storage class
kubectl get storageclass

# Check PV binding
kubectl describe pv
```

### Performance Issues
```bash
# Check resource usage
kubectl top pods -n camp
kubectl top nodes

# Check HPA status
kubectl get hpa -n camp
```

## 🗑️ Cleanup

### Remove Application Only
```bash
./cleanup.sh
```

### Remove Everything
```bash
# Delete namespace
kubectl delete namespace camp

# Delete resource group
az group delete --name camp-rg --yes
```

## 📚 Advanced Topics

### Canary Deployments
```bash
# Deploy canary
kubectl apply -f canary-deployment.yaml

# Split traffic (20% to canary)
kubectl patch service camp-backend-service -p '{"spec":{"selector":{"version":"canary"}}}' -n camp
```

### GitOps with ArgoCD
```bash
# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Create application
kubectl apply -f argocd-application.yaml
```

### Backup & Restore
```bash
# Backup etcd
az aks snapshot create --resource-group camp-rg --name camp-backup --cluster-name camp-aks-cluster

# Restore from backup
az aks snapshot restore --resource-group camp-rg --name camp-restore --cluster-name camp-aks-cluster --snapshot-id <snapshot-id>
```

## 📞 Support

### Azure Support
- **AKS Documentation**: [Microsoft Docs](https://docs.microsoft.com/en-us/azure/aks/)
- **Azure CLI Reference**: [CLI Commands](https://docs.microsoft.com/en-us/cli/azure/aks)
- **Azure Status**: [Service Health](https://status.azure.com/)

### Kubernetes Resources
- **Kubernetes Docs**: [kubernetes.io](https://kubernetes.io/docs/)
- **kubectl Cheat Sheet**: [Reference](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands)

### Project Support
- **Issues**: GitHub Repository Issues
- **Documentation**: Project README.md
- **Container Registry**: GitHub Packages

---

**Version**: 1.0.0  
**Last Updated**: 2026-04-04  
**Status**: Production Ready for AKS
