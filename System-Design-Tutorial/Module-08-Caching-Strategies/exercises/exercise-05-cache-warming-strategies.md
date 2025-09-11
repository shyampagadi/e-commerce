# Exercise 5: Cache Warming Strategies

## Overview

**Duration**: 3-4 hours  
**Difficulty**: Intermediate  
**Prerequisites**: Exercise 1-4 completion, understanding of cache patterns

## Learning Objectives

By completing this exercise, you will:
- Implement comprehensive cache warming strategies
- Design predictive cache preloading systems
- Create intelligent cache eviction policies
- Optimize cache hit ratios through proactive warming

## Scenario

You are implementing cache warming for a content management system with the following requirements:

### Content Types and Patterns
- **Popular Content**: Frequently accessed articles, videos, images
- **Trending Content**: Content gaining popularity rapidly
- **Seasonal Content**: Content with predictable access patterns
- **User-Specific Content**: Personalized content based on user behavior
- **Search Results**: Cached search results and recommendations

### Access Patterns
- **Peak Hours**: 9 AM - 6 PM (business hours)
- **Geographic Patterns**: Different content popular in different regions
- **Temporal Patterns**: Content popularity changes over time
- **User Behavior**: Users access content in predictable sequences

### Performance Requirements
- **Cache Hit Ratio**: > 95% for popular content
- **Warm-up Time**: < 5 minutes for new content
- **Prediction Accuracy**: > 85% for content popularity prediction
- **Resource Usage**: < 20% additional CPU/memory for warming

## Exercise Tasks

### Task 1: Predictive Cache Warming (90 minutes)

Implement intelligent cache warming based on content popularity prediction:

1. **Popularity Prediction Model**
   - Implement machine learning model for content popularity
   - Create feature engineering for content characteristics
   - Design real-time popularity scoring
   - Implement model training and retraining

2. **Cache Warming Engine**
   - Create cache warming scheduler
   - Implement priority-based warming
   - Design batch warming for efficiency
   - Create warming progress tracking

**Implementation Requirements**:
```python
class PredictiveCacheWarmer:
    def __init__(self, cache_client, ml_model, content_analyzer):
        self.cache = cache_client
        self.ml_model = ml_model
        self.content_analyzer = content_analyzer
        self.warming_queue = queue.PriorityQueue()
        self.warming_progress = {}
        self.start_warming_processor()
    
    def predict_content_popularity(self, content_id, features):
        """Predict content popularity using ML model"""
        pass
    
    def schedule_cache_warming(self, content_id, priority, features):
        """Schedule content for cache warming"""
        pass
    
    def warm_cache_batch(self, content_ids, batch_size=100):
        """Warm cache for multiple content items"""
        pass
    
    def get_warming_progress(self, content_id):
        """Get warming progress for content"""
        pass
    
    def update_popularity_model(self, training_data):
        """Update popularity prediction model"""
        pass
```

### Task 2: Temporal Cache Warming (75 minutes)

Implement time-based cache warming for predictable access patterns:

1. **Schedule-Based Warming**
   - Implement cron-based warming schedules
   - Create timezone-aware warming
   - Design seasonal content warming
   - Implement peak hour preparation

2. **Event-Driven Warming**
   - Create event-based warming triggers
   - Implement content lifecycle warming
   - Design user action-triggered warming
   - Create system event warming

**Implementation Requirements**:
```python
class TemporalCacheWarmer:
    def __init__(self, cache_client, scheduler, event_bus):
        self.cache = cache_client
        self.scheduler = scheduler
        self.event_bus = event_bus
        self.warming_schedules = {}
        self.timezone_aware = True
        self.setup_scheduled_warming()
        self.setup_event_warming()
    
    def schedule_peak_hour_warming(self, content_ids, peak_hours):
        """Schedule warming for peak hours"""
        pass
    
    def schedule_seasonal_warming(self, content_id, seasonal_pattern):
        """Schedule warming for seasonal content"""
        pass
    
    def setup_event_warming(self, event_types):
        """Setup event-driven warming"""
        pass
    
    def warm_on_user_action(self, user_id, action_type):
        """Warm cache based on user action"""
        pass
    
    def warm_on_content_update(self, content_id, update_type):
        """Warm cache when content is updated"""
        pass
```

