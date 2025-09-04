# 🚀 Quick Start Deployment Guide

## 📋 What You Get

This deployment guide provides:
- **3-Tier Docker Architecture** (Frontend + Backend + Database)
- **GitHub Actions CI** (Build, Test, Security Scan)
- **GitLab CD** (Deploy to Staging/Production)
- **Production-Ready Kubernetes** manifests
- **Monitoring & Alerting** setup
- **Automated Deployment Script**

## ⚡ Quick Start (5 Minutes)

### **Option 1: Automated Script (Recommended)**
```bash
# Make script executable and run
chmod +x deploy.sh
./deploy.sh

# That's it! Your app will be running at:
# Frontend: http://localhost:3000
# Backend: http://localhost:8000
# API Docs: http://localhost:8000/docs
```

### **Option 2: Manual Docker Compose**
```bash
# 1. Create environment file
cp .env.example .env

# 2. Start all services
docker-compose up --build -d

# 3. Check status
docker-compose ps
```

## 📁 File Structure Overview

```
e-commerce/
├── 📄 DEPLOYMENT_GUIDE.md      # Complete deployment guide
├── 📄 DEPLOYMENT_README.md     # This quick start guide
├── 🔧 deploy.sh               # Automated deployment script
├── 🐳 docker-compose.yml      # Multi-container setup
├── 📁 .github/workflows/      # GitHub Actions CI
├── 📁 .gitlab/               # GitLab CD configuration
├── 📁 k8s/                   # Kubernetes manifests
├── 📁 frontend/              # React application
├── 📁 backend/               # FastAPI application
└── 📁 database/              # Database scripts
```

## 🎯 Deployment Options

### **1. Local Development (Docker)**
- **Purpose**: Development and testing
- **Time**: 5 minutes
- **Command**: `./deploy.sh`
- **Access**: http://localhost:3000

### **2. Staging Environment (Kubernetes)**
- **Purpose**: Pre-production testing
- **Time**: 15 minutes
- **Requirements**: Kubernetes cluster
- **Command**: `kubectl apply -f k8s/staging/`

### **3. Production Environment (Full CI/CD)**
- **Purpose**: Live application
- **Time**: 30 minutes setup
- **Requirements**: GitHub + GitLab + Kubernetes
- **Process**: Automated via CI/CD pipeline

## 🔧 Available Commands

### **Deployment Script Commands**
```bash
./deploy.sh           # Deploy application
./deploy.sh stop      # Stop all services
./deploy.sh restart   # Restart services
./deploy.sh logs      # View logs
./deploy.sh status    # Check status
./deploy.sh clean     # Remove everything
./deploy.sh help      # Show help
```

### **Docker Compose Commands**
```bash
docker-compose up -d           # Start services
docker-compose down            # Stop services
docker-compose logs -f         # View logs
docker-compose ps              # Check status
docker-compose restart backend # Restart specific service
```

### **Kubernetes Commands**
```bash
kubectl get pods -n ecommerce     # Check pods
kubectl logs -f <pod-name>        # View logs
kubectl describe pod <pod-name>   # Debug pod
kubectl port-forward svc/frontend 3000:80  # Access service
```

## 🔐 Default Credentials

### **Application Login**
- **Admin**: admin@ecommerce.com / admin123
- **User**: user@ecommerce.com / user123

### **Database Access**
- **Host**: localhost:5432
- **Database**: ecommerce_db
- **Username**: postgres
- **Password**: admin

## 🌐 Access URLs

### **Local Development**
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8000
- **API Documentation**: http://localhost:8000/docs
- **Database**: localhost:5432

### **Production (Replace with your domain)**
- **Frontend**: https://yourdomain.com
- **Backend API**: https://yourdomain.com/api
- **Admin Panel**: https://yourdomain.com/admin

## 🚨 Troubleshooting

### **Common Issues**

#### **1. Port Already in Use**
```bash
# Check what's using the port
lsof -i :3000
lsof -i :8000
lsof -i :5432

# Kill the process
kill -9 <PID>
```

#### **2. Docker Issues**
```bash
# Restart Docker service
sudo systemctl restart docker

# Clean Docker system
docker system prune -a

# Check Docker logs
docker-compose logs <service-name>
```

#### **3. Database Connection Failed**
```bash
# Check database status
docker-compose exec database pg_isready -U postgres

# Reset database
docker-compose down -v
docker-compose up database -d
```

#### **4. Frontend Not Loading**
```bash
# Check if backend is running
curl http://localhost:8000/health

# Rebuild frontend
docker-compose up --build frontend
```

### **Getting Help**

#### **Check Service Status**
```bash
# Overall status
./deploy.sh status

# Detailed container info
docker-compose ps
docker stats
```

#### **View Logs**
```bash
# All services
./deploy.sh logs

# Specific service
docker-compose logs backend
docker-compose logs frontend
docker-compose logs database
```

#### **Debug Container**
```bash
# Access container shell
docker-compose exec backend bash
docker-compose exec frontend sh
docker-compose exec database psql -U postgres
```

## 📊 Performance & Monitoring

### **Health Checks**
```bash
# Backend health
curl http://localhost:8000/health

# Database health
docker-compose exec database pg_isready -U postgres

# Frontend health
curl http://localhost:3000
```

### **Performance Monitoring**
- **Metrics**: Available at http://localhost:8000/metrics
- **Logs**: Structured JSON logs in containers
- **Alerts**: Configured for production deployment

## 🔒 Security Features

### **Built-in Security**
- ✅ JWT Authentication
- ✅ CORS Protection
- ✅ Input Validation
- ✅ SQL Injection Prevention
- ✅ XSS Protection
- ✅ HTTPS/TLS (Production)

### **Security Scanning**
- ✅ Container Vulnerability Scanning
- ✅ Dependency Scanning
- ✅ Static Code Analysis
- ✅ Dynamic Security Testing

## 🚀 Next Steps

### **For Development**
1. ✅ Run `./deploy.sh` to start locally
2. ✅ Access http://localhost:3000
3. ✅ Make changes to code
4. ✅ Test your changes

### **For Production**
1. ✅ Follow the complete [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
2. ✅ Setup GitHub Actions CI
3. ✅ Configure GitLab CD
4. ✅ Deploy to Kubernetes

### **For Scaling**
1. ✅ Add horizontal pod autoscaling
2. ✅ Setup load balancing
3. ✅ Configure CDN
4. ✅ Implement caching

## 📞 Support

### **Documentation**
- **Complete Guide**: [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
- **API Documentation**: http://localhost:8000/docs
- **Test Results**: [TEST_SUMMARY.md](TEST_SUMMARY.md)

### **Quick Commands Reference**
```bash
# Start everything
./deploy.sh

# Check if working
curl http://localhost:8000/health
curl http://localhost:3000

# View what's running
docker-compose ps

# Stop everything
./deploy.sh stop
```

---

## 🎉 Success!

If you can access http://localhost:3000 and see the e-commerce application, you're all set! 

Your 3-tier application is now running with:
- ✅ React Frontend
- ✅ FastAPI Backend  
- ✅ PostgreSQL Database
- ✅ Docker Containerization
- ✅ Health Monitoring
- ✅ Security Features

**Happy coding! 🚀**
