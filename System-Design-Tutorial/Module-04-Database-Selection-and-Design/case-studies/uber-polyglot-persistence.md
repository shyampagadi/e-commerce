# Case Study: Uber - Polyglot Persistence Strategy

## Business Context

### Company Overview
Uber is a global mobility platform that connects riders with drivers through a mobile application. The company operates in over 10,000 cities across 69 countries, serving millions of users daily with ride-sharing, food delivery, and freight services.

### Business Model
- **Ride-Sharing**: Connecting riders with drivers for transportation
- **Food Delivery**: Uber Eats for restaurant food delivery
- **Freight**: Uber Freight for shipping and logistics
- **Multi-Modal Transportation**: Bikes, scooters, and public transit integration
- **Global Operations**: Worldwide service with local adaptations

### Scale and Growth
- **Users**: 100+ million monthly active users globally
- **Drivers**: 5+ million active drivers worldwide
- **Trips**: 15+ million trips per day
- **Cities**: 10,000+ cities across 69 countries
- **Data Volume**: Petabytes of data generated daily
- **Growth Rate**: 20%+ year-over-year growth

### Business Requirements
- **Real-Time Matching**: Sub-second driver-rider matching
- **Global Scale**: Support for millions of concurrent users
- **High Availability**: 99.99% uptime globally
- **Low Latency**: Sub-second response times
- **Data Consistency**: Strong consistency for critical operations
- **Geographic Distribution**: Data close to users worldwide

## Technical Challenges

### Database Performance Issues
- **Real-Time Requirements**: Sub-second response times for matching
- **High Concurrency**: Millions of simultaneous users
- **Global Latency**: Cross-region data access
- **Data Volume**: Petabytes of data generated daily
- **Complex Queries**: Real-time matching and routing algorithms

### Scalability Bottlenecks
- **Monolithic Database**: Single database couldn't handle scale
- **Geographic Distribution**: Data needed to be close to users
- **Different Data Types**: Various data types with different access patterns
- **Real-Time Processing**: Need for real-time data processing
- **Complex Relationships**: Complex data relationships and dependencies

### Data Consistency Challenges
- **Real-Time Matching**: Strong consistency for critical operations
- **Eventual Consistency**: Acceptable for non-critical data
- **Cross-Service Dependencies**: Data consistency across services
- **Geographic Distribution**: Data consistency across regions
- **Conflict Resolution**: Handling concurrent updates

## Solution Architecture

### Polyglot Persistence Strategy

Uber implemented a polyglot persistence strategy using multiple database technologies optimized for specific use cases:

#### Database Technology Selection
```
Service                    | Database        | Justification
--------------------------|-----------------|----------------------------------
User Management           | PostgreSQL      | ACID properties, complex queries
Driver Management         | PostgreSQL      | ACID properties, driver data
Trip Management           | PostgreSQL      | ACID properties, trip data
Location Services         | Redis           | High-performance, real-time data
Matching Engine           | Redis           | High-performance, real-time matching
Analytics                 | ClickHouse      | Time-series, analytical queries
Search & Discovery        | Elasticsearch   | Full-text search, geospatial queries
Event Streaming           | Kafka           | Real-time event processing
Configuration             | MySQL           | Configuration data
Audit & Compliance        | PostgreSQL      | ACID properties, audit trails
```

