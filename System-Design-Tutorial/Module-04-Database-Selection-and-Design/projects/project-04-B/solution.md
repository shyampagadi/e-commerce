# Project 04-B: Polyglot Database Architecture - Solution

## Overview
This document provides a comprehensive solution for implementing a polyglot persistence architecture for a multi-tenant e-commerce platform. The solution demonstrates how to integrate multiple database technologies to optimize for different use cases and access patterns.

## Solution Architecture

### 1. Database Technology Selection

#### Database Technology Matrix

| Use Case | Database | Technology | Justification |
|----------|----------|------------|---------------|
| User Management | PostgreSQL | RDBMS | ACID compliance, complex relationships, transactions |
| Product Catalog | MongoDB | Document DB | Flexible schema, complex product attributes, search |
| Session Management | Redis | Key-Value | Fast access, TTL support, high performance |
| Analytics | Cassandra | Column-Family | Time-series data, high write throughput |
| Search | Elasticsearch | Search Engine | Full-text search, faceted search, real-time |
| Recommendations | Neo4j | Graph DB | Relationship queries, recommendation algorithms |
| Content Management | MongoDB | Document DB | Flexible content structure, versioning |
| Caching | Redis | Key-Value | High-performance caching, pub/sub |

### 2. Data Flow Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                POLYGLOT DATABASE ARCHITECTURE              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                Application Layer                    │    │
│  │                                                     │    │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────┐  │    │
│  │  │   Web       │    │   API       │    │  Mobile │  │    │
│  │  │  Server     │    │  Server     │    │   App   │  │    │
│  │  └─────────────┘    └─────────────┘    └─────────┘  │    │
│  └─────────────────────────────────────────────────────┘    │
│                             │                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                Data Access Layer                    │    │
│  │                                                     │    │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────┐  │    │
│  │  │   User      │    │  Product    │    │  Order  │  │    │
│  │  │  Service    │    │  Service    │    │ Service │  │    │
│  │  └─────────────┘    └─────────────┘    └─────────┘  │    │
│  │                                                     │    │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────┐  │    │
│  │  │  Analytics  │    │   Search    │    │Recommend│  │    │
│  │  │  Service    │    │  Service    │    │ Service │  │    │
│  │  └─────────────┘    └─────────────┘    └─────────┘  │    │
│  └─────────────────────────────────────────────────────┘    │
│                             │                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                Database Layer                       │    │
│  │                                                     │    │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────┐  │    │
│  │  │PostgreSQL   │    │   MongoDB   │    │  Redis  │  │    │
│  │  │             │    │             │    │         │  │    │
│  │  │ - Users     │    │ - Products  │    │ - Cache │  │    │
│  │  │ - Orders    │    │ - Content   │    │ - Session│  │    │
│  │  │ - Payments  │    │ - Metadata  │    │ - Queue │  │    │
│  │  └─────────────┘    └─────────────┘    └─────────┘  │    │
│  │                                                     │    │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────┐  │    │
│  │  │ Cassandra   │    │Elasticsearch│    │  Neo4j  │  │    │
│  │  │             │    │             │    │         │  │    │
│  │  │ - Analytics │    │ - Search    │    │ - Graph │  │    │
│  │  │ - Metrics   │    │ - Logs      │    │ - Recomm│  │    │
│  │  │ - Events    │    │ - Indexes   │    │ - Social│  │    │
│  │  └─────────────┘    └─────────────┘    └─────────┘  │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 3. Data Synchronization Strategy

#### Event-Driven Synchronization

