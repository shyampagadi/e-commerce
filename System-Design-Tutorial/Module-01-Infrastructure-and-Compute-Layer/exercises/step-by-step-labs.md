# Step-by-Step AWS Implementation Labs

## Lab 1: Auto Scaling Web Application
**Duration**: 2 hours | **Difficulty**: Intermediate

### Prerequisites
- AWS CLI configured
- Basic understanding of EC2 and Load Balancers

### Step 1: Create Launch Template
```bash
# Create launch template
aws ec2 create-launch-template \
    --launch-template-name web-app-template \
    --launch-template-data '{
        "ImageId": "ami-0abcdef1234567890",
        "InstanceType": "t3.micro",
        "SecurityGroupIds": ["sg-12345678"],
        "UserData": "IyEvYmluL2Jhc2gKZWNobyAiSGVsbG8gV29ybGQiID4gL3Zhci93d3cvaHRtbC9pbmRleC5odG1s"
    }'
```

### Step 2: Create Application Load Balancer
```bash
# Create ALB
aws elbv2 create-load-balancer \
    --name web-app-alb \
    --subnets subnet-12345678 subnet-87654321 \
    --security-groups sg-12345678

# Create target group
aws elbv2 create-target-group \
    --name web-app-targets \
    --protocol HTTP \
    --port 80 \
    --vpc-id vpc-12345678 \
    --health-check-path /health
```

### Step 3: Configure Auto Scaling Group
```bash
# Create Auto Scaling Group
aws autoscaling create-auto-scaling-group \
    --auto-scaling-group-name web-app-asg \
    --launch-template LaunchTemplateName=web-app-template,Version=1 \
    --min-size 2 \
    --max-size 10 \
    --desired-capacity 2 \
    --target-group-arns arn:aws:elasticloadbalancing:region:account:targetgroup/web-app-targets/1234567890123456 \
    --vpc-zone-identifier "subnet-12345678,subnet-87654321"
```

### Step 4: Create Scaling Policies
```bash
# Scale out policy
aws autoscaling put-scaling-policy \
    --auto-scaling-group-name web-app-asg \
    --policy-name scale-out \
    --policy-type TargetTrackingScaling \
    --target-tracking-configuration '{
        "TargetValue": 70.0,
        "PredefinedMetricSpecification": {
            "PredefinedMetricType": "ASGAverageCPUUtilization"
        }
    }'
```

### Step 5: Test Scaling Behavior
```bash
# Generate load to test scaling
for i in {1..1000}; do
    curl http://your-alb-dns-name.region.elb.amazonaws.com/
done

# Monitor scaling activity
aws autoscaling describe-scaling-activities --auto-scaling-group-name web-app-asg
```

### Expected Outcomes
- Auto Scaling Group scales out when CPU > 70%
- Load balancer distributes traffic evenly
- Health checks remove unhealthy instances

## Lab 2: Serverless API with Lambda
**Duration**: 90 minutes | **Difficulty**: Beginner

### Step 1: Create Lambda Function
```bash
# Create deployment package
echo 'exports.handler = async (event) => {
    return {
        statusCode: 200,
        body: JSON.stringify({
            message: "Hello from Lambda!",
            timestamp: new Date().toISOString()
        })
    };
};' > index.js

zip function.zip index.js

# Create Lambda function
aws lambda create-function \
    --function-name hello-api \
    --runtime nodejs18.x \
    --role arn:aws:iam::account:role/lambda-execution-role \
    --handler index.handler \
    --zip-file fileb://function.zip
```

### Step 2: Create API Gateway
```bash
# Create REST API
aws apigateway create-rest-api --name hello-api

# Get root resource ID
aws apigateway get-resources --rest-api-id your-api-id

# Create method
aws apigateway put-method \
    --rest-api-id your-api-id \
    --resource-id your-resource-id \
    --http-method GET \
    --authorization-type NONE
```