### Task 3: Geographic Cache Warming (60 minutes)

Implement geographic-aware cache warming for global content delivery:

1. **Regional Warming**
   - Implement region-specific content warming
   - Create geographic popularity analysis
   - Design cross-region warming strategies
   - Implement timezone-based warming

2. **CDN Warming**
   - Create CDN cache warming
   - Implement edge location warming
   - Design global warming coordination
   - Create warming status monitoring

**Implementation Requirements**:
```python
class GeographicCacheWarmer:
    def __init__(self, cache_client, cdn_client, geo_analyzer):
        self.cache = cache_client
        self.cdn = cdn_client
        self.geo_analyzer = geo_analyzer
        self.regions = ['us-east', 'us-west', 'eu-west', 'ap-southeast']
        self.warming_coordinator = WarmingCoordinator()
    
    def warm_region_specific_content(self, region, content_ids):
        """Warm content specific to region"""
        pass
    
    def warm_global_content(self, content_ids, priority_regions=None):
        """Warm content across all regions"""
        pass
    
    def warm_cdn_edge_locations(self, content_ids, edge_locations):
        """Warm CDN edge locations"""
        pass
    
    def coordinate_cross_region_warming(self, content_id, source_region):
        """Coordinate warming across regions"""
        pass
    
    def get_regional_warming_status(self, region):
        """Get warming status for region"""
        pass
```

### Task 4: Cache Warming Optimization (45 minutes)

Implement optimization strategies for cache warming efficiency:

1. **Resource Optimization**
   - Implement resource-aware warming
   - Create warming throttling mechanisms
   - Design warming priority algorithms
   - Implement warming cost optimization

2. **Performance Optimization**
   - Create parallel warming processes
   - Implement warming batching
   - Design warming compression
   - Create warming monitoring

**Implementation Requirements**:
```python
class CacheWarmingOptimizer:
    def __init__(self, cache_client, resource_monitor, cost_calculator):
        self.cache = cache_client
        self.resource_monitor = resource_monitor
        self.cost_calculator = cost_calculator
        self.warming_throttle = WarmingThrottle()
        self.parallel_processor = ParallelProcessor()
    
    def optimize_warming_resources(self, warming_tasks):
        """Optimize resource usage for warming"""
        pass
    
    def throttle_warming_operations(self, current_load, max_load):
        """Throttle warming based on system load"""
        pass
    
    def prioritize_warming_tasks(self, tasks, priority_criteria):
        """Prioritize warming tasks based on criteria"""
        pass
    
    def batch_warming_operations(self, tasks, batch_size):
        """Batch warming operations for efficiency"""
        pass
    
    def monitor_warming_performance(self):
        """Monitor warming performance metrics"""
        pass
```

## Performance Targets

### Warming Performance
- **Warming Speed**: 1000+ items per minute
- **Prediction Accuracy**: > 85% for popularity prediction
- **Resource Usage**: < 20% additional CPU/memory
- **Warming Success Rate**: > 95%

### Cache Hit Ratio
- **Popular Content**: > 95% hit ratio
- **Trending Content**: > 90% hit ratio
- **Seasonal Content**: > 85% hit ratio
- **Overall Hit Ratio**: > 90%

### Latency Targets
- **Warming Latency**: < 5 minutes for new content
- **Cache Access**: < 10ms for warmed content
- **Prediction Latency**: < 100ms
- **Scheduling Latency**: < 1 second

## Evaluation Criteria

### Technical Implementation (40%)
- **Prediction Model**: Effective ML model for popularity prediction
- **Warming Engine**: Robust cache warming implementation
- **Scheduling**: Proper temporal and event-based warming
- **Optimization**: Effective resource and performance optimization

### Performance Achievement (30%)
- **Warming Speed**: Meets warming speed targets
- **Hit Ratio**: Achieves target cache hit ratios
- **Resource Usage**: Stays within resource limits
- **Latency**: Meets latency targets

### Prediction Accuracy (20%)
- **Popularity Prediction**: Accurate content popularity prediction
- **Temporal Patterns**: Effective temporal pattern recognition
- **Geographic Patterns**: Accurate geographic content analysis
- **User Behavior**: Effective user behavior prediction

