# Cloud Asset Management Platform (CAMP) - cloud-native microservices platform using Kubernete

-  Designed and deployed a Kubernetes-based microservices platform using Docker and Helm
-  Implemented GitOps workflows using Argo CD for automated, declarative deployments
-  Built CI/CD pipelines with GitHub Actions to automate container builds and cluster deployments
-  Architected environment-agnostic configurations supporting multi-cluster deployments (AKS, k3s)
-  Developed a fully parameterized deployment system eliminating hardcoded infrastructure values
-  Applied best practices in container orchestration, service isolation, and scalable system design

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           Cloud Asset Management Platform                         │
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
│                          ┌─────────────────┐                                      │
│                          │   File Storage  │                                      │
│                          │   (Local Disk)  │                                      │
│                          │                 │                                      │
│                          │ • uploads/      │                                      │
│                          │ • Metadata DB   │                                      │
│                          │ • camp.db       │                                      │
│                          └─────────────────┘                                      │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```
<img width="1402" height="1121" alt="image" src="https://github.com/user-attachments/assets/4c0cfaeb-b4ca-4ef5-a448-ef08eba56212" />


## 🐳 Docker Containerization

This project is fully containerized with Docker support:

### Container Images
- **Backend**: `ghcr.io/elishatheodore/kubernetes-microservices/camp-backend:latest`
- **Web Frontend**: `ghcr.io/elishatheodore/kubernetes-microservices/camp-web:latest`
- **Auth Frontend**: `ghcr.io/elishatheodore/kubernetes-microservices/camp-auth:latest`

### Quick Docker Start
```bash
# Using pre-built images from GHCR
docker-compose -f docker-compose.ghcr.yml up -d

# Or build locally
docker-compose up -d
```

### Container Access URLs
- **Auth Frontend**: http://localhost:3000
- **Web Frontend**: http://localhost:3004
- **Backend API**: http://localhost:8000
- **API Documentation**: http://localhost:8000/docs

## 📁 Project Structure

```
kubernetes-microservices/
├── README.md                           # Main project documentation
├── DOCKER_README.md                   # Docker-specific documentation
├── GHCR_SETUP.md                      # GitHub Container Registry guide
├── AKS_SETUP.md                       # AKS deployment guide
├── HELM_README.md                     # Helm chart documentation
├── MULTI_CLUSTER_DEPLOYMENT.md         # Multi-cluster deployment guide
│
├── 🐳 Docker Configuration
│   ├── docker-compose.yml             # Local Docker compose
│   ├── docker-compose.ghcr.yml       # GHCR Docker compose
│   ├── build.sh / build.bat          # Build scripts
│   ├── restart.sh / restart.bat      # Restart scripts
│   ├── push-to-ghcr.sh              # GHCR push script
│   ├── push-to-ghcr-simple.sh       # Simple GHCR push
│   └── setup-ghcr.sh                # GHCR setup script
│
├── 🏗️ Application Services
│   ├── camp-backend/                 # FastAPI Python Backend
│   │   ├── README.md               # Backend documentation
│   │   ├── requirements.txt        # Python dependencies
│   │   ├── run.py                  # Backend entry point
│   │   ├── Dockerfile              # Backend container definition
│   │   ├── .dockerignore           # Docker build exclusions
│   │   ├── .env                    # Backend environment config
│   │   ├── camp.db                 # SQLite database (auto-created)
│   │   ├── uploads/                # File storage directory
│   │   └── app/                    # Application code
│   │       ├── main.py            # FastAPI application
│   │       ├── api/               # API routers
│   │       ├── core/              # Core configuration
│   │       ├── models/            # Database models
│   │       ├── schemas/           # Pydantic schemas
│   │       ├── services/          # Business logic
│   │       └── db/                # Database configuration
│   │
│   ├── camp-web-frontend/          # Main Web Frontend
│   │   ├── README.md              # Frontend documentation
│   │   ├── serve.py               # Development server
│   │   ├── Dockerfile             # Web frontend container
│   │   ├── .dockerignore          # Docker build exclusions
│   │   ├── package.json           # Node.js dependencies
│   │   ├── index.html             # Main application
│   │   ├── styles.css             # Custom CSS (dark theme)
│   │   ├── config.js              # API configuration
│   │   ├── api-client.js          # API communication
│   │   ├── app.js                 # Application logic
│   │   ├── api-tester.js          # API testing interface
│   │   ├── debug.html             # Debug interface
│   │   └── API_DOCUMENTATION.md   # API usage guide
│   │
│   └── camp-auth-frontend/         # Authentication Frontend
│       ├── README.md              # Auth documentation
│       ├── Dockerfile             # Auth frontend container
│       ├── .dockerignore          # Docker build exclusions
│       ├── nginx.conf             # Nginx configuration
│       ├── index.html             # Login page
│       ├── styles.css             # Auth styling (matching theme)
│       └── app.js                 # Authentication logic
│
├── ☸️ Kubernetes Deployments
│   ├── k8s/                        # Raw Kubernetes manifests
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
│   └── helm/                       # Helm chart deployment
│       ├── deploy-helm.sh          # Helm deployment script
│       ├── values-dev.yaml         # Development values
│       ├── values-prod.yaml        # Production values
│       └── camp/
│           ├── Chart.yaml          # Helm chart metadata
│           ├── values.yaml         # Default values
│           └── templates/          # Kubernetes templates
│               ├── _helpers.tpl    # Template helpers
│               ├── deployment.yaml # Deployments
│               ├── service.yaml    # Services
│               ├── ingress.yaml    # Ingress
│               ├── configmap.yaml  # Config maps
│               ├── secret.yaml     # Secrets
│               ├── pvc.yaml       # Persistent volumes
│               ├── hpa.yaml       # Autoscalers
│               ├── resourcequota.yaml # Resource quotas
│               ├── networkpolicy.yaml # Network policies
│               ├── monitoring.yaml # Monitoring
│               ├── serviceaccount.yaml # Service accounts
│               └── notes.txt      # Installation notes
│
├── 🌍 Multi-Cluster Deployment
│   ├── environments/               # Environment-specific configurations
│   │   ├── values-dev.yaml       # Development configuration
│   │   ├── values-staging.yaml   # Staging configuration
│   │   └── values-prod.yaml      # Production configuration
│   │
│   ├── clusters/                  # Cluster definitions
│   │   └── cluster-config.yaml   # Multi-cluster configuration
│   │
│   └── scripts/                   # Management scripts
│       ├── deploy.sh             # Multi-cluster deployment script
│       ├── cluster-manager.sh    # Cluster management script
│       └── make-executable.sh    # Setup script
│
├── 🔄 CI/CD Pipelines
│   └── ci-cd/                     # CI/CD configurations
│       └── github-actions/
│           └── build-and-deploy.yml # GitHub Actions workflow
│
├── 🚀 GitOps Integration
│   └── gitops/                    # GitOps configurations
│       ├── argocd/               # ArgoCD manifests
│       │   └── application.yaml # ArgoCD applications
│       └── flux/                 # Flux CD manifests
│           ├── gitrepository.yaml # Git repository source
│           └── kustomization.yaml # Flux kustomizations
│
├── 📚 Documentation
│   └── docs/                      # Additional documentation
│       └── MULTI_CLUSTER_DEPLOYMENT.md # Multi-cluster guide
│
└── 🧪 Testing & Utilities
    └── test-uploads.py            # Upload testing utility