```python
# Event-driven data synchronization service
class DataSynchronizationService:
    def __init__(self, kafka_producer, kafka_consumer, database_connections):
        self.kafka_producer = kafka_producer
        self.kafka_consumer = kafka_consumer
        self.db_connections = database_connections
        self.sync_handlers = {
            'user_created': self._sync_user_created,
            'user_updated': self._sync_user_updated,
            'product_created': self._sync_product_created,
            'product_updated': self._sync_product_updated,
            'order_created': self._sync_order_created,
            'order_updated': self._sync_order_updated
        }
    
    def start_synchronization(self):
        """Start consuming and processing synchronization events"""
        for message in self.kafka_consumer:
            try:
                event = json.loads(message.value)
                self._process_sync_event(event)
            except Exception as e:
                print(f"Error processing sync event: {e}")
    
    def _process_sync_event(self, event):
        """Process synchronization event"""
        event_type = event['event_type']
        if event_type in self.sync_handlers:
            self.sync_handlers[event_type](event)
    
    def _sync_user_created(self, event):
        """Synchronize user creation across databases"""
        user_data = event['data']
        
        # Sync to MongoDB for profile data
        self.db_connections['mongodb'].users.insert_one({
            '_id': user_data['id'],
            'email': user_data['email'],
            'profile': {
                'firstName': user_data['first_name'],
                'lastName': user_data['last_name'],
                'createdAt': user_data['created_at']
            }
        })
        
        # Sync to Redis for session data
        self.db_connections['redis'].hset(
            f"user:profile:{user_data['id']}",
            mapping={
                'email': user_data['email'],
                'name': f"{user_data['first_name']} {user_data['last_name']}",
                'created_at': user_data['created_at']
            }
        )
        
        # Sync to Neo4j for relationship data
        self.db_connections['neo4j'].run(
            "CREATE (u:User {id: $id, email: $email, name: $name})",
            id=user_data['id'],
            email=user_data['email'],
            name=f"{user_data['first_name']} {user_data['last_name']}"
        )
    
    def _sync_product_created(self, event):
        """Synchronize product creation across databases"""
        product_data = event['data']
        
        # Sync to Elasticsearch for search
        self.db_connections['elasticsearch'].index(
            index='products',
            id=product_data['id'],
            body={
                'name': product_data['name'],
                'description': product_data['description'],
                'price': product_data['price'],
                'category': product_data['category'],
                'tags': product_data.get('tags', []),
                'created_at': product_data['created_at']
            }
        )
        
        # Sync to Redis for caching
        self.db_connections['redis'].hset(
            f"product:cache:{product_data['id']}",
            mapping={
                'name': product_data['name'],
                'price': str(product_data['price']),
                'category': product_data['category'],
                'cached_at': datetime.utcnow().isoformat()
            }
        )
        
        # Sync to Neo4j for recommendations
        self.db_connections['neo4j'].run(
            "CREATE (p:Product {id: $id, name: $name, category: $category})",
            id=product_data['id'],
            name=product_data['name'],
            category=product_data['category']
        )
    
    def _sync_order_created(self, event):
        """Synchronize order creation across databases"""
        order_data = event['data']
        
        # Sync to Cassandra for analytics
        self.db_connections['cassandra'].execute(
            """
            INSERT INTO order_analytics (order_id, event_date, event_hour, event_type, user_id, properties, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            """,
            (
                order_data['id'],
                datetime.utcnow().date(),
                datetime.utcnow().hour,
                'order_created',
                order_data['user_id'],
                {'total_amount': str(order_data['total_amount']), 'currency': order_data['currency']},
                datetime.utcnow()
            )
        )
        
        # Sync to Redis for real-time updates
        self.db_connections['redis'].hset(
            f"order:status:{order_data['id']}",
            mapping={
                'status': order_data['status'],
                'total_amount': str(order_data['total_amount']),
                'created_at': order_data['created_at']
            }
        )
        
        # Sync to Neo4j for relationship analysis
        self.db_connections['neo4j'].run(
            """
            MATCH (u:User {id: $user_id})
            CREATE (o:Order {id: $order_id, total_amount: $total_amount, created_at: $created_at})
            CREATE (u)-[:PURCHASED]->(o)
            """,
            user_id=order_data['user_id'],
            order_id=order_data['id'],
            total_amount=order_data['total_amount'],
            created_at=order_data['created_at']
        )
```

### 4. Data Consistency Management

#### Consistency Models by Use Case