#### Architecture Overview
```
┌─────────────────────────────────────────────────────────────┐
│                UBER POLYGLOT ARCHITECTURE                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                Application Layer                    │    │
│  │                                                     │    │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────┐  │    │
│  │  │   Rider     │    │   Driver    │    │  Trip   │  │    │
│  │  │  Service    │    │  Service    │    │ Service │  │    │
│  │  └─────────────┘    └─────────────┘    └─────────┘  │    │
│  │                                                     │    │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────┐  │    │
│  │  │  Location   │    │  Matching   │    │Analytics│  │    │
│  │  │  Service    │    │  Service    │    │ Service │  │    │
│  │  └─────────────┘    └─────────────┘    └─────────┘  │    │
│  └─────────────────────────────────────────────────────┘    │
│                             │                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                Database Layer                       │    │
│  │                                                     │    │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────┐  │    │
│  │  │PostgreSQL   │    │    Redis    │    │ClickHouse│  │    │
│  │  │             │    │             │    │         │  │    │
│  │  │ - Users     │    │ - Locations │    │ - Events │  │    │
│  │  │ - Drivers   │    │ - Matching  │    │ - Metrics│  │    │
│  │  │ - Trips    │    │ - Sessions  │    │ - Analytics│  │    │
│  │  │ - Payments  │    │ - Cache     │    │ - Reports│  │    │
│  │  └─────────────┘    └─────────────┘    └─────────┘  │    │
│  │                                                     │    │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────┐  │    │
│  │  │Elasticsearch│    │    Kafka    │    │  MySQL  │  │    │
│  │  │             │    │             │    │         │  │    │
│  │  │ - Search    │    │ - Events    │    │ - Config│  │    │
│  │  │ - Discovery │    │ - Streaming │    │ - Settings│  │    │
│  │  │ - Geospatial│    │ - Messaging │    │ - Metadata│  │    │
│  │  └─────────────┘    └─────────────┘    └─────────┘  │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Data Model Design

#### User Management (PostgreSQL)
```sql
-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    phone_number VARCHAR(20) UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    date_of_birth DATE,
    country_code VARCHAR(3) NOT NULL,
    language_code VARCHAR(5) DEFAULT 'en',
    is_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_phone (phone_number),
    INDEX idx_country (country_code)
);

-- User addresses
CREATE TABLE user_addresses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    address_type VARCHAR(50) DEFAULT 'home',
    is_default BOOLEAN DEFAULT FALSE,
    address_line_1 VARCHAR(255) NOT NULL,
    address_line_2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(100) NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_location (latitude, longitude)
);

-- User preferences
CREATE TABLE user_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    preference_key VARCHAR(100) NOT NULL,
    preference_value TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uk_user_preference (user_id, preference_key)
);
```

#### Driver Management (PostgreSQL)
```sql
-- Drivers table
CREATE TABLE drivers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    driver_license_number VARCHAR(50) UNIQUE NOT NULL,
    license_expiry_date DATE NOT NULL,
    vehicle_id UUID,
    is_online BOOLEAN DEFAULT FALSE,
    is_available BOOLEAN DEFAULT FALSE,
    current_latitude DECIMAL(10, 8),
    current_longitude DECIMAL(11, 8),
    current_heading INTEGER,
    current_speed DECIMAL(5, 2),
    rating DECIMAL(3, 2) DEFAULT 0.0,
    total_trips INTEGER DEFAULT 0,
    total_earnings DECIMAL(10, 2) DEFAULT 0.0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_license (driver_license_number),
    INDEX idx_location (current_latitude, current_longitude),
    INDEX idx_online (is_online, is_available)
);

