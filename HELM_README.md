# Helm Chart for CAMP Platform

This document provides comprehensive information about the Helm chart for deploying the Cloud Asset Management Platform (CAMP) to Kubernetes clusters.

## 📋 Prerequisites

- **Helm 3.x** - Package manager for Kubernetes
- **kubectl** - Kubernetes command line tool
- **Kubernetes cluster** - AKS, EKS, GKE, or local cluster
- **Container registry access** - To pull CAMP images

## 🚀 Quick Start

### 1. Clone Repository
```bash
git clone https://github.com/elishatheodore/kubernetes-microservices.git
cd kubernetes-microservices/helm
```

### 2. Deploy with Default Values
```bash
./deploy-helm.sh
```

### 3. Deploy with Environment-Specific Values
```bash
# Development
./deploy-helm.sh -f camp/values-dev.yaml

# Production
./deploy-helm.sh -f camp/values-prod.yaml
```

### 4. Verify Deployment
```bash
helm status camp-release -n camp
kubectl get pods -n camp
```

## 📁 Chart Structure

```
helm/camp/
├── Chart.yaml              # Chart metadata and dependencies
├── values.yaml             # Default configuration values
├── values-dev.yaml         # Development-specific values
├── values-prod.yaml        # Production-specific values
├── deploy-helm.sh          # Automated deployment script
└── templates/
    ├── _helpers.tpl        # Template helpers and functions
    ├── deployment.yaml     # Application deployments
    ├── service.yaml        # Service definitions
    ├── ingress.yaml        # Ingress configuration
    ├── configmap.yaml      # Configuration maps
    ├── secret.yaml         # Encrypted secrets
    ├── pvc.yaml           # Persistent volume claims
    ├── hpa.yaml           # Horizontal pod autoscalers
    ├── resourcequota.yaml  # Resource quotas and limits
    ├── networkpolicy.yaml  # Network security policies
    ├── monitoring.yaml     # Prometheus monitoring
    ├── serviceaccount.yaml # Service accounts
    └── notes.txt          # Installation notes
```

## ⚙️ Configuration

### Global Settings
```yaml
global:
  imageRegistry: ghcr.io
  imagePullSecrets: []
  storageClass: default
```

### Image Configuration
```yaml
image:
  registry: ghcr.io
  repository: elishatheodore/kubernetes-microservices
  pullPolicy: IfNotPresent
  tag: "latest"
```

### Replica Configuration
```yaml
replicaCount:
  backend: 2
  web: 2
  auth: 2
```

### Ingress Configuration
```yaml
ingress:
  enabled: true
  className: nginx
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
  hosts:
    - host: camp.yourdomain.com
      paths:
        - path: /api(/|$)(.*)
          service: backend
        - path: /auth(/|$)(.*)
          service: auth
        - path: /(.*)
          service: web
  tls:
    - secretName: camp-tls
      hosts:
        - camp.yourdomain.com
```

### Resource Configuration
```yaml
backend:
  resources:
    requests:
      memory: "256Mi"
      cpu: "250m"
    limits:
      memory: "512Mi"
      cpu: "500m"
  autoscaling:
    enabled: true
    minReplicas: 2
    maxReplicas: 10
    targetCPUUtilizationPercentage: 70
```

### Storage Configuration
```yaml
backend:
  persistence:
    uploads:
      enabled: true
      storageClass: default
      accessMode: ReadWriteOnce
      size: 10Gi
      mountPath: /app/uploads
    database:
      enabled: true
      storageClass: default
      accessMode: ReadWriteOnce
      size: 1Gi
      mountPath: /app/camp.db
      subPath: camp.db
```

## 🔧 Environment-Specific Values

### Development (values-dev.yaml)
- **Replicas**: 1 per service
- **Resources**: Minimal allocation
- **Debug**: Enabled
- **Monitoring**: Disabled
- **Network Policies**: Disabled
- **TLS**: Disabled

### Production (values-prod.yaml)
- **Replicas**: 3+ for backend, 2+ for frontends
- **Resources**: High allocation
- **Debug**: Disabled
- **Monitoring**: Enabled with Prometheus
- **Network Policies**: Enabled
- **TLS**: Enabled with cert-manager
- **Security**: Enhanced with rate limiting and ModSecurity

## 📊 Monitoring and Observability

### Prometheus Integration
```yaml
monitoring:
  enabled: true
  serviceMonitor:
    enabled: true
    interval: 30s
    scrapeTimeout: 10s
    path: /metrics
  podMonitor:
    enabled: true
    interval: 30s
    scrapeTimeout: 10s
    path: /metrics
```

### Health Checks
All services include comprehensive health checks:
- **Liveness Probe**: `/test` endpoint
- **Readiness Probe**: `/health` endpoint
- **Startup Probe**: Container startup verification

## 🔒 Security Features

