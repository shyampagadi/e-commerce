# S3 and CloudFront CDN

## Overview
Learn to implement AWS S3 for storage and CloudFront for global content delivery.

## S3 Bucket Configuration

### Creating S3 Buckets
```bash
# Create S3 bucket
aws s3 mb s3://my-app-static-assets --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning \
    --bucket my-app-static-assets \
    --versioning-configuration Status=Enabled

# Configure public access block
aws s3api put-public-access-block \
    --bucket my-app-static-assets \
    --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=false,RestrictPublicBuckets=false
```

### Bucket Policy for CloudFront
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowCloudFrontAccess",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity E1234567890123"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::my-app-static-assets/*"
        }
    ]
}
```

### S3 Website Hosting
```bash
# Configure website hosting
aws s3 website s3://my-app-static-assets \
    --index-document index.html \
    --error-document error.html

# Upload files
aws s3 sync ./dist/ s3://my-app-static-assets/ \
    --delete \
    --cache-control "max-age=31536000" \
    --exclude "*.html" \
    --exclude "service-worker.js"

# Upload HTML with shorter cache
aws s3 sync ./dist/ s3://my-app-static-assets/ \
    --cache-control "max-age=300" \
    --include "*.html" \
    --include "service-worker.js"
```

## CloudFront Distribution

### Creating Distribution
```yaml
# cloudfront-distribution.yml
Resources:
  CloudFrontDistribution:
    Type: AWS::CloudFront::Distribution
    Properties:
      DistributionConfig:
        Aliases:
          - www.myapp.com
          - myapp.com
        DefaultCacheBehavior:
          TargetOriginId: S3Origin
          ViewerProtocolPolicy: redirect-to-https
          CachePolicyId: 4135ea2d-6df8-44a3-9df3-4b5a84be39ad  # Managed-CachingOptimized
          OriginRequestPolicyId: 88a5eaf4-2fd4-4709-b370-b4c650ea3fcf  # Managed-CORS-S3Origin
          ResponseHeadersPolicyId: 5cc3b908-e619-4b99-88e5-2cf7f45965bd  # Managed-SecurityHeadersPolicy
        Origins:
          - Id: S3Origin
            DomainName: !GetAtt S3Bucket.RegionalDomainName
            S3OriginConfig:
              OriginAccessIdentity: !Sub "origin-access-identity/cloudfront/${OriginAccessIdentity}"
        Enabled: true
        DefaultRootObject: index.html
        CustomErrorResponses:
          - ErrorCode: 404
            ResponseCode: 200
            ResponsePagePath: /index.html
          - ErrorCode: 403
            ResponseCode: 200
            ResponsePagePath: /index.html
        ViewerCertificate:
          AcmCertificateArn: !Ref SSLCertificate
          SslSupportMethod: sni-only
          MinimumProtocolVersion: TLSv1.2_2021
        PriceClass: PriceClass_100
        HttpVersion: http2
        IPV6Enabled: true
        
  OriginAccessIdentity:
    Type: AWS::CloudFront::CloudFrontOriginAccessIdentity
    Properties:
      CloudFrontOriginAccessIdentityConfig:
        Comment: !Sub "OAI for ${AWS::StackName}"
```

### Cache Behaviors
```yaml
CacheBehaviors:
  - PathPattern: "/api/*"
    TargetOriginId: APIOrigin
    ViewerProtocolPolicy: https-only
    CachePolicyId: 4135ea2d-6df8-44a3-9df3-4b5a84be39ad
    TTLs:
      DefaultTTL: 0
      MaxTTL: 0
      MinTTL: 0
  - PathPattern: "/static/*"
    TargetOriginId: S3Origin
    ViewerProtocolPolicy: redirect-to-https
    CachePolicyId: 658327ea-f89d-4fab-a63d-7e88639e58f6  # Managed-CachingOptimizedForUncompressedObjects
    TTLs:
      DefaultTTL: 86400
      MaxTTL: 31536000
      MinTTL: 0
```

## Advanced S3 Features

### Lifecycle Policies
```json
{
    "Rules": [
        {
            "ID": "TransitionToIA",
            "Status": "Enabled",
            "Filter": {
                "Prefix": "logs/"
            },
            "Transitions": [
                {
                    "Days": 30,
                    "StorageClass": "STANDARD_IA"
                },
                {
                    "Days": 90,
                    "StorageClass": "GLACIER"
                },
                {
                    "Days": 365,
                    "StorageClass": "DEEP_ARCHIVE"
                }
            ]
        },
        {
            "ID": "DeleteOldVersions",
            "Status": "Enabled",
            "NoncurrentVersionExpiration": {
                "NoncurrentDays": 30
            }
        }
    ]
}
```

### Cross-Region Replication
```yaml
ReplicationConfiguration:
  Role: !GetAtt ReplicationRole.Arn
  Rules:
    - Id: ReplicateToSecondaryRegion
      Status: Enabled
      Priority: 1
      Filter:
        Prefix: important/
      Destination:
        Bucket: !Sub "arn:aws:s3:::${BackupBucket}"
        StorageClass: STANDARD_IA
        ReplicationTime:
          Status: Enabled
          Time:
            Minutes: 15
        Metrics:
          Status: Enabled
          EventThreshold:
            Minutes: 15
```

## CloudFront Functions

### Edge Functions
```javascript
// viewer-request-function.js
function handler(event) {
    var request = event.request;
    var uri = request.uri;
    
    // Redirect root to index.html
    if (uri === '/') {
        request.uri = '/index.html';
    }
    
    // Add security headers
    if (!request.headers['x-forwarded-proto'] || 
        request.headers['x-forwarded-proto'].value !== 'https') {
        return {
            statusCode: 301,
            statusDescription: 'Moved Permanently',
            headers: {
                'location': { value: 'https://' + request.headers.host.value + request.uri }
            }
        };
    }
    
    return request;
}
```

### Lambda@Edge
```python
import json
import base64

def lambda_handler(event, context):
    request = event['Records'][0]['cf']['request']
    headers = request['headers']
    
    # Add security headers
    response = {
        'status': '200',
        'statusDescription': 'OK',
        'headers': {
            'strict-transport-security': [{
                'key': 'Strict-Transport-Security',
                'value': 'max-age=31536000; includeSubDomains'
            }],
            'x-content-type-options': [{
                'key': 'X-Content-Type-Options',
                'value': 'nosniff'
            }],
            'x-frame-options': [{
                'key': 'X-Frame-Options',
                'value': 'DENY'
            }],
            'x-xss-protection': [{
                'key': 'X-XSS-Protection',
                'value': '1; mode=block'
            }]
        }
    }
    
    return response
```

## Performance Optimization

### Compression
```bash
# Enable gzip compression for text files
aws s3 cp file.js s3://my-bucket/file.js \
    --content-encoding gzip \
    --content-type "application/javascript"
```

### Cache Headers
```bash
# Set cache headers for different file types
aws s3 sync ./build/ s3://my-bucket/ \
    --cache-control "public, max-age=31536000, immutable" \
    --exclude "*.html" \
    --exclude "service-worker.js"

aws s3 sync ./build/ s3://my-bucket/ \
    --cache-control "public, max-age=0, must-revalidate" \
    --include "*.html" \
    --include "service-worker.js"
```

## Security Best Practices

### S3 Security
```yaml
S3BucketPolicy:
  Type: AWS::S3::BucketPolicy
  Properties:
    Bucket: !Ref S3Bucket
    PolicyDocument:
      Statement:
        - Sid: DenyInsecureConnections
          Effect: Deny
          Principal: "*"
          Action: "s3:*"
          Resource:
            - !Sub "${S3Bucket}/*"
            - !Ref S3Bucket
          Condition:
            Bool:
              "aws:SecureTransport": "false"
```

### CloudFront Security
```yaml
ResponseHeadersPolicy:
  Type: AWS::CloudFront::ResponseHeadersPolicy
  Properties:
    ResponseHeadersPolicyConfig:
      Name: SecurityHeaders
      SecurityHeadersConfig:
        StrictTransportSecurity:
          AccessControlMaxAgeSec: 31536000
          IncludeSubdomains: true
        ContentTypeOptions:
          Override: true
        FrameOptions:
          FrameOption: DENY
          Override: true
        ReferrerPolicy:
          ReferrerPolicy: strict-origin-when-cross-origin
          Override: true
```

## Monitoring and Logging

### CloudWatch Metrics
```bash
# Get CloudFront metrics
aws cloudwatch get-metric-statistics \
    --namespace AWS/CloudFront \
    --metric-name Requests \
    --dimensions Name=DistributionId,Value=E1234567890123 \
    --start-time 2024-01-01T00:00:00Z \
    --end-time 2024-01-01T23:59:59Z \
    --period 3600 \
    --statistics Sum

# Get S3 metrics
aws cloudwatch get-metric-statistics \
    --namespace AWS/S3 \
    --metric-name BucketSizeBytes \
    --dimensions Name=BucketName,Value=my-app-static-assets Name=StorageType,Value=StandardStorage \
    --start-time 2024-01-01T00:00:00Z \
    --end-time 2024-01-01T23:59:59Z \
    --period 86400 \
    --statistics Average
```

### Access Logging
```yaml
CloudFrontDistribution:
  Properties:
    DistributionConfig:
      Logging:
        Bucket: !GetAtt LoggingBucket.DomainName
        Prefix: cloudfront-logs/
        IncludeCookies: false
```

## Troubleshooting

### Common Issues
1. **403 Forbidden**: Check OAI configuration and bucket policy
2. **Cache not updating**: Verify cache headers and create invalidation
3. **SSL certificate errors**: Ensure certificate is in us-east-1 region

### Useful Commands
```bash
# Create CloudFront invalidation
aws cloudfront create-invalidation \
    --distribution-id E1234567890123 \
    --paths "/*"

# Check distribution status
aws cloudfront get-distribution --id E1234567890123

# List S3 objects with metadata
aws s3api list-objects-v2 \
    --bucket my-app-static-assets \
    --query 'Contents[?Size > `1000000`].[Key,Size,LastModified]' \
    --output table
```
