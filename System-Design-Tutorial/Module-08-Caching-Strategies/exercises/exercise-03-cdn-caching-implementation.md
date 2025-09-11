# Exercise 3: CDN Caching Implementation

## Overview

**Duration**: 3-4 hours  
**Difficulty**: Advanced  
**Prerequisites**: Exercise 1 and 2 completion, understanding of CDN concepts

## Learning Objectives

By completing this exercise, you will:
- Implement comprehensive CDN caching strategies using AWS CloudFront
- Design cache behaviors and invalidation patterns for different content types
- Optimize CDN performance for global content delivery
- Monitor and analyze CDN performance metrics

## Scenario

You are implementing a global CDN solution for a media streaming platform with the following requirements:

### Content Types and Requirements
- **Video Content**: 4K videos, 1080p, 720p, 480p (1GB - 10GB per file)
- **Thumbnails**: Video thumbnails and preview images (50KB - 500KB)
- **Metadata**: Video metadata, user profiles, playlists (1KB - 10KB)
- **Static Assets**: CSS, JavaScript, fonts (10KB - 1MB)
- **API Responses**: REST API responses, search results (1KB - 100KB)

### Performance Requirements
- **Global Latency**: < 100ms for 95% of requests worldwide
- **Cache Hit Ratio**: > 95% for static content, > 80% for dynamic content
- **Bandwidth**: 100+ Gbps peak traffic
- **Availability**: 99.99% uptime
- **Geographic Coverage**: 20+ countries, 5 regions

### Content Update Patterns
- **Video Content**: Updated every 6 hours
- **Thumbnails**: Updated every 2 hours
- **Metadata**: Updated every 15 minutes
- **Static Assets**: Updated every 24 hours
- **API Responses**: Updated every 5 minutes

## Exercise Tasks

### Task 1: CloudFront Distribution Design (60 minutes)

Design and implement a comprehensive CloudFront distribution with custom cache behaviors:

1. **Distribution Configuration**
   - Create CloudFront distribution with multiple origins
   - Configure custom cache behaviors for different content types
   - Set up geographic restrictions and access controls
   - Implement SSL/TLS configuration

2. **Cache Behavior Design**
   - Design cache behaviors for video content (long TTL)
   - Configure cache behaviors for thumbnails (medium TTL)
   - Set up cache behaviors for metadata (short TTL)
   - Implement cache behaviors for static assets (very long TTL)
   - Configure cache behaviors for API responses (no cache)

**Implementation Requirements**:
```python
class CloudFrontDistributionManager:
    def __init__(self, region='us-east-1'):
        self.cloudfront = boto3.client('cloudfront', region_name=region)
        self.distribution_id = None
    
    def create_distribution(self, origins, behaviors, default_behavior):
        """Create CloudFront distribution with custom behaviors"""
        pass
    
    def create_origin(self, domain_name, origin_path='', s3_origin_config=None):
        """Create CloudFront origin"""
        pass
    
    def create_cache_behavior(self, path_pattern, target_origin_id, ttl_config):
        """Create custom cache behavior"""
        pass
    
    def configure_geo_restrictions(self, allowed_countries=None, blocked_countries=None):
        """Configure geographic restrictions"""
        pass
```

### Task 2: Cache Invalidation System (45 minutes)

Implement comprehensive cache invalidation for different content types:

1. **Invalidation Strategies**
   - Implement time-based invalidation for scheduled updates
   - Create event-based invalidation for real-time updates
   - Design pattern-based invalidation for bulk operations
   - Implement selective invalidation for specific content

2. **Invalidation Optimization**
   - Batch invalidation requests to reduce costs
   - Implement invalidation queuing for high-volume scenarios
   - Create invalidation monitoring and alerting
   - Design invalidation rollback mechanisms

