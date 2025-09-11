# AWS CloudFront Advanced Configuration

## Overview

This document provides comprehensive guidance on advanced AWS CloudFront configuration for caching strategies, covering custom behaviors, edge computing, security, performance optimization, and cost management.

## CloudFront Architecture

### Distribution Types
- **Web Distribution**: For web content delivery
- **RTMP Distribution**: For streaming media (deprecated)
- **Custom Distribution**: For API and custom protocols

### Edge Locations
- **Global Edge Network**: 400+ edge locations worldwide
- **Regional Edge Caches**: 13 regional edge caches
- **Origin Shield**: Additional caching layer near origins

## Advanced Configuration

### Custom Cache Behaviors

#### Behavior Configuration
```yaml
CacheBehaviors:
  - PathPattern: "/api/v1/users/*"
    TargetOriginId: "api-origin"
    ViewerProtocolPolicy: "redirect-to-https"
    AllowedMethods: ["GET", "HEAD", "OPTIONS"]
    CachedMethods: ["GET", "HEAD"]
    Compress: true
    ForwardedValues:
      QueryString: true
      Cookies:
        Forward: "none"
      Headers:
        - "Authorization"
        - "X-User-ID"
    MinTTL: 0
    DefaultTTL: 300
    MaxTTL: 3600
    PriceClass: "PriceClass_All"
```

#### Dynamic Content Caching
```yaml
DynamicContentBehavior:
  PathPattern: "/api/v1/dynamic/*"
  TargetOriginId: "api-origin"
  ViewerProtocolPolicy: "redirect-to-https"
  AllowedMethods: ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
  CachedMethods: ["GET", "HEAD"]
  Compress: true
  ForwardedValues:
    QueryString: true
    Cookies:
      Forward: "all"
    Headers:
      - "Authorization"
      - "X-User-ID"
      - "X-Session-ID"
  MinTTL: 0
  DefaultTTL: 0
  MaxTTL: 0
  CachePolicyId: "managed-caching-disabled"
```

### Origin Configuration

#### Multiple Origins
```yaml
Origins:
  - Id: "s3-static-origin"
    DomainName: "static.example.com.s3.amazonaws.com"
    OriginPath: "/assets"
    S3OriginConfig:
      OriginAccessIdentity: "origin-access-identity/cloudfront/E1234567890"
  
  - Id: "api-origin"
    DomainName: "api.example.com"
    OriginPath: "/v1"
    CustomOriginConfig:
      HTTPPort: 80
      HTTPSPort: 443
      OriginProtocolPolicy: "https-only"
      OriginSslProtocols:
        - "TLSv1.2"
      OriginReadTimeout: 30
      OriginKeepaliveTimeout: 5
  
  - Id: "media-origin"
    DomainName: "media.example.com"
    OriginPath: "/videos"
    CustomOriginConfig:
      HTTPPort: 80
      HTTPSPort: 443
      OriginProtocolPolicy: "https-only"
      OriginSslProtocols:
        - "TLSv1.2"
```

#### Origin Groups
```yaml
OriginGroups:
  - Id: "api-origin-group"
    PrimaryOriginId: "api-origin-primary"
    FailoverOriginId: "api-origin-secondary"
    FailoverCriteria:
      StatusCodes:
        Values: [500, 502, 503, 504]
```

### Cache Policies

#### Custom Cache Policies
```yaml
CachePolicies:
  - Name: "Custom-API-Cache-Policy"
    Comment: "Custom cache policy for API endpoints"
    DefaultTTL: 300
    MaxTTL: 3600
    MinTTL: 0
    ParametersInCacheKeyAndForwardedToOrigin:
      QueryStrings:
        Config: "all"
      Headers:
        Config: "whitelist"
        Items:
          - "Authorization"
          - "X-User-ID"
      Cookies:
        Config: "none"
```

#### Managed Cache Policies
```yaml
ManagedCachePolicies:
  - "managed-caching-optimized": "Optimized for caching"
  - "managed-caching-disabled": "Disable caching"
  - "managed-caching-optimized-for-uncompressed-objects": "Uncompressed objects"
  - "managed-elements-cache-policy": "Element cache policy"
```

### Security Configuration

#### Web Application Firewall (WAF)
```yaml
WebACLId: "arn:aws:wafv2:us-east-1:123456789012:global/webacl/example"
```

#### SSL/TLS Configuration
```yaml
ViewerCertificate:
  CloudFrontDefaultCertificate: false
  ACMCertificateArn: "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
  SSLSupportMethod: "sni-only"
  MinimumProtocolVersion: "TLSv1.2_2021"
```