```

## 🚀 Quick Start

### 🐳 Docker (Recommended)

```bash
# Option 1: Use pre-built images from GitHub Container Registry
docker-compose -f docker-compose.ghcr.yml up -d

# Option 2: Build locally
docker-compose up -d

# Option 3: Use build scripts
# Windows
.\build.bat
# Linux/Mac
./build.sh
```

### 📍 Access URLs (Docker)
- **Auth Frontend**: http://localhost:3000
- **Web Frontend**: http://localhost:3004
- **Backend API**: http://localhost:8000
- **API Documentation**: http://localhost:8000/docs

### 💻 Local Development

#### Prerequisites
- Python 3.8+
- Modern web browser
- Terminal/command prompt

#### 1. Start the Backend
```bash
cd camp-backend
python run.py
```
Backend will run on: `http://localhost:8000`
- API Documentation: `http://localhost:8000/docs`
- Health Check: `http://localhost:8000/health`

#### 2. Start the Main Frontend
```bash
cd camp-web-frontend
python serve.py
```
Frontend will be available at: `http://localhost:3004`

#### 3. Start the Auth Frontend
```bash
cd camp-auth-frontend
python -m http.server 3000
```
Auth page will be available at: `http://localhost:3000`

#### 4. Use the Application
1. **Login**: Visit `http://localhost:3000` and authenticate
   - Username: `admin`
   - Password: `admin123`
2. **Redirect**: After successful login, you'll be redirected to the main app
3. **Manage Files**: Upload, view, rename, and delete assets

## ✨ Features

### 🔐 Authentication System
- **Secure Login**: Enterprise-grade authentication with security features
- **Session Management**: 30-minute session timeout
- **Account Lockout**: 5 failed attempts → 15-minute lockout
- **Input Validation**: Comprehensive client-side validation
- **Accessibility**: WCAG compliant for screen readers
- **Theme Consistency**: Perfect integration with main app design