```python
class ConsistencyManager:
    def __init__(self, database_connections):
        self.db_connections = database_connections
        self.consistency_config = {
            'users': 'strong',  # PostgreSQL - ACID compliance
            'orders': 'strong',  # PostgreSQL - Financial transactions
            'payments': 'strong',  # PostgreSQL - Critical financial data
            'products': 'eventual',  # MongoDB - Product catalog
            'sessions': 'eventual',  # Redis - Session data
            'analytics': 'eventual',  # Cassandra - Analytics data
            'search': 'eventual',  # Elasticsearch - Search index
            'recommendations': 'eventual'  # Neo4j - Recommendation data
        }
    
    def read_data(self, entity_type, entity_id, consistency_level=None):
        """Read data with specified consistency level"""
        consistency_level = consistency_level or self.consistency_config.get(entity_type, 'eventual')
        
        if consistency_level == 'strong':
            return self._read_strong_consistency(entity_type, entity_id)
        else:
            return self._read_eventual_consistency(entity_type, entity_id)
    
    def write_data(self, entity_type, data, consistency_level=None):
        """Write data with specified consistency level"""
        consistency_level = consistency_level or self.consistency_config.get(entity_type, 'eventual')
        
        if consistency_level == 'strong':
            return self._write_strong_consistency(entity_type, data)
        else:
            return self._write_eventual_consistency(entity_type, data)
    
    def _read_strong_consistency(self, entity_type, entity_id):
        """Read with strong consistency (PostgreSQL)"""
        if entity_type in ['users', 'orders', 'payments']:
            return self.db_connections['postgresql'].execute(
                f"SELECT * FROM {entity_type} WHERE id = %s",
                (entity_id,)
            ).fetchone()
        return None
    
    def _read_eventual_consistency(self, entity_type, entity_id):
        """Read with eventual consistency (other databases)"""
        if entity_type == 'products':
            return self.db_connections['mongodb'].products.find_one({'_id': entity_id})
        elif entity_type == 'sessions':
            return self.db_connections['redis'].hgetall(f"session:{entity_id}")
        elif entity_type == 'analytics':
            return self.db_connections['cassandra'].execute(
                f"SELECT * FROM {entity_type} WHERE id = %s",
                (entity_id,)
            ).one()
        return None
    
    def _write_strong_consistency(self, entity_type, data):
        """Write with strong consistency (PostgreSQL)"""
        if entity_type in ['users', 'orders', 'payments']:
            # Use transactions for strong consistency
            with self.db_connections['postgresql'].begin():
                result = self.db_connections['postgresql'].execute(
                    f"INSERT INTO {entity_type} (...) VALUES (...)",
                    data
                )
                return result.lastrowid
        return None
    
    def _write_eventual_consistency(self, entity_type, data):
        """Write with eventual consistency (other databases)"""
        if entity_type == 'products':
            return self.db_connections['mongodb'].products.insert_one(data)
        elif entity_type == 'sessions':
            return self.db_connections['redis'].hset(f"session:{data['id']}", mapping=data)
        elif entity_type == 'analytics':
            return self.db_connections['cassandra'].execute(
                f"INSERT INTO {entity_type} (...) VALUES (...)",
                data
            )
        return None
```

### 5. Data Access Layer Implementation

#### Repository Pattern Implementation