#### Geographic Restrictions
```yaml
Restrictions:
  GeoRestriction:
    RestrictionType: "whitelist"
    Locations:
      - "US"
      - "CA"
      - "GB"
      - "DE"
      - "FR"
```

### Performance Optimization

#### Compression Configuration
```yaml
DefaultCacheBehavior:
  Compress: true
  CompressIncludeContentTypes:
    - "text/html"
    - "text/css"
    - "text/javascript"
    - "application/javascript"
    - "application/json"
    - "application/xml"
    - "text/xml"
```

#### HTTP/2 Configuration
```yaml
HttpVersion: "http2"
IsIPV6Enabled: true
```

#### Connection Settings
```yaml
DefaultCacheBehavior:
  OriginRequestPolicyId: "managed-cors-s3origin"
  ResponseHeadersPolicyId: "managed-security-headers"
```

## Lambda@Edge Implementation

### Edge Functions

#### Viewer Request Function
```javascript
exports.handler = (event, context, callback) => {
    const request = event.Records[0].cf.request;
    const headers = request.headers;
    
    // Add custom headers
    request.headers['x-edge-location'] = [{
        key: 'X-Edge-Location',
        value: event.Records[0].cf.config.distributionDomainName
    }];
    
    // Modify request based on user agent
    const userAgent = headers['user-agent'] ? headers['user-agent'][0].value : '';
    if (userAgent.includes('Mobile')) {
        request.uri = request.uri.replace('/desktop/', '/mobile/');
    }
    
    callback(null, request);
};
```

#### Origin Request Function
```javascript
exports.handler = (event, context, callback) => {
    const request = event.Records[0].cf.request;
    
    // Add authentication headers
    request.headers['authorization'] = [{
        key: 'Authorization',
        value: 'Bearer ' + generateToken()
    }];
    
    // Modify query parameters
    if (request.querystring) {
        request.querystring += '&edge=true';
    } else {
        request.querystring = 'edge=true';
    }
    
    callback(null, request);
};
```

#### Origin Response Function
```javascript
exports.handler = (event, context, callback) => {
    const response = event.Records[0].cf.response;
    const headers = response.headers;
    
    // Add security headers
    headers['strict-transport-security'] = [{
        key: 'Strict-Transport-Security',
        value: 'max-age=31536000; includeSubDomains'
    }];
    
    headers['x-content-type-options'] = [{
        key: 'X-Content-Type-Options',
        value: 'nosniff'
    }];
    
    // Modify cache headers
    if (headers['cache-control']) {
        headers['cache-control'][0].value = 'public, max-age=3600';
    }
    
    callback(null, response);
};
```

#### Viewer Response Function
```javascript
exports.handler = (event, context, callback) => {
    const response = event.Records[0].cf.response;
    const headers = response.headers;
    
    // Add custom response headers
    headers['x-cache-status'] = [{
        key: 'X-Cache-Status',
        value: 'HIT'
    }];
    
    // Modify response based on client
    const request = event.Records[0].cf.request;
    const userAgent = request.headers['user-agent'] ? 
        request.headers['user-agent'][0].value : '';
    
    if (userAgent.includes('Mobile')) {
        headers['x-mobile-optimized'] = [{
            key: 'X-Mobile-Optimized',
            value: 'true'
        }];
    }
    
    callback(null, response);
};
```

### Edge Function Configuration
```yaml
LambdaFunctionAssociations:
  - EventType: "viewer-request"
    LambdaFunctionARN: "arn:aws:lambda:us-east-1:123456789012:function:viewer-request:1"
    IncludeBody: false
  
  - EventType: "origin-request"
    LambdaFunctionARN: "arn:aws:lambda:us-east-1:123456789012:function:origin-request:1"
    IncludeBody: false
  
  - EventType: "origin-response"
    LambdaFunctionARN: "arn:aws:lambda:us-east-1:123456789012:function:origin-response:1"
    IncludeBody: false
  
  - EventType: "viewer-response"
    LambdaFunctionARN: "arn:aws:lambda:us-east-1:123456789012:function:viewer-response:1"
    IncludeBody: false
```

## Monitoring and Analytics

### CloudWatch Metrics

#### Key Metrics
```yaml
Metrics:
  - "Requests": "Total number of requests"
  - "BytesDownloaded": "Total bytes downloaded"
  - "BytesUploaded": "Total bytes uploaded"
  - "4xxErrorRate": "4xx error rate"
  - "5xxErrorRate": "5xx error rate"
  - "CacheHitRate": "Cache hit rate"
  - "OriginLatency": "Origin response time"
  - "ViewerResponseTime": "Viewer response time"
```

