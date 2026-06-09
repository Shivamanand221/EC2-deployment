# EC2 Deployment with Strapi

A production-ready deployment setup for **Strapi** (headless CMS) on AWS EC2 with containerization, infrastructure-as-code, and database management.

![TypeScript](https://img.shields.io/badge/TypeScript-51.1%25-blue)
![HCL](https://img.shields.io/badge/HCL-29.4%25-purple)
![Shell](https://img.shields.io/badge/Shell-17.6%25-green)
![Docker](https://img.shields.io/badge/Docker-1.9%25-blue?logo=docker)

---

## 📋 Table of Contents

- [Overview](#overview)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Local Development](#local-development)
- [Docker & Docker Compose](#docker--docker-compose)
- [EC2 User Data Script](#ec2-user-data-script)
- [Terraform Deployment](#terraform-deployment)
- [Environment Configuration](#environment-configuration)
- [Database Management](#database-management)
- [Deployment](#deployment)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

---

## Overview

This repository provides a complete infrastructure setup for deploying **Strapi**, a powerful headless CMS, on AWS EC2 instances. It includes:

- **Strapi v5.31.2** - Modern headless CMS for content management
- **Docker & Docker Compose** - Containerized deployment
- **Terraform (HCL)** - Infrastructure as Code for AWS resources
- **EC2 User Data Script** - Automated EC2 initialization and deployment
- **PostgreSQL** - Production-grade database
- **TypeScript** - Type-safe application code

Perfect for teams looking to deploy a scalable, maintainable CMS infrastructure on AWS with automated provisioning.

---

## Tech Stack

| Technology | Version | Purpose |
|-----------|---------|---------|
| **Strapi** | 5.31.2 | Headless CMS |
| **Node.js** | 20.x - 24.x | Runtime |
| **PostgreSQL** | 15 | Database |
| **Docker** | Latest | Containerization |
| **Docker Compose** | 2.25.0 | Multi-container orchestration |
| **Terraform** | Latest | Infrastructure as Code |
| **TypeScript** | ^5 | Type safety |
| **React** | ^18.0.0 | Admin UI |

---

## Project Structure

```
EC2-deployment/
├── src/                      # Application source code (TypeScript)
├── public/                   # Static assets
├── database/                 # Database schemas and migrations
├── config/                   # Application configuration
├── terraform/                # Terraform IaC files (HCL) - 29.4%
│   ├── main.tf              # Main AWS resources
│   ├── variables.tf         # Input variables
│   ├── outputs.tf           # Output values
│   ├── terraform.tfvars     # Variable values
│   └── user_data.sh         # EC2 instance initialization script ⭐
├── types/                    # TypeScript type definitions
├── Dockerfile               # Container image definition (1.9%)
├── compose.yaml             # Docker Compose configuration
├── package.json             # Dependencies
├── tsconfig.json            # TypeScript configuration
├── .env.example             # Environment variables template
└── README.md                # This file

**Language Composition:**
- TypeScript: 51.1%
- HCL: 29.4%
- Shell: 17.6%
- Dockerfile: 1.9%
```

---

## Prerequisites

Before you begin, ensure you have the following installed:

- **Node.js** (v20.0.0 or higher, up to 24.x)
- **npm** (v6.0.0 or higher)
- **Docker** & **Docker Compose** (for containerized deployment)
- **Terraform** (for AWS infrastructure provisioning)
- **AWS CLI** (for AWS interactions)
- **Git**

### Verify Installation

```bash
node --version          # Should be v20.x - v24.x
npm --version           # Should be v6.0.0+
docker --version        # Latest version
docker-compose --version
terraform --version     # Latest version
aws --version           # Latest version
```

---

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/Shivamanand221/EC2-deployment.git
cd EC2-deployment
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Configure Environment Variables

```bash
cp .env.example .env
# Edit .env with your configuration
nano .env
```

See [Environment Configuration](#environment-configuration) for details.

### 4. Run Strapi

**Development Mode:**
```bash
npm run develop
```

**Production Mode:**
```bash
npm start
```

The application will be available at `http://localhost:1337`

---

## Local Development

### Development Commands

| Command | Description |
|---------|-------------|
| `npm run dev` | Start in development mode with hot reload |
| `npm run develop` | Alias for development mode |
| `npm run build` | Build the admin panel |
| `npm run start` | Start in production mode |
| `npm run console` | Open Strapi console |
| `npm run deploy` | Deploy to Strapi Cloud |

### Development Workflow

```bash
# Install dependencies
npm install

# Start development server with auto-reload
npm run develop

# In another terminal, build the admin panel
npm run build

# Run the production build
npm start
```

### TypeScript Support

This project uses TypeScript with strict type checking. Check your code:

```bash
npx tsc --noEmit
```

---

## Docker & Docker Compose

### Build Docker Image

```bash
docker build -t strapi:latest .
```

### Run with Docker Compose

```bash
docker-compose up -d
```

This will start:
- **Strapi** on `http://localhost:1337`
- **PostgreSQL** database (internal networking)

### Docker Compose Services

```yaml
services:
  postgres:
    - Image: postgres:15
    - Database: strapi
    - Port: 5432 (internal)

  strapi:
    - Image: shivamanand221/strapi:latest
    - Port: 1337
    - Depends on: postgres
```

### Useful Docker Commands

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f strapi

# Access PostgreSQL shell
docker-compose exec postgres psql -U strapi -d strapi

# Remove all data and volumes
docker-compose down -v
```

---

## EC2 User Data Script

### 📜 Overview

The `terraform/user_data.sh` script is a **critical automation script** that automatically provisions and initializes AWS EC2 instances with a fully functional Strapi + PostgreSQL deployment. This script is executed automatically when an EC2 instance is launched via Terraform.

### 🔧 What the Script Does

Located at: `terraform/user_data.sh`

#### 1. **System Initialization**
```bash
apt-get update -y
apt-get upgrade -y
```
- Updates the system package manager
- Upgrades all existing packages to latest versions

#### 2. **Docker Installation**
```bash
apt-get install -y ca-certificates curl gnupg lsb-release
curl -fsSL https://get.docker.com | sh
```
- Installs Docker prerequisites
- Downloads and installs official Docker from get.docker.com
- Supports both Docker and Docker Compose from the start

#### 3. **Docker Service Configuration**
```bash
systemctl start docker
systemctl enable docker
usermod -aG docker ubuntu
```
- Starts the Docker daemon immediately
- Enables Docker to auto-start on system reboot
- Adds `ubuntu` user to docker group (no sudo needed for docker commands)

#### 4. **Docker Compose Installation**
```bash
curl -L https://github.com/docker/compose/releases/download/v2.25.0/docker-compose-linux-x86_64 \
  -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```
- Downloads Docker Compose v2.25.0 for Linux x86_64
- Makes it executable and places in system PATH

#### 5. **Application Directory Setup**
```bash
mkdir -p /opt/strapi
chown ubuntu:ubuntu /opt/strapi
cd /opt/strapi
```
- Creates `/opt/strapi` directory for application files
- Sets proper ownership and permissions

#### 6. **Docker Compose Configuration Generation**
```bash
cat <<EOF > docker-compose.yml
# PostgreSQL service configuration
# Strapi service configuration with environment variables
# Ports and volume mappings
EOF
```
- Generates `docker-compose.yml` with:
  - **PostgreSQL 15** database service
  - **Strapi** application service
  - Pre-configured environment variables
  - Port 1337 mapping for Strapi
  - Persistent database volumes

#### 7. **Container Startup**
```bash
docker-compose pull
docker-compose up -d
```
- Pulls latest Docker images from registry
- Starts all services in detached mode (background)

### 🚀 How It's Used in Terraform

The script is referenced in your Terraform EC2 resource:

```hcl
resource "aws_instance" "strapi_instance" {
  ami           = "ami-0c55b159cbfafe1f0"  # Ubuntu 20.04 LTS
  instance_type = "t3.medium"
  
  # Execute user_data.sh on instance launch
  user_data = file("${path.module}/user_data.sh")
  
  tags = {
    Name = "Strapi-EC2-Instance"
  }
}
```

### ✅ Automated Setup Benefits

| Benefit | Details |
|---------|---------|
| **Zero Manual Steps** | No SSH into instance and running commands manually |
| **Idempotent** | Safe to re-run without breaking existing setup |
| **Fast Deployment** | Entire stack runs within 2-5 minutes |
| **Reproducible** | Same setup every time instance launches |
| **Production-Ready** | Docker best practices built-in |

### 📝 Important Notes

- **Security Keys**: The script includes placeholder security keys. Update them for production in `terraform/user_data.sh` or pass them as environment variables
- **Image Registry**: The script uses `shivamanand221/strapi:latest`. Ensure your Docker image is pushed to Docker Hub
- **Instance Type**: Use at least `t3.medium` for Strapi to run smoothly
- **Security Groups**: Ensure port 1337 is open in your AWS security group

### 🔄 Post-Deployment

After EC2 instance launches with this script:

```bash
# SSH into the instance
ssh -i your-key.pem ubuntu@your-instance-ip

# Check if services are running
docker-compose ps

# View Strapi logs
docker-compose logs -f strapi

# Access Strapi admin panel
# Navigate to: http://your-instance-ip:1337/admin
```

---

## Terraform Deployment

Deploy infrastructure to AWS using Terraform.

### Terraform Files

- **main.tf** - EC2 instances, security groups, VPCs
- **variables.tf** - Input variables and configurations
- **outputs.tf** - Output values (IPs, DNS names, etc.)
- **terraform.tfvars** - Variable values
- **user_data.sh** - EC2 instance initialization script ⭐ (17.6% Shell code)

### Deployment Steps

```bash
cd terraform

# Initialize Terraform
terraform init

# Plan the infrastructure
terraform plan -out=tfplan

# Review the plan and apply
terraform apply tfplan

# View outputs
terraform output
```

### Common Terraform Commands

```bash
# Validate configuration
terraform validate

# Format code
terraform fmt -recursive

# Destroy infrastructure
terraform destroy

# Get current state
terraform state list
terraform state show <resource>

# Show user_data script that will be executed
terraform plan -out=tfplan
terraform show tfplan | grep user_data
```

### AWS Prerequisites

- AWS Account with appropriate permissions (EC2, VPC, Security Groups)
- AWS CLI configured with credentials
- VPC and security group access

---

## Environment Configuration

### .env File Template

Copy `.env.example` to `.env` and configure:

```env
# Server Configuration
HOST=0.0.0.0
PORT=1337

# Security Keys (Generate new values for production!)
APP_KEYS="key1,key2,key3,key4"
API_TOKEN_SALT=random_salt_value
ADMIN_JWT_SECRET=random_secret
TRANSFER_TOKEN_SALT=random_salt_value
JWT_SECRET=random_secret
ENCRYPTION_KEY=random_encryption_key

# Database Configuration (for non-Docker deployments)
DATABASE_CLIENT=postgres
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_NAME=strapi
DATABASE_USERNAME=strapi
DATABASE_PASSWORD=secure_password
```

### Generating Secure Keys

```bash
# Generate random strings for security keys
node -e "console.log(require('crypto').randomBytes(16).toString('base64'))"
```

### Environment Variables for Docker Compose

The `compose.yaml` file includes pre-configured environment variables. Update them for your deployment.

### Updating user_data.sh for Production

For production deployments, update the security keys in `terraform/user_data.sh`:

```bash
# Replace placeholder values with real ones
APP_KEYS: your-real-app-keys
API_TOKEN_SALT: your-real-api-token-salt
ADMIN_JWT_SECRET: your-real-admin-jwt-secret
# ... etc
```

---

## Database Management

### PostgreSQL Database

This project uses PostgreSQL 15 as the primary database.

### Database Configuration

```yaml
# Via Docker Compose
POSTGRES_DB: strapi
POSTGRES_USER: strapi
POSTGRES_PASSWORD: strapi
```

### Database Backups

```bash
# Backup
docker-compose exec postgres pg_dump -U strapi -d strapi > backup.sql

# Restore
docker-compose exec -T postgres psql -U strapi -d strapi < backup.sql
```

### Database Migrations

Strapi handles migrations automatically. To manually trigger:

```bash
npm run strapi migrate
```

---

## Deployment

### Deployment Options

1. **Automated EC2 Deployment** - Using Terraform + user_data.sh (Recommended)
2. **Docker on EC2** - Manual Docker Compose setup
3. **Strapi Cloud** - Managed hosting by Strapi
4. **Custom EC2** - Self-managed on AWS

### Deploy Automatically with Terraform + user_data.sh

This is the **fastest and most reproducible** way:

```bash
# 1. Navigate to terraform directory
cd terraform

# 2. Configure variables
# Edit terraform.tfvars with your AWS details

# 3. Initialize Terraform
terraform init

# 4. Plan and review
terraform plan

# 5. Apply configuration
terraform apply

# 6. Get instance IP
terraform output instance_public_ip

# 7. Access Strapi (wait 2-5 minutes for user_data to complete)
# Visit: http://<instance-public-ip>:1337/admin
```

### Deploy to EC2 Using Docker (Manual)

```bash
# 1. Build Docker image
docker build -t shivamanand221/strapi:latest .

# 2. Push to Docker Hub
docker push shivamanand221/strapi:latest

# 3. SSH into EC2 instance
ssh -i your-key.pem ec2-user@your-instance-ip

# 4. Install Docker and Docker Compose
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

# 5. Create docker-compose.yml (copy from compose.yaml)
# 6. Pull and run
docker-compose up -d
```

### Deploy to Strapi Cloud

```bash
npm run deploy
```

Follow the interactive prompts to deploy to Strapi Cloud.

### Production Checklist

- [ ] Generate new security keys and secrets (don't use defaults)
- [ ] Configure PostgreSQL with strong passwords
- [ ] Set up SSL/TLS certificates
- [ ] Configure domain name and DNS
- [ ] Set up monitoring and logging (CloudWatch)
- [ ] Configure automated backups
- [ ] Set environment to production
- [ ] Enable security headers
- [ ] Set up CI/CD pipeline
- [ ] Test all API endpoints
- [ ] Update security groups for restricted access
- [ ] Enable EC2 instance termination protection

---

## Troubleshooting Common Issues

#### Port 1337 Already in Use

```bash
# Kill process on port 1337
lsof -i :1337
kill -9 <PID>

# Or use a different port
PORT=3000 npm run develop
```

#### Module Not Found Errors

```bash
# Clear node_modules and reinstall
rm -rf node_modules package-lock.json
npm install

# Clear Strapi cache
rm -rf .strapi
```

#### Docker Image Build Fails

```bash
# Build with verbose output
docker build --no-cache -t strapi:latest .

# Check Node version in Dockerfile
cat Dockerfile
```

#### Terraform Errors

```bash
# Validate Terraform files
terraform validate

# Check AWS credentials
aws sts get-caller-identity

# Review Terraform state
terraform state list
```

#### user_data.sh Not Executing

```bash
# SSH into EC2 instance
ssh -i your-key.pem ubuntu@your-instance-ip

# Check user_data logs
tail -100 /var/log/cloud-init-output.log

# Verify Docker is running
docker ps
docker-compose ps
```

#### Strapi Not Accessible After EC2 Launch

```bash
# Wait for user_data.sh to complete (2-5 minutes)
# Check if containers are running
docker-compose ps

# Check Strapi logs
docker-compose logs strapi

# Verify port 1337 is open in security group
# Check in AWS Console: EC2 > Security Groups > Inbound Rules
```

## Roadmap

- [ ] Add GitHub Actions CI/CD pipeline
- [ ] Implement automated backups with AWS S3
- [ ] Add Kubernetes deployment option
- [ ] Set up monitoring with CloudWatch/Prometheus
- [ ] Add API documentation with Swagger
- [ ] Implement automated security scanning
- [ ] Add RDS support for managed PostgreSQL
- [ ] Create multi-environment setup (dev, staging, prod)

---

## Acknowledgments

- [Strapi](https://strapi.io/) - Excellent headless CMS
- [Terraform](https://www.terraform.io/) - Infrastructure as Code
- [Docker](https://www.docker.com/) - Containerization platform
- [AWS](https://aws.amazon.com/) - Cloud infrastructure