```python
# Base repository class
class BaseRepository:
    def __init__(self, database_connection):
        self.db = database_connection
    
    def find_by_id(self, entity_id):
        raise NotImplementedError
    
    def find_all(self, filters=None):
        raise NotImplementedError
    
    def create(self, data):
        raise NotImplementedError
    
    def update(self, entity_id, data):
        raise NotImplementedError
    
    def delete(self, entity_id):
        raise NotImplementedError

# User repository (PostgreSQL)
class UserRepository(BaseRepository):
    def find_by_id(self, user_id):
        return self.db.execute(
            "SELECT * FROM users WHERE id = %s",
            (user_id,)
        ).fetchone()
    
    def find_by_email(self, email):
        return self.db.execute(
            "SELECT * FROM users WHERE email = %s",
            (email,)
        ).fetchone()
    
    def create(self, user_data):
        with self.db.begin():
            result = self.db.execute(
                """
                INSERT INTO users (email, password_hash, first_name, last_name, phone, date_of_birth)
                VALUES (%s, %s, %s, %s, %s, %s)
                RETURNING id
                """,
                (
                    user_data['email'],
                    user_data['password_hash'],
                    user_data['first_name'],
                    user_data['last_name'],
                    user_data.get('phone'),
                    user_data.get('date_of_birth')
                )
            )
            return result.fetchone()[0]
    
    def update(self, user_id, user_data):
        with self.db.begin():
            self.db.execute(
                """
                UPDATE users 
                SET first_name = %s, last_name = %s, phone = %s, updated_at = NOW()
                WHERE id = %s
                """,
                (
                    user_data['first_name'],
                    user_data['last_name'],
                    user_data.get('phone'),
                    user_id
                )
            )

# Product repository (MongoDB)
class ProductRepository(BaseRepository):
    def find_by_id(self, product_id):
        return self.db.products.find_one({'_id': product_id})
    
    def find_by_category(self, category_id, limit=20, skip=0):
        return list(self.db.products.find(
            {'category.id': category_id}
        ).limit(limit).skip(skip))
    
    def search(self, query, filters=None, limit=20, skip=0):
        search_criteria = {'$text': {'$search': query}}
        if filters:
            search_criteria.update(filters)
        
        return list(self.db.products.find(search_criteria).limit(limit).skip(skip))
    
    def create(self, product_data):
        result = self.db.products.insert_one(product_data)
        return result.inserted_id
    
    def update(self, product_id, product_data):
        return self.db.products.update_one(
            {'_id': product_id},
            {'$set': product_data}
        )

# Session repository (Redis)
class SessionRepository(BaseRepository):
    def find_by_id(self, session_id):
        return self.db.hgetall(f"session:{session_id}")
    
    def create(self, session_data):
        session_id = session_data['id']
        self.db.hset(f"session:{session_id}", mapping=session_data)
        self.db.expire(f"session:{session_id}", session_data.get('ttl', 3600))
        return session_id
    
    def update(self, session_id, session_data):
        self.db.hset(f"session:{session_id}", mapping=session_data)
    
    def delete(self, session_id):
        return self.db.delete(f"session:{session_id}")

# Analytics repository (Cassandra)
class AnalyticsRepository(BaseRepository):
    def find_by_user(self, user_id, start_date, end_date):
        return self.db.execute(
            """
            SELECT * FROM user_analytics 
            WHERE user_id = %s AND event_date >= %s AND event_date <= %s
            ORDER BY event_date DESC, event_hour DESC
            """,
            (user_id, start_date, end_date)
        ).fetchall()
    
    def create_event(self, event_data):
        return self.db.execute(
            """
            INSERT INTO user_analytics (user_id, event_date, event_hour, event_type, properties, created_at)
            VALUES (%s, %s, %s, %s, %s, %s)
            """,
            (
                event_data['user_id'],
                event_data['event_date'],
                event_data['event_hour'],
                event_data['event_type'],
                event_data['properties'],
                event_data['created_at']
            )
        )

# Search repository (Elasticsearch)
class SearchRepository(BaseRepository):
    def search_products(self, query, filters=None, limit=20, skip=0):
        search_body = {
            'query': {
                'bool': {
                    'must': [
                        {'match': {'name': query}}
                    ]
                }
            },
            'size': limit,
            'from': skip
        }
        
        if filters:
            search_body['query']['bool']['filter'] = filters
        
        response = self.db.search(
            index='products',
            body=search_body
        )
        
        return [hit['_source'] for hit in response['hits']['hits']]
    
    def index_product(self, product_data):
        return self.db.index(
            index='products',
            id=product_data['id'],
            body=product_data
        )
    
    def update_product(self, product_id, product_data):
        return self.db.update(
            index='products',
            id=product_id,
            body={'doc': product_data}
        )

# Recommendation repository (Neo4j)
class RecommendationRepository(BaseRepository):
    def get_user_recommendations(self, user_id, limit=10):
        query = """
        MATCH (u:User {id: $user_id})-[:PURCHASED]->(p:Product)-[:SIMILAR_TO]->(rec:Product)
        WHERE NOT (u)-[:PURCHASED]->(rec)
        RETURN rec.id as product_id, rec.name as product_name, rec.price as price
        ORDER BY rec.price DESC
        LIMIT $limit
        """
        
        result = self.db.run(query, user_id=user_id, limit=limit)
        return [record.data() for record in result]
    
    def get_frequently_bought_together(self, product_id, limit=5):
        query = """
        MATCH (p:Product {id: $product_id})-[:FREQUENTLY_BOUGHT_WITH]->(rec:Product)
        RETURN rec.id as product_id, rec.name as product_name, rec.price as price
        ORDER BY rec.price DESC
        LIMIT $limit
        """
        
        result = self.db.run(query, product_id=product_id, limit=limit)
        return [record.data() for record in result]
```

### 6. Service Layer Implementation

#### Service Layer with Database Abstraction