#### Custom Metrics
```python
import boto3

def create_custom_metrics():
    cloudwatch = boto3.client('cloudwatch')
    
    # Custom cache hit ratio metric
    cloudwatch.put_metric_data(
        Namespace='CloudFront/Custom',
        MetricData=[
            {
                'MetricName': 'CacheHitRatio',
                'Value': 0.95,
                'Unit': 'Percent',
                'Dimensions': [
                    {
                        'Name': 'DistributionId',
                        'Value': 'E1234567890'
                    }
                ]
            }
        ]
    )
```

### Real-Time Logs

#### Log Configuration
```yaml
Logging:
  Bucket: "cloudfront-logs.example.com"
  Prefix: "logs/"
  IncludeCookies: true
  LogFileFormat: "JSON"
```

#### Log Analysis
```python
import json
import boto3

def analyze_cloudfront_logs():
    s3 = boto3.client('s3')
    
    # Get log files
    response = s3.list_objects_v2(
        Bucket='cloudfront-logs.example.com',
        Prefix='logs/'
    )
    
    for obj in response.get('Contents', []):
        # Download and analyze log file
        log_data = s3.get_object(
            Bucket='cloudfront-logs.example.com',
            Key=obj['Key']
        )
        
        # Parse and analyze logs
        for line in log_data['Body'].read().decode('utf-8').split('\n'):
            if line.strip():
                log_entry = json.loads(line)
                analyze_log_entry(log_entry)

def analyze_log_entry(log_entry):
    """Analyze individual log entry"""
    # Extract key information
    timestamp = log_entry['timestamp']
    method = log_entry['http_method']
    uri = log_entry['uri']
    status = log_entry['http_status']
    cache_status = log_entry['cache_status']
    
    # Analyze cache performance
    if cache_status == 'Hit':
        record_cache_hit(uri)
    elif cache_status == 'Miss':
        record_cache_miss(uri)
    
    # Analyze error rates
    if status >= 400:
        record_error(status, uri)
```

## Cost Optimization

### Cost Analysis

#### Cost Components
```yaml
CostComponents:
  DataTransferOut:
    Description: "Data transfer out to internet"
    Pricing: "$0.085 per GB (first 10 TB)"
  
  Requests:
    Description: "HTTP/HTTPS requests"
    Pricing: "$0.0075 per 10,000 requests"
  
  LambdaEdge:
    Description: "Lambda@Edge executions"
    Pricing: "$0.60 per 1M requests"
  
  Invalidation:
    Description: "Cache invalidation requests"
    Pricing: "$0.005 per 1,000 paths"
```

#### Cost Optimization Strategies
```python
class CloudFrontCostOptimizer:
    def __init__(self, cloudfront_client, cost_explorer):
        self.cloudfront = cloudfront_client
        self.cost_explorer = cost_explorer
    
    def analyze_costs(self, distribution_id, start_date, end_date):
        """Analyze CloudFront costs"""
        # Get cost data
        cost_data = self.cost_explorer.get_cost_and_usage(
            TimePeriod={
                'Start': start_date,
                'End': end_date
            },
            Granularity='MONTHLY',
            Metrics=['BlendedCost'],
            GroupBy=[
                {
                    'Type': 'DIMENSION',
                    'Key': 'SERVICE'
                }
            ]
        )
        
        # Analyze CloudFront costs
        cloudfront_costs = self._extract_cloudfront_costs(cost_data)
        
        # Generate optimization recommendations
        recommendations = self._generate_recommendations(cloudfront_costs)
        
        return {
            'total_cost': cloudfront_costs['total'],
            'cost_breakdown': cloudfront_costs['breakdown'],
            'recommendations': recommendations
        }
    
    def _generate_recommendations(self, costs):
        """Generate cost optimization recommendations"""
        recommendations = []
        
        # Data transfer optimization
        if costs['data_transfer'] > costs['total'] * 0.5:
            recommendations.append({
                'type': 'data_transfer_optimization',
                'description': 'High data transfer costs detected',
                'suggestions': [
                    'Enable compression',
                    'Optimize image sizes',
                    'Use appropriate cache TTLs'
                ]
            })
        
        # Request optimization
        if costs['requests'] > costs['total'] * 0.3:
            recommendations.append({
                'type': 'request_optimization',
                'description': 'High request costs detected',
                'suggestions': [
                    'Implement request batching',
                    'Use appropriate cache behaviors',
                    'Optimize cache hit ratios'
                ]
            })
        
        return recommendations
```

### Pricing Optimization

#### Price Class Selection
```yaml
PriceClasses:
  PriceClass_All:
    Description: "All edge locations worldwide"
    Cost: "Highest"
    UseCase: "Global audience"
  
  PriceClass_200:
    Description: "US, Canada, Europe, Asia, Middle East, Africa"
    Cost: "Medium"
    UseCase: "Most global audiences"
  
  PriceClass_100:
    Description: "US, Canada, Europe"
    Cost: "Lowest"
    UseCase: "US/Europe focused"
```