**Implementation Requirements**:
```python
class CloudFrontInvalidationManager:
    def __init__(self, distribution_id):
        self.cloudfront = boto3.client('cloudfront')
        self.distribution_id = distribution_id
        self.invalidation_queue = queue.Queue()
        self.start_invalidation_processing()
    
    def invalidate_paths(self, paths, batch_size=100):
        """Invalidate specific paths with batching"""
        pass
    
    def invalidate_pattern(self, pattern, content_types=None):
        """Invalidate paths matching pattern"""
        pass
    
    def schedule_invalidation(self, paths, schedule_time):
        """Schedule invalidation for future time"""
        pass
    
    def get_invalidation_status(self, invalidation_id):
        """Get invalidation status"""
        pass
```

### Task 3: Performance Optimization (60 minutes)

Optimize CDN performance for global content delivery:

1. **Compression Optimization**
   - Implement Gzip compression for text content
   - Configure Brotli compression for better ratios
   - Set up compression rules for different content types
   - Monitor compression effectiveness

2. **Image Optimization**
   - Implement WebP conversion for images
   - Set up responsive image delivery
   - Configure image resizing and cropping
   - Optimize image quality settings

3. **Caching Optimization**
   - Implement cache warming strategies
   - Set up predictive content preloading
   - Configure cache hit ratio optimization
   - Monitor cache performance metrics

**Implementation Requirements**:
```python
class CDNPerformanceOptimizer:
    def __init__(self, distribution_id, s3_client):
        self.distribution_id = distribution_id
        self.s3_client = s3_client
        self.cloudwatch = boto3.client('cloudwatch')
    
    def optimize_compression(self, content_type, compression_level=6):
        """Optimize compression for content type"""
        pass
    
    def convert_to_webp(self, image_key, quality=80):
        """Convert image to WebP format"""
        pass
    
    def generate_responsive_images(self, image_key, sizes):
        """Generate responsive images for different screen sizes"""
        pass
    
    def warm_cache(self, paths, priority='normal'):
        """Warm cache for specific paths"""
        pass
    
    def monitor_performance(self):
        """Monitor CDN performance metrics"""
        pass
```

### Task 4: Monitoring and Analytics (45 minutes)

Implement comprehensive monitoring and analytics for CDN performance:

1. **Performance Monitoring**
   - Set up CloudWatch metrics collection
   - Create custom performance dashboards
   - Implement real-time alerting
   - Configure performance threshold monitoring

2. **Analytics Implementation**
   - Track cache hit ratios by content type
   - Monitor geographic performance distribution
   - Analyze bandwidth usage patterns
   - Track user experience metrics

3. **Cost Monitoring**
   - Monitor data transfer costs
   - Track invalidation costs
   - Analyze cost optimization opportunities
   - Implement cost alerting

**Implementation Requirements**:
```python
class CDNMonitoringSystem:
    def __init__(self, distribution_id):
        self.distribution_id = distribution_id
        self.cloudwatch = boto3.client('cloudwatch')
        self.cost_explorer = boto3.client('ce')
        self.monitoring_active = True
        self.start_monitoring()
    
    def collect_metrics(self):
        """Collect CDN performance metrics"""
        pass
    
    def create_dashboard(self, dashboard_name):
        """Create CloudWatch dashboard"""
        pass
    
    def setup_alerts(self, thresholds):
        """Setup performance alerts"""
        pass
    
    def analyze_costs(self, start_date, end_date):
        """Analyze CDN costs"""
        pass
    
    def generate_performance_report(self):
        """Generate comprehensive performance report"""
        pass
```

## Performance Targets

### Latency Targets
- **Static Content**: < 50ms globally
- **Dynamic Content**: < 100ms globally
- **Video Content**: < 200ms globally
- **API Responses**: < 150ms globally

### Cache Hit Ratio Targets
- **Static Assets**: > 98%
- **Video Content**: > 95%
- **Thumbnails**: > 90%
- **Metadata**: > 85%
- **API Responses**: > 80%

### Bandwidth Targets
- **Peak Throughput**: 100+ Gbps
- **Average Throughput**: 50+ Gbps
- **Data Transfer Efficiency**: > 90%
- **Compression Ratio**: > 60%

## Evaluation Criteria