```python
# Base service class
class BaseService:
    def __init__(self, repositories):
        self.repositories = repositories
    
    def get_repository(self, entity_type):
        return self.repositories.get(entity_type)

# User service
class UserService(BaseService):
    def __init__(self, repositories, consistency_manager):
        super().__init__(repositories)
        self.consistency_manager = consistency_manager
    
    def get_user(self, user_id, consistency_level='strong'):
        """Get user with specified consistency level"""
        return self.consistency_manager.read_data('users', user_id, consistency_level)
    
    def create_user(self, user_data):
        """Create user with strong consistency"""
        # Create in PostgreSQL (strong consistency)
        user_id = self.repositories['users'].create(user_data)
        
        # Publish event for eventual consistency sync
        self._publish_user_created_event(user_id, user_data)
        
        return user_id
    
    def update_user(self, user_id, user_data):
        """Update user with strong consistency"""
        # Update in PostgreSQL (strong consistency)
        self.repositories['users'].update(user_id, user_data)
        
        # Publish event for eventual consistency sync
        self._publish_user_updated_event(user_id, user_data)
    
    def _publish_user_created_event(self, user_id, user_data):
        """Publish user created event for synchronization"""
        event = {
            'event_type': 'user_created',
            'data': {
                'id': user_id,
                'email': user_data['email'],
                'first_name': user_data['first_name'],
                'last_name': user_data['last_name'],
                'created_at': datetime.utcnow().isoformat()
            }
        }
        # Publish to Kafka for event-driven synchronization
        self.kafka_producer.send('user_events', json.dumps(event))

# Product service
class ProductService(BaseService):
    def __init__(self, repositories, consistency_manager):
        super().__init__(repositories)
        self.consistency_manager = consistency_manager
    
    def get_product(self, product_id, consistency_level='eventual'):
        """Get product with specified consistency level"""
        return self.consistency_manager.read_data('products', product_id, consistency_level)
    
    def search_products(self, query, filters=None, limit=20, skip=0):
        """Search products using Elasticsearch"""
        return self.repositories['search'].search_products(query, filters, limit, skip)
    
    def create_product(self, product_data):
        """Create product with eventual consistency"""
        # Create in MongoDB (eventual consistency)
        product_id = self.repositories['products'].create(product_data)
        
        # Index in Elasticsearch for search
        self.repositories['search'].index_product(product_data)
        
        # Cache in Redis
        self._cache_product(product_id, product_data)
        
        # Publish event for synchronization
        self._publish_product_created_event(product_id, product_data)
        
        return product_id
    
    def _cache_product(self, product_id, product_data):
        """Cache product data in Redis"""
        cache_data = {
            'id': product_id,
            'name': product_data['name'],
            'price': str(product_data['price']),
            'category': product_data['category'],
            'cached_at': datetime.utcnow().isoformat()
        }
        self.repositories['cache'].hset(f"product:cache:{product_id}", mapping=cache_data)
        self.repositories['cache'].expire(f"product:cache:{product_id}", 3600)  # 1 hour TTL

# Order service
class OrderService(BaseService):
    def __init__(self, repositories, consistency_manager):
        super().__init__(repositories)
        self.consistency_manager = consistency_manager
    
    def create_order(self, order_data):
        """Create order with strong consistency"""
        # Create in PostgreSQL (strong consistency)
        order_id = self.repositories['orders'].create(order_data)
        
        # Publish event for analytics
        self._publish_order_created_event(order_id, order_data)
        
        return order_id
    
    def get_order(self, order_id, consistency_level='strong'):
        """Get order with specified consistency level"""
        return self.consistency_manager.read_data('orders', order_id, consistency_level)
    
    def _publish_order_created_event(self, order_id, order_data):
        """Publish order created event for analytics"""
        event = {
            'event_type': 'order_created',
            'data': {
                'id': order_id,
                'user_id': order_data['user_id'],
                'total_amount': order_data['total_amount'],
                'currency': order_data['currency'],
                'created_at': datetime.utcnow().isoformat()
            }
        }
        # Publish to Kafka for event-driven synchronization
        self.kafka_producer.send('order_events', json.dumps(event))

# Analytics service
class AnalyticsService(BaseService):
    def __init__(self, repositories):
        super().__init__(repositories)
    
    def track_event(self, event_data):
        """Track analytics event"""
        # Store in Cassandra (eventual consistency)
        self.repositories['analytics'].create_event(event_data)
        
        # Update real-time metrics in Redis
        self._update_real_time_metrics(event_data)
    
    def get_user_analytics(self, user_id, start_date, end_date):
        """Get user analytics data"""
        return self.repositories['analytics'].find_by_user(user_id, start_date, end_date)
    
    def _update_real_time_metrics(self, event_data):
        """Update real-time metrics in Redis"""
        metric_key = f"metrics:{event_data['event_type']}:{datetime.utcnow().strftime('%Y-%m-%d-%H')}"
        self.repositories['cache'].incr(metric_key)
        self.repositories['cache'].expire(metric_key, 86400)  # 24 hours TTL

# Recommendation service
class RecommendationService(BaseService):
    def __init__(self, repositories):
        super().__init__(repositories)
    
    def get_user_recommendations(self, user_id, limit=10):
        """Get personalized recommendations for user"""
        return self.repositories['recommendations'].get_user_recommendations(user_id, limit)
    
    def get_product_recommendations(self, product_id, limit=5):
        """Get recommendations for a specific product"""
        return self.repositories['recommendations'].get_frequently_bought_together(product_id, limit)
```

