# Project 3: IoT Data Processing Platform Caching System

## Overview

**Duration**: 3-4 weeks  
**Difficulty**: Advanced  
**Prerequisites**: Completion of Module 08 exercises and Projects 1-2

## Project Description

Design and implement a comprehensive caching system for an IoT data processing platform that handles millions of sensor readings per second, provides real-time analytics, and supports predictive maintenance across industrial equipment.

## Business Context

### Platform Requirements
- **Data Volume**: 100M+ sensor readings per day, 1M+ readings per second peak
- **Data Types**: Temperature, pressure, vibration, power consumption, GPS coordinates
- **Real-time Processing**: < 100ms latency for critical alerts
- **Historical Analysis**: 5+ years of data retention
- **Global Scale**: 50+ manufacturing facilities worldwide

### IoT Use Cases
- **Real-time Monitoring**: Live equipment status and performance metrics
- **Predictive Maintenance**: ML-based failure prediction and maintenance scheduling
- **Energy Optimization**: Power consumption analysis and optimization recommendations
- **Quality Control**: Product quality monitoring and defect detection
- **Environmental Monitoring**: Air quality, temperature, and humidity tracking

## Technical Requirements

### Performance Requirements
- **Data Ingestion**: 1M+ sensor readings per second
- **Query Latency**: < 50ms for real-time queries, < 1s for historical queries
- **Data Freshness**: < 5 seconds for real-time data
- **Availability**: 99.99% uptime for critical systems
- **Throughput**: 10M+ queries per day

### Data Characteristics
- **Time-series Data**: Sensor readings with timestamps
- **Geographic Data**: Location-based sensor data
- **High Cardinality**: 100K+ unique sensor IDs
- **Variable Frequency**: 1Hz to 1kHz sampling rates
- **Data Retention**: Hot (1 day), Warm (1 month), Cold (5 years)

### Query Patterns
- **Point Queries**: Single sensor value at specific time
- **Range Queries**: Sensor values over time range
- **Aggregation Queries**: Min, max, avg, sum over time windows
- **Spatial Queries**: Sensors within geographic region
- **Correlation Queries**: Relationships between multiple sensors

## Architecture Design

### Multi-Tier Caching Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    IoT Data Sources                        │
│              (Sensors, Gateways, Edge Devices)             │
└─────────────────────┬───────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────┐
│                Edge Cache Layer                             │
│              (Local Processing, 1s TTL)                    │
└─────────────────────┬───────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────┐
│                L1: Application Cache                        │
│              (In-Memory, 5min TTL)                         │
└─────────────────────┬───────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────┐
│                L2: Time-Series Cache                        │
│              (Redis TimeSeries, 1h TTL)                    │
└─────────────────────┬───────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────┐
│                L3: Aggregated Cache                         │
│              (InfluxDB Cache, 24h TTL)                     │
└─────────────────────┬───────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────┐
│                L4: Historical Cache                         │
│              (S3 + Glacier, 5y TTL)                        │
└─────────────────────────────────────────────────────────────┘
```

### Cache Strategy by Data Type

#### Real-time Data (Hot Cache)
- **Storage**: In-memory cache (Redis)
- **TTL**: 1-5 minutes
- **Use Case**: Live monitoring, alerts
- **Access Pattern**: High frequency, low latency

#### Recent Data (Warm Cache)
- **Storage**: Time-series database (InfluxDB)
- **TTL**: 1-24 hours
- **Use Case**: Dashboards, recent analysis
- **Access Pattern**: Medium frequency, medium latency

#### Historical Data (Cold Cache)
- **Storage**: Object storage (S3) + Glacier
- **TTL**: 5 years
- **Use Case**: Long-term analysis, compliance
- **Access Pattern**: Low frequency, high latency

## Implementation Tasks

### Task 1: Time-Series Cache Implementation (Week 1)

#### 1.1 Redis TimeSeries Setup
- Configure Redis TimeSeries module
- Set up time-series data structures
- Implement data compression
- Configure retention policies

#### 1.2 Edge Cache Implementation
- Implement local edge caching
- Set up data aggregation at edge
- Configure edge-to-cloud synchronization
- Implement edge cache warming

### Task 2: Real-time Data Processing (Week 2)

#### 2.1 Stream Processing Cache
- Implement Apache Kafka caching
- Set up stream processing with caching
- Configure real-time aggregation
- Implement backpressure handling

#### 2.2 Alert System Caching
- Cache alert conditions and thresholds
- Implement alert state management
- Set up alert escalation caching
- Configure alert history storage

### Task 3: Historical Data Caching (Week 2)

#### 3.1 Tiered Storage Implementation
- Implement hot/warm/cold data tiers
- Set up automatic data tiering
- Configure data lifecycle management
- Implement data archival strategies

#### 3.2 Query Optimization
- Implement query result caching
- Set up query plan caching
- Configure materialized views
- Implement query result compression

### Task 4: Performance Optimization (Week 3)

#### 4.1 Cache Warming Strategies
- Implement predictive cache warming
- Set up ML-based cache optimization
- Configure workload-based warming
- Implement geographic cache warming

#### 4.2 Monitoring and Analytics
- Set up comprehensive cache monitoring
- Implement performance analytics
- Configure cost optimization
- Set up capacity planning

## Technical Implementation

### Time-Series Cache Manager

```python
import redis
import time
import json
from typing import Dict, List, Any, Optional
from dataclasses import dataclass
from datetime import datetime, timedelta

