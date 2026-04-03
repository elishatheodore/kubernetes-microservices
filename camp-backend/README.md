# Cloud Asset Management Platform (CAMP) Backend

A production-ready FastAPI backend service for secure cloud asset management with comprehensive file handling, database operations, and API documentation.

## 🏗️ Backend Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              FastAPI Backend Service                            │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐              │
│  │   API Layer     │    │  Service Layer  │    │   Data Layer    │              │
│  │                 │    │                 │    │                 │              │
│  │ • Routes        │◄──►│ • Business      │◄──►│ • SQLAlchemy    │              │
│  │ • Validation    │    │   Logic         │    │ • SQLite DB     │              │
│  │ • CORS          │    │ • Storage       │    │ • Models        │              │
│  │ • Error Handling│    │ • File Ops      │    │ • Migrations    │              │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘              │
│           │                       │                       │                      │
│           └───────────────────────┼───────────────────────┘                      │
│                                   │                                              │
│                          ┌─────────────────┐                                      │
│                          │  File Storage   │                                      │
│                          │                 │                                      │
│                          │ • uploads/      │                                      │
│                          │ • UUID Names    │                                      │
│                          │ • Metadata      │                                      │
│                          └─────────────────┘                                      │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## 📁 Directory Structure

```
camp-backend/
├── README.md                    # This documentation
├── requirements.txt             # Python dependencies
├── run.py                      # Application entry point
├── .env                        # Environment configuration
├── .venv/                      # Virtual environment
├── camp.db                     # SQLite database (auto-created)
├── uploads/                    # File storage directory
├── test-uploads.py            # Upload testing script
└── app/
    ├── __init__.py
    ├── main.py                 # FastAPI application factory
    ├── api/
    │   ├── __init__.py
    │   └── assets.py          # Asset management endpoints
    ├── core/
    │   ├── __init__.py
    │   └── config.py          # Settings and environment variables
    ├── models/
    │   ├── __init__.py
    │   └── asset.py           # SQLAlchemy database models
    ├── schemas/
    │   ├── __init__.py
    │   └── asset.py           # Pydantic request/response schemas
    ├── services/
    │   ├── __init__.py
    │   ├── storage.py         # Abstract storage service
    │   └── asset_service.py   # Asset business logic
    └── db/
        ├── __init__.py
        └── database.py        # Database connection and setup
```

## 🚀 Quick Start

### Prerequisites
- Python 3.8+
- pip or poetry package manager
- 100MB free disk space

### Installation & Setup

1. **Clone and Navigate**:
```bash
cd camp-backend
```

2. **Create Virtual Environment**:
```bash
python -m venv .venv
# Windows
.venv\Scripts\activate
# macOS/Linux
source .venv/bin/activate
```

3. **Install Dependencies**:
```bash
pip install -r requirements.txt
```

4. **Configure Environment**:
```bash
# Copy example environment file
cp .env.example .env
# Edit .env with your settings
```

5. **Start the Server**:
```bash
python run.py
```

### Server Access
- **API Base URL**: `http://localhost:8000`
- **Interactive Docs**: `http://localhost:8000/docs`
- **Health Check**: `http://localhost:8000/`
- **ReDoc**: `http://localhost:8000/redoc`

## ✨ Features

### 🗄️ Database Operations
- **Auto-migration**: Database schema created automatically
- **Asset Tracking**: Complete file metadata storage
- **Timestamps**: Created/updated time tracking
- **Relationships**: Proper foreign key constraints

### 📁 File Management
- **Secure Upload**: UUID-based filenames prevent conflicts
- **Type Validation**: File type and size verification
- **Storage Abstraction**: Pluggable storage backends
- **Metadata Extraction**: File size and content type detection

### 🔌 API Features
- **OpenAPI Documentation**: Auto-generated interactive docs
- **Request Validation**: Pydantic schema validation
- **Error Handling**: Comprehensive error responses
- **CORS Support**: Cross-origin resource sharing
- **Health Monitoring**: Service health endpoints

### 🛡️ Security Features
- **Input Validation**: Comprehensive request validation
- **File Security**: Type and size restrictions
- **Path Validation**: Prevents directory traversal
- **Error Sanitization**: No sensitive data leakage

## 📡 API Endpoints

### Health & System
```http
GET /                    # Basic health check
GET /api/v1/health       # Detailed health status
```

### Asset Management
```http
POST /api/v1/upload      # Upload file with metadata
GET /api/v1/files        # List all assets with pagination
PUT /api/v1/files/{id}   # Update asset metadata
DELETE /api/v1/files/{id} # Delete asset by ID
```