### 7. Data Synchronization and Consistency

#### Event-Driven Data Synchronization

```python
# Event-driven synchronization service
class EventDrivenSynchronization:
    def __init__(self, kafka_consumer, database_connections):
        self.kafka_consumer = kafka_consumer
        self.db_connections = database_connections
        self.sync_handlers = {
            'user_created': self._sync_user_created,
            'user_updated': self._sync_user_updated,
            'product_created': self._sync_product_created,
            'product_updated': self._sync_product_updated,
            'order_created': self._sync_order_created,
            'order_updated': self._sync_order_updated
        }
    
    def start_synchronization(self):
        """Start consuming and processing synchronization events"""
        for message in self.kafka_consumer:
            try:
                event = json.loads(message.value)
                self._process_sync_event(event)
            except Exception as e:
                print(f"Error processing sync event: {e}")
    
    def _process_sync_event(self, event):
        """Process synchronization event"""
        event_type = event['event_type']
        if event_type in self.sync_handlers:
            self.sync_handlers[event_type](event)
    
    def _sync_user_created(self, event):
        """Synchronize user creation across databases"""
        user_data = event['data']
        
        # Sync to MongoDB for profile data
        self.db_connections['mongodb'].users.insert_one({
            '_id': user_data['id'],
            'email': user_data['email'],
            'profile': {
                'firstName': user_data['first_name'],
                'lastName': user_data['last_name'],
                'createdAt': user_data['created_at']
            }
        })
        
        # Sync to Redis for session data
        self.db_connections['redis'].hset(
            f"user:profile:{user_data['id']}",
            mapping={
                'email': user_data['email'],
                'name': f"{user_data['first_name']} {user_data['last_name']}",
                'created_at': user_data['created_at']
            }
        )
        
        # Sync to Neo4j for relationship data
        self.db_connections['neo4j'].run(
            "CREATE (u:User {id: $id, email: $email, name: $name})",
            id=user_data['id'],
            email=user_data['email'],
            name=f"{user_data['first_name']} {user_data['last_name']}"
        )
    
    def _sync_product_created(self, event):
        """Synchronize product creation across databases"""
        product_data = event['data']
        
        # Sync to Elasticsearch for search
        self.db_connections['elasticsearch'].index(
            index='products',
            id=product_data['id'],
            body={
                'name': product_data['name'],
                'description': product_data['description'],
                'price': product_data['price'],
                'category': product_data['category'],
                'tags': product_data.get('tags', []),
                'created_at': product_data['created_at']
            }
        )
        
        # Sync to Redis for caching
        self.db_connections['redis'].hset(
            f"product:cache:{product_data['id']}",
            mapping={
                'name': product_data['name'],
                'price': str(product_data['price']),
                'category': product_data['category'],
                'cached_at': datetime.utcnow().isoformat()
            }
        )
        
        # Sync to Neo4j for recommendations
        self.db_connections['neo4j'].run(
            "CREATE (p:Product {id: $id, name: $name, category: $category})",
            id=product_data['id'],
            name=product_data['name'],
            category=product_data['category']
        )
    
    def _sync_order_created(self, event):
        """Synchronize order creation across databases"""
        order_data = event['data']
        
        # Sync to Cassandra for analytics
        self.db_connections['cassandra'].execute(
            """
            INSERT INTO order_analytics (order_id, event_date, event_hour, event_type, user_id, properties, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            """,
            (
                order_data['id'],
                datetime.utcnow().date(),
                datetime.utcnow().hour,
                'order_created',
                order_data['user_id'],
                {'total_amount': str(order_data['total_amount']), 'currency': order_data['currency']},
                datetime.utcnow()
            )
        )
        
        # Sync to Redis for real-time updates
        self.db_connections['redis'].hset(
            f"order:status:{order_data['id']}",
            mapping={
                'status': order_data['status'],
                'total_amount': str(order_data['total_amount']),
                'created_at': order_data['created_at']
            }
        )
        
        # Sync to Neo4j for relationship analysis
        self.db_connections['neo4j'].run(
            """
            MATCH (u:User {id: $user_id})
            CREATE (o:Order {id: $order_id, total_amount: $total_amount, created_at: $created_at})
            CREATE (u)-[:PURCHASED]->(o)
            """,
            user_id=order_data['user_id'],
            order_id=order_data['id'],
            total_amount=order_data['total_amount'],
            created_at=order_data['created_at']
        )
```