@dataclass
class SensorReading:
    sensor_id: str
    timestamp: float
    value: float
    unit: str
    location: str
    device_type: str

class TimeSeriesCacheManager:
    def __init__(self, redis_client, influxdb_client):
        self.redis = redis_client
        self.influxdb = influxdb_client
        self.cache_config = {
            'hot_ttl': 300,      # 5 minutes
            'warm_ttl': 3600,    # 1 hour
            'cold_ttl': 86400,   # 24 hours
            'compression': True,
            'retention_days': 30
        }
        
    def store_sensor_reading(self, reading: SensorReading) -> bool:
        """Store sensor reading in appropriate cache tier"""
        try:
            # Store in hot cache (Redis)
            self._store_in_hot_cache(reading)
            
            # Store in warm cache (InfluxDB)
            self._store_in_warm_cache(reading)
            
            # Update aggregated data
            self._update_aggregated_data(reading)
            
            return True
        except Exception as e:
            logger.error(f"Failed to store sensor reading: {e}")
            return False
    
    def _store_in_hot_cache(self, reading: SensorReading):
        """Store reading in hot cache (Redis)"""
        key = f"sensor:{reading.sensor_id}:latest"
        data = {
            'value': reading.value,
            'timestamp': reading.timestamp,
            'unit': reading.unit,
            'location': reading.location
        }
        
        # Store with TTL
        self.redis.setex(key, self.cache_config['hot_ttl'], json.dumps(data))
        
        # Store in time series
        ts_key = f"sensor:{reading.sensor_id}:ts"
        self.redis.ts().add(ts_key, int(reading.timestamp * 1000), reading.value)
    
    def _store_in_warm_cache(self, reading: SensorReading):
        """Store reading in warm cache (InfluxDB)"""
        point = {
            'measurement': 'sensor_readings',
            'tags': {
                'sensor_id': reading.sensor_id,
                'location': reading.location,
                'device_type': reading.device_type
            },
            'fields': {
                'value': reading.value,
                'unit': reading.unit
            },
            'time': int(reading.timestamp * 1000000000)  # Nanoseconds
        }
        
        self.influxdb.write_points([point])
    
    def get_latest_reading(self, sensor_id: str) -> Optional[SensorReading]:
        """Get latest reading for sensor"""
        key = f"sensor:{sensor_id}:latest"
        data = self.redis.get(key)
        
        if data:
            reading_data = json.loads(data)
            return SensorReading(
                sensor_id=sensor_id,
                timestamp=reading_data['timestamp'],
                value=reading_data['value'],
                unit=reading_data['unit'],
                location=reading_data['location'],
                device_type='unknown'
            )
        
        return None
    
    def get_readings_range(self, sensor_id: str, start_time: float, 
                          end_time: float) -> List[SensorReading]:
        """Get readings for sensor in time range"""
        # Try hot cache first
        hot_readings = self._get_from_hot_cache(sensor_id, start_time, end_time)
        if hot_readings:
            return hot_readings
        
        # Try warm cache
        warm_readings = self._get_from_warm_cache(sensor_id, start_time, end_time)
        if warm_readings:
            return warm_readings
        
        # Fall back to cold cache
        return self._get_from_cold_cache(sensor_id, start_time, end_time)
    
    def _get_from_hot_cache(self, sensor_id: str, start_time: float, 
                           end_time: float) -> List[SensorReading]:
        """Get readings from hot cache"""
        ts_key = f"sensor:{sensor_id}:ts"
        
        try:
            # Get time series data
            data = self.redis.ts().range(
                ts_key,
                int(start_time * 1000),
                int(end_time * 1000)
            )
            
            readings = []
            for timestamp, value in data:
                readings.append(SensorReading(
                    sensor_id=sensor_id,
                    timestamp=timestamp / 1000.0,
                    value=value,
                    unit='unknown',
                    location='unknown',
                    device_type='unknown'
                ))
            
            return readings
        except Exception as e:
            logger.error(f"Failed to get from hot cache: {e}")
            return []
    
    def _get_from_warm_cache(self, sensor_id: str, start_time: float, 
                            end_time: float) -> List[SensorReading]:
        """Get readings from warm cache (InfluxDB)"""
        query = f"""
        SELECT value, unit, location, device_type
        FROM sensor_readings
        WHERE sensor_id = '{sensor_id}'
        AND time >= {int(start_time * 1000000000)}
        AND time <= {int(end_time * 1000000000)}
        ORDER BY time
        """
        
        try:
            result = self.influxdb.query(query)
            readings = []
            
            for point in result.get_points():
                readings.append(SensorReading(
                    sensor_id=sensor_id,
                    timestamp=point['time'] / 1000000000.0,
                    value=point['value'],
                    unit=point['unit'],
                    location=point['location'],
                    device_type=point['device_type']
                ))
            
            return readings
        except Exception as e:
            logger.error(f"Failed to get from warm cache: {e}")
            return []
    
    def _get_from_cold_cache(self, sensor_id: str, start_time: float, 
                            end_time: float) -> List[SensorReading]:
        """Get readings from cold cache (S3)"""
        # This would typically involve:
        # 1. Determining which S3 objects contain the data
        # 2. Downloading and parsing the data
        # 3. Filtering by time range
        # For this example, we'll return empty list
        return []
    
    def _update_aggregated_data(self, reading: SensorReading):
        """Update aggregated data for analytics"""
        # Update hourly aggregates
        hour_key = f"aggregate:hourly:{reading.sensor_id}:{int(reading.timestamp // 3600)}"
        self.redis.hincrbyfloat(hour_key, 'sum', reading.value)
        self.redis.hincrby(hour_key, 'count', 1)
        self.redis.expire(hour_key, 86400 * 7)  # 7 days
        
        # Update daily aggregates
        day_key = f"aggregate:daily:{reading.sensor_id}:{int(reading.timestamp // 86400)}"
        self.redis.hincrbyfloat(day_key, 'sum', reading.value)
        self.redis.hincrby(day_key, 'count', 1)
        self.redis.expire(day_key, 86400 * 30)  # 30 days