### Response Format
```json
{
  "success": true,
  "data": {
    "id": 1,
    "filename": "uuid-generated-name.jpg",
    "original_filename": "my-photo.jpg",
    "content_type": "image/jpeg",
    "file_size": 1024000,
    "created_at": "2026-04-03T14:30:00Z"
  },
  "message": "File uploaded successfully",
  "timestamp": "2026-04-03T14:30:00Z"
}
```

## 🗄 Database Schema

### Assets Table
```sql
CREATE TABLE assets (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    filename VARCHAR(255) NOT NULL UNIQUE,
    original_filename VARCHAR(255) NOT NULL,
    content_type VARCHAR(100),
    file_size INTEGER NOT NULL,
    upload_path VARCHAR(500) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for performance
CREATE INDEX idx_assets_created_at ON assets(created_at);
CREATE INDEX idx_assets_filename ON assets(filename);
```

### Database Operations
- **Auto-creation**: Database and tables created on first run
- **Connection Pooling**: Efficient database connections
- **Transaction Management**: ACID compliance
- **Migration Ready**: Schema versioning support

## 📁 File Storage Architecture

### Local Storage (Default)
```
uploads/
├── 550e8400-e29b-41d4-a716-446655440000.jpg
├── 123e4567-e89b-12d3-a456-426614174000.pdf
└── 987e6543-e21b-43d4-a987-123456789abc.png
```

### Storage Features
- **UUID Naming**: Prevents filename conflicts
- **Path Validation**: Secure file path handling
- **Size Limits**: Configurable maximum file sizes
- **Type Detection**: MIME type identification
- **Metadata Tracking**: Database-stored file information

## 🔧 Configuration

### Environment Variables (.env)
```env
# Database Configuration
DATABASE_URL=sqlite:///./camp.db
# DATABASE_URL=postgresql://user:password@localhost/camp_db

# Storage Configuration
STORAGE_TYPE=local
LOCAL_STORAGE_PATH=./uploads
MAX_FILE_SIZE=52428800  # 50MB in bytes

# Application Configuration
APP_NAME=Cloud Asset Management Platform
APP_VERSION=1.0.0
DEBUG=True
LOG_LEVEL=INFO

# CORS Configuration
CORS_ORIGINS=["http://localhost:3004", "http://localhost:8081"]

# Security Configuration
ALLOWED_EXTENSIONS=[".jpg", ".jpeg", ".png", ".gif", ".pdf", ".txt", ".doc", ".docx"]
UPLOAD_CHUNK_SIZE=8192
```

### Configuration Hierarchy
1. **Environment Variables** (highest priority)
2. **.env File** (development)
3. **Default Values** (fallback)

## 🛠 Development

### Running Tests
```bash
# Install test dependencies
pip install pytest pytest-asyncio httpx

# Run tests
pytest

# Run with coverage
pytest --cov=app tests/
```

### Code Quality
```bash
# Code formatting
black app/
isort app/

# Linting
flake8 app/
pylint app/

# Type checking
mypy app/
```

### Development Server
```bash
# Hot reload enabled
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# With specific log level
uvicorn app.main:app --log-level debug

# With custom workers
uvicorn app.main:app --workers 4
```

## 🚀 Production Deployment

### Docker Configuration
```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app/ ./app/
COPY .env .

# Create uploads directory
RUN mkdir -p uploads

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/ || exit 1

# Start application
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Docker Compose
```yaml
version: '3.8'
services:
  backend:
    build: .
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=sqlite:///./camp.db
      - DEBUG=False
    volumes:
      - ./uploads:/app/uploads
    restart: unless-stopped
```

### Production Settings
```env
# Production environment variables
DEBUG=False
LOG_LEVEL=WARNING
DATABASE_URL=postgresql://user:password@db:5432/camp_db
CORS_ORIGINS=["https://yourdomain.com"]
MAX_FILE_SIZE=104857600  # 100MB
```

## 🌐 Cloud Deployment (Azure)

### Azure Container Instances
```bash
# Build and push to Azure Container Registry
az acr build --registry myregistry --image camp-backend .
az container create \
  --resource-group my-rg \
  --name camp-backend \
  --image myregistry.azurecr.io/camp-backend \
  --ports 8000 \
  --environment-variables DATABASE_URL=postgresql://...
```

### Azure App Service
- **Platform**: Linux App Service
- **Runtime**: Python 3.11
- **Configuration**: Application settings for environment variables
- **Storage**: Azure Files for upload directory

### Azure Integration
- **Azure Blob Storage**: Replace local storage
- **Azure SQL Database**: Replace SQLite
- **Azure Application Gateway**: Load balancing and SSL
- **Azure Monitor**: Logging and metrics

## 📊 Performance & Monitoring

### Performance Optimizations
- **Database Indexing**: Optimized queries
- **File Streaming**: Memory-efficient uploads
- **Async Operations**: Non-blocking I/O
- **Connection Pooling**: Database efficiency

### Monitoring Features
- **Structured Logging**: JSON-formatted logs
- **Health Endpoints**: Service monitoring
- **Request Tracing**: Performance tracking
- **Error Metrics**: Failure rate monitoring

### Log Analysis
```bash
# View application logs
docker logs camp-backend