### 8. Monitoring and Observability

#### Database Health Monitoring

```python
# Database health monitoring service
class DatabaseHealthMonitor:
    def __init__(self, database_connections):
        self.db_connections = database_connections
        self.health_checks = {
            'postgresql': self._check_postgresql_health,
            'mongodb': self._check_mongodb_health,
            'redis': self._check_redis_health,
            'cassandra': self._check_cassandra_health,
            'elasticsearch': self._check_elasticsearch_health,
            'neo4j': self._check_neo4j_health
        }
    
    def check_all_databases(self):
        """Check health of all databases"""
        health_status = {}
        for db_name, health_check in self.health_checks.items():
            try:
                health_status[db_name] = health_check()
            except Exception as e:
                health_status[db_name] = {
                    'status': 'unhealthy',
                    'error': str(e),
                    'timestamp': datetime.utcnow().isoformat()
                }
        return health_status
    
    def _check_postgresql_health(self):
        """Check PostgreSQL health"""
        db = self.db_connections['postgresql']
        
        # Check connection
        db.execute("SELECT 1")
        
        # Check database size
        size_result = db.execute("SELECT pg_database_size(current_database())").fetchone()
        db_size = size_result[0]
        
        # Check active connections
        conn_result = db.execute("SELECT count(*) FROM pg_stat_activity").fetchone()
        active_connections = conn_result[0]
        
        return {
            'status': 'healthy',
            'database_size': db_size,
            'active_connections': active_connections,
            'timestamp': datetime.utcnow().isoformat()
        }
    
    def _check_mongodb_health(self):
        """Check MongoDB health"""
        db = self.db_connections['mongodb']
        
        # Check connection
        db.admin.command('ping')
        
        # Check database stats
        stats = db.command('dbStats')
        
        return {
            'status': 'healthy',
            'database_size': stats['dataSize'],
            'collections': stats['collections'],
            'timestamp': datetime.utcnow().isoformat()
        }
    
    def _check_redis_health(self):
        """Check Redis health"""
        db = self.db_connections['redis']
        
        # Check connection
        db.ping()
        
        # Check memory usage
        info = db.info('memory')
        
        return {
            'status': 'healthy',
            'memory_used': info['used_memory'],
            'memory_peak': info['used_memory_peak'],
            'timestamp': datetime.utcnow().isoformat()
        }
    
    def _check_cassandra_health(self):
        """Check Cassandra health"""
        db = self.db_connections['cassandra']
        
        # Check connection
        db.execute("SELECT now() FROM system.local")
        
        # Check cluster status
        cluster_info = db.execute("SELECT * FROM system.local").one()
        
        return {
            'status': 'healthy',
            'cluster_name': cluster_info.cluster_name,
            'timestamp': datetime.utcnow().isoformat()
        }
    
    def _check_elasticsearch_health(self):
        """Check Elasticsearch health"""
        db = self.db_connections['elasticsearch']
        
        # Check cluster health
        health = db.cluster.health()
        
        return {
            'status': 'healthy' if health['status'] == 'green' else 'degraded',
            'cluster_status': health['status'],
            'number_of_nodes': health['number_of_nodes'],
            'timestamp': datetime.utcnow().isoformat()
        }
    
    def _check_neo4j_health(self):
        """Check Neo4j health"""
        db = self.db_connections['neo4j']
        
        # Check connection
        result = db.run("RETURN 1 as test").single()
        
        # Check database info
        db_info = db.run("CALL dbms.components()").data()
        
        return {
            'status': 'healthy',
            'version': db_info[0]['versions'][0],
            'timestamp': datetime.utcnow().isoformat()
        }
```

