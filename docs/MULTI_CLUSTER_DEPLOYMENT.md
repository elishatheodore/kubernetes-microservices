# Multi-Cluster Deployment Guide

This comprehensive guide covers deploying the CAMP platform across multiple Kubernetes clusters and environments using Helm, CI/CD, and GitOps.

## 🎯 Overview

The CAMP platform supports deployment across multiple Kubernetes clusters with full parameterization, enabling:
- Multi-cloud deployment (AKS, EKS, GKE, local)
- Environment-specific configurations
- Automated CI/CD pipelines
- GitOps-based deployments
- Zero-touch production deployments

## 📁 Architecture

```
kubernetes-microservices/
├── environments/              # Environment-specific values
│   ├── values-dev.yaml       # Development configuration
│   ├── values-staging.yaml   # Staging configuration
│   └── values-prod.yaml      # Production configuration
├── clusters/                  # Cluster definitions
│   └── cluster-config.yaml   # All cluster configurations
├── scripts/                   # Management scripts
│   ├── deploy.sh             # Multi-cluster deployment
│   └── cluster-manager.sh    # Cluster management
├── ci-cd/                     # CI/CD pipelines
│   └── github-actions/
│       └── build-and-deploy.yml
├── gitops/                    # GitOps configurations
│   ├── argocd/
│   │   └── application.yaml
│   └── flux/
│       ├── kustomization.yaml
│       └── gitrepository.yaml
└── helm/                      # Helm charts
    └── camp/                  # Main application chart
```

## 🚀 Quick Start

### 1. Prerequisites

```bash
# Install required tools
# Helm
curl https://get.helm.sh/helm-v3.12.0-linux-amd64.tar.gz | tar xz
sudo mv linux-amd64/helm /usr/local/bin/

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# yq (for YAML processing)
sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
sudo chmod +x /usr/local/bin/yq

# Azure CLI (for AKS)
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

### 2. Configure Clusters

Edit `clusters/cluster-config.yaml` to define your clusters:

```yaml
clusters:
  local-dev:
    name: local-dev
    type: local
    provider: minikube
    context: minikube
    namespace: camp-dev
    environments: [dev]
    
  aks-prod:
    name: aks-prod
    type: managed
    provider: azure
    region: eastus
    resourceGroup: camp-prod-rg
    clusterName: camp-prod-aks
    context: camp-prod-aks
    namespace: camp-prod
    environments: [prod]