```

### Edge Cache Implementation

```python
class EdgeCacheManager:
    def __init__(self, local_storage, cloud_sync):
        self.local_storage = local_storage
        self.cloud_sync = cloud_sync
        self.edge_config = {
            'max_local_readings': 10000,
            'sync_interval': 60,  # seconds
            'compression_enabled': True,
            'encryption_enabled': True
        }
        self.local_readings = []
        self.sync_scheduler = Scheduler()
        self.setup_sync_scheduler()
    
    def store_reading(self, reading: SensorReading) -> bool:
        """Store reading in edge cache"""
        try:
            # Add to local storage
            self.local_readings.append(reading)
            
            # Check if we need to sync to cloud
            if len(self.local_readings) >= self.edge_config['max_local_readings']:
                self.sync_to_cloud()
            
            return True
        except Exception as e:
            logger.error(f"Failed to store reading in edge cache: {e}")
            return False
    
    def get_local_readings(self, sensor_id: str, limit: int = 100) -> List[SensorReading]:
        """Get readings from local edge cache"""
        filtered_readings = [
            r for r in self.local_readings 
            if r.sensor_id == sensor_id
        ]
        
        # Sort by timestamp (newest first)
        filtered_readings.sort(key=lambda x: x.timestamp, reverse=True)
        
        return filtered_readings[:limit]
    
    def setup_sync_scheduler(self):
        """Setup periodic sync to cloud"""
        self.sync_scheduler.add_job(
            self.sync_to_cloud,
            'interval',
            seconds=self.edge_config['sync_interval'],
            id='edge_sync'
        )
    
    def sync_to_cloud(self):
        """Sync local readings to cloud"""
        if not self.local_readings:
            return
        
        try:
            # Compress data if enabled
            if self.edge_config['compression_enabled']:
                data = self._compress_readings(self.local_readings)
            else:
                data = self.local_readings
            
            # Encrypt data if enabled
            if self.edge_config['encryption_enabled']:
                data = self._encrypt_data(data)
            
            # Send to cloud
            success = self.cloud_sync.send_readings(data)
            
            if success:
                # Clear local readings after successful sync
                self.local_readings.clear()
                logger.info(f"Successfully synced {len(data)} readings to cloud")
            else:
                logger.error("Failed to sync readings to cloud")
                
        except Exception as e:
            logger.error(f"Error during edge sync: {e}")
    
    def _compress_readings(self, readings: List[SensorReading]) -> bytes:
        """Compress readings data"""
        import gzip
        import pickle
        
        data = pickle.dumps(readings)
        compressed = gzip.compress(data)
        return compressed
    
    def _encrypt_data(self, data: bytes) -> bytes:
        """Encrypt data before sending to cloud"""
        from cryptography.fernet import Fernet
        
        # In production, use proper key management
        key = Fernet.generate_key()
        f = Fernet(key)
        encrypted = f.encrypt(data)
        return encrypted
