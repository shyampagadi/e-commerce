# AWS Lambda and Serverless

## Overview

AWS Lambda is a serverless compute service that runs code without provisioning or managing servers.

## Key Features

### 1. Event-Driven Execution
- **API Gateway**: HTTP requests
- **S3 Events**: File uploads
- **DynamoDB**: Database changes
- **SNS/SQS**: Message processing

### 2. Automatic Scaling
- **Concurrent Executions**: Up to 1000 by default
- **Scale to Zero**: No cost when not running
- **Provisioned Concurrency**: Keep functions warm

### 3. Pay-per-Use Pricing
- **Request Count**: Number of invocations
- **Duration**: Execution time
- **Memory**: Allocated memory

## Function Example

```javascript
exports.handler = async (event) => {
    const result = await processEvent(event);
    return {
        statusCode: 200,
        body: JSON.stringify(result)
    };
};
```

## Best Practices

### Performance
- **Minimize Dependencies**: Reduce package size
- **Connection Pooling**: Reuse database connections
- **Cold Start Mitigation**: Use provisioned concurrency

### Security
- **IAM Roles**: Use least privilege principle
- **VPC**: Use VPC for network isolation
- **Secrets**: Use AWS Secrets Manager