### Technical Implementation (40%)
- **CloudFront Configuration**: Proper distribution and behavior setup
- **Cache Invalidation**: Effective invalidation strategies
- **Performance Optimization**: Compression and image optimization
- **Monitoring**: Comprehensive monitoring and alerting

### Performance Achievement (30%)
- **Latency**: Meets latency targets for all content types
- **Cache Hit Ratio**: Achieves target hit ratios
- **Bandwidth**: Handles peak traffic requirements
- **Availability**: Maintains high availability

### Cost Optimization (20%)
- **Data Transfer Costs**: Optimized data transfer usage
- **Invalidation Costs**: Minimized invalidation costs
- **Storage Costs**: Efficient storage utilization
- **Monitoring Costs**: Reasonable monitoring overhead

### Documentation (10%)
- **Architecture Documentation**: Clear CDN architecture design
- **Configuration Documentation**: Detailed configuration setup
- **Performance Analysis**: Comprehensive performance analysis
- **Cost Analysis**: Detailed cost optimization analysis

## Sample Implementation

### CloudFront Distribution Setup

```python
class CloudFrontDistributionManager:
    def __init__(self, region='us-east-1'):
        self.cloudfront = boto3.client('cloudfront', region_name=region)
        self.distribution_id = None
    
    def create_distribution(self, origins, behaviors, default_behavior):
        """Create CloudFront distribution with custom behaviors"""
        try:
            response = self.cloudfront.create_distribution(
                DistributionConfig={
                    'CallerReference': str(int(time.time())),
                    'Comment': 'Media Streaming Platform CDN',
                    'DefaultCacheBehavior': default_behavior,
                    'CacheBehaviors': {
                        'Quantity': len(behaviors),
                        'Items': behaviors
                    },
                    'Origins': {
                        'Quantity': len(origins),
                        'Items': origins
                    },
                    'Enabled': True,
                    'PriceClass': 'PriceClass_All',
                    'WebACLId': 'arn:aws:wafv2:us-east-1:123456789012:global/webacl/example',
                    'HttpVersion': 'http2',
                    'IsIPV6Enabled': True
                }
            )
            self.distribution_id = response['Distribution']['Id']
            return response['Distribution']
        except ClientError as e:
            print(f"Error creating distribution: {e}")
            return None
    
    def create_origin(self, domain_name, origin_path='', s3_origin_config=None):
        """Create CloudFront origin"""
        origin = {
            'Id': f"origin-{domain_name}",
            'DomainName': domain_name,
            'OriginPath': origin_path,
            'CustomOriginConfig': {
                'HTTPPort': 80,
                'HTTPSPort': 443,
                'OriginProtocolPolicy': 'https-only',
                'OriginSslProtocols': {
                    'Quantity': 1,
                    'Items': ['TLSv1.2']
                }
            }
        }
        
        if s3_origin_config:
            origin['S3OriginConfig'] = s3_origin_config
            del origin['CustomOriginConfig']
        
        return origin
    
    def create_cache_behavior(self, path_pattern, target_origin_id, ttl_config):
        """Create custom cache behavior"""
        return {
            'PathPattern': path_pattern,
            'TargetOriginId': target_origin_id,
            'ViewerProtocolPolicy': 'redirect-to-https',
            'TrustedSigners': {
                'Enabled': False,
                'Quantity': 0
            },
            'ForwardedValues': {
                'QueryString': ttl_config.get('forward_query_string', False),
                'Cookies': {
                    'Forward': ttl_config.get('forward_cookies', 'none')
                },
                'Headers': {
                    'Quantity': len(ttl_config.get('forward_headers', [])),
                    'Items': ttl_config.get('forward_headers', [])
                }
            },
            'MinTTL': ttl_config.get('min_ttl', 0),
            'DefaultTTL': ttl_config.get('default_ttl', 86400),
            'MaxTTL': ttl_config.get('max_ttl', 31536000),
            'Compress': ttl_config.get('compress', True)
        }
```

### Cache Invalidation Manager

