# kubernetes-microservices — Cloud Asset Management Platform (CAMP)

[![Build and Lint](https://github.com/elishatheodore/kubernetes-microservices/actions/workflows/build-and-deploy.yml/badge.svg)](https://github.com/elishatheodore/kubernetes-microservices/actions/workflows/build-and-deploy.yml)

A **production-grade, cloud-native microservices platform** built with Kubernetes, Helm, and GitOps — deployed on Azure Kubernetes Service (AKS) with full multi-cluster enterprise support.

This project demonstrates end-to-end platform engineering: from containerized application development to automated CI/CD, GitOps delivery, and multi-environment orchestration across AKS, EKS, GKE, and local clusters.

---

## 🎯 What This Project Demonstrates

- **Production Kubernetes** — Helm charts, HPA, Network Policies, Resource Quotas, Kustomize, and PVCs
- **GitOps workflows** — Full ArgoCD and Flux CD integration with automated sync and self-healing
- **Multi-cluster enterprise deployment** — Parameterized deployment across AKS, EKS, GKE, and local environments
- **CI/CD pipeline** — GitHub Actions with multi-architecture builds (AMD64/ARM64), Trivy security scanning, and automated staging/production deployments
- **Infrastructure as Code** — Environment-specific configurations for dev, staging, and production
- **Containerization** — Docker multi-service orchestration with images published to GitHub Container Registry (GHCR)
- **Security architecture** — RBAC, Network Policies, JWT auth, XSS prevention, brute-force protection, and secret management

---

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           Cloud Asset Management Platform                        │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐              │
│  │   Auth Frontend │    │  Main Frontend  │    │    Backend      │              │
│  │   (Port 3000)   │    │   (Port 3004)   │    │   (Port 8000)   │              │
│  │                 │    │                 │    │                 │              │
│  │ • Login Page    │◄──►│ • File Manager  │◄──►│ • FastAPI       │              │
│  │ • Security      │    │ • Upload UI     │    │ • SQLAlchemy    │              │
│  │ • Validation    │    │ • Asset Grid    │    │ • SQLite DB     │              │
│  │ • Redirection   │    │ • Real-time     │    │ • File Storage  │              │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘              │
│           │                       │                       │                      │
│           └───────────────────────┼───────────────────────┘                      │
│                                   │                                              │
│                          ┌─────────────────┐                                     │
│                          │   File Storage  │                                     │
│                          │   (Local Disk)  │                                     │
│                          │                 │                                     │
│                          │ • uploads/      │                                     │
│                          │ • Metadata DB   │                                     │
│                          │ • camp.db       │                                     │
│                          └─────────────────┘                                     │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

<img width="1402" height="1121" alt="image" src="https://github.com/user-attachments/assets/4c0cfaeb-b4ca-4ef5-a448-ef08eba56212" />

---

## 🔧 Technical Stack

### Backend
- **FastAPI** — Modern Python web framework
- **SQLAlchemy** — Database ORM
- **SQLite** — File-based database (development)
- **Pydantic** — Data validation and serialization
- **Uvicorn** — ASGI server
- **Python 3.8+**

### Frontend
- **HTML5** — Semantic markup
- **CSS3** — Custom styling with dark theme
- **JavaScript (ES6+)** — Modern client-side logic
- **Font Awesome** — Icon library
- **Fetch API** — HTTP requests

### Platform & Infrastructure
- **Kubernetes (AKS)** — Container orchestration
- **Helm 3** — Kubernetes package manager
- **Docker** — Containerization
- **Terraform** — Infrastructure as Code
- **GitHub Actions** — CI/CD pipelines
- **ArgoCD / Flux CD** — GitOps delivery
- **Kustomize** — Kubernetes configuration management
- **Trivy** — Container security scanning
- **GHCR** — GitHub Container Registry

---

## 📁 Project Structure

```
kubernetes-microservices/
├── README.md                           # Main project documentation
├── DOCKER_README.md                    # Docker-specific documentation
├── GHCR_SETUP.md                       # GitHub Container Registry guide
├── AKS_SETUP.md                        # AKS deployment guide
├── HELM_README.md                      # Helm chart documentation
├── MULTI_CLUSTER_DEPLOYMENT.md         # Multi-cluster deployment guide
│
├── 🐳 Docker Configuration
│   ├── docker-compose.yml              # Local Docker compose
│   ├── docker-compose.ghcr.yml        # GHCR Docker compose
│   ├── build.sh / build.bat           # Build scripts
│   ├── restart.sh / restart.bat       # Restart scripts
│   ├── push-to-ghcr.sh               # GHCR push script
│   ├── push-to-ghcr-simple.sh        # Simple GHCR push
│   └── setup-ghcr.sh                 # GHCR setup script
│
├── 🏗️ Application Services
│   ├── camp-backend/                  # FastAPI Python Backend
│   │   ├── README.md                # Backend documentation
│   │   ├── requirements.txt         # Python dependencies
│   │   ├── run.py                   # Backend entry point
│   │   ├── Dockerfile               # Backend container definition
│   │   ├── .dockerignore            # Docker build exclusions
│   │   ├── .env.example             # Environment config template (copy to .env)
│   │   ├── uploads/                 # File storage (git-ignored, auto-created)
│   │   └── app/                     # Application code
│   │       ├── main.py             # FastAPI application
│   │       ├── api/                # API routers
│   │       ├── core/               # Core configuration
│   │       ├── models/             # Database models
│   │       ├── schemas/            # Pydantic schemas
│   │       ├── services/           # Business logic
│   │       └── db/                 # Database configuration
│   │
│   ├── camp-web-frontend/           # Main Web Frontend
│   │   ├── README.md               # Frontend documentation
│   │   ├── serve.py                # Development server
│   │   ├── Dockerfile              # Web frontend container
│   │   ├── .dockerignore           # Docker build exclusions
│   │   ├── package.json            # Node.js dependencies
│   │   ├── index.html              # Main application
│   │   ├── styles.css              # Custom CSS (dark theme)
│   │   ├── config.js               # API configuration
│   │   ├── api-client.js           # API communication
│   │   ├── app.js                  # Application logic
│   │   ├── api-tester.js           # API testing interface
│   │   ├── debug.html              # Debug interface
│   │   └── API_DOCUMENTATION.md    # API usage guide
│   │
│   └── camp-auth-frontend/          # Authentication Frontend
│       ├── README.md               # Auth documentation
│       ├── Dockerfile              # Auth frontend container
│       ├── .dockerignore           # Docker build exclusions
│       ├── nginx.conf              # Nginx configuration
│       ├── index.html              # Login page
│       ├── styles.css              # Auth styling (matching theme)
│       └── app.js                  # Authentication logic
│
├── ☸️ Kubernetes Deployments
│   ├── k8s/                         # Raw Kubernetes manifests
│   │   ├── deploy.sh                # AKS deployment script
│   │   ├── cleanup.sh               # AKS cleanup script
│   │   ├── namespace.yaml           # Namespace
│   │   ├── configmap.yaml           # Configuration
│   │   ├── secret.yaml              # Secrets
│   │   ├── persistent-volumes.yaml  # Storage
│   │   ├── backend-deployment.yaml  # Backend deployment
│   │   ├── web-frontend-deployment.yaml # Web deployment
│   │   ├── auth-frontend-deployment.yaml # Auth deployment
│   │   ├── ingress.yaml             # Ingress
│   │   ├── horizontal-pod-autoscaler.yaml # HPA
│   │   ├── resource-quota.yaml      # Resource quotas
│   │   ├── network-policy.yaml      # Network policies
│   │   ├── monitoring.yaml          # Monitoring
│   │   └── kustomization.yaml       # Kustomize config
│   │
│   └── helm/                        # Helm chart deployment
│       ├── deploy-helm.sh           # Helm deployment script
│       ├── values-dev.yaml          # Development values
│       ├── values-prod.yaml         # Production values
│       └── camp/
│           ├── Chart.yaml           # Helm chart metadata
│           ├── values.yaml          # Default values
│           └── templates/           # Kubernetes templates
│               ├── _helpers.tpl     # Template helpers
│               ├── deployment.yaml  # Deployments
│               ├── service.yaml     # Services
│               ├── ingress.yaml     # Ingress
│               ├── configmap.yaml   # Config maps
│               ├── secret.yaml      # Secrets
│               ├── pvc.yaml         # Persistent volumes
│               ├── hpa.yaml         # Autoscalers
│               ├── resourcequota.yaml # Resource quotas
│               ├── networkpolicy.yaml # Network policies
│               ├── monitoring.yaml  # Monitoring
│               ├── serviceaccount.yaml # Service accounts
│               └── notes.txt        # Installation notes
│
├── 🌍 Multi-Cluster Deployment
│   ├── environments/                # Environment-specific configurations
│   │   ├── values-dev.yaml          # Development configuration
│   │   ├── values-staging.yaml      # Staging configuration
│   │   └── values-prod.yaml         # Production configuration
│   │
│   ├── clusters/                    # Cluster definitions
│   │   └── cluster-config.yaml      # Multi-cluster configuration
│   │
│   └── scripts/                     # Management scripts
│       ├── deploy.sh                # Multi-cluster deployment script
│       ├── cluster-manager.sh       # Cluster management script
│       └── make-executable.sh       # Setup script
│
├── 🔄 CI/CD Pipelines
│   └── .github/workflows/
│       └── build-and-deploy.yml # GitHub Actions workflow
│
├── 🚀 GitOps Integration
│   └── gitops/
│       ├── argocd/
│       │   └── application.yaml     # ArgoCD applications
│       └── flux/
│           ├── gitrepository.yaml   # Git repository source
│           └── kustomization.yaml   # Flux kustomizations
│
├── 📚 Documentation
│   └── docs/
│       └── MULTI_CLUSTER_DEPLOYMENT.md
│
└── 🧪 Testing & Utilities
    └── test-uploads.py              # Upload testing utility
```

---

## 🚀 Quick Start

### Option 1 — Docker (Recommended for Local)

```bash
# Use pre-built images from GitHub Container Registry
docker-compose -f docker-compose.ghcr.yml up -d

# Or build locally
docker-compose up -d

# Windows
.\build.bat
# Linux/Mac
./build.sh
```

**Access URLs:**
- Auth Frontend: http://localhost:3000
- Web Frontend: http://localhost:3004
- Backend API: http://localhost:8000
- API Docs: http://localhost:8000/docs

### Option 2 — Helm (Recommended for Production)

```bash
cd helm

# Deploy with environment-specific values
./deploy-helm.sh -f values-dev.yaml     # Development
./deploy-helm.sh -f values-prod.yaml    # Production
./deploy-helm.sh --dry-run              # Preview deployment
./deploy-helm.sh --uninstall            # Remove deployment

# Manual Helm commands
helm install camp-release ./camp \
  --namespace camp \
  --create-namespace \
  --values ./camp/values.yaml
```

### Option 3 — Multi-Cluster Enterprise

```bash
# Make scripts executable
./scripts/make-executable.sh

# Deploy to any cluster and environment
./scripts/deploy.sh -c local-dev -e dev
./scripts/deploy.sh -c aks-staging -e staging -t v1.0.0
./scripts/deploy.sh -c aks-prod -e prod -t v1.0.0 -f

# Cluster management
./scripts/cluster-manager.sh list
./scripts/cluster-manager.sh switch aks-prod
./scripts/cluster-manager.sh status aks-prod
./scripts/cluster-manager.sh validate
```

### Option 4 — GitOps (ArgoCD / Flux CD)

```bash
# ArgoCD
kubectl apply -f gitops/argocd/

# Flux CD
kubectl apply -f gitops/flux/

# GitOps controller automatically:
# - Clones the repository
# - Deploys Helm charts
# - Monitors for changes
# - Syncs cluster state with self-healing
```

### Option 5 — Raw Kubernetes

```bash
cd k8s
./deploy.sh       # AKS deployment
kubectl apply -k . # Kustomize deployment
```

---

## ✨ Features

### 🔐 Authentication System
- **Secure Login** — Enterprise-grade authentication with security features
- **Session Management** — 30-minute session timeout
- **Account Lockout** — 5 failed attempts triggers 15-minute lockout
- **Input Validation** — Comprehensive client-side validation
- **Accessibility** — WCAG compliant for screen readers
- **Theme Consistency** — Integrated with main app design

### 🗄️ Backend (FastAPI)
- **File Upload** — Secure file upload with validation
- **Asset Management** — List, rename, delete operations
- **Database** — SQLite with SQLAlchemy ORM
- **API Documentation** — Auto-generated OpenAPI/Swagger docs
- **Error Handling** — Comprehensive error responses
- **CORS Support** — Cross-origin resource sharing
- **Logging** — Structured logging with configurable levels

### 🎨 Frontend (HTML/CSS/JS)
- **Modern UI** — Dark theme matching CAMP design system
- **Responsive Design** — Mobile-friendly interface
- **Drag & Drop** — Intuitive file upload experience
- **Real-time Updates** — Live file management
- **Notifications** — Success/error feedback system
- **Accessibility** — ARIA labels and keyboard navigation

---

## 🐳 Docker Containerization

### Container Images (GHCR)
- **Backend**: `ghcr.io/elishatheodore/kubernetes-microservices/camp-backend:latest`
- **Web Frontend**: `ghcr.io/elishatheodore/kubernetes-microservices/camp-web:latest`
- **Auth Frontend**: `ghcr.io/elishatheodore/kubernetes-microservices/camp-auth:latest`

### Docker Commands
```bash
docker-compose up -d                          # Build and run locally
docker-compose -f docker-compose.ghcr.yml up -d  # Use GHCR images
docker-compose logs -f                        # View logs
docker-compose down                           # Stop services
docker-compose build --no-cache               # Rebuild with no cache
```

### Push to GHCR
```bash
echo YOUR_GITHUB_TOKEN | docker login ghcr.io -u elishatheodore --password-stdin
bash push-to-ghcr.sh
```

View packages: https://github.com/elishatheodore/kubernetes-microservices/pkgs/container

---

## 🎯 Helm Chart Deployment

### Helm Chart Structure
```
helm/camp/
├── Chart.yaml              # Chart metadata
├── values.yaml             # Default values
├── values-dev.yaml         # Development values
├── values-prod.yaml        # Production values
└── templates/
    ├── _helpers.tpl        # Template helpers
    ├── deployment.yaml     # Application deployments
    ├── service.yaml        # Service definitions
    ├── ingress.yaml        # Ingress configuration
    ├── configmap.yaml      # Configuration maps
    ├── secret.yaml         # Secrets
    ├── pvc.yaml            # Persistent volumes
    ├── hpa.yaml            # Horizontal pod autoscalers
    ├── resourcequota.yaml  # Resource quotas
    ├── networkpolicy.yaml  # Network policies
    ├── monitoring.yaml     # Monitoring setup
    ├── serviceaccount.yaml # Service accounts
    └── notes.txt           # Installation notes
```

### Environment Configuration
- **Development** — Single replicas, debug enabled, minimal resources
- **Production** — Multiple replicas, high resources, security hardened
- **Default** — Balanced configuration for general use

### Custom Values Example
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

### Helm Operations
```bash
helm list -n camp                                             # List releases
helm status camp-release -n camp                              # Release status
helm history camp-release -n camp                             # Release history
helm rollback camp-release 1 -n camp                          # Rollback
helm template camp-release ./camp --values values.yaml        # Preview manifests
helm get values camp-release -n camp                          # Get current values
```

---

## 🔄 CI/CD Pipeline

### GitHub Actions Workflow Features
- **Multi-architecture builds** — AMD64 and ARM64 support
- **Automated testing** and validation
- **Security scanning** with Trivy
- **Manual deployment triggers** to any cluster
- **Automated deployments** for staging and production
- **Helm chart validation** and testing

### Workflow Triggers
- Push to `main` → Auto-deploy to staging
- Push to `develop` → Build and test only
- Tags (`v*`) → Auto-deploy to production
- Manual dispatch → On-demand deployment to any cluster

### Pipeline Stages
1. **Build & Test** — Multi-architecture Docker builds
2. **Security Scan** — Vulnerability scanning with Trivy
3. **Helm Validation** — Chart linting and template testing
4. **Deploy** — Targeted deployment to specified cluster
5. **Verify** — Smoke tests and health checks

### Manual Deployment via GitHub Actions UI
1. Go to Actions → "Build and Deploy CAMP Platform"
2. Click "Run workflow"
3. Select cluster, environment, and image tag
4. Enable deployment option

---

## 🚀 GitOps Integration

### ArgoCD
- Automated sync from Git repository
- Multi-environment applications (`camp-dev`, `camp-staging`, `camp-prod`)
- Self-healing capabilities
- Rollback support via Git history

### Flux CD
- Git repository source configuration
- Helm release management
- Interval-based synchronization
- Prune and self-heal capabilities

---

## 🌍 Multi-Cluster Deployment

### Supported Clusters
- **Local** — Minikube, K3s, Docker Desktop
- **Azure** — AKS clusters
- **AWS** — EKS clusters
- **GCP** — GKE clusters
- **Custom** — Any Kubernetes cluster

### Environment Configurations
- **Development** — Single replicas, debug enabled, minimal resources
- **Staging** — Multiple replicas, staging domain, basic monitoring
- **Production** — High availability, security hardened, full monitoring

### Key Design Principles
- **Zero Hardcoding** — All values configurable via values files
- **Cloud Agnostic** — Works with any Kubernetes provider
- **GitOps Ready** — Single source of truth in Git
- **Production Grade** — Security, monitoring, and scaling built-in

For detailed instructions, see [Multi-Cluster Deployment Guide](docs/MULTI_CLUSTER_DEPLOYMENT.md).

---

## 📊 Deployment Comparison

| Method | Best For | Complexity | Scalability | Production Ready | Multi-Cluster | GitOps | CI/CD |
|--------|----------|------------|-------------|------------------|---------------|--------|-------|
| **Docker** | Local Development | ⭐ | ⭐ | ⭐ | ❌ | ❌ | ❌ |
| **Helm Chart** | Single Cluster | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐ | ⭐⭐ |
| **Multi-Cluster** | Enterprise | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| **CI/CD Pipeline** | Automation | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| **GitOps** | Production | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Raw K8s** | Custom | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ❌ | ❌ |

### Recommended Deployment Path
1. **Development** — Local Python servers → Docker Compose
2. **Staging** — Helm with dev values → CI/CD pipeline
3. **Production** — Helm with prod values → Multi-Cluster → Full GitOps automation

---

## 📡 API Endpoints

### Health & System
- `GET /` — Service health check and basic info
- `GET /health` — Detailed health status with database checks
- `GET /test` — Simple endpoint for connectivity testing

### Asset Management
- `POST /api/v1/upload` — Upload file with metadata
- `GET /api/v1/files` — List all assets with pagination
- `PUT /api/v1/files/{id}` — Update asset metadata
- `DELETE /api/v1/files/{id}` — Delete asset by ID

### Response Format
```json
{
  "success": true,
  "data": {},
  "message": "Operation completed",
  "timestamp": "2026-04-04T14:30:00Z"
}
```

---

## 🗄️ Database Schema

```sql
CREATE TABLE assets (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    filename VARCHAR(255) NOT NULL,
    original_filename VARCHAR(255) NOT NULL,
    content_type VARCHAR(100),
    file_size INTEGER,
    upload_path VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## 🔒 Security Architecture

### Authentication Layer
- **Input Sanitization** — XSS prevention
- **Brute Force Protection** — Account lockout mechanism
- **Session Security** — Timeout-based session management
- **Secure Storage** — Proper localStorage cleanup

### API Security
- **CORS Configuration** — Restricted cross-origin access
- **File Validation** — Type and size verification
- **Error Handling** — No sensitive information leakage
- **Rate Limiting** — Implicit through authentication flow

### Kubernetes Security
- **RBAC** — Role-based access control via service accounts
- **Network Policies** — Pod-level traffic isolation
- **Resource Quotas** — Namespace resource governance
- **Secret Management** — Kubernetes secrets for sensitive config

### File Storage Security
- **File Type Validation** — Prevents executable uploads
- **Size Limits** — Configurable maximum (default 50MB)
- **UUID Filenames** — Prevents naming conflicts and enumeration
- **Path Validation** — Prevents directory traversal attacks

---

## 🌐 Network Architecture

```
User Browser
    │
    ├─► Auth Frontend (3000) ──► Main Frontend (3004)
    │                                      │
    │                                      ▼
    │                                 Backend API (8000)
    │                                      │
    │                                      ▼
    │                              SQLite Database + Files
    │
    └─► Direct API Access (8000/docs)
```

<img width="1366" height="1150" alt="image" src="https://github.com/user-attachments/assets/e663ea5d-bc4a-4e31-abec-9d1ddb3433c1" />

---

## 📁 File Storage

- **Directory** — `camp-backend/uploads/`
- **Supported Formats** — All file types
- **Size Limit** — 50MB per file (configurable)
- **Naming** — UUID-based unique filenames
- **Organization** — Flat structure with metadata tracking

---

## ⚙️ Configuration

### Environment Variables
Copy `.env.example` to `.env` and configure:
```bash
cp camp-backend/.env.example camp-backend/.env
```

**Key Variables:**
- `DATABASE_URL` - Database connection string
- `STORAGE_TYPE` - Storage backend (local/s3/etc.)
- `LOCAL_STORAGE_PATH` - Upload directory path
- `MAX_FILE_SIZE` - Maximum file upload size
- `SECRET_KEY` - Application secret key
- `JWT_SECRET` - JWT signing secret
- `DEFAULT_PASSWORD` - Default admin password
- `CORS_ORIGINS` - Allowed CORS origins

### Frontend Configuration (config.js)
```javascript
const API_BASE_URL = 'http://localhost:8000';
const APP_VERSION = '1.0.0';
const MAX_FILE_SIZE = 50 * 1024 * 1024; // 50MB
```

---

## 🧪 Testing

```bash
# Backend health check
curl http://localhost:8000/health

# API connectivity
curl http://localhost:8000/test

# Container health
docker-compose ps

# Kubernetes health
kubectl get pods -n camp
kubectl get services -n camp
kubectl get ingress -n camp

# Backend unit tests
cd camp-backend && pytest

# Upload testing utility
python test-uploads.py
```

---

## 🛠️ Local Development

### Backend
```bash
cd camp-backend
pip install -r requirements.txt
python run.py
# Runs at http://localhost:8000
# Docs at http://localhost:8000/docs
```

### Web Frontend
```bash
cd camp-web-frontend
python serve.py
# Or: npm install && npm start
# Runs at http://localhost:3004
```

### Auth Frontend
```bash
cd camp-auth-frontend
python -m http.server 3000
# Runs at http://localhost:3000
```

---

## 🚀 Deployment Roadmap

### Phase 1: Complete ✅
- ✅ Local SQLite database
- ✅ File system storage
- ✅ Development servers
- ✅ Basic authentication
- ✅ Docker containerization
- ✅ GitHub Container Registry integration
- ✅ Helm chart packaging
- ✅ Kubernetes manifests
- ✅ Multi-environment support
- ✅ Multi-cluster deployment system
- ✅ CI/CD pipelines
- ✅ GitOps integration (ArgoCD + Flux CD)

### Phase 2: Production Ready 🔄
- 🔄 PostgreSQL database integration
- 🔄 Automated testing pipelines
- 🔄 Monitoring and alerting (Prometheus + Grafana)
- 🔄 Backup and recovery
- 🔄 Multi-region deployment
- 🔄 Advanced security features

### Phase 3: Cloud Native 📋
- 📋 Azure Blob Storage
- 📋 Azure SQL Database
- 📋 Application Gateway
- 📋 Front Door CDN
- 📋 Service mesh integration

---

## 📚 Documentation

| Document | Description |
|---|---|
| `README.md` | This file — main project overview |
| `DOCKER_README.md` | Docker containerization and local development |
| `GHCR_SETUP.md` | GitHub Container Registry configuration |
| `AKS_SETUP.md` | Azure Kubernetes Service deployment guide |
| `HELM_README.md` | Helm chart documentation and usage |
| `docs/MULTI_CLUSTER_DEPLOYMENT.md` | Complete multi-cluster deployment guide |
| `camp-web-frontend/API_DOCUMENTATION.md` | API usage examples |

Script help:
```bash
./scripts/deploy.sh --help           # Multi-cluster deployment help
./scripts/cluster-manager.sh --help  # Cluster management help
./helm/deploy-helm.sh --help         # Helm deployment help
./k8s/deploy.sh --help               # AKS deployment help
```

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Test locally with Docker
5. Push to branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

**Guidelines:** Follow existing code style, add tests for new features, update documentation, test Docker containers, and ensure accessibility compliance.

---

## 📄 License

MIT License — see LICENSE file for details.

---

## 🆘 Support

1. Check existing documentation listed above
2. Review API documentation at `/docs`
3. Open an issue in the repository
4. Check browser console for frontend errors

---

**Built by [Elisha Theodore](https://github.com/elishatheodore) · [elisha.app](https://www.elisha.app) · [LinkedIn](https://www.linkedin.com/in/elishatheodore)**

**Stack:** FastAPI · Docker · Helm · Kubernetes · ArgoCD · Flux CD · GitHub Actions · Terraform · Azure (AKS) · Python · CI/CD · GitOps

![Version](https://img.shields.io/badge/version-1.0.0-blue) ![Status](https://img.shields.io/badge/status-production--ready-green) ![Clusters](https://img.shields.io/badge/deployment-multi--cluster-orange) ![Registry](https://img.shields.io/badge/registry-GHCR-purple)