### 🗄️ Backend (FastAPI)
- **File Upload**: Secure file upload with validation
- **Asset Management**: List, rename, delete operations
- **Database**: SQLite with SQLAlchemy ORM
- **API Documentation**: Auto-generated OpenAPI/Swagger docs
- **Error Handling**: Comprehensive error responses
- **CORS Support**: Cross-origin resource sharing
- **Logging**: Structured logging with configurable levels

### 🎨 Frontend (HTML/CSS/JS)
- **Modern UI**: Dark theme matching CAMP design system
- **Responsive Design**: Mobile-friendly interface
- **Drag & Drop**: Intuitive file upload experience
- **Real-time Updates**: Live file management
- **Notifications**: Success/error feedback system
- **Accessibility**: ARIA labels and keyboard navigation

## 🔧 Technical Stack

### Backend
- **FastAPI** - Modern Python web framework
- **SQLAlchemy** - Database ORM
- **SQLite** - File-based database (development)
- **Pydantic** - Data validation and serialization
- **Uvicorn** - ASGI server
- **Python** - Programming language (3.8+)

### Frontend
- **HTML5** - Semantic markup
- **CSS3** - Custom styling with dark theme
- **JavaScript (ES6+)** - Modern client-side logic
- **Font Awesome** - Icon library
- **Fetch API** - HTTP requests

### Authentication
- **Vanilla JS** - No external dependencies
- **localStorage** - Session management
- **CSS Animations** - Smooth transitions
- **WCAG Compliance** - Accessibility features

## 📡 API Endpoints

### Health & System
- `GET /` - Service health check and basic info
- `GET /health` - Detailed health status with database checks
- `GET /test` - Simple endpoint for connectivity testing

### Asset Management
- `POST /api/v1/upload` - Upload file with metadata
- `GET /api/v1/files` - List all assets with pagination
- `PUT /api/v1/files/{id}` - Update asset metadata
- `DELETE /api/v1/files/{id}` - Delete asset by ID

### Response Format
```json
{
  "success": true,
  "data": {...},
  "message": "Operation completed",
  "timestamp": "2026-04-04T14:30:00Z"
}
```

## 🐳 Docker Configuration

### Container Images
- **Backend**: `ghcr.io/elishatheodore/kubernetes-microservices/camp-backend:latest`
- **Web Frontend**: `ghcr.io/elishatheodore/kubernetes-microservices/camp-web:latest`
- **Auth Frontend**: `ghcr.io/elishatheodore/kubernetes-microservices/camp-auth:latest`

### Container Features
- **Health Checks**: All containers include health monitoring
- **Volume Mounting**: Persistent storage for uploads and database
- **Networking**: Dedicated Docker network for inter-service communication
- **Environment Variables**: Configurable settings for different environments

### Docker Commands
```bash
# Build and run locally
docker-compose up -d

# Use GHCR images
docker-compose -f docker-compose.ghcr.yml up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Rebuild with no cache
docker-compose build --no-cache
```

## 🎯 Helm Chart Deployment

### Prerequisites
- **Helm 3.x** - Package manager for Kubernetes
- **kubectl** - Kubernetes command line tool
- **Kubernetes cluster** - AKS, EKS, GKE, or local cluster

### Quick Helm Deployment
```bash
# Navigate to helm directory
cd helm

# Deploy with default values
./deploy-helm.sh

# Deploy with development values
./deploy-helm.sh -f values-dev.yaml

# Deploy with production values
./deploy-helm.sh -f values-prod.yaml

# Dry run to preview deployment
./deploy-helm.sh --dry-run

# Uninstall deployment
./deploy-helm.sh --uninstall
```

### Manual Helm Commands
```bash
# Add Helm repositories
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add jetstack https://charts.jetstack.io
helm repo update

# Install the chart
helm install camp-release ./helm/camp \
  --namespace camp \
  --create-namespace \
  --values ./helm/camp/values.yaml

# Upgrade the chart
helm upgrade camp-release ./helm/camp \
  --namespace camp \
  --values ./helm/camp/values.yaml

# Uninstall the chart
helm uninstall camp-release --namespace camp
```

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
    ├── pvc.yaml           # Persistent volumes
    ├── hpa.yaml           # Horizontal pod autoscalers
    ├── resourcequota.yaml  # Resource quotas
    ├── networkpolicy.yaml  # Network policies
    ├── monitoring.yaml     # Monitoring setup
    ├── serviceaccount.yaml # Service accounts
    └── notes.txt          # Installation notes