-- Vehicles table
CREATE TABLE vehicles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    driver_id UUID NOT NULL REFERENCES drivers(id) ON DELETE CASCADE,
    make VARCHAR(100) NOT NULL,
    model VARCHAR(100) NOT NULL,
    year INTEGER NOT NULL,
    color VARCHAR(50) NOT NULL,
    license_plate VARCHAR(20) UNIQUE NOT NULL,
    vehicle_type VARCHAR(50) NOT NULL,
    capacity INTEGER NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (driver_id) REFERENCES drivers(id) ON DELETE CASCADE,
    INDEX idx_driver_id (driver_id),
    INDEX idx_license_plate (license_plate),
    INDEX idx_vehicle_type (vehicle_type)
);
```

#### Trip Management (PostgreSQL)
```sql
-- Trips table
CREATE TABLE trips (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rider_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    driver_id UUID NOT NULL REFERENCES drivers(id) ON DELETE CASCADE,
    vehicle_id UUID NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
    trip_status VARCHAR(20) DEFAULT 'requested',
    pickup_latitude DECIMAL(10, 8) NOT NULL,
    pickup_longitude DECIMAL(11, 8) NOT NULL,
    pickup_address TEXT NOT NULL,
    dropoff_latitude DECIMAL(10, 8) NOT NULL,
    dropoff_longitude DECIMAL(11, 8) NOT NULL,
    dropoff_address TEXT NOT NULL,
    distance_km DECIMAL(8, 2),
    duration_minutes INTEGER,
    base_fare DECIMAL(8, 2) NOT NULL,
    distance_fare DECIMAL(8, 2) DEFAULT 0.0,
    time_fare DECIMAL(8, 2) DEFAULT 0.0,
    surge_multiplier DECIMAL(3, 2) DEFAULT 1.0,
    total_fare DECIMAL(8, 2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    payment_status VARCHAR(20) DEFAULT 'pending',
    requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    accepted_at TIMESTAMP,
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    cancelled_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (rider_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (driver_id) REFERENCES drivers(id) ON DELETE CASCADE,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE,
    INDEX idx_rider_id (rider_id),
    INDEX idx_driver_id (driver_id),
    INDEX idx_status (trip_status),
    INDEX idx_requested_at (requested_at),
    INDEX idx_pickup_location (pickup_latitude, pickup_longitude),
    INDEX idx_dropoff_location (dropoff_latitude, dropoff_longitude)
);
```

#### Location Services (Redis)
```python
import redis
import json
import time

class LocationService:
    def __init__(self, redis_client):
        self.redis = redis_client
    
    def update_driver_location(self, driver_id, latitude, longitude, heading, speed):
        """Update driver location in Redis"""
        location_data = {
            'driver_id': driver_id,
            'latitude': latitude,
            'longitude': longitude,
            'heading': heading,
            'speed': speed,
            'timestamp': time.time()
        }
        
        # Store location data
        key = f"driver_location:{driver_id}"
        self.redis.setex(key, 300, json.dumps(location_data))  # 5 minute TTL
        
        # Update geospatial index
        self.redis.geoadd("driver_locations", longitude, latitude, driver_id)
        
        # Update driver status
        self.redis.hset(f"driver_status:{driver_id}", mapping={
            'is_online': 'true',
            'is_available': 'true',
            'last_seen': str(int(time.time()))
        })
    
    def find_nearby_drivers(self, latitude, longitude, radius_km=5, limit=10):
        """Find nearby drivers using geospatial queries"""
        # Search for drivers within radius
        results = self.redis.georadius(
            "driver_locations",
            longitude,
            latitude,
            radius_km,
            unit="km",
            withdist=True,
            withcoord=True,
            count=limit,
            sort="ASC"
        )
        
        drivers = []
        for result in results:
            driver_id, distance, coordinates = result
            longitude, latitude = coordinates
            
            # Get driver status
            status = self.redis.hgetall(f"driver_status:{driver_id}")
            if status.get('is_available') == 'true':
                drivers.append({
                    'driver_id': driver_id,
                    'latitude': latitude,
                    'longitude': longitude,
                    'distance_km': distance,
                    'status': status
                })
        
        return drivers
    
    def get_driver_location(self, driver_id):
        """Get current driver location"""
        key = f"driver_location:{driver_id}"
        data = self.redis.get(key)
        if data:
            return json.loads(data)
        return None
```

#### Matching Engine (Redis)
```python
class MatchingEngine:
    def __init__(self, redis_client):
        self.redis = redis_client
    
    def find_best_driver(self, rider_id, pickup_latitude, pickup_longitude, vehicle_type='standard'):
        """Find the best driver for a rider"""
        # Get nearby drivers
        nearby_drivers = self.find_nearby_drivers(
            pickup_latitude, 
            pickup_longitude, 
            radius_km=10
        )
        
        if not nearby_drivers:
            return None
        
        # Score drivers based on multiple factors
        scored_drivers = []
        for driver in nearby_drivers:
            score = self._calculate_driver_score(
                driver, 
                pickup_latitude, 
                pickup_longitude, 
                vehicle_type
            )
            scored_drivers.append((driver, score))
        
        # Sort by score (highest first)
        scored_drivers.sort(key=lambda x: x[1], reverse=True)
        
        # Return best driver
        return scored_drivers[0][0] if scored_drivers else None
    
    def _calculate_driver_score(self, driver, pickup_lat, pickup_lon, vehicle_type):
        """Calculate driver score based on multiple factors"""
        score = 0
        
        # Distance factor (closer is better)
        distance = driver['distance_km']
        distance_score = max(0, 100 - (distance * 10))  # 0-100 based on distance
        score += distance_score * 0.4
        
        # Rating factor (higher is better)
        rating = float(driver['status'].get('rating', 0))
        rating_score = rating * 20  # 0-100 based on rating
        score += rating_score * 0.3
        
        # Availability factor (recently active is better)
        last_seen = int(driver['status'].get('last_seen', 0))
        current_time = int(time.time())
        time_diff = current_time - last_seen
        
        if time_diff < 60:  # Active within last minute
            availability_score = 100
        elif time_diff < 300:  # Active within last 5 minutes
            availability_score = 80
        elif time_diff < 900:  # Active within last 15 minutes
            availability_score = 60
        else:
            availability_score = 20
        
        score += availability_score * 0.3
        
        return score
    
    def match_driver_to_rider(self, rider_id, driver_id, trip_id):
        """Match a driver to a rider"""
        # Store match in Redis
        match_data = {
            'rider_id': rider_id,
            'driver_id': driver_id,
            'trip_id': trip_id,
            'matched_at': time.time(),
            'status': 'matched'
        }
        
        self.redis.setex(
            f"trip_match:{trip_id}", 
            3600,  # 1 hour TTL
            json.dumps(match_data)
        )
        
        # Notify driver and rider
        self._notify_match(rider_id, driver_id, trip_id)
    
    def _notify_match(self, rider_id, driver_id, trip_id):
        """Notify driver and rider about the match"""
        # Implementation for push notifications
        pass
```

#### Analytics (ClickHouse)
```sql
-- Trip events table
CREATE TABLE trip_events (
    event_id UUID,
    trip_id UUID,
    rider_id UUID,
    driver_id UUID,
    event_type String,
    event_data String,
    latitude Float64,
    longitude Float64,
    timestamp DateTime,
    city String,
    country String,
    date Date
) ENGINE = MergeTree()
PARTITION BY date
ORDER BY (trip_id, timestamp)
SETTINGS index_granularity = 8192;

-- Driver metrics table
CREATE TABLE driver_metrics (
    driver_id UUID,
    date Date,
    total_trips UInt32,
    total_earnings Float64,
    total_distance_km Float64,
    total_duration_minutes UInt32,
    average_rating Float64,
    online_hours Float64,
    acceptance_rate Float64,
    cancellation_rate Float64
) ENGINE = SummingMergeTree()
PARTITION BY date
ORDER BY (driver_id, date)
SETTINGS index_granularity = 8192;

-- Rider metrics table
CREATE TABLE rider_metrics (
    rider_id UUID,
    date Date,
    total_trips UInt32,
    total_spent Float64,
    average_rating Float64,
    cancellation_rate Float64
) ENGINE = SummingMergeTree()
PARTITION BY date
ORDER BY (rider_id, date)
SETTINGS index_granularity = 8192;
```

### Data Synchronization Strategy

#### Event-Driven Synchronization
```python
import json
import time
from kafka import KafkaProducer

class EventPublisher:
    def __init__(self, kafka_producer):
        self.producer = kafka_producer
    
    def publish_trip_event(self, trip_id, event_type, event_data):
        """Publish trip event to Kafka"""
        event = {
            'event_id': str(uuid.uuid4()),
            'trip_id': trip_id,
            'event_type': event_type,
            'event_data': event_data,
            'timestamp': time.time(),
            'source': 'trip_service'
        }
        
        self.producer.send('trip_events', json.dumps(event))
    
    def publish_driver_event(self, driver_id, event_type, event_data):
        """Publish driver event to Kafka"""
        event = {
            'event_id': str(uuid.uuid4()),
            'driver_id': driver_id,
            'event_type': event_type,
            'event_data': event_data,
            'timestamp': time.time(),
            'source': 'driver_service'
        }
        
        self.producer.send('driver_events', json.dumps(event))
    
    def publish_user_event(self, user_id, event_type, event_data):
        """Publish user event to Kafka"""
        event = {
            'event_id': str(uuid.uuid4()),
            'user_id': user_id,
            'event_type': event_type,
            'event_data': event_data,
            'timestamp': time.time(),
            'source': 'user_service'
        }
        
        self.producer.send('user_events', json.dumps(event))
```

#### Data Synchronization Service
```python
from kafka import KafkaConsumer
import json

class DataSynchronizationService:
    def __init__(self, kafka_consumer, postgres_client, redis_client, clickhouse_client):
        self.consumer = kafka_consumer
        self.postgres = postgres_client
        self.redis = redis_client
        self.clickhouse = clickhouse_client
    
    def start_consuming(self):
        """Start consuming events and synchronizing data"""
        for message in self.consumer:
            try:
                event = json.loads(message.value)
                self._process_event(event)
            except Exception as e:
                print(f"Error processing event: {e}")
    
    def _process_event(self, event):
        """Process individual event"""
        event_type = event['event_type']
        source = event['source']
        
        if source == 'trip_service':
            self._process_trip_event(event)
        elif source == 'driver_service':
            self._process_driver_event(event)
        elif source == 'user_service':
            self._process_user_event(event)
    
    def _process_trip_event(self, event):
        """Process trip-related events"""
        event_type = event['event_type']
        trip_id = event['trip_id']
        
        if event_type == 'trip_started':
            # Update Redis with trip status
            self.redis.hset(f"trip_status:{trip_id}", mapping={
                'status': 'started',
                'started_at': str(int(time.time()))
            })
            
            # Update ClickHouse analytics
            self._update_trip_analytics(event)
        
        elif event_type == 'trip_completed':
            # Update Redis with trip completion
            self.redis.hset(f"trip_status:{trip_id}", mapping={
                'status': 'completed',
                'completed_at': str(int(time.time()))
            })
            
            # Update ClickHouse analytics
            self._update_trip_analytics(event)
    
    def _process_driver_event(self, event):
        """Process driver-related events"""
        event_type = event['event_type']
        driver_id = event['driver_id']
        
        if event_type == 'driver_online':
            # Update Redis with driver status
            self.redis.hset(f"driver_status:{driver_id}", mapping={
                'is_online': 'true',
                'is_available': 'true',
                'last_seen': str(int(time.time()))
            })
        
        elif event_type == 'driver_offline':
            # Update Redis with driver status
            self.redis.hset(f"driver_status:{driver_id}", mapping={
                'is_online': 'false',
                'is_available': 'false',
                'last_seen': str(int(time.time()))
            })
    
    def _process_user_event(self, event):
        """Process user-related events"""
        event_type = event['event_type']
        user_id = event['user_id']
        
        if event_type == 'user_created':
            # Update Redis with user data
            user_data = event['event_data']
            self.redis.hset(f"user_data:{user_id}", mapping=user_data)
    
    def _update_trip_analytics(self, event):
        """Update ClickHouse analytics with trip data"""
        # Implementation for updating analytics
        pass
```

## Implementation Details

### Database Migration Strategy

#### Phase 1: Service Extraction
1. **Identify Bounded Contexts**: User management, driver management, trip management
2. **Extract Services**: Create microservices for each bounded context
3. **Database per Service**: Assign dedicated databases to each service
4. **Event Streaming**: Implement event-driven communication

#### Phase 2: Data Migration
1. **Data Analysis**: Understand data relationships and dependencies
2. **Migration Planning**: Create detailed migration scripts
3. **Data Validation**: Ensure data integrity during migration
4. **Rollback Strategy**: Plan for migration rollback if needed

#### Phase 3: Service Integration
1. **Event Streaming**: Implement event-driven communication
2. **Data Synchronization**: Set up cross-service data sync
3. **Monitoring**: Implement comprehensive monitoring
4. **Testing**: End-to-end testing of the new architecture

### Performance Optimization

#### Caching Strategy
```python
class CachingStrategy:
    def __init__(self, redis_client):
        self.redis = redis_client
    
    def cache_user_data(self, user_id, user_data, ttl=3600):
        """Cache user data in Redis"""
        key = f"user_data:{user_id}"
        self.redis.setex(key, ttl, json.dumps(user_data))
    
    def get_cached_user_data(self, user_id):
        """Get cached user data from Redis"""
        key = f"user_data:{user_id}"
        data = self.redis.get(key)
        if data:
            return json.loads(data)
        return None
    
    def cache_driver_locations(self, driver_id, location_data, ttl=300):
        """Cache driver location data"""
        key = f"driver_location:{driver_id}"
        self.redis.setex(key, ttl, json.dumps(location_data))
    
    def get_cached_driver_location(self, driver_id):
        """Get cached driver location"""
        key = f"driver_location:{driver_id}"
        data = self.redis.get(key)
        if data:
            return json.loads(data)
        return None
```

#### Query Optimization
```sql
-- Optimized trip query with proper indexing
SELECT 
    t.id,
    t.trip_status,
    t.pickup_address,
    t.dropoff_address,
    t.total_fare,
    u.first_name as rider_name,
    d.driver_license_number,
    v.make,
    v.model,
    v.license_plate
FROM trips t
JOIN users u ON t.rider_id = u.id
JOIN drivers d ON t.driver_id = d.id
JOIN vehicles v ON t.vehicle_id = v.id
WHERE t.trip_status = 'completed'
  AND t.requested_at >= CURRENT_DATE - INTERVAL '7 days'
ORDER BY t.requested_at DESC
LIMIT 100;

-- Optimized driver location query
SELECT 
    d.id,
    d.driver_license_number,
    d.current_latitude,
    d.current_longitude,
    d.rating,
    v.make,
    v.model
FROM drivers d
JOIN vehicles v ON d.vehicle_id = v.id
WHERE d.is_online = TRUE
  AND d.is_available = TRUE
  AND d.current_latitude BETWEEN ? AND ?
  AND d.current_longitude BETWEEN ? AND ?
ORDER BY d.rating DESC;
```

### Monitoring and Observability

#### Database Metrics
```python
class DatabaseMonitoring:
    def __init__(self, postgres_client, redis_client, clickhouse_client):
        self.postgres = postgres_client
        self.redis = redis_client
        self.clickhouse = clickhouse_client
    
    def get_postgres_metrics(self):
        """Get PostgreSQL metrics"""
        metrics = {}
        
        # Connection count
        result = self.postgres.execute("SELECT count(*) FROM pg_stat_activity")
        metrics['connection_count'] = result.fetchone()[0]
        
        # Query performance
        result = self.postgres.execute("""
            SELECT 
                query,
                calls,
                total_time,
                mean_time
            FROM pg_stat_statements
            ORDER BY total_time DESC
            LIMIT 10
        """)
        metrics['slow_queries'] = result.fetchall()
        
        return metrics
    
    def get_redis_metrics(self):
        """Get Redis metrics"""
        metrics = {}
        
        # Memory usage
        metrics['memory_usage'] = self.redis.info('memory')['used_memory']
        
        # Hit rate
        info = self.redis.info('stats')
        metrics['hit_rate'] = info['keyspace_hits'] / (info['keyspace_hits'] + info['keyspace_misses'])
        
        # Connection count
        metrics['connection_count'] = info['connected_clients']
        
        return metrics
    
    def get_clickhouse_metrics(self):
        """Get ClickHouse metrics"""
        metrics = {}
        
        # Query performance
        result = self.clickhouse.execute("""
            SELECT 
                query,
                query_duration_ms,
                memory_usage,
                read_rows
            FROM system.query_log
            WHERE event_date = today()
            ORDER BY query_duration_ms DESC
            LIMIT 10
        """)
        metrics['slow_queries'] = result.fetchall()
        
        return metrics
```

## Results and Lessons

### Performance Improvements
- **Response Time**: 50% reduction in average response time
- **Throughput**: 10x increase in requests per second
- **Availability**: 99.99% uptime achieved
- **Global Latency**: Sub-second response times globally
- **Scalability**: Linear scaling with user growth

### Cost Optimization
- **Infrastructure Costs**: 30% reduction through right-sizing
- **Operational Costs**: 40% reduction through automation
- **Storage Costs**: 50% reduction through data lifecycle management
- **Bandwidth Costs**: 25% reduction through CDN optimization

### Operational Benefits
- **Deployment Speed**: 5x faster service deployments
- **Incident Response**: 60% faster incident resolution
- **Team Productivity**: 40% increase in development velocity
- **System Reliability**: 90% reduction in critical incidents

### Lessons Learned

#### What Worked Well
1. **Polyglot Persistence**: Right tool for the right job
2. **Event-Driven Architecture**: Improved system resilience and flexibility
3. **Caching Strategy**: Significantly improved performance
4. **Monitoring**: Proactive issue detection and resolution
5. **Automation**: Reduced operational overhead

#### Challenges Encountered
1. **Data Consistency**: Complex eventual consistency management
2. **Service Dependencies**: Managing inter-service communication
3. **Data Migration**: Complex migration of existing data
4. **Monitoring Complexity**: Managing multiple database systems
5. **Team Learning**: Training teams on new technologies

#### What Would Be Done Differently
1. **Gradual Migration**: More incremental service extraction
2. **Better Testing**: More comprehensive integration testing
3. **Documentation**: Better documentation of data flows
4. **Team Training**: Earlier and more extensive training
5. **Monitoring**: Earlier implementation of comprehensive monitoring

### Future Considerations
1. **Technology Evolution**: Adopting new database technologies
2. **Global Expansion**: Supporting new regions and languages
3. **Data Growth**: Handling increasing data volumes
4. **Performance**: Further optimization for scale
5. **Compliance**: Meeting new regulatory requirements

## Key Takeaways

### Database Selection Criteria
- **Choose the right tool for the job**: Different databases for different use cases
- **Consider scalability**: Plan for future growth and scale
- **Balance consistency and performance**: Make informed trade-offs
- **Think globally**: Design for global distribution
- **Plan for operations**: Consider monitoring and maintenance

### Architecture Patterns
- **Polyglot Persistence**: Use multiple databases for different needs
- **Event-Driven**: Improves system resilience and flexibility
- **Caching**: Essential for performance at scale
- **Monitoring**: Critical for operational excellence
- **Automation**: Reduces operational overhead

### Implementation Strategy
- **Gradual Migration**: Incremental approach reduces risk
- **Comprehensive Testing**: Essential for complex systems
- **Team Training**: Invest in team capabilities
- **Documentation**: Critical for long-term maintenance
- **Monitoring**: Implement from the beginning

This case study demonstrates how Uber successfully implemented a polyglot persistence strategy to handle massive scale while maintaining high performance and availability. The key lessons can be applied to other large-scale systems facing similar challenges.

