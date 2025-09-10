# Exercise 1 Solution: EC2 Instance Setup

## Overview
This solution demonstrates how to set up and configure EC2 instances for a web application.

## Step-by-Step Solution

### 1. Launch EC2 Instance

#### Instance Configuration
```bash
# Launch EC2 instance
aws ec2 run-instances \
  --image-id ami-0c02fb55956c7d316 \
  --instance-type t3.medium \
  --key-name my-key-pair \
  --security-group-ids sg-12345678 \
  --subnet-id subnet-12345678 \
  --associate-public-ip-address \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=web-server}]'
```

### 2. Configure Security Groups

#### Security Group Rules
- **SSH (22)**: 0.0.0.0/0 (for administration)
- **HTTP (80)**: 0.0.0.0/0 (for web traffic)
- **HTTPS (443)**: 0.0.0.0/0 (for secure web traffic)

### 3. Install Web Server

#### Install Apache
```bash
# Update system
sudo yum update -y

# Install Apache
sudo yum install -y httpd

# Start and enable
sudo systemctl start httpd
sudo systemctl enable httpd
```

### 4. Deploy Sample Application

#### Create Sample Page
```bash
# Create sample HTML
sudo tee /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Sample Web Application</title>
</head>
<body>
    <h1>Welcome to Sample Web Application</h1>
    <p>This is running on EC2.</p>
</body>
</html>
EOF
```

### 5. Test Connectivity

#### Basic Test
```bash
# Test HTTP
curl -I http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

# Performance test
ab -n 1000 -c 10 http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)/
```

## Expected Results
- **Response Time**: <100ms
- **Throughput**: 500-1000 requests/second
- **Cost**: ~$30/month