```

### Helm Configuration Options

#### Environment-Specific Values
- **Development**: `values-dev.yaml` - Single replicas, debug enabled, minimal resources
- **Production**: `values-prod.yaml` - Multiple replicas, high resources, security hardened
- **Default**: `values.yaml` - Balanced configuration for general use

#### Customization Examples
```yaml
# Custom values file (custom-values.yaml)
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

secrets:
  secretKey: "your-custom-secret-key"
  jwtSecret: "your-custom-jwt-secret"
```

#### Deploy with Custom Values
```bash
helm install camp-release ./helm/camp \
  --namespace camp \
  --create-namespace \
  --values ./helm/camp/values.yaml \
  --values custom-values.yaml
```

### Helm Features
- **Template-based Configuration**: Flexible YAML templating
- **Environment Management**: Separate values for dev/prod
- **Dependency Management**: Chart dependencies
- **Rollback Support**: Easy rollback to previous versions
- **Release Management**: Multiple releases per cluster
- **Hooks Support**: Pre/post install/upgrade hooks
- **Testing**: Built-in chart testing framework

## 🚀 GitHub Container Registry (GHCR)

### Push Images to GHCR
```bash
# Setup authentication
echo YOUR_GITHUB_TOKEN | docker login ghcr.io -u elishatheodore --password-stdin

# Push all images
bash push-to-ghcr.sh

# Or setup interactively
bash setup-ghcr.sh
```

### Available Images
- `ghcr.io/elishatheodore/kubernetes-microservices/camp-backend:latest`
- `ghcr.io/elishatheodore/kubernetes-microservices/camp-web:latest`
- `ghcr.io/elishatheodore/kubernetes-microservices/camp-auth:latest`

### View Packages
https://github.com/elishatheodore/kubernetes-microservices/pkgs/container

## 🗄 Database Schema

### Assets Table
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

## 📁 File Storage

### Local Storage (Default)
- **Directory**: `camp-backend/uploads/`
- **Supported Formats**: All file types
- **Size Limit**: 50MB per file (configurable)
- **Naming**: UUID-based unique filenames
- **Organization**: Flat structure with metadata tracking

### Security Features
- **File Type Validation**: Prevents executable uploads
- **Size Limits**: Configurable maximum file sizes
- **Secure Names**: UUID-based filenames prevent conflicts
- **Path Validation**: Prevents directory traversal attacks

## 🔒 Security Architecture

### Authentication Layer
- **Input Sanitization**: XSS prevention
- **Brute Force Protection**: Account lockout mechanism
- **Session Security**: Timeout-based session management
- **Secure Storage**: Proper localStorage cleanup

### API Security
- **CORS Configuration**: Restricted cross-origin access
- **File Validation**: Type and size verification
- **Error Handling**: No sensitive information leakage
- **Rate Limiting**: Implicit through authentication flow

### Data Protection
- **Input Validation**: Comprehensive server-side validation
- **File Security**: Secure upload and storage practices
- **Environment Variables**: Sensitive config protection
- **Logging Security**: No sensitive data in logs

## 🌐 Network Architecture

```
User Browser
    │
    ├─► Auth Frontend (8081) ──► Main Frontend (3004)
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


## 🛠 Development Setup

### Backend Development
```bash
cd camp-backend
# Install dependencies
pip install -r requirements.txt
# Run development server
python run.py
```

### Frontend Development
```bash
cd camp-web-frontend
# Serve with Python
python serve.py
# Or use Node.js
npm install
npm start
```

### Auth Development
```bash
cd camp-auth-frontend
# Simple HTTP server
python -m http.server 8081
# Or open directly in browser
open index.html
```

## 🚀 Deployment Architecture

### Development Environment
- **Backend**: Local SQLite + Uvicorn
- **Frontend**: Python HTTP server
- **Auth**: Static file serving
- **Database**: Local SQLite file

### Production Architecture (Future)
- **Backend**: Docker + Gunicorn + PostgreSQL
- **Frontend**: Nginx static serving
- **Auth**: Integrated with main app
- **Database**: PostgreSQL or Azure SQL
- **Storage**: Azure Blob Storage
- **Load Balancer**: Azure Application Gateway

## 📊 Performance Considerations

### Backend Optimization
- **Database Indexing**: Primary key and timestamp indexes
- **File Streaming**: Efficient file upload/download
- **Memory Management**: Proper resource cleanup
- **Async Operations**: Non-blocking I/O with FastAPI

### Frontend Optimization
- **Lazy Loading**: Load files on demand
- **Caching**: Browser cache optimization
- **Compression**: Gzip for API responses
- **Bundle Size**: Minimal external dependencies

### Security Performance
- **Rate Limiting**: Prevent abuse
- **Input Validation**: Early rejection of invalid data
- **File Size Limits**: Prevent resource exhaustion
- **Session Management**: Efficient cleanup