### Monitoring and Optimization (10%)
- **Monitoring**: Comprehensive warming monitoring
- **Optimization**: Continuous optimization strategies
- **Alerting**: Effective alerting for warming issues
- **Reporting**: Detailed warming performance reports

## Sample Implementation

### Predictive Cache Warmer

```python
class PredictiveCacheWarmer:
    def __init__(self, cache_client, ml_model, content_analyzer):
        self.cache = cache_client
        self.ml_model = ml_model
        self.content_analyzer = content_analyzer
        self.warming_queue = queue.PriorityQueue()
        self.warming_progress = {}
        self.start_warming_processor()
    
    def predict_content_popularity(self, content_id, features):
        """Predict content popularity using ML model"""
        try:
            # Extract features for content
            content_features = self.content_analyzer.extract_features(content_id, features)
            
            # Predict popularity score
            popularity_score = self.ml_model.predict(content_features)
            
            # Add confidence score
            confidence = self.ml_model.predict_proba(content_features)
            
            return {
                'content_id': content_id,
                'popularity_score': popularity_score[0],
                'confidence': confidence[0].max(),
                'features': content_features,
                'timestamp': time.time()
            }
        except Exception as e:
            print(f"Error predicting popularity for {content_id}: {e}")
            return None
    
    def schedule_cache_warming(self, content_id, priority, features):
        """Schedule content for cache warming"""
        prediction = self.predict_content_popularity(content_id, features)
        if not prediction:
            return False
        
        # Calculate warming priority
        warming_priority = self._calculate_warming_priority(prediction, priority)
        
        # Add to warming queue
        warming_task = {
            'content_id': content_id,
            'priority': warming_priority,
            'prediction': prediction,
            'scheduled_at': time.time(),
            'status': 'pending'
        }
        
        self.warming_queue.put((warming_priority, warming_task))
        return True
    
    def warm_cache_batch(self, content_ids, batch_size=100):
        """Warm cache for multiple content items"""
        warmed_count = 0
        failed_count = 0
        
        for i in range(0, len(content_ids), batch_size):
            batch = content_ids[i:i + batch_size]
            
            try:
                # Warm cache for batch
                results = self._warm_cache_batch_internal(batch)
                
                # Update statistics
                warmed_count += results['success']
                failed_count += results['failed']
                
                # Update progress
                for content_id in batch:
                    self.warming_progress[content_id] = {
                        'status': 'completed' if content_id in results['success_items'] else 'failed',
                        'completed_at': time.time()
                    }
                
            except Exception as e:
                print(f"Error warming batch {batch}: {e}")
                failed_count += len(batch)
        
        return {
            'warmed': warmed_count,
            'failed': failed_count,
            'total': len(content_ids)
        }
    
    def _warm_cache_batch_internal(self, content_ids):
        """Internal method to warm cache for batch"""
        success_items = []
        failed_items = []
        
        for content_id in content_ids:
            try:
                # Get content data
                content_data = self.content_analyzer.get_content_data(content_id)
                if not content_data:
                    failed_items.append(content_id)
                    continue
                
                # Warm cache
                cache_key = f"content:{content_id}"
                self.cache.setex(cache_key, 3600, json.dumps(content_data))
                
                # Warm related content
                related_content = self.content_analyzer.get_related_content(content_id)
                for related_id in related_content:
                    related_data = self.content_analyzer.get_content_data(related_id)
                    if related_data:
                        related_key = f"content:{related_id}"
                        self.cache.setex(related_key, 3600, json.dumps(related_data))
                
                success_items.append(content_id)
                
            except Exception as e:
                print(f"Error warming content {content_id}: {e}")
                failed_items.append(content_id)
        
        return {
            'success': len(success_items),
            'failed': len(failed_items),
            'success_items': success_items,
            'failed_items': failed_items
        }
    
    def get_warming_progress(self, content_id):
        """Get warming progress for content"""
        return self.warming_progress.get(content_id, {
            'status': 'not_scheduled',
            'scheduled_at': None,
            'completed_at': None
        })
    
    def update_popularity_model(self, training_data):
        """Update popularity prediction model"""
        try:
            # Prepare training data
            X, y = self._prepare_training_data(training_data)
            
            # Train model
            self.ml_model.fit(X, y)
            
            # Save model
            self._save_model()
            
            return True
        except Exception as e:
            print(f"Error updating model: {e}")
            return False
    
    def _calculate_warming_priority(self, prediction, base_priority):
        """Calculate warming priority based on prediction"""
        popularity_score = prediction['popularity_score']
        confidence = prediction['confidence']
        
        # Higher popularity and confidence = higher priority
        priority = base_priority * popularity_score * confidence
        
        return priority
    
    def start_warming_processor(self):
        """Start background warming processor"""
        def process_warming_queue():
            while True:
                try:
                    if not self.warming_queue.empty():
                        priority, task = self.warming_queue.get()
                        self._process_warming_task(task)
                        self.warming_queue.task_done()
                    else:
                        time.sleep(1)
                except Exception as e:
                    print(f"Error in warming processor: {e}")
                    time.sleep(1)
        
        threading.Thread(target=process_warming_queue, daemon=True).start()
    
    def _process_warming_task(self, task):
        """Process individual warming task"""
        content_id = task['content_id']
        
        try:
            # Update status
            self.warming_progress[content_id] = {
                'status': 'warming',
                'scheduled_at': task['scheduled_at'],
                'started_at': time.time()
            }
            
            # Warm cache
            content_data = self.content_analyzer.get_content_data(content_id)
            if content_data:
                cache_key = f"content:{content_id}"
                self.cache.setex(cache_key, 3600, json.dumps(content_data))
                
                # Update status
                self.warming_progress[content_id]['status'] = 'completed'
                self.warming_progress[content_id]['completed_at'] = time.time()
            else:
                self.warming_progress[content_id]['status'] = 'failed'
                
        except Exception as e:
            print(f"Error processing warming task for {content_id}: {e}")
            self.warming_progress[content_id]['status'] = 'failed'
```

