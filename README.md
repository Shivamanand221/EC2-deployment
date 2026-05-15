# EC2 Deployment with Strapi

A production-ready deployment setup for **Strapi** (headless CMS) on AWS EC2 with containerization, infrastructure-as-code, and database management.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Local Development](#local-development)
- [Docker & Docker Compose](#docker--docker-compose)
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
- **PostgreSQL** - Production-grade database

Perfect for teams looking to deploy a scalable, maintainable CMS infrastructure on AWS.

---

## Tech Stack

| Technology | Version | Purpose |
|-----------|---------|---------|
| **Strapi** | 5.31.2 | Headless CMS |
| **Node.js** | 20.x - 24.x | Runtime |
| **PostgreSQL** | 15 | Database |
| **Docker** | Latest | Containerization |
| **Terraform** | Latest | Infrastructure as Code |

---

## Project Structure

```
EC2-deployment/
├── src/                      # Application source code (TypeScript)
├── public/                   # Static assets
├── database/                 # Database schemas and migrations
├── config/                   # Application configuration
├── terraform/                # Terraform IaC files (HCL)
│   ├── main.tf              # Main AWS resources
│   ├── variables.tf         # Input variables
│   ├── outputs.tf           # Output values
│   └── terraform.tfvars     # Variable values
├── types/                    # TypeScript type definitions
├── Dockerfile               # Container image definition
├── compose.yaml             # Docker Compose configuration
├── package.json             # Dependencies
├── tsconfig.json            # TypeScript configuration
├── .env.example             # Environment variables template
└── README.md                # This file
```

---

## Prerequisites

Before you begin, ensure you have the following installed:

- **Node.js** (v20.0.0 or higher, up to 24.x)
- **npm** (v6.0.0 or higher)
- **Docker** & **Docker Compose** (for containerized deployment)
- **Terraform** (for AWS infrastructure provisioning)
- **AWS CLI** (for AWS interactions)

### Verify Installation

```bash
node --version          # Should be v20.x - v24.x
npm --version           # Should be v6.0.0+
docker --version        # Latest version
docker-compose --version
terraform --version     # Latest version
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

## Terraform Deployment

Deploy infrastructure to AWS using Terraform.

### Terraform Files

- **main.tf** - EC2 instances, security groups, VPCs
- **variables.tf** - Input variables and configurations
- **outputs.tf** - Output values (IPs, DNS names, etc.)
- **terraform.tfvars** - Variable values

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
```

### AWS Prerequisites

- AWS Account with appropriate permissions
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

### Access Database

**From Docker Container:**
```bash
docker-compose exec postgres psql -U strapi -d strapi
```

**From Host (if PostgreSQL installed):**
```bash
psql -h localhost -U strapi -d strapi
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

1. **Docker on EC2** - Recommended for most use cases
2. **Strapi Cloud** - Managed hosting by Strapi
3. **Custom EC2** - Self-managed on AWS

### Deploy to EC2 Using Docker

```bash
# 1. Build Docker image
docker build -t shivamanand221/strapi:latest .

# 2. Push to Docker Hub (or your registry)
docker push shivamanand221/strapi:latest

# 3. SSH into EC2 instance
ssh -i your-key.pem ec2-user@your-instance-ip

# 4. Pull and run
docker pull shivamanand221/strapi:latest
docker-compose up -d
```

### Deploy to Strapi Cloud

```bash
npm run deploy
```

Follow the interactive prompts to deploy to Strapi Cloud.

### Production Checklist

- [ ] Generate new security keys and secrets
- [ ] Configure PostgreSQL with strong passwords
- [ ] Set up SSL/TLS certificates
- [ ] Configure domain name and DNS
- [ ] Set up monitoring and logging
- [ ] Configure backups
- [ ] Set environment to production
- [ ] Enable security headers
- [ ] Set up CI/CD pipeline
- [ ] Test all API endpoints

---

## Troubleshooting

### Common Issues

#### Port 1337 Already in Use

```bash
# Kill process on port 1337
lsof -i :1337
kill -9 <PID>

# Or use a different port
PORT=3000 npm run develop
```

#### PostgreSQL Connection Error

```bash
# Check if Docker Compose services are running
docker-compose ps

# Check PostgreSQL logs
docker-compose logs postgres

# Verify environment variables
cat .env
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

### Getting Help

- **Strapi Docs**: https://docs.strapi.io
- **Strapi Discord**: https://discord.strapi.io
- **AWS Documentation**: https://docs.aws.amazon.com
- **Terraform Docs**: https://www.terraform.io/docs

---

## API Documentation

Once Strapi is running, access:

- **API Documentation**: `http://localhost:1337/documentation`
- **Admin Panel**: `http://localhost:1337/admin`
- **GraphQL (if enabled)**: `http://localhost:1337/graphql`

---

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

### Development Guidelines

- Follow TypeScript best practices
- Add tests for new features
- Update documentation
- Keep commits atomic and descriptive

---

## License

This project is open source and available under the MIT License.

---

## Support

For issues and questions:
- 🐛 **Bug Reports**: [GitHub Issues](https://github.com/Shivamanand221/EC2-deployment/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/Shivamanand221/EC2-deployment/discussions)
- 📧 **Email**: Check repository profile

---

## Roadmap

- [ ] Add GitHub Actions CI/CD pipeline
- [ ] Implement automated backups
- [ ] Add Kubernetes deployment option
- [ ] Set up monitoring with CloudWatch/Prometheus
- [ ] Add API documentation with Swagger
- [ ] Implement automated security scanning

---

## Acknowledgments

- [Strapi](https://strapi.io/) - Excellent headless CMS
- [Terraform](https://www.terraform.io/) - Infrastructure as Code
- [Docker](https://www.docker.com/) - Containerization platform
- [AWS](https://aws.amazon.com/) - Cloud infrastructure

---

<div align="center">

**Made with ❤️ by [Shivamanand221](https://github.com/Shivamanand221)**

⭐ If you found this helpful, please consider giving it a star!

</div>