## 📱 Browser Support

- **Chrome** 90+ (recommended)
- **Firefox** 88+
- **Safari** 14+
- **Edge** 90+

## 🔧 Configuration

### Environment Variables (.env)
```env
# Database Configuration
DATABASE_URL=sqlite:///./camp.db

# Storage Configuration
STORAGE_TYPE=local
LOCAL_STORAGE_PATH=./uploads
MAX_FILE_SIZE=52428800  # 50MB

# Application Configuration
APP_NAME=Cloud Asset Management Platform
APP_VERSION=1.0.0
DEBUG=True
LOG_LEVEL=INFO

# CORS Configuration
CORS_ORIGINS=["http://localhost:3004", "http://localhost:8081"]
```

### Frontend Configuration (config.js)
```javascript
const API_BASE_URL = 'http://localhost:8000';
const APP_VERSION = '1.0.0';
const MAX_FILE_SIZE = 50 * 1024 * 1024; // 50MB
```

## 🧪 Testing

### Backend Testing
```bash
cd camp-backend
# Run tests (if available)
pytest
# Check API health
curl http://localhost:8000/health
```

### Frontend Testing
- **Manual Testing**: Use browser developer tools
- **API Testing**: Built-in API tester in debug.html
- **Cross-browser**: Test on multiple browsers

## 📚 Documentation

- **Backend API**: `http://localhost:8000/docs`
- **Frontend Guide**: `camp-web-frontend/README.md`
- **Auth System**: `camp-auth-frontend/README.md`
- **API Usage**: `camp-web-frontend/API_DOCUMENTATION.md`

## 🔄 Integration Flow

1. **User Access**: Auth frontend validates credentials
2. **Session Creation**: Secure session token stored
3. **Redirect**: User sent to main application
4. **API Calls**: Frontend communicates with backend
5. **File Operations**: Upload, list, rename, delete
6. **Session Management**: Timeout and cleanup

## 🚀 Deployment Roadmap

### Phase 1: Current ✅
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
- ✅ GitOps integration

### Phase 2: Production Ready 🔄
- 🔄 PostgreSQL database integration
- 🔄 Automated testing pipelines
- 🔄 Monitoring and alerting
- 🔄 Backup and recovery
- 🔄 Multi-region deployment
- 🔄 Advanced security features

### Phase 3: Cloud Native 📋
- 📋 Azure Container Instances
- 📋 Azure Blob Storage
- 📋 Azure SQL Database
- 📋 Application Gateway
- 📋 Front Door CDN
- 📋 GitOps with ArgoCD/Flux
- 📋 Service mesh integration

## 🎯 Deployment Options Summary

| Method | Best For | Complexity | Scalability | Production Ready | Multi-Cluster |
|--------|----------|------------|-------------|------------------|---------------|
| **Local Development** | Testing & Development | ⭐ | ⭐ | ⭐ | ❌ |
| **Docker Compose** | Small deployments | ⭐⭐ | ⭐⭐ | ⭐⭐ | ❌ |
| **Raw Kubernetes** | Custom deployments | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ |
| **Helm Chart** | Production deployments | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Multi-Cluster System** | Enterprise deployments | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |

### Recommended Deployment Path
1. **Development**: Local Python servers → Docker Compose
2. **Staging**: Docker Compose → Helm with dev values
3. **Production**: Helm with prod values → Multi-Cluster → GitOps automation

## 🔄 CI/CD Integration

### GitHub Actions Workflow
The project includes a comprehensive CI/CD pipeline with:

**Features:**
- **Multi-architecture builds** (AMD64/ARM64)
- **Automated testing** and validation
- **Security scanning** with Trivy
- **Manual deployment triggers** to any cluster
- **Automated deployments** for staging and production
- **Helm chart validation** and testing

**Workflow Triggers:**
- **Push to `main`**: Auto-deploy to staging
- **Push to `develop`**: Build and test only
- **Tags (`v*`)**: Auto-deploy to production
- **Manual dispatch**: On-demand deployment to any cluster

**Manual Deployment Options:**
```bash
# Via GitHub Actions UI
1. Go to Actions → Build and Deploy CAMP Platform
2. Click "Run workflow"
3. Select:
   - Cluster: local-dev, aks-dev, aks-staging, aks-prod
   - Environment: dev, staging, prod
   - Image Tag: specific version or latest
   - Deploy: true/false
   - Dry Run: true/false
```

### CI/CD Pipeline Stages
1. **Build & Test**: Multi-architecture Docker builds
2. **Security Scan**: Vulnerability scanning with Trivy
3. **Helm Validation**: Chart linting and template testing
4. **Deploy**: Targeted deployment to specified cluster
5. **Verify**: Smoke tests and health checks

