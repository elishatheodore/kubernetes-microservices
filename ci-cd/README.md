# CI/CD Configuration

## 📁 Moved to GitHub Actions

**Workflow files have been moved to `.github/workflows/` for GitHub Actions compatibility.**

### 📍 New Location
- **Main Workflow**: `.github/workflows/build-and-deploy.yml`

### 🔄 Why Moved?
GitHub Actions only recognizes workflows in `.github/workflows/` directory. Moving the workflow file enables:
- Automatic triggers on push/PR
- Manual workflow dispatch
- Proper GitHub Actions integration
- Workflow visibility in repository

### 📋 Reference
This directory is kept for reference and documentation purposes. The actual CI/CD pipeline now runs from:
- `.github/workflows/build-and-deploy.yml`

### 🚀 Features
The moved workflow includes:
- Multi-architecture Docker builds
- Security scanning with Trivy
- Helm chart validation
- Automated deployments to staging/production
- Manual deployment triggers
- Multi-cluster support

### 📖 Documentation
For complete CI/CD documentation, see:
- Main README.md → CI/CD Integration section
- Multi-Cluster Deployment Guide

---

**Status**: ✅ Successfully migrated to GitHub Actions  
**Last Updated**: 2026-04-06