### Step 3: Configure Integration
```bash
# Set up Lambda integration
aws apigateway put-integration \
    --rest-api-id your-api-id \
    --resource-id your-resource-id \
    --http-method GET \
    --type AWS_PROXY \
    --integration-http-method POST \
    --uri arn:aws:apigateway:region:lambda:path/2015-03-31/functions/arn:aws:lambda:region:account:function:hello-api/invocations
```

### Step 4: Deploy API
```bash
# Deploy API
aws apigateway create-deployment \
    --rest-api-id your-api-id \
    --stage-name prod

# Test the API
curl https://your-api-id.execute-api.region.amazonaws.com/prod
```

### Expected Outcomes
- Serverless API responds to HTTP requests
- Lambda function executes on demand
- No infrastructure management required

## Lab 3: Container Deployment with ECS
**Duration**: 2.5 hours | **Difficulty**: Advanced

### Step 1: Create Container Image
```dockerfile
# Dockerfile
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

```bash
# Build and push to ECR
aws ecr create-repository --repository-name web-app
docker build -t web-app .
docker tag web-app:latest account.dkr.ecr.region.amazonaws.com/web-app:latest
docker push account.dkr.ecr.region.amazonaws.com/web-app:latest
```

### Step 2: Create ECS Cluster
```bash
# Create ECS cluster
aws ecs create-cluster --cluster-name web-app-cluster

# Create task definition
aws ecs register-task-definition --cli-input-json file://task-definition.json
```

### Step 3: Create ECS Service
```bash
# Create ECS service
aws ecs create-service \
    --cluster web-app-cluster \
    --service-name web-app-service \
    --task-definition web-app:1 \
    --desired-count 2 \
    --launch-type FARGATE \
    --network-configuration '{
        "awsvpcConfiguration": {
            "subnets": ["subnet-12345678", "subnet-87654321"],
            "securityGroups": ["sg-12345678"],
            "assignPublicIp": "ENABLED"
        }
    }'
```

### Step 4: Configure Load Balancer Integration
```bash
# Update service with load balancer
aws ecs update-service \
    --cluster web-app-cluster \
    --service web-app-service \
    --load-balancers targetGroupArn=arn:aws:elasticloadbalancing:region:account:targetgroup/web-app-targets/1234567890123456,containerName=web-app,containerPort=80
```

### Expected Outcomes
- Containerized application running on ECS
- Service automatically maintains desired count
- Load balancer distributes traffic to containers

## Troubleshooting Guide

### Common Issues and Solutions

#### Issue: Auto Scaling Not Working
**Symptoms**: Instances not scaling despite high CPU
**Solution**:
```bash
# Check CloudWatch metrics
aws cloudwatch get-metric-statistics \
    --namespace AWS/EC2 \
    --metric-name CPUUtilization \
    --dimensions Name=AutoScalingGroupName,Value=web-app-asg \
    --start-time 2023-01-01T00:00:00Z \
    --end-time 2023-01-01T01:00:00Z \
    --period 300 \
    --statistics Average
```

#### Issue: Lambda Function Timeout
**Symptoms**: Function times out after 3 seconds
**Solution**:
```bash
# Increase timeout
aws lambda update-function-configuration \
    --function-name hello-api \
    --timeout 30
```

#### Issue: ECS Service Not Starting
**Symptoms**: Tasks keep stopping
**Solution**:
```bash
# Check service events
aws ecs describe-services \
    --cluster web-app-cluster \
    --services web-app-service \
    --query 'services[0].events'
```

## Performance Benchmarking

### Load Testing Scripts
```bash
# Install Apache Bench
sudo apt-get install apache2-utils

# Test Auto Scaling setup
ab -n 10000 -c 100 http://your-alb-dns-name/

# Test Lambda API
ab -n 1000 -c 50 https://your-api-gateway-url/

# Test ECS service
ab -n 5000 -c 75 http://your-ecs-alb-dns-name/
```

### Expected Performance Metrics
- **Auto Scaling**: < 2 minutes scale-out time
- **Lambda**: < 100ms response time (warm)
- **ECS**: < 50ms response time, 99.9% availability