## 🚀 GitOps Integration

### ArgoCD Support
Complete ArgoCD application manifests for automated GitOps:

**Features:**
- **Automated sync** from Git repository
- **Multi-environment** applications
- **Self-healing** capabilities
- **Rollback support** via Git history

**Applications:**
- `camp-dev`: Development environment
- `camp-staging`: Staging environment  
- `camp-prod`: Production environment

### Flux CD Support
Flux CD kustomizations for GitOps deployment:

**Features:**
- **Git repository** source configuration
- **Helm release** management
- **Interval-based** synchronization
- **Prune and self-heal** capabilities

### GitOps Workflow
```bash
# 1. Configure GitOps controller (ArgoCD/Flux)
# 2. Apply GitOps manifests
kubectl apply -f gitops/argocd/  # or gitops/flux/

# 3. GitOps controller automatically:
#    - Clones the repository
#    - Deploys Helm charts
#    - Monitors for changes
#    - Syncs cluster state
```

## 🚀 Deployment Options

### 1. 🐳 Docker Development (Recommended for Local)
**Best for**: Local development, testing, small deployments

```bash
# Quick start with pre-built images
docker-compose -f docker-compose.ghcr.yml up -d

# Or build locally
docker-compose up -d

# Access at:
# Auth: http://localhost:3000
# Web: http://localhost:3004
# API: http://localhost:8000
```

### 2. 🎯 Helm Chart (Recommended for Production)
**Best for**: Single-cluster production deployments

```bash
# Navigate to helm directory
cd helm

# Deploy with environment-specific values
./deploy-helm.sh -f values-dev.yaml     # Development
./deploy-helm.sh -f values-prod.yaml    # Production

# Manual Helm commands
helm install camp-release ./camp \
  --namespace camp \
  --create-namespace \
  --values ./camp/values.yaml
```

### 3. 🌍 Multi-Cluster System (Recommended for Enterprise)
**Best for**: Multi-environment, multi-cloud deployments

```bash
# Make scripts executable
./scripts/make-executable.sh

# Deploy to any cluster/environment
./scripts/deploy.sh -c local-dev -e dev           # Local development
./scripts/deploy.sh -c aks-staging -e staging    # AKS staging
./scripts/deploy.sh -c aks-prod -e prod           # AKS production

# Cluster management
./scripts/cluster-manager.sh list                 # List all clusters
./scripts/cluster-manager.sh test aks-prod        # Test connectivity
./scripts/cluster-manager.sh switch aks-prod     # Switch context
```

### 4. 🔄 CI/CD Pipeline (Recommended for Automation)
**Best for**: Automated builds and deployments

**Automated Triggers:**
- Push to `main` → Deploy to staging
- Push tags (`v*`) → Deploy to production
- Pull requests → Build and test only

**Manual Deployment:**
1. Go to GitHub Actions → "Build and Deploy CAMP Platform"
2. Click "Run workflow"
3. Select cluster, environment, image tag
4. Enable deployment option

### 5. 🚀 GitOps (Recommended for Production)
**Best for**: Git-based deployment automation

```bash
# Apply GitOps manifests
kubectl apply -f gitops/argocd/    # For ArgoCD
# OR
kubectl apply -f gitops/flux/       # For Flux CD

# GitOps controller handles:
# - Automatic deployment from Git
# - Continuous synchronization
# - Self-healing
# - Rollback via Git history
```

### 6. ☸️ Raw Kubernetes (For Custom Deployments)
**Best for**: Manual Kubernetes deployments

```bash
# Navigate to k8s directory
cd k8s

# Deploy to AKS
./deploy.sh

# Manual deployment
kubectl apply -k .
```

## 📊 Deployment Comparison

| Method | Best For | Complexity | Scalability | Production Ready | Multi-Cluster | GitOps | CI/CD |
|--------|----------|------------|-------------|------------------|---------------|---------|---------|
| **Docker** | Local Development | ⭐ | ⭐ | ⭐ | ❌ | ❌ | ❌ |
| **Helm Chart** | Single Cluster | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐ | ⭐⭐ |
| **Multi-Cluster** | Enterprise | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| **CI/CD Pipeline** | Automation | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| **GitOps** | Production | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Raw K8s** | Custom | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ❌ | ❌ |

### Recommended Deployment Path

1. **Development**: Docker → Local testing
2. **Staging**: Multi-Cluster → CI/CD → GitOps
3. **Production**: Multi-Cluster → CI/CD + GitOps → Full automation

## 🌍 Multi-Cluster Deployment

The CAMP platform now supports deployment across multiple Kubernetes clusters with full parameterization:

### Quick Start
```bash
# Make scripts executable
./scripts/make-executable.sh

# Deploy to local development
./scripts/deploy.sh -c local-dev -e dev

# Deploy to staging
./scripts/deploy.sh -c aks-staging -e staging -t v1.0.0

# Deploy to production
./scripts/deploy.sh -c aks-prod -e prod -t v1.0.0 -f
```

### Supported Clusters
- **Local**: Minikube, K3s, Docker Desktop
- **Azure**: AKS clusters
- **AWS**: EKS clusters
- **GCP**: GKE clusters
- **Custom**: Any Kubernetes cluster

### Environment Configurations
- **Development**: Single replicas, debug enabled, minimal resources
- **Staging**: Multiple replicas, staging domain, basic monitoring
- **Production**: High availability, security hardened, full monitoring

### CI/CD Integration
- **GitHub Actions**: Automated builds and deployments
- **Manual Triggers**: On-demand deployments to any cluster
- **GitOps Support**: ArgoCD and Flux CD integration
- **Multi-architecture**: AMD64 and ARM64 support

### Key Features
- **Zero Hardcoding**: All values configurable
- **Cloud Agnostic**: Works with any Kubernetes provider
- **GitOps Ready**: Single source of truth in Git
- **Production Grade**: Security, monitoring, scaling built-in
- **Easy Extension**: Add new clusters and environments easily

For detailed multi-cluster deployment instructions, see [Multi-Cluster Deployment Guide](docs/MULTI_CLUSTER_DEPLOYMENT.md).

## 🛠 Development & Operations

### Docker Development
```bash
# Development workflow
docker-compose up -d                    # Start services
docker-compose logs -f camp-backend     # View backend logs
docker-compose restart camp-backend     # Restart backend
docker-compose down                     # Stop all services

# Build and push
bash push-to-ghcr.sh                   # Push to GHCR
bash setup-ghcr.sh                     # Interactive setup
```

### Helm Development
```bash
# Navigate to helm directory
cd helm

# Deploy with different environments
./deploy-helm.sh                         # Default deployment
./deploy-helm.sh -f values-dev.yaml     # Development
./deploy-helm.sh -f values-prod.yaml    # Production

# Helm operations
helm list -n camp                        # List releases
helm status camp-release -n camp         # Release status
helm history camp-release -n camp        # Release history
helm rollback camp-release 1 -n camp     # Rollback to previous version

# Debug and troubleshoot
helm template camp-release ./camp --values values.yaml  # Preview manifests
helm get values camp-release -n camp      # Get current values
helm get all camp-release -n camp         # Get all release info
```

### Multi-Cluster Development
```bash
# Navigate to scripts directory
cd scripts

# Deploy with different environments
./deploy.sh -c local-dev -e dev                 # Local development
./deploy.sh -c aks-staging -e staging          # AKS staging
./deploy.sh -c aks-prod -e prod                 # AKS production

# Cluster management
./cluster-manager.sh list                       # List all clusters
./cluster-manager.sh details aks-prod         # Cluster details
./cluster-manager.sh switch aks-prod          # Switch context
./cluster-manager.sh test aks-prod            # Test connectivity
./cluster-manager.sh status aks-prod           # Show status
./cluster-manager.sh validate                  # Validate configs

# Advanced deployment options
./deploy.sh -c aks-prod -e prod -t v1.0.0      # With specific tag
./deploy.sh -c aks-prod -e prod --dry-run      # Preview deployment
./deploy.sh -c aks-prod -e prod -f             # Force upgrade
./deploy.sh -c aks-prod -e prod -g             # Enable GitOps
```

### Local Development
```bash
# Backend
cd camp-backend
python run.py                           # Start backend

# Frontend
cd camp-web-frontend
python serve.py                        # Start web frontend

# Auth
cd camp-auth-frontend
python -m http.server 3000            # Start auth frontend
```

### Testing
```bash
# Backend health check
curl http://localhost:8000/health

# API testing
curl http://localhost:8000/test

# Container health
docker-compose ps

# Kubernetes health
kubectl get pods -n camp
kubectl get services -n camp
kubectl get ingress -n camp
```

## 📚 Documentation

### 📖 Core Documentation
- **Main Documentation**: This README.md
- **Docker Guide**: `DOCKER_README.md` - Docker containerization and local development
- **GHCR Setup**: `GHCR_SETUP.md` - GitHub Container Registry configuration
- **AKS Deployment**: `AKS_SETUP.md` - Azure Kubernetes Service deployment guide
- **Helm Chart**: `HELM_README.md` - Helm chart documentation and usage