```python
class CloudFrontInvalidationManager:
    def __init__(self, distribution_id):
        self.cloudfront = boto3.client('cloudfront')
        self.distribution_id = distribution_id
        self.invalidation_queue = queue.Queue()
        self.start_invalidation_processing()
    
    def invalidate_paths(self, paths, batch_size=100):
        """Invalidate specific paths with batching"""
        invalidation_batches = [paths[i:i + batch_size] for i in range(0, len(paths), batch_size)]
        invalidation_ids = []
        
        for batch in invalidation_batches:
            try:
                response = self.cloudfront.create_invalidation(
                    DistributionId=self.distribution_id,
                    InvalidationBatch={
                        'Paths': {
                            'Quantity': len(batch),
                            'Items': batch
                        },
                        'CallerReference': str(int(time.time()))
                    }
                )
                invalidation_ids.append(response['Invalidation']['Id'])
            except ClientError as e:
                print(f"Error creating invalidation: {e}")
        
        return invalidation_ids
    
    def invalidate_pattern(self, pattern, content_types=None):
        """Invalidate paths matching pattern"""
        # This would typically involve:
        # 1. Querying S3 or origin to find matching paths
        # 2. Creating invalidation for those paths
        # For this example, we'll simulate the pattern matching
        paths = self._find_paths_matching_pattern(pattern, content_types)
        return self.invalidate_paths(paths)
    
    def _find_paths_matching_pattern(self, pattern, content_types):
        """Find paths matching pattern (simplified implementation)"""
        # In a real implementation, this would query the origin
        # to find all paths matching the pattern
        return [f"/{pattern}/*"]
    
    def get_invalidation_status(self, invalidation_id):
        """Get invalidation status"""
        try:
            response = self.cloudfront.get_invalidation(
                DistributionId=self.distribution_id,
                Id=invalidation_id
            )
            return response['Invalidation']
        except ClientError as e:
            print(f"Error getting invalidation status: {e}")
            return None
    
    def start_invalidation_processing(self):
        """Start background invalidation processing"""
        def process_invalidations():
            while True:
                try:
                    invalidation_task = self.invalidation_queue.get(timeout=1)
                    self._process_invalidation_task(invalidation_task)
                    self.invalidation_queue.task_done()
                except queue.Empty:
                    continue
        
        threading.Thread(target=process_invalidations, daemon=True).start()
    
    def _process_invalidation_task(self, task):
        """Process invalidation task"""
        task_type = task.get('type')
        
        if task_type == 'immediate':
            self.invalidate_paths(task['paths'])
        elif task_type == 'scheduled':
            schedule_time = task['schedule_time']
            if time.time() >= schedule_time:
                self.invalidate_paths(task['paths'])
            else:
                # Re-queue for later
                self.invalidation_queue.put(task)
```

## Additional Resources

### AWS Documentation
- [CloudFront Developer Guide](https://docs.aws.amazon.com/cloudfront/)
- [CloudFront API Reference](https://docs.aws.amazon.com/cloudfront/latest/APIReference/)
- [CloudWatch Metrics for CloudFront](https://docs.aws.amazon.com/cloudfront/latest/developerguide/monitoring-using-cloudwatch.html)

### Tools and Libraries
- **Boto3**: AWS SDK for Python
- **CloudWatch**: AWS monitoring service
- **S3**: Origin storage for static content
- **Lambda@Edge**: Edge computing functions

### Best Practices
- Use appropriate TTL values for different content types
- Implement compression for text content
- Use WebP format for images
- Monitor cache hit ratios and optimize accordingly
- Implement proper invalidation strategies

## Next Steps

After completing this exercise:
1. **Deploy**: Deploy CloudFront distribution to AWS
2. **Test**: Perform comprehensive load testing
3. **Monitor**: Set up monitoring and alerting
4. **Optimize**: Continuously optimize performance
5. **Scale**: Plan for future growth and scaling

---

**Last Updated**: 2024-01-15  
**Version**: 1.0  
**Next Review**: 2024-02-15