## Implementation Best Practices

### 1. Data Consistency Management

**Strong Consistency (PostgreSQL)**:
- Use for critical financial data (orders, payments)
- Implement proper transaction management
- Use database constraints and foreign keys
- Implement proper error handling and rollback

**Eventual Consistency (Other Databases)**:
- Use for non-critical data (products, analytics)
- Implement proper event-driven synchronization
- Use idempotent operations
- Implement conflict resolution strategies

### 2. Error Handling and Resilience

**Circuit Breaker Pattern**:
```python
class CircuitBreaker:
    def __init__(self, failure_threshold=5, timeout=60):
        self.failure_threshold = failure_threshold
        self.timeout = timeout
        self.failure_count = 0
        self.last_failure_time = None
        self.state = 'CLOSED'  # CLOSED, OPEN, HALF_OPEN
    
    def call(self, func, *args, **kwargs):
        if self.state == 'OPEN':
            if time.time() - self.last_failure_time > self.timeout:
                self.state = 'HALF_OPEN'
            else:
                raise Exception("Circuit breaker is OPEN")
        
        try:
            result = func(*args, **kwargs)
            if self.state == 'HALF_OPEN':
                self.state = 'CLOSED'
                self.failure_count = 0
            return result
        except Exception as e:
            self.failure_count += 1
            self.last_failure_time = time.time()
            if self.failure_count >= self.failure_threshold:
                self.state = 'OPEN'
            raise e
```

**Retry Pattern**:
```python
class RetryHandler:
    def __init__(self, max_retries=3, backoff_factor=1):
        self.max_retries = max_retries
        self.backoff_factor = backoff_factor
    
    def execute_with_retry(self, func, *args, **kwargs):
        for attempt in range(self.max_retries):
            try:
                return func(*args, **kwargs)
            except Exception as e:
                if attempt == self.max_retries - 1:
                    raise e
                time.sleep(self.backoff_factor * (2 ** attempt))
```

### 3. Performance Optimization

**Connection Pooling**:
```python
class DatabaseConnectionPool:
    def __init__(self, database_config, pool_size=10):
        self.pool_size = pool_size
        self.connections = []
        self.available_connections = []
        self.database_config = database_config
        self._initialize_pool()
    
    def _initialize_pool(self):
        for _ in range(self.pool_size):
            conn = self._create_connection()
            self.connections.append(conn)
            self.available_connections.append(conn)
    
    def get_connection(self):
        if not self.available_connections:
            raise Exception("No available connections")
        return self.available_connections.pop()
    
    def return_connection(self, conn):
        self.available_connections.append(conn)
    
    def _create_connection(self):
        # Implementation depends on database type
        pass
```

**Caching Strategy**:
```python
class MultiLevelCache:
    def __init__(self, local_cache, redis_cache):
        self.local_cache = local_cache
        self.redis_cache = redis_cache
    
    def get(self, key):
        # Try local cache first
        value = self.local_cache.get(key)
        if value:
            return value
        
        # Try Redis cache
        value = self.redis_cache.get(key)
        if value:
            # Store in local cache
            self.local_cache.set(key, value)
            return value
        
        return None
    
    def set(self, key, value, ttl=None):
        # Set in both caches
        self.local_cache.set(key, value, ttl)
        self.redis_cache.set(key, value, ttl)
    
    def delete(self, key):
        # Delete from both caches
        self.local_cache.delete(key)
        self.redis_cache.delete(key)
```

## Conclusion

This comprehensive polyglot database architecture solution demonstrates how to effectively integrate multiple database technologies to optimize for different use cases and access patterns. The key success factors are:

1. **Right Tool for the Job**: Using appropriate database types for different use cases
2. **Proper Data Synchronization**: Implementing event-driven synchronization for consistency
3. **Service Layer Abstraction**: Providing clean interfaces for data access
4. **Error Handling and Resilience**: Implementing proper error handling and circuit breakers
5. **Performance Optimization**: Using connection pooling, caching, and other optimization techniques
6. **Monitoring and Observability**: Implementing comprehensive health monitoring

This solution provides a solid foundation for building a scalable, high-performance e-commerce platform that can handle millions of users and transactions while maintaining data integrity and providing excellent user experience across multiple database technologies.