# Filter by level
docker logs camp-backend | grep ERROR

# Real-time monitoring
tail -f logs/app.log
```

## 🔒 Security Architecture

### Input Validation
- **Pydantic Schemas**: Type-safe request validation
- **File Type Checking**: MIME type verification
- **Size Limits**: Resource protection
- **Path Sanitization**: Directory traversal prevention

### Data Protection
- **Environment Variables**: Sensitive config protection
- **Error Sanitization**: No internal data exposure
- **CORS Configuration**: Restricted cross-origin access
- **Secure Headers**: Security best practices

### File Security
```
Security Layers:
1. File Extension Validation
2. MIME Type Verification  
3. Size Limit Enforcement
4. UUID Filename Generation
5. Path Traversal Prevention
6. Content Scanning (optional)
```

## 🧪 Testing Strategy

### Unit Tests
```python
# Test file: tests/test_asset_service.py
import pytest
from app.services.asset_service import AssetService

class TestAssetService:
    def test_file_upload_validation(self):
        # Test file validation logic
        pass
    
    def test_uuid_filename_generation(self):
        # Test unique filename generation
        pass
```

### Integration Tests
```python
# Test file: tests/test_api.py
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_upload_file():
    with open("test_file.txt", "rb") as f:
        response = client.post("/api/v1/upload", files={"file": f})
    assert response.status_code == 200
```

### API Testing
```bash
# Health check
curl http://localhost:8000/

# File upload
curl -X POST http://localhost:8000/api/v1/upload \
  -F "file=@test.txt"

# List files
curl http://localhost:8000/api/v1/files
```

## 🔍 Troubleshooting

### Common Issues

#### Database Connection Error
```bash
# Check database file permissions
ls -la camp.db

# Recreate database
rm camp.db
python run.py  # Will auto-recreate
```

#### File Upload Issues
```bash
# Check uploads directory
ls -la uploads/
mkdir -p uploads
chmod 755 uploads/
```

#### Port Conflicts
```bash
# Check port usage
netstat -tulpn | grep 8000

# Use different port
uvicorn app.main:app --port 8001
```

### Debug Mode
```bash
# Enable debug logging
export LOG_LEVEL=DEBUG
python run.py
```

## 📚 API Documentation

### Interactive Documentation
- **Swagger UI**: `http://localhost:8000/docs`
- **ReDoc**: `http://localhost:8000/redoc`
- **OpenAPI JSON**: `http://localhost:8000/openapi.json`

### Client Libraries
```python
# Python client example
import requests

# Upload file
with open('file.txt', 'rb') as f:
    response = requests.post(
        'http://localhost:8000/api/v1/upload',
        files={'file': f}
    )

# List files
response = requests.get('http://localhost:8000/api/v1/files')
files = response.json()['data']
```

## 🔄 Version Management

### Semantic Versioning
- **Major**: Breaking changes
- **Minor**: New features (backward compatible)
- **Patch**: Bug fixes

### Database Migrations
```python
# Migration file structure
# alembic/versions/001_initial_schema.py
def upgrade():
    # Database schema changes
    pass

def downgrade():
    # Rollback changes
    pass
```

## 🤝 Contributing

### Development Workflow
1. **Fork** repository
2. **Create** feature branch
3. **Write** tests for new functionality
4. **Ensure** all tests pass
5. **Update** documentation
6. **Submit** pull request

### Code Standards
- **PEP 8**: Python style guide
- **Type Hints**: All functions typed
- **Docstrings**: Comprehensive documentation
- **Tests**: 90%+ coverage required

## 📄 License

MIT License - see LICENSE file for details

## 🆘 Support

### Getting Help
1. **Documentation**: Check this README and API docs
2. **Issues**: Open GitHub issue with details
3. **Logs**: Include application logs
4. **Environment**: Specify Python version and OS

### Issue Reporting Template
```markdown
## Issue Description
Brief description of the problem

## Steps to Reproduce
1. Step one
2. Step two
3. Step three

## Expected Behavior
What should happen

## Actual Behavior
What actually happens

## Environment
- Python version:
- OS:
- Browser (if applicable):
```

---

**Built with ❤️ using FastAPI, SQLAlchemy, and modern Python practices**

**Version**: 1.0.0  
**Last Updated**: 2026-04-03  
**Status**: Production Ready