```

### 3. Deploy to Cluster

```bash
# Make scripts executable
chmod +x scripts/*.sh

# Deploy to development cluster
./scripts/deploy.sh -c local-dev -e dev

# Deploy to staging with specific tag
./scripts/deploy.sh -c aks-staging -e staging -t v1.0.0

# Deploy to production
./scripts/deploy.sh -c aks-prod -e prod -t v1.0.0 -f
```

## 🔧 Configuration Management

### Environment Configuration

Each environment has its own configuration file:

#### Development (`environments/values-dev.yaml`)
```yaml
environment: development
replicaCount:
  backend: 1
  web: 1
  auth: 1
resources:
  backend:
    requests:
      memory: "128Mi"
      cpu: "100m"
    limits:
      memory: "256Mi"
      cpu: "200m"
ingress:
  hosts:
    - host: camp-dev.local
```

#### Staging (`environments/values-staging.yaml`)
```yaml
environment: staging
replicaCount:
  backend: 2
  web: 2
  auth: 2
resources:
  backend:
    requests:
      memory: "256Mi"
      cpu: "250m"
    limits:
      memory: "512Mi"
      cpu: "500m"
ingress:
  hosts:
    - host: camp-staging.yourdomain.com
```

#### Production (`environments/values-prod.yaml`)
```yaml
environment: production
replicaCount:
  backend: 3
  web: 3
  auth: 2
resources:
  backend:
    requests:
      memory: "512Mi"
      cpu: "500m"
    limits:
      memory: "1Gi"
      cpu: "1000m"
ingress:
  hosts:
    - host: camp.yourdomain.com
```

### Cluster Configuration

Define all your clusters in `clusters/cluster-config.yaml`:

```yaml
clusters:
  # Local development
  local-dev:
    name: local-dev
    type: local
    provider: minikube
    region: local
    context: minikube
    namespace: camp-dev
    environments: [dev]
    capabilities:
      - loadbalancer
      - ingress
      - persistent-storage
    
  # AKS production
  aks-prod:
    name: aks-prod
    type: managed
    provider: azure
    region: eastus
    resourceGroup: camp-prod-rg
    clusterName: camp-prod-aks
    context: camp-prod-aks
    namespace: camp-prod
    environments: [prod]
    capabilities:
      - loadbalancer
      - ingress
      - persistent-storage
      - autoscaling
      - monitoring
      - aad-pod-identity
```

## 📋 Deployment Methods

### 1. Manual Deployment

Using the deployment script:

```bash
# Basic deployment
./scripts/deploy.sh -c <cluster> -e <environment>

# With custom image tag
./scripts/deploy.sh -c aks-prod -e prod -t v1.0.0

# Dry run (preview only)
./scripts/deploy.sh -c aks-prod -e prod --dry-run

# Force upgrade
./scripts/deploy.sh -c aks-prod -e prod -f
```

### 2. Cluster Management

Using the cluster manager script:

```bash
# List all clusters
./scripts/cluster-manager.sh list

# Show cluster details
./scripts/cluster-manager.sh details aks-prod

# Switch cluster context
./scripts/cluster-manager.sh switch aks-prod

# Test cluster connectivity
./scripts/cluster-manager.sh test aks-prod

# Show cluster status
./scripts/cluster-manager.sh status aks-prod

# Validate all configurations
./scripts/cluster-manager.sh validate
```

### 3. CI/CD Deployment

#### GitHub Actions

The project includes a comprehensive GitHub Actions workflow:

```yaml
# .github/workflows/build-and-deploy.yml
name: Build and Deploy CAMP Platform

on:
  push:
    branches: [ main, develop ]
    tags: [ 'v*' ]
  workflow_dispatch:
    inputs:
      cluster:
        description: 'Target cluster'
        type: choice
        options: [local-dev, aks-dev, aks-staging, aks-prod]
      environment:
        description: 'Target environment'
        type: choice
        options: [dev, staging, prod]
      deploy:
        description: 'Deploy after build'
        type: boolean
        default: false
```

**Features:**
- Multi-architecture builds (AMD64/ARM64)
- Security scanning with Trivy
- Helm chart validation
- Automated deployments
- Manual deployment triggers

### 4. GitOps Deployment

#### ArgoCD

```yaml
# gitops/argocd/application.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: camp-prod
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/elishatheodore/kubernetes-microservices.git
    targetRevision: main
    path: helm/camp
    helm:
      valueFiles:
        - values.yaml
        - ../../environments/values-prod.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: camp-prod
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

#### Flux CD

```yaml
# gitops/flux/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
metadata:
  name: camp-prod
  namespace: flux-system
spec:
  interval: 10m
  path: ./helm/camp
  prune: false
  sourceRef:
    kind: GitRepository
    name: camp-repo
  helm:
    valueFiles:
      - values.yaml
      - ../../environments/values-prod.yaml
    releaseName: camp-prod
    targetNamespace: camp-prod
```

## 🌍 Multi-Cloud Support

### Azure Kubernetes Service (AKS)

```bash
# Create AKS cluster
az group create --name camp-prod-rg --location eastus
az aks create \
  --resource-group camp-prod-rg \
  --name camp-prod-aks \
  --node-count 3 \
  --enable-cluster-autoscaler \
  --min-count 2 \
  --max-count 5 \
  --network-plugin azure \
  --generate-ssh-keys

# Get credentials
az aks get-credentials \
  --resource-group camp-prod-rg \
  --name camp-prod-aks \
  --overwrite-existing

# Deploy
./scripts/deploy.sh -c aks-prod -e prod
```

### Amazon EKS

```bash
# Create EKS cluster
aws eks create-cluster \
  --name camp-prod-eks \
  --region us-east-1 \
  --kubernetes-version 1.28 \
  --nodegroup-name standard-workers \
  --node-type t3.medium \
  --nodes 3 \
  --nodes-min 1 \
  --nodes-max 4 \
  --managed

# Update kubeconfig
aws eks update-kubeconfig \
  --region us-east-1 \
  --name camp-prod-eks

# Deploy
./scripts/deploy.sh -c eks-prod -e prod
```

### Google GKE

```bash
# Create GKE cluster
gcloud container clusters create camp-prod-gke \
  --region us-central1 \
  --num-nodes 3 \
  --enable-autoscaling \
  --min-nodes 1 \
  --max-nodes 5 \
  --enable-autorepair

# Get credentials
gcloud container clusters get-credentials camp-prod-gke \
  --region us-central1

# Deploy
./scripts/deploy.sh -c gke-prod -e prod
```

### Local Development

#### Minikube

```bash
# Start Minikube
minikube start --cpus 4 --memory 8192

# Enable ingress
minikube addons enable ingress

# Deploy
./scripts/deploy.sh -c local-dev -e dev
```

#### K3s

```bash
# Install K3s
curl -sfL https://get.k3s.io | sh -

# Get kubeconfig
sudo cat /etc/rancher/k3s/k3s.yaml > ~/.kube/config-k3s
export KUBECONFIG=~/.kube/config-k3s

# Deploy
./scripts/deploy.sh -c local-k3s -e dev
```

## 🔒 Security Best Practices

### Secrets Management

```yaml
# Use external secrets in production
secrets:
  secretKey: "production-secret-key"  # Use external secret management
  jwtSecret: "production-jwt-secret"
  defaultPassword: "change-this-immediately"
```

### Network Policies

```yaml
# Enable network policies in production
networkPolicy:
  enabled: true
  ingress:
    - from:
      - namespaceSelector:
          matchLabels:
            name: ingress-nginx
  egress:
    - to: []
      ports:
      - protocol: TCP
        port: 443
```

### Resource Limits

```yaml
# Always set resource limits
resources:
  backend:
    requests:
      memory: "512Mi"
      cpu: "500m"
    limits:
      memory: "1Gi"
      cpu: "1000m"
```

## 📊 Monitoring and Observability

### Prometheus Integration

```yaml
# Enable monitoring in production
monitoring:
  enabled: true
  serviceMonitor:
    enabled: true
    interval: 30s
    scrapeTimeout: 10s
    path: /metrics
```

### Health Checks

```yaml
# Comprehensive health checks
livenessProbe:
  httpGet:
    path: /test
    port: http
  initialDelaySeconds: 30
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 3

readinessProbe:
  httpGet:
    path: /health
    port: http
  initialDelaySeconds: 5
  periodSeconds: 5
  timeoutSeconds: 3
  failureThreshold: 3
```

## 🔄 Rollback and Recovery

### Manual Rollback

```bash
# List release history
helm history camp-prod -n camp-prod

# Rollback to previous version
helm rollback camp-prod 1 -n camp-prod

# Rollback with Helm
helm rollback camp-prod REVISION -n NAMESPACE
```

### GitOps Rollback

```bash
# For ArgoCD
argocd app rollback camp-prod -n argocd

# For Flux
git revert <commit-hash>
git push origin main
```

## 🧪 Testing and Validation

### Pre-deployment Validation

```bash
# Validate cluster configuration
./scripts/cluster-manager.sh validate

# Test cluster connectivity
./scripts/cluster-manager.sh test aks-prod

# Lint Helm chart
helm lint helm/camp

# Dry run deployment
./scripts/deploy.sh -c aks-prod -e prod --dry-run
```

### Post-deployment Testing

```bash
# Verify deployment
kubectl get pods -n camp-prod
kubectl get services -n camp-prod
kubectl get ingress -n camp-prod

# Run smoke tests
curl -f https://camp.yourdomain.com/api/test
curl -f https://camp.yourdomain.com/api/health
curl -f https://camp.yourdomain.com/
curl -f https://camp.yourdomain.com/auth
```

## 🚨 Troubleshooting

### Common Issues

#### 1. Cluster Not Found
```bash
# Check available clusters
./scripts/cluster-manager.sh list

# Verify kubeconfig
kubectl config get-contexts
```

#### 2. Environment Not Supported
```bash
# Check supported environments
./scripts/cluster-manager.sh details aks-prod
```

#### 3. Image Pull Issues
```bash
# Check image registry access
docker pull ghcr.io/elishatheodore/kubernetes-microservices/camp-backend:latest

# Check image pull secrets
kubectl get secret ghcr-secret -n camp-prod
```

#### 4. Resource Limits
```bash
# Check resource quotas
kubectl describe quota -n camp-prod

# Check resource usage
kubectl top nodes
kubectl top pods -n camp-prod
```

### Debug Commands

```bash
# Show deployment status
./scripts/deploy.sh -c aks-prod -e prod --dry-run

# Check pod logs
kubectl logs -f deployment/camp-prod-backend -n camp-prod

# Describe pod
kubectl describe pod <pod-name> -n camp-prod

# Check events
kubectl get events -n camp-prod --sort-by=.metadata.creationTimestamp
```

## 📚 Advanced Topics

### Custom Values Override

```yaml
# custom-values.yaml
replicaCount:
  backend: 5
  web: 3
  auth: 2

ingress:
  hosts:
    - host: camp-custom.yourdomain.com

secrets:
  secretKey: "custom-secret-key"
```

```bash
# Deploy with custom values
./scripts/deploy.sh -c aks-prod -e prod \
  --values custom-values.yaml
```

### Multi-Region Deployment

```yaml
# Define multiple production clusters
clusters:
  aks-prod-eastus:
    name: aks-prod-eastus
    region: eastus
    environments: [prod]
    
  aks-prod-westus:
    name: aks-prod-westus
    region: westus
    environments: [prod]
```

### Canary Deployments

```bash
# Deploy canary version
./scripts/deploy.sh -c aks-prod -e prod \
  --set image.tag=v1.1.0-canary \
  --set replicaCount.backend=1 \
  --set ingress.annotations."nginx\.ingress\.kubernetes\.io/canary"="true" \
  --set ingress.annotations."nginx\.ingress\.kubernetes\.io/canary-weight"="10"
```

## 🎯 Best Practices

1. **Always use environment-specific values files**
2. **Never hardcode secrets in values files**
3. **Enable resource limits in production**
4. **Use network policies for security**
5. **Implement proper monitoring and alerting**
6. **Test in staging before production**
7. **Use GitOps for production deployments**
8. **Regular backup of persistent data**
9. **Implement proper CI/CD pipelines**
10. **Document your deployment processes**

---

**Version**: 1.0.0  
**Last Updated**: 2026-04-05  
**Status**: Production Ready