### Network Policies
- Default deny all traffic
- Allow intra-namespace communication
- Allow ingress from nginx controller
- Allow DNS and HTTPS egress

### Resource Security
- **Security Context**: Non-root user, read-only filesystem
- **Resource Quotas**: Prevent resource exhaustion
- **Limit Ranges**: Enforce resource constraints
- **Pod Security**: Restricted capabilities

### Secrets Management
- **Base64 Encoding**: All secrets encoded
- **Separation**: ConfigMaps vs Secrets
- **Environment Variables**: Secure injection

## 🚀 Deployment Options

### Option 1: Automated Script (Recommended)
```bash
./deploy-helm.sh
```

### Option 2: Manual Helm Commands
```bash
# Install
helm install camp-release ./camp \
  --namespace camp \
  --create-namespace \
  --values ./camp/values.yaml

# Upgrade
helm upgrade camp-release ./camp \
  --namespace camp \
  --values ./camp/values.yaml

# Uninstall
helm uninstall camp-release --namespace camp
```

### Option 3: Custom Values
```bash
helm install camp-release ./camp \
  --namespace camp \
  --create-namespace \
  --values ./camp/values.yaml \
  --values custom-values.yaml \
  --set ingress.hosts[0].host=camp.mycompany.com \
  --set backend.replicaCount=3
```

## 🔄 Lifecycle Management

### Upgrades
```bash
# Upgrade with new values
helm upgrade camp-release ./camp \
  --namespace camp \
  --values ./camp/values-prod.yaml

# Upgrade with specific version
helm upgrade camp-release ./camp \
  --namespace camp \
  --version 1.1.0
```

### Rollbacks
```bash
# View history
helm history camp-release -n camp

# Rollback to previous version
helm rollback camp-release 1 -n camp
```

### Testing
```bash
# Lint the chart
helm lint ./camp

# Template rendering
helm template camp-release ./camp --values ./camp/values.yaml

# Dry run installation
helm install camp-release ./camp --dry-run --debug
```

## 📈 Scaling and Performance

### Horizontal Pod Autoscaling
```yaml
backend:
  autoscaling:
    enabled: true
    minReplicas: 2
    maxReplicas: 10
    targetCPUUtilizationPercentage: 70
    targetMemoryUtilizationPercentage: 80
```

### Resource Optimization
- **CPU Requests**: 100m - 500m per service
- **Memory Requests**: 128Mi - 512Mi per service
- **Storage**: SSD for production, standard for development

### Performance Tuning
- **Affinity Rules**: Spread pods across nodes
- **Anti-Affinity**: Prevent same-node deployment
- **Tolerations**: Schedule on dedicated nodes
- **Resource Limits**: Prevent resource contention

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
kubectl describe ingress camp-release -n camp

# Test connectivity
kubectl port-forward svc/camp-release-backend-service 8000:8000 -n camp
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

### Debug Commands
```bash
# Get all resources
kubectl get all -n camp

# Check events
kubectl get events -n camp --sort-by=.metadata.creationTimestamp

# Check resource usage
kubectl top pods -n camp
kubectl top nodes
```

## 📚 Advanced Usage

### Custom Values Override
Create `custom-values.yaml`:
```yaml
replicaCount:
  backend: 5
  web: 3
  auth: 2

ingress:
  hosts:
    - host: camp.mycompany.com
      paths:
        - path: /api(/|$)(.*)
          service: backend
        - path: /auth(/|$)(.*)
          service: auth
        - path: /(.*)
          service: web

backend:
  resources:
    requests:
      memory: "1Gi"
      cpu: "500m"
    limits:
      memory: "2Gi"
      cpu: "1000m"
```

### Hooks and Jobs
Add pre/post-install hooks:
```yaml
# In templates/hooks/
apiVersion: batch/v1
kind: Job
metadata:
  name: "{{ .Release.Name }}-pre-install-job"
  annotations:
    "helm.sh/hook": pre-install
    "helm.sh/hook-weight": "-5"
spec:
  template:
    spec:
      containers:
      - name: pre-install
        image: busybox
        command: ['echo', 'Pre-install hook']
      restartPolicy: Never
```

### Dependencies
Add chart dependencies in `Chart.yaml`:
```yaml
dependencies:
  - name: postgresql
    version: 12.x.x
    repository: https://charts.bitnami.com/bitnami
    condition: postgresql.enabled
```

## 📞 Support

### Getting Help
- **Chart Issues**: GitHub repository issues
- **Helm Documentation**: https://helm.sh/docs/
- **Kubernetes Docs**: https://kubernetes.io/docs/
- **Community**: Helm Slack channel

### Validation
```bash
# Validate chart syntax
helm lint ./camp

# Validate templates
helm template camp-release ./camp --validate

# Test installation
helm test camp-release -n camp
```

---

**Chart Version**: 1.0.0  
**App Version**: 1.0.0  
**Kubernetes Version**: 1.20+  
**Helm Version**: 3.8+