```

### Predictive Cache Warming

```python
class PredictiveCacheWarmer:
    def __init__(self, cache_manager, ml_model):
        self.cache_manager = cache_manager
        self.ml_model = ml_model
        self.warming_strategies = {
            'time_based': self._warm_by_time_patterns,
            'anomaly_based': self._warm_by_anomalies,
            'correlation_based': self._warm_by_correlations
        }
    
    def warm_cache(self, strategy: str = 'time_based'):
        """Warm cache using specified strategy"""
        if strategy in self.warming_strategies:
            self.warming_strategies[strategy]()
        else:
            logger.error(f"Unknown warming strategy: {strategy}")
    
    def _warm_by_time_patterns(self):
        """Warm cache based on historical time patterns"""
        # Get sensors that typically have high activity at current time
        current_hour = datetime.now().hour
        active_sensors = self.ml_model.get_sensors_active_at_hour(current_hour)
        
        for sensor_id in active_sensors:
            # Pre-load recent data for active sensors
            end_time = time.time()
            start_time = end_time - 3600  # Last hour
            
            readings = self.cache_manager.get_readings_range(
                sensor_id, start_time, end_time
            )
            
            # Store in hot cache
            for reading in readings:
                self.cache_manager._store_in_hot_cache(reading)
    
    def _warm_by_anomalies(self):
        """Warm cache for sensors showing anomalous patterns"""
        # Get sensors with recent anomalies
        anomalous_sensors = self.ml_model.get_anomalous_sensors()
        
        for sensor_id in anomalous_sensors:
            # Pre-load data for anomaly analysis
            end_time = time.time()
            start_time = end_time - 86400  # Last 24 hours
            
            readings = self.cache_manager.get_readings_range(
                sensor_id, start_time, end_time
            )
            
            # Store in hot cache for quick access
            for reading in readings:
                self.cache_manager._store_in_hot_cache(reading)
    
    def _warm_by_correlations(self):
        """Warm cache for correlated sensors"""
        # Get sensor correlation groups
        correlation_groups = self.ml_model.get_sensor_correlations()
        
        for group in correlation_groups:
            # If one sensor in group is accessed, warm others
            for sensor_id in group:
                if self._is_sensor_accessed(sensor_id):
                    # Warm correlated sensors
                    for correlated_sensor in group:
                        if correlated_sensor != sensor_id:
                            self._warm_sensor_data(correlated_sensor)
    
    def _is_sensor_accessed(self, sensor_id: str) -> bool:
        """Check if sensor was recently accessed"""
        # Check access logs or cache hit rates
        access_key = f"access:{sensor_id}"
        last_access = self.cache_manager.redis.get(access_key)
        
        if last_access:
            return time.time() - float(last_access) < 300  # 5 minutes
        return False
    
    def _warm_sensor_data(self, sensor_id: str):
        """Warm data for specific sensor"""
        end_time = time.time()
        start_time = end_time - 1800  # Last 30 minutes
        
        readings = self.cache_manager.get_readings_range(
            sensor_id, start_time, end_time
        )
        
        # Store in hot cache
        for reading in readings:
            self.cache_manager._store_in_hot_cache(reading)