### Temporal Cache Warmer

```python
class TemporalCacheWarmer:
    def __init__(self, cache_client, scheduler, event_bus):
        self.cache = cache_client
        self.scheduler = scheduler
        self.event_bus = event_bus
        self.warming_schedules = {}
        self.timezone_aware = True
        self.setup_scheduled_warming()
        self.setup_event_warming()
    
    def schedule_peak_hour_warming(self, content_ids, peak_hours):
        """Schedule warming for peak hours"""
        for hour in peak_hours:
            schedule_id = f"peak_warming_{hour}"
            
            # Schedule warming 30 minutes before peak hour
            warming_time = hour - 0.5
            
            self.scheduler.add_job(
                func=self._warm_peak_content,
                trigger='cron',
                hour=int(warming_time),
                minute=int((warming_time % 1) * 60),
                args=[content_ids],
                id=schedule_id
            )
            
            self.warming_schedules[schedule_id] = {
                'type': 'peak_hour',
                'content_ids': content_ids,
                'hour': hour,
                'status': 'scheduled'
            }
    
    def schedule_seasonal_warming(self, content_id, seasonal_pattern):
        """Schedule warming for seasonal content"""
        schedule_id = f"seasonal_warming_{content_id}"
        
        # Parse seasonal pattern
        pattern = self._parse_seasonal_pattern(seasonal_pattern)
        
        # Schedule warming based on pattern
        for schedule in pattern['schedules']:
            self.scheduler.add_job(
                func=self._warm_seasonal_content,
                trigger='cron',
                month=schedule['month'],
                day=schedule['day'],
                hour=schedule['hour'],
                args=[content_id, schedule['duration']],
                id=f"{schedule_id}_{schedule['month']}_{schedule['day']}"
            )
        
        self.warming_schedules[schedule_id] = {
            'type': 'seasonal',
            'content_id': content_id,
            'pattern': seasonal_pattern,
            'status': 'scheduled'
        }
    
    def setup_event_warming(self, event_types):
        """Setup event-driven warming"""
        for event_type in event_types:
            self.event_bus.subscribe(event_type, self._handle_warming_event)
    
    def warm_on_user_action(self, user_id, action_type):
        """Warm cache based on user action"""
        try:
            # Get user preferences
            user_prefs = self._get_user_preferences(user_id)
            
            # Get recommended content
            recommended_content = self._get_recommended_content(user_id, action_type)
            
            # Warm cache for recommended content
            for content_id in recommended_content:
                self._warm_user_content(user_id, content_id)
            
            return True
        except Exception as e:
            print(f"Error warming on user action: {e}")
            return False
    
    def warm_on_content_update(self, content_id, update_type):
        """Warm cache when content is updated"""
        try:
            # Get updated content
            content_data = self._get_updated_content(content_id)
            if not content_data:
                return False
            
            # Warm cache
            cache_key = f"content:{content_id}"
            self.cache.setex(cache_key, 3600, json.dumps(content_data))
            
            # Warm related content
            related_content = self._get_related_content(content_id)
            for related_id in related_content:
                self._warm_related_content(related_id)
            
            return True
        except Exception as e:
            print(f"Error warming on content update: {e}")
            return False
    
    def _warm_peak_content(self, content_ids):
        """Warm content for peak hours"""
        for content_id in content_ids:
            try:
                content_data = self._get_content_data(content_id)
                if content_data:
                    cache_key = f"content:{content_id}"
                    self.cache.setex(cache_key, 3600, json.dumps(content_data))
            except Exception as e:
                print(f"Error warming peak content {content_id}: {e}")
    
    def _warm_seasonal_content(self, content_id, duration):
        """Warm seasonal content"""
        try:
            content_data = self._get_content_data(content_id)
            if content_data:
                cache_key = f"content:{content_id}"
                # Set longer TTL for seasonal content
                ttl = duration * 3600  # Convert hours to seconds
                self.cache.setex(cache_key, ttl, json.dumps(content_data))
        except Exception as e:
            print(f"Error warming seasonal content {content_id}: {e}")
    
    def _handle_warming_event(self, event):
        """Handle warming event"""
        event_type = event.get('type')
        
        if event_type == 'user_login':
            self.warm_on_user_action(event['user_id'], 'login')
        elif event_type == 'content_published':
            self.warm_on_content_update(event['content_id'], 'published')
        elif event_type == 'content_updated':
            self.warm_on_content_update(event['content_id'], 'updated')
    
    def _parse_seasonal_pattern(self, pattern):
        """Parse seasonal pattern configuration"""
        # This would parse a configuration like:
        # "monthly:1,6,12:9:24" (month 1,6,12 at 9 AM for 24 hours)
        # For this example, we'll return a simple structure
        return {
            'schedules': [
                {'month': 1, 'day': 1, 'hour': 9, 'duration': 24},
                {'month': 6, 'day': 1, 'hour': 9, 'duration': 24},
                {'month': 12, 'day': 1, 'hour': 9, 'duration': 24}
            ]
        }
```