### 🌍 Advanced Deployment Guides
- **Multi-Cluster Deployment**: `docs/MULTI_CLUSTER_DEPLOYMENT.md` - Complete multi-cluster guide
  - Multi-cloud support (AKS, EKS, GKE, local)
  - Environment-specific configurations
  - CI/CD integration
  - GitOps setup
  - Troubleshooting and best practices

### 🏗️ Application Documentation
- **Backend API**: `http://localhost:8000/docs` - Interactive API documentation
- **Frontend Guide**: `camp-web-frontend/README.md` - Web frontend documentation
- **Auth System**: `camp-auth-frontend/README.md` - Authentication system guide
- **API Usage**: `camp-web-frontend/API_DOCUMENTATION.md` - API usage examples

### 📋 Configuration Files
- **Environment Configs**: `environments/values-*.yaml` - Dev/staging/prod configurations
- **Cluster Configs**: `clusters/cluster-config.yaml` - Multi-cluster definitions
- **CI/CD Pipeline**: `ci-cd/github-actions/build-and-deploy.yml` - GitHub Actions workflow
- **GitOps Manifests**: `gitops/argocd/` and `gitops/flux/` - GitOps configurations

### 🛠️ Script Documentation
All scripts include comprehensive help and documentation:
```bash
./scripts/deploy.sh --help           # Multi-cluster deployment help
./scripts/cluster-manager.sh --help  # Cluster management help
./helm/deploy-helm.sh --help        # Helm deployment help
./k8s/deploy.sh --help            # AKS deployment help
```

## 🔄 Integration Flow

### Docker Integration Flow
1. **Container Startup**: Docker Compose orchestrates all services
2. **User Access**: Auth frontend validates credentials (Port 3000)
3. **Session Creation**: Secure session token stored
4. **Redirect**: User sent to main application (Port 3004)
5. **API Calls**: Frontend communicates with backend (Port 8000)
6. **File Operations**: Upload, list, rename, delete
7. **Session Management**: Timeout and cleanup
8. **Data Persistence**: Volume mounts for database and uploads

### Helm/Kubernetes Integration Flow
1. **Chart Installation**: Helm creates all Kubernetes resources
2. **Pod Deployment**: Kubernetes schedules pods across nodes
3. **Service Exposure**: Services expose pods internally
4. **Ingress Configuration**: External access through load balancer
5. **Auto-scaling**: HPA adjusts pod count based on metrics
6. **Health Monitoring**: Probes and monitoring ensure availability
7. **Data Persistence**: PVCs provide persistent storage
8. **Network Security**: Network policies control traffic flow

### Deployment Options Comparison

| Feature | Docker Compose | Helm/Kubernetes |
|---------|----------------|-----------------|
| **Ease of Use** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Scalability** | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Production Ready** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Auto-scaling** | ❌ | ✅ |
| **Health Monitoring** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Rolling Updates** | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Resource Management** | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Multi-environment** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **CI/CD Integration** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |

## 🎯 Production Considerations

### Security
- **Environment Variables**: All secrets in environment variables
- **Volume Permissions**: Proper file system permissions
- **Network Isolation**: Docker network segmentation
- **Health Monitoring**: Container health checks

### Performance
- **Resource Limits**: Container resource constraints
- **Database Optimization**: Proper indexing and queries
- **File Storage**: Efficient file handling
- **Caching**: Browser and API response caching

### Monitoring
- **Health Checks**: All services monitored
- **Logging**: Structured logging with levels
- **Metrics**: Container and application metrics
- **Alerting**: Health check failures

## 🤝 Contributing

1. **Fork** the repository
2. **Create** feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** changes (`git commit -m 'Add amazing feature'`)
4. **Test** locally with Docker
5. **Push** to branch (`git push origin feature/amazing-feature`)
6. **Open** Pull Request

### Development Guidelines
- Follow existing code style
- Add tests for new features
- Update documentation
- Test Docker containers
- Ensure accessibility compliance
- Test on multiple browsers

## 📄 License

MIT License - see LICENSE file for details

## 🆘 Support

For support and questions:
1. Check existing documentation
2. Review API documentation at `/docs`
3. Check `DOCKER_README.md` for Docker issues
4. Review `GHCR_SETUP.md` for container registry issues
5. Open an issue in the repository
6. Check browser console for errors

---

**Built by Elisha Theodore (https://github.com/elishatheodore) using FastAPI, Docker, Helm, Kubernetes, CI/CD, GitOps, HTML, CSS, JavaScript, and modern security practices**

**Version**: 1.0.0  
**Last Updated**: 2026-04-05  
**Status**: Production Ready (Multi-Cluster + CI/CD + GitOps)  
**Container Registry**: GitHub Container Registry (GHCR)  
**Package Manager**: Helm Chart Available  
**Deployment**: Multi-Cluster Enterprise Ready