```

## Performance Optimization

### Cache Performance Monitoring

```python
class IoTCacheMonitor:
    def __init__(self, cache_manager):
        self.cache_manager = cache_manager
        self.metrics = {
            'ingestion_rate': 0,
            'query_latency': [],
            'cache_hit_ratio': 0,
            'data_volume': 0,
            'error_rate': 0
        }
    
    def monitor_performance(self):
        """Monitor cache performance metrics"""
        # Monitor ingestion rate
        self._monitor_ingestion_rate()
        
        # Monitor query latency
        self._monitor_query_latency()
        
        # Monitor cache hit ratio
        self._monitor_cache_hit_ratio()
        
        # Monitor data volume
        self._monitor_data_volume()
        
        # Monitor error rate
        self._monitor_error_rate()
    
    def _monitor_ingestion_rate(self):
        """Monitor data ingestion rate"""
        # Count readings processed in last minute
        current_time = time.time()
        minute_ago = current_time - 60
        
        # This would typically query a metrics store
        # For this example, we'll simulate
        self.metrics['ingestion_rate'] = 1000  # readings per minute
    
    def _monitor_query_latency(self):
        """Monitor query response latency"""
        # This would typically measure actual query times
        # For this example, we'll simulate
        avg_latency = 50  # milliseconds
        self.metrics['query_latency'].append(avg_latency)
        
        # Keep only last 100 measurements
        if len(self.metrics['query_latency']) > 100:
            self.metrics['query_latency'] = self.metrics['query_latency'][-100:]
    
    def get_performance_summary(self) -> Dict[str, Any]:
        """Get performance summary"""
        avg_latency = sum(self.metrics['query_latency']) / len(self.metrics['query_latency']) if self.metrics['query_latency'] else 0
        
        return {
            'ingestion_rate': self.metrics['ingestion_rate'],
            'avg_query_latency': avg_latency,
            'cache_hit_ratio': self.metrics['cache_hit_ratio'],
            'data_volume': self.metrics['data_volume'],
            'error_rate': self.metrics['error_rate']
        }
```

## Success Metrics

### Performance Metrics
- **Data Ingestion**: 1M+ readings per second
- **Query Latency**: < 50ms for real-time, < 1s for historical
- **Cache Hit Ratio**: > 90% for hot data, > 80% for warm data
- **Availability**: 99.99% uptime

### Cost Metrics
- **Storage Cost**: < $0.10 per GB per month
- **Query Cost**: < $0.001 per query
- **Data Transfer Cost**: < $0.05 per GB
- **Overall Cost Reduction**: 50% vs. direct database access

### Business Metrics
- **Alert Response Time**: < 5 seconds
- **Predictive Accuracy**: > 95% for failure prediction
- **Data Freshness**: < 5 seconds for real-time data
- **Compliance**: 100% data retention compliance

## Deliverables

### Technical Deliverables
1. **Multi-tier Cache Architecture**: Complete implementation
2. **Time-series Cache System**: Redis + InfluxDB integration
3. **Edge Cache Implementation**: Local processing and sync
4. **Predictive Cache Warming**: ML-based optimization
5. **Performance Monitoring**: Comprehensive monitoring system

### Documentation Deliverables
1. **System Design Document**: Complete architecture design
2. **API Documentation**: Cache API documentation
3. **Operations Guide**: Operational procedures
4. **Performance Guide**: Optimization strategies
5. **Cost Analysis**: Cost optimization analysis

## Evaluation Criteria

### Technical Implementation (40%)
- **Architecture Design**: Comprehensive multi-tier design
- **Time-series Handling**: Effective time-series data management
- **Edge Integration**: Proper edge cache implementation
- **Performance**: Meets all performance requirements

### Business Value (30%)
- **Performance Achievement**: Meets all performance targets
- **Cost Optimization**: Effective cost optimization
- **Scalability**: Handles required scale
- **Reliability**: High availability and reliability

### Innovation and Best Practices (20%)
- **Innovation**: Creative IoT-specific solutions
- **Best Practices**: Following IoT and caching best practices
- **Documentation**: Clear and comprehensive documentation
- **Testing**: Thorough testing and validation

### Presentation and Communication (10%)
- **Presentation**: Clear and engaging presentation
- **Documentation**: Professional-quality documentation
- **Communication**: Effective communication of technical concepts
- **Questions**: Ability to answer technical questions

This project provides a comprehensive real-world implementation of caching strategies for IoT data processing, demonstrating advanced time-series caching concepts and optimization techniques.