## Additional Resources

### Cache Warming Strategies
- [Cache Warming Patterns](https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/Strategies.html)
- [Predictive Caching](https://en.wikipedia.org/wiki/Predictive_caching)
- [Cache Preloading](https://en.wikipedia.org/wiki/Cache_preloading)

### Machine Learning for Caching
- [Content Popularity Prediction](https://en.wikipedia.org/wiki/Popularity_prediction)
- [Time Series Analysis](https://en.wikipedia.org/wiki/Time_series)
- [Recommendation Systems](https://en.wikipedia.org/wiki/Recommender_system)

### Tools and Libraries
- **Scikit-learn**: Machine learning library
- **Pandas**: Data analysis library
- **NumPy**: Numerical computing
- **Redis**: Cache storage
- **Celery**: Task queue for warming

### Best Practices
- Use appropriate warming strategies for different content types
- Implement proper resource throttling
- Monitor warming performance continuously
- Optimize warming based on actual usage patterns

## Next Steps

After completing this exercise:
1. **Deploy**: Deploy warming system to production
2. **Monitor**: Set up comprehensive warming monitoring
3. **Optimize**: Continuously optimize warming strategies
4. **Scale**: Plan for future scaling requirements
5. **Improve**: Enhance prediction accuracy over time

---

**Last Updated**: 2024-01-15  
**Version**: 1.0  
**Next Review**: 2024-02-15