#### Compression Optimization
```python
def optimize_compression():
    """Optimize compression settings"""
    compression_config = {
        'enabled': True,
        'include_content_types': [
            'text/html',
            'text/css',
            'text/javascript',
            'application/javascript',
            'application/json',
            'application/xml',
            'text/xml'
        ],
        'exclude_content_types': [
            'image/jpeg',
            'image/png',
            'image/gif',
            'video/mp4',
            'application/pdf'
        ]
    }
    
    return compression_config
```

## Security Best Practices

### Security Headers

#### Response Headers Policy
```yaml
ResponseHeadersPolicy:
  Name: "SecurityHeadersPolicy"
  Comment: "Security headers for CloudFront"
  SecurityHeadersConfig:
    StrictTransportSecurity:
      AccessControlMaxAgeSec: 31536000
      IncludeSubdomains: true
      Override: false
    ContentTypeOptions:
      Override: false
    FrameOptions:
      FrameOption: "DENY"
      Override: false
    ReferrerPolicy:
      ReferrerPolicy: "strict-origin-when-cross-origin"
      Override: false
    ContentSecurityPolicy:
      ContentSecurityPolicy: "default-src 'self'"
      Override: false
```

### Access Control

#### Signed URLs
```python
import boto3
from botocore.signers import CloudFrontSigner
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.primitives.serialization import load_pem_private_key

def create_signed_url(url, key_pair_id, private_key, expiration_time):
    """Create signed URL for CloudFront"""
    # Load private key
    private_key_obj = load_pem_private_key(private_key, password=None)
    
    # Create CloudFront signer
    cloudfront_signer = CloudFrontSigner(key_pair_id, private_key_obj)
    
    # Create signed URL
    signed_url = cloudfront_signer.generate_presigned_url(
        url=url,
        date_less_than=expiration_time
    )
    
    return signed_url
```

#### Signed Cookies
```python
def create_signed_cookies(url, key_pair_id, private_key, expiration_time):
    """Create signed cookies for CloudFront"""
    # Load private key
    private_key_obj = load_pem_private_key(private_key, password=None)
    
    # Create CloudFront signer
    cloudfront_signer = CloudFrontSigner(key_pair_id, private_key_obj)
    
    # Create signed cookies
    signed_cookies = cloudfront_signer.generate_presigned_cookies(
        url=url,
        date_less_than=expiration_time
    )
    
    return signed_cookies
```

## Troubleshooting

### Common Issues

#### Cache Miss Issues
```python
def troubleshoot_cache_misses():
    """Troubleshoot cache miss issues"""
    issues = []
    
    # Check TTL settings
    if default_ttl == 0:
        issues.append("Default TTL is 0 - content not cached")
    
    # Check cache behaviors
    if not cache_behaviors:
        issues.append("No cache behaviors configured")
    
    # Check origin headers
    if origin_sends_no_cache:
        issues.append("Origin sending no-cache headers")
    
    # Check query string forwarding
    if query_strings_not_forwarded:
        issues.append("Query strings not forwarded to origin")
    
    return issues
```

#### Performance Issues
```python
def troubleshoot_performance():
    """Troubleshoot performance issues"""
    issues = []
    
    # Check compression
    if compression_disabled:
        issues.append("Compression disabled - enable for text content")
    
    # Check HTTP/2
    if http_version != "http2":
        issues.append("HTTP/2 not enabled - enable for better performance")
    
    # Check edge locations
    if not using_optimal_edge_locations:
        issues.append("Not using optimal edge locations")
    
    return issues
```

### Monitoring and Alerting

#### CloudWatch Alarms
```yaml
Alarms:
  - AlarmName: "CloudFront-High-Error-Rate"
    MetricName: "4xxErrorRate"
    Threshold: 5.0
    ComparisonOperator: "GreaterThanThreshold"
    EvaluationPeriods: 2
    
  - AlarmName: "CloudFront-Low-Cache-Hit-Rate"
    MetricName: "CacheHitRate"
    Threshold: 80.0
    ComparisonOperator: "LessThanThreshold"
    EvaluationPeriods: 3
    
  - AlarmName: "CloudFront-High-Origin-Latency"
    MetricName: "OriginLatency"
    Threshold: 2000.0
    ComparisonOperator: "GreaterThanThreshold"
    EvaluationPeriods: 2
```

This comprehensive guide provides everything needed to implement advanced CloudFront configurations for optimal caching performance, security, and cost management.
