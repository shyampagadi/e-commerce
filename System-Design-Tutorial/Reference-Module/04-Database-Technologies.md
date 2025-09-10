# Database Technologies

## Overview

Database systems are the foundation of modern applications, providing structured storage and retrieval of data. This document explores the diverse landscape of database technologies, their architectural patterns, trade-offs, and implementation considerations.

## Table of Contents
- [Core Concepts](#core-concepts)
- [Database Types and Use Cases](#database-types-and-use-cases)
- [Database Architecture Patterns](#database-architecture-patterns)
- [Scaling Strategies](#scaling-strategies)
- [Data Consistency and Availability](#data-consistency-and-availability)
- [AWS Implementation](#aws-implementation)
- [Decision Matrix](#decision-matrix)
- [Use Cases](#use-cases)
- [Best Practices](#best-practices)

## Core Concepts

### Relational vs NoSQL Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    DATABASE LANDSCAPE                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────┐              ┌─────────────────┐      │
│  │   RELATIONAL    │              │     NoSQL       │      │
│  │                 │              │                 │      │
│  │ ┌─────────────┐ │              │ ┌─────────────┐ │      │
│  │ │   Tables    │ │              │ │  Document   │ │      │
│  │ │   Rows      │ │              │ │  Key-Value  │ │      │
│  │ │   Columns   │ │              │ │  Column     │ │      │
│  │ │   ACID      │ │              │ │  Graph      │ │      │
│  │ └─────────────┘ │              │ └─────────────┘ │      │
│  │                 │              │                 │      │
│  │ Examples:       │              │ Examples:       │      │
│  │ • PostgreSQL    │              │ • MongoDB       │      │
│  │ • MySQL         │              │ • Redis         │      │
│  │ • Oracle        │              │ • Cassandra     │      │
│  └─────────────────┘              │ • Neo4j         │      │
│                                   └─────────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

### Data Models

The data model defines how data is structured, organized, and related within a database system.

#### Relational Model

The relational model organizes data into tables (relations) with rows and columns, where:

1. **Tables**: Represent entities or concepts
2. **Rows**: Represent individual records or instances
3. **Columns**: Represent attributes or properties
4. **Keys**: Establish relationships between tables
   - **Primary Keys**: Uniquely identify records
   - **Foreign Keys**: Reference primary keys in other tables

Characteristics:
- Strong schema enforcement
- ACID transactions
- Powerful query capabilities via SQL
- Well-established mathematical foundation based on set theory and relational algebra

```sql
-- E-commerce Database Schema
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    parent_id INTEGER REFERENCES categories(category_id),
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INTEGER DEFAULT 0,
    category_id INTEGER REFERENCES categories(category_id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id),
    total_amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    shipping_address TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE order_items (
    order_id INTEGER REFERENCES orders(order_id),
    product_id INTEGER REFERENCES products(product_id),
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (order_id, product_id)
);
```

#### Document Model

The document model organizes data as flexible, self-contained documents (typically JSON or BSON):

1. **Collections**: Groups of related documents
2. **Documents**: Self-contained data records with varying structure
3. **Fields**: Key-value pairs within documents
4. **Nested Documents**: Hierarchical data within a document

```
┌─────────────────────────────────────────────────────────────┐
│                    DOCUMENT DATABASE                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Collection: users                                          │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ {                                                       ││
│  │   "_id": "507f1f77bcf86cd799439011",                   ││
│  │   "name": "John Doe",                                   ││
│  │   "email": "john@example.com",                          ││
│  │   "address": {                                          ││
│  │     "street": "123 Main St",                            ││
│  │     "city": "New York",                                 ││
│  │     "zipcode": "10001"                                  ││
│  │   },                                                    ││
│  │   "orders": [                                           ││
│  │     {"order_id": "ord_123", "amount": 99.99},          ││
│  │     {"order_id": "ord_124", "amount": 149.99}          ││
│  │   ],                                                    ││
│  │   "preferences": {                                      ││
│  │     "theme": "dark",                                    ││
│  │     "notifications": true                               ││
│  │   }                                                     ││
│  │ }                                                       ││
│  └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

Characteristics:
- Flexible schema (schema-less or schema-on-read)
- Natural representation of hierarchical data
- Horizontal scaling capabilities
- Eventual consistency models
- Rich query capabilities for document structure

```json
{
  "user_id": "usr_12345",
  "profile": {
    "name": "Alice Smith",
    "email": "alice@example.com",
    "preferences": {
      "theme": "dark",
      "notifications": true,
      "language": "en"
    }
  },
  "activity": {
    "last_login": "2025-09-10T14:30:00Z",
    "login_count": 47,
    "favorite_categories": ["electronics", "books"]
  },
  "orders": [
    {
      "order_id": "ord_789",
      "date": "2025-09-05T10:15:00Z",
      "items": [
        {"product": "laptop", "price": 999.99},
        {"product": "mouse", "price": 29.99}
      ],
      "total": 1029.98
    }
  ]
}
```

#### Key-Value Model

The key-value model is the simplest NoSQL model, storing data as key-value pairs:

1. **Keys**: Unique identifiers for data retrieval
2. **Values**: Data associated with keys (can be simple or complex)
3. **Partitioning**: Keys distributed across multiple nodes
4. **Hashing**: Keys mapped to storage locations via hash functions

```
┌─────────────────────────────────────────────────────────────┐
│                    KEY-VALUE STORE                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Key                    │  Value                            │
│  ─────────────────────  │  ───────────────────────────────  │
│  user:12345:session     │  {"token": "abc123", "exp": ...} │
│  product:67890:cache    │  {"name": "Laptop", "price": 999} │
│  cart:user:12345        │  ["prod_1", "prod_2", "prod_3"]   │
│  counter:page_views     │  1,247,893                        │
│  config:app:settings    │  {"debug": false, "version": "2"} │
│  user:12345:profile     │  {"name": "John", "email": "..."} │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

Characteristics:
- Extremely fast read/write operations
- Simple data model
- Excellent for caching and session storage
- Limited query capabilities (usually key-based only)
- Horizontal scaling through consistent hashing

#### Column-Family Model

The column-family model organizes data into column families (similar to tables) with flexible column structures:

1. **Column Families**: Containers for related columns
2. **Rows**: Identified by unique row keys
3. **Columns**: Name-value pairs with timestamps
4. **Super Columns**: Nested column structures (in some implementations)

Characteristics:
- Optimized for write-heavy workloads
- Flexible column structure within families
- Excellent compression ratios
- Time-series data handling
- Tunable consistency levels

#### Graph Model

The graph model represents data as nodes (entities) and edges (relationships):

1. **Nodes**: Entities with properties
2. **Edges**: Relationships between nodes with properties
3. **Labels**: Categories for nodes and relationships
4. **Properties**: Key-value pairs attached to nodes and edges

Characteristics:
- Natural representation of connected data
- Efficient traversal of relationships
- Complex relationship queries
- ACID transactions (in many implementations)
- Specialized query languages (e.g., Cypher, Gremlin)

### ACID Properties

ACID properties ensure database transaction reliability:

#### Atomicity
- **Definition**: Transactions are all-or-nothing operations
- **Implementation**: Transaction logs, rollback mechanisms
- **Example**: Bank transfer must debit one account and credit another, or neither

#### Consistency
- **Definition**: Database remains in valid state after transactions
- **Implementation**: Constraints, triggers, referential integrity
- **Example**: Account balances cannot be negative

#### Isolation
- **Definition**: Concurrent transactions don't interfere with each other
- **Implementation**: Locking mechanisms, MVCC (Multi-Version Concurrency Control)
- **Levels**: Read Uncommitted, Read Committed, Repeatable Read, Serializable

#### Durability
- **Definition**: Committed transactions persist even after system failures
- **Implementation**: Write-ahead logging, data replication
- **Example**: Completed orders survive server crashes

### BASE Properties

BASE properties provide an alternative to ACID for distributed systems:

#### Basically Available
- **Definition**: System guarantees availability of data
- **Implementation**: Replication, partitioning
- **Trade-off**: May serve stale data during failures

#### Soft State
- **Definition**: Data consistency is not guaranteed at all times
- **Implementation**: Eventual consistency mechanisms
- **Example**: Social media feeds may show different content to different users temporarily

#### Eventually Consistent
- **Definition**: System will become consistent over time
- **Implementation**: Anti-entropy protocols, vector clocks
- **Example**: DNS updates propagate globally over time

## Database Types and Use Cases

### Relational Databases (RDBMS)

Relational databases organize data into structured tables with predefined schemas and relationships.

#### Key Characteristics
- **Structured Schema**: Fixed table structure with defined columns and data types
- **ACID Compliance**: Full support for ACID transactions
- **SQL Support**: Standardized query language for data manipulation
- **Referential Integrity**: Foreign key constraints maintain data consistency
- **Normalization**: Data organized to reduce redundancy and improve consistency

#### Popular Implementations
1. **PostgreSQL**
   - Advanced open-source RDBMS
   - Excellent for complex queries and data integrity
   - Strong JSON support for hybrid workloads
   - Advanced indexing and full-text search

2. **MySQL**
   - Widely adopted open-source database
   - High performance for read-heavy workloads
   - Strong replication capabilities
   - Excellent for web applications

3. **Oracle Database**
   - Enterprise-grade commercial database
   - Advanced features for large-scale applications
   - Comprehensive security and compliance features
   - Excellent for mission-critical systems

4. **Microsoft SQL Server**
   - Enterprise database with strong Windows integration
   - Advanced analytics and reporting capabilities
   - Excellent development tools and ecosystem
   - Strong performance for mixed workloads

#### Use Cases
- **Financial Systems**: Banking, accounting, payment processing
- **E-commerce Platforms**: Order management, inventory tracking
- **Enterprise Applications**: ERP, CRM, HR systems
- **Data Warehousing**: Business intelligence and analytics
- **Content Management**: Structured content with complex relationships

#### Advantages
- Strong consistency guarantees
- Mature ecosystem and tooling
- Standardized SQL interface
- Excellent for complex queries and joins
- Well-understood by developers and DBAs

#### Disadvantages
- Limited horizontal scaling capabilities
- Rigid schema requirements
- Performance bottlenecks with very large datasets
- Higher complexity for simple key-value operations

### Document Databases

Document databases store data as flexible, self-contained documents, typically in JSON or BSON format.

#### Key Characteristics
- **Flexible Schema**: Documents can have varying structures
- **Rich Data Types**: Support for nested objects, arrays, and complex data types
- **Horizontal Scaling**: Built-in support for sharding and replication
- **Query Flexibility**: Rich query capabilities for document structure
- **Developer Friendly**: Natural mapping to application objects

#### Popular Implementations
1. **MongoDB**
   - Leading document database
   - Rich query language and indexing
   - Built-in sharding and replication
   - Strong ecosystem and tooling

2. **Amazon DocumentDB**
   - MongoDB-compatible managed service
   - Automatic scaling and backup
   - Integration with AWS services
   - Enterprise security features

3. **CouchDB**
   - Multi-master replication
   - RESTful HTTP API
   - Offline-first design
   - Conflict resolution mechanisms

4. **RavenDB**
   - .NET-focused document database
   - ACID transactions
   - Advanced indexing capabilities
   - Built-in full-text search

#### Document Structure Example

```json
{
  "_id": "product_12345",
  "name": "Wireless Headphones",
  "category": "Electronics",
  "price": {
    "amount": 199.99,
    "currency": "USD"
  },
  "specifications": {
    "battery_life": "30 hours",
    "connectivity": ["Bluetooth 5.0", "USB-C"],
    "weight": "250g"
  },
  "reviews": [
    {
      "user_id": "user_789",
      "rating": 5,
      "comment": "Excellent sound quality",
      "date": "2025-09-01T10:30:00Z"
    },
    {
      "user_id": "user_456",
      "rating": 4,
      "comment": "Good value for money",
      "date": "2025-09-03T14:15:00Z"
    }
  ],
  "inventory": {
    "stock_count": 150,
    "warehouse_locations": ["US-East", "US-West", "EU-Central"],
    "reorder_level": 20
  },
  "metadata": {
    "created_at": "2025-08-15T09:00:00Z",
    "updated_at": "2025-09-10T11:45:00Z",
    "version": 3
  }
}
```

#### Use Cases
- **Content Management**: Blogs, wikis, document repositories
- **Product Catalogs**: E-commerce with varying product attributes
- **User Profiles**: Social networks, gaming platforms
- **IoT Data**: Sensor data with varying schemas
- **Real-time Analytics**: Event tracking and analysis

#### Advantages
- Flexible schema evolution
- Natural object mapping
- Horizontal scaling capabilities
- Rich query capabilities
- Rapid development cycles

#### Disadvantages
- Eventual consistency challenges
- Limited transaction support across documents
- Potential for data duplication
- Query performance can vary with document size

### Key-Value Stores

Key-value stores provide the simplest NoSQL data model, storing data as unique key-value pairs.

#### Key Characteristics
- **Simple Data Model**: Just keys and values
- **High Performance**: Optimized for fast read/write operations
- **Horizontal Scaling**: Easy partitioning across nodes
- **Minimal Overhead**: Low latency and high throughput
- **Flexible Values**: Values can be simple strings or complex objects

#### Popular Implementations
1. **Redis**
   - In-memory data structure store
   - Rich data types (strings, hashes, lists, sets, sorted sets)
   - Built-in pub/sub messaging
   - Excellent for caching and real-time applications

2. **Amazon DynamoDB**
   - Fully managed NoSQL service
   - Automatic scaling and backup
   - Global tables for multi-region deployment
   - Integration with AWS ecosystem

3. **Apache Cassandra**
   - Distributed wide-column store
   - Linear scalability
   - High availability with no single point of failure
   - Tunable consistency levels

4. **Riak**
   - Distributed key-value store
   - Built-in conflict resolution
   - MapReduce query capabilities
   - High availability focus

#### Redis Data Types Example

```python
import redis

# Connect to Redis
r = redis.Redis(host='localhost', port=6379, db=0)

# String operations
r.set('user:12345:name', 'John Doe')
r.setex('session:abc123', 3600, 'user_data')  # Expires in 1 hour

# Hash operations (user profile)
r.hset('user:12345:profile', mapping={
    'name': 'John Doe',
    'email': 'john@example.com',
    'age': 30,
    'city': 'New York'
})

# List operations (shopping cart)
r.lpush('cart:user:12345', 'product:67890')
r.lpush('cart:user:12345', 'product:54321')

# Set operations (user interests)
r.sadd('interests:user:12345', 'technology', 'sports', 'music')

# Sorted set operations (leaderboard)
r.zadd('leaderboard:game:123', {'player1': 1500, 'player2': 1200, 'player3': 1800})

# Counter operations
r.incr('page_views:homepage')
r.hincrby('stats:daily', '2025-09-10', 1)
```

#### Use Cases
- **Caching**: Application-level caching, session storage
- **Session Management**: User sessions, shopping carts
- **Real-time Analytics**: Counters, metrics, leaderboards
- **Configuration Storage**: Application settings, feature flags
- **Message Queues**: Simple pub/sub messaging

#### Advantages
- Extremely fast performance
- Simple data model
- Excellent scalability
- Low operational complexity
- Perfect for caching scenarios

#### Disadvantages
- Limited query capabilities
- No built-in relationships
- Simple data model may not fit complex use cases
- Limited transaction support

### Column-Family Databases

Column-family databases organize data into column families, optimizing for write-heavy workloads and time-series data.

#### Key Characteristics
- **Column-Oriented Storage**: Data stored by columns rather than rows
- **Write Optimization**: Excellent performance for write-heavy workloads
- **Compression**: High compression ratios due to column storage
- **Flexible Schema**: Columns can be added dynamically
- **Time-Series Support**: Natural fit for time-stamped data

#### Popular Implementations
1. **Apache Cassandra**
   - Distributed column-family database
   - Linear scalability across commodity hardware
   - No single point of failure
   - Tunable consistency levels

2. **HBase**
   - Hadoop ecosystem column database
   - Strong consistency model
   - Automatic sharding and load balancing
   - Integration with Hadoop tools

3. **Amazon Timestream**
   - Purpose-built time-series database
   - Automatic data lifecycle management
   - Built-in analytics functions
   - Serverless scaling

#### Data Model Example

```
Column Family: user_activity
Row Key: user_12345

Columns:
timestamp:2025-09-10:09:00 -> {"action": "login", "ip": "192.168.1.1"}
timestamp:2025-09-10:09:15 -> {"action": "view_product", "product_id": "prod_123"}
timestamp:2025-09-10:09:30 -> {"action": "add_to_cart", "product_id": "prod_123"}
timestamp:2025-09-10:09:45 -> {"action": "checkout", "order_id": "ord_456"}
timestamp:2025-09-10:10:00 -> {"action": "logout"}
```

#### Use Cases
- **Time-Series Data**: IoT sensors, monitoring metrics, financial data
- **Event Logging**: Application logs, audit trails, user activity
- **Content Management**: Content versioning, document storage
- **Recommendation Systems**: User behavior tracking, preference analysis
- **Analytics Platforms**: Data warehousing, business intelligence

#### Advantages
- Excellent write performance
- Efficient storage and compression
- Good for time-series data
- Horizontal scaling capabilities
- Flexible column structure

#### Disadvantages
- Complex data modeling
- Limited query flexibility
- Eventual consistency challenges
- Learning curve for developers

### Graph Databases

Graph databases excel at managing and querying highly connected data through nodes, edges, and properties.

#### Key Characteristics
- **Graph Data Model**: Nodes (entities) and edges (relationships)
- **Relationship Focus**: Optimized for traversing connections
- **Property Support**: Rich properties on nodes and edges
- **Query Languages**: Specialized languages like Cypher, Gremlin
- **ACID Support**: Many implementations support full ACID transactions

#### Popular Implementations
1. **Neo4j**
   - Leading graph database
   - Cypher query language
   - ACID transactions
   - Rich visualization tools

2. **Amazon Neptune**
   - Fully managed graph database
   - Supports both property graph and RDF models
   - Gremlin and SPARQL query support
   - High availability and backup

3. **ArangoDB**
   - Multi-model database (document, graph, key-value)
   - AQL query language
   - Distributed architecture
   - ACID transactions

4. **TigerGraph**
   - High-performance graph analytics
   - Real-time graph analytics
   - Parallel processing
   - Machine learning integration

#### Graph Model Example

```
Nodes:
- User(id: "user_123", name: "Alice", age: 28)
- User(id: "user_456", name: "Bob", age: 32)
- Product(id: "prod_789", name: "Laptop", price: 999)
- Category(id: "cat_001", name: "Electronics")

Relationships:
- (user_123)-[:FRIENDS_WITH {since: "2020-01-15"}]->(user_456)
- (user_123)-[:PURCHASED {date: "2025-09-01", rating: 5}]->(prod_789)
- (user_456)-[:VIEWED {timestamp: "2025-09-10T10:30:00Z"}]->(prod_789)
- (prod_789)-[:BELONGS_TO]->(cat_001)
- (user_123)-[:INTERESTED_IN]->(cat_001)
```

#### Cypher Query Examples

```cypher
// Find friends of Alice who purchased laptops
MATCH (alice:User {name: "Alice"})-[:FRIENDS_WITH]-(friend:User)
MATCH (friend)-[:PURCHASED]->(product:Product)
WHERE product.name CONTAINS "Laptop"
RETURN friend.name, product.name, product.price

// Recommend products based on friend purchases
MATCH (user:User {id: "user_123"})-[:FRIENDS_WITH]-(friend:User)
MATCH (friend)-[:PURCHASED]->(product:Product)
WHERE NOT (user)-[:PURCHASED]->(product)
RETURN product.name, COUNT(*) as friend_purchases
ORDER BY friend_purchases DESC
LIMIT 5

// Find shortest path between users
MATCH path = shortestPath((user1:User {id: "user_123"})-[*]-(user2:User {id: "user_789"}))
RETURN path
```

#### Use Cases
- **Social Networks**: Friend connections, influence analysis
- **Recommendation Systems**: Product recommendations, content discovery
- **Fraud Detection**: Transaction pattern analysis, risk assessment
- **Knowledge Graphs**: Semantic relationships, information discovery
- **Network Analysis**: Infrastructure monitoring, dependency mapping

#### Advantages
- Natural representation of connected data
- Efficient relationship traversal
- Complex relationship queries
- Real-time graph analytics
- Flexible schema evolution

#### Disadvantages
- Specialized use cases
- Learning curve for graph concepts
- Limited ecosystem compared to relational databases
- Performance depends on graph structure

## Database Architecture Patterns

### Master-Slave Replication

Master-slave replication provides data redundancy and read scalability by maintaining multiple copies of data across different database instances.

```
┌─────────────────────────────────────────────────────────────┐
│                 MASTER-SLAVE REPLICATION                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│                    ┌─────────────┐                         │
│                    │   MASTER    │                         │
│                    │  (Primary)  │                         │
│                    │             │                         │
│                    │ Writes ✓    │                         │
│                    │ Reads  ✓    │                         │
│                    └──────┬──────┘                         │
│                           │                                │
│                           │ Replication Log                │
│                           │ (Async/Sync)                   │
│                           │                                │
│        ┌──────────────────┼──────────────────┐             │
│        │                  │                  │             │
│        ▼                  ▼                  ▼             │
│  ┌───────────┐      ┌───────────┐      ┌───────────┐      │
│  │  SLAVE 1  │      │  SLAVE 2  │      │  SLAVE 3  │      │
│  │(Read-Only)│      │(Read-Only)│      │(Read-Only)│      │
│  │           │      │           │      │           │      │
│  │ Writes ✗  │      │ Writes ✗  │      │ Writes ✗  │      │
│  │ Reads  ✓  │      │ Reads  ✓  │      │ Reads  ✓  │      │
│  └───────────┘      └───────────┘      └───────────┘      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### Key Characteristics
- **Single Write Point**: All writes go to the master
- **Multiple Read Points**: Reads can be distributed across slaves
- **Data Consistency**: Eventual consistency between master and slaves
- **Failover Capability**: Slaves can be promoted to master
- **Load Distribution**: Read traffic distributed across multiple nodes

#### Replication Types
1. **Synchronous Replication**
   - Master waits for slave acknowledgment before committing
   - Strong consistency but higher latency
   - Risk of blocking if slaves are unavailable

2. **Asynchronous Replication**
   - Master commits immediately, slaves catch up later
   - Better performance but potential data loss
   - Eventual consistency model

3. **Semi-Synchronous Replication**
   - Master waits for at least one slave acknowledgment
   - Balance between consistency and performance
   - Reduced risk of data loss

#### Implementation Example (MySQL)

```sql
-- Master Configuration (my.cnf)
[mysqld]
server-id = 1
log-bin = mysql-bin
binlog-format = ROW
sync_binlog = 1
innodb_flush_log_at_trx_commit = 1

-- Create replication user on master
CREATE USER 'replication'@'%' IDENTIFIED BY 'password';
GRANT REPLICATION SLAVE ON *.* TO 'replication'@'%';
FLUSH PRIVILEGES;

-- Get master status
SHOW MASTER STATUS;
```

```sql
-- Slave Configuration (my.cnf)
[mysqld]
server-id = 2
relay-log = relay-bin
read_only = 1

-- Configure slave to connect to master
CHANGE MASTER TO
  MASTER_HOST='master-host',
  MASTER_USER='replication',
  MASTER_PASSWORD='password',
  MASTER_LOG_FILE='mysql-bin.000001',
  MASTER_LOG_POS=154;

-- Start replication
START SLAVE;

-- Check slave status
SHOW SLAVE STATUS\G
```

#### Use Cases
- **Read Scaling**: Distribute read queries across multiple slaves
- **Backup Strategy**: Use slaves for backup without affecting master
- **Analytics Workloads**: Run reporting queries on slaves
- **Geographic Distribution**: Place slaves closer to users
- **High Availability**: Quick failover to slave in case of master failure

#### Advantages
- Improved read performance through load distribution
- Data redundancy and backup capabilities
- Relatively simple to implement and understand
- Good for read-heavy workloads
- Supports different storage engines

#### Disadvantages
- Single point of failure for writes
- Replication lag can cause consistency issues
- Complexity in handling failover scenarios
- Limited write scalability
- Potential for split-brain scenarios

### Master-Master Replication

Master-master replication allows multiple nodes to accept both read and write operations, providing better write scalability and availability.

```
┌─────────────────────────────────────────────────────────────┐
│                 MASTER-MASTER REPLICATION                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│        ┌─────────────┐              ┌─────────────┐        │
│        │  MASTER A   │◄────────────►│  MASTER B   │        │
│        │             │ Bidirectional│             │        │
│        │ Writes ✓    │ Replication  │ Writes ✓    │        │
│        │ Reads  ✓    │              │ Reads  ✓    │        │
│        └─────┬───────┘              └─────┬───────┘        │
│              │                            │                │
│              │                            │                │
│              ▼                            ▼                │
│        ┌───────────┐                ┌───────────┐          │
│        │Application│                │Application│          │
│        │  Server   │                │  Server   │          │
│        │  Cluster  │                │  Cluster  │          │
│        └───────────┘                └───────────┘          │
│                                                             │
│        Region A                      Region B              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### Conflict Resolution Strategies
1. **Timestamp-based**: Last write wins based on timestamp
2. **Application-level**: Business logic determines winner
3. **Manual Resolution**: Human intervention for conflicts
4. **Avoid Conflicts**: Partition data to prevent conflicts

#### Implementation Considerations
- **Auto-increment Handling**: Use different ranges or UUIDs
- **Conflict Detection**: Monitor for replication conflicts
- **Network Partitions**: Handle split-brain scenarios
- **Consistency Models**: Define acceptable consistency levels

### Database Sharding

Sharding distributes data across multiple database instances based on a partitioning key, enabling horizontal scaling.

```
┌─────────────────────────────────────────────────────────────┐
│                    DATABASE SHARDING                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│                  ┌─────────────────┐                       │
│                  │  APPLICATION    │                       │
│                  │     LAYER       │                       │
│                  └─────────┬───────┘                       │
│                            │                               │
│                            ▼                               │
│                  ┌─────────────────┐                       │
│                  │  SHARD ROUTER   │                       │
│                  │  (Partition     │                       │
│                  │   Logic)        │                       │
│                  └─────────┬───────┘                       │
│                            │                               │
│              ┌─────────────┼─────────────┐                 │
│              │             │             │                 │
│              ▼             ▼             ▼                 │
│        ┌──────────┐  ┌──────────┐  ┌──────────┐           │
│        │ SHARD A  │  │ SHARD B  │  │ SHARD C  │           │
│        │          │  │          │  │          │           │
│        │Users     │  │Users     │  │Users     │           │
│        │1-1000    │  │1001-2000 │  │2001-3000 │           │
│        │          │  │          │  │          │           │
│        │Orders    │  │Orders    │  │Orders    │           │
│        │1-1000    │  │1001-2000 │  │2001-3000 │           │
│        └──────────┘  └──────────┘  └──────────┘           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### Sharding Strategies

1. **Range-based Sharding**
   - Partition data based on key ranges
   - Simple to implement and understand
   - Risk of hotspots with uneven data distribution

2. **Hash-based Sharding**
   - Use hash function to determine shard
   - Better data distribution
   - Difficult to perform range queries

3. **Directory-based Sharding**
   - Lookup service maps keys to shards
   - Flexible shard assignment
   - Additional complexity and potential bottleneck

4. **Geographic Sharding**
   - Partition data by geographic region
   - Reduces latency for regional users
   - Compliance with data residency requirements

#### Sharding Implementation Example

```python
import hashlib
import json
from typing import Dict, List, Any

class DatabaseShardRouter:
    def __init__(self, shard_configs: List[Dict[str, Any]]):
        self.shards = {}
        for config in shard_configs:
            self.shards[config['name']] = {
                'host': config['host'],
                'port': config['port'],
                'database': config['database'],
                'range': config.get('range'),
                'connection': None  # Database connection object
            }
    
    def get_shard_by_range(self, user_id: int) -> str:
        """Range-based sharding"""
        for shard_name, config in self.shards.items():
            if config['range']:
                start, end = config['range']
                if start <= user_id <= end:
                    return shard_name
        raise ValueError(f"No shard found for user_id: {user_id}")
    
    def get_shard_by_hash(self, key: str) -> str:
        """Hash-based sharding"""
        hash_value = int(hashlib.md5(key.encode()).hexdigest(), 16)
        shard_index = hash_value % len(self.shards)
        return list(self.shards.keys())[shard_index]
    
    def execute_query(self, shard_name: str, query: str, params: tuple = None):
        """Execute query on specific shard"""
        shard_config = self.shards[shard_name]
        # Implementation would use actual database connection
        print(f"Executing on {shard_name}: {query}")
        return f"Result from {shard_name}"
    
    def execute_cross_shard_query(self, query: str) -> List[Any]:
        """Execute query across all shards and aggregate results"""
        results = []
        for shard_name in self.shards.keys():
            result = self.execute_query(shard_name, query)
            results.append(result)
        return results

# Usage example
shard_configs = [
    {'name': 'shard_a', 'host': 'db1.example.com', 'port': 5432, 
     'database': 'app_shard_a', 'range': (1, 1000)},
    {'name': 'shard_b', 'host': 'db2.example.com', 'port': 5432, 
     'database': 'app_shard_b', 'range': (1001, 2000)},
    {'name': 'shard_c', 'host': 'db3.example.com', 'port': 5432, 
     'database': 'app_shard_c', 'range': (2001, 3000)}
]

router = DatabaseShardRouter(shard_configs)

# Route queries to appropriate shards
user_id = 1500
shard = router.get_shard_by_range(user_id)
result = router.execute_query(shard, "SELECT * FROM users WHERE user_id = %s", (user_id,))
```

#### Challenges and Solutions

1. **Cross-shard Queries**
   - **Problem**: Queries spanning multiple shards are complex
   - **Solution**: Denormalization, application-level joins, or federated queries

2. **Rebalancing**
   - **Problem**: Adding/removing shards requires data migration
   - **Solution**: Consistent hashing, virtual shards, or gradual migration

3. **Transaction Management**
   - **Problem**: ACID transactions across shards are difficult
   - **Solution**: Two-phase commit, saga pattern, or eventual consistency

4. **Operational Complexity**
   - **Problem**: Managing multiple database instances
   - **Solution**: Automation tools, monitoring, and standardized procedures

### Federation

Database federation creates a unified view of multiple independent databases without physically merging the data.

```
┌─────────────────────────────────────────────────────────────┐
│                    DATABASE FEDERATION                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│                  ┌─────────────────┐                       │
│                  │   APPLICATION   │                       │
│                  └─────────┬───────┘                       │
│                            │                               │
│                            ▼                               │
│                  ┌─────────────────┐                       │
│                  │  FEDERATION     │                       │
│                  │    LAYER        │                       │
│                  │  (Query Router) │                       │
│                  └─────────┬───────┘                       │
│                            │                               │
│              ┌─────────────┼─────────────┐                 │
│              │             │             │                 │
│              ▼             ▼             ▼                 │
│        ┌──────────┐  ┌──────────┐  ┌──────────┐           │
│        │   USER   │  │ PRODUCT  │  │ ORDER    │           │
│        │DATABASE  │  │DATABASE  │  │DATABASE  │           │
│        │          │  │          │  │          │           │
│        │• Users   │  │• Products│  │• Orders  │           │
│        │• Profiles│  │• Catalog │  │• Payments│           │
│        │• Auth    │  │• Inventory│  │• Shipping│           │
│        └──────────┘  └──────────┘  └──────────┘           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### Federation Approaches

1. **Schema Integration**
   - Create unified schema across federated databases
   - Map local schemas to global schema
   - Handle schema evolution and conflicts

2. **Query Federation**
   - Decompose queries into sub-queries for each database
   - Execute sub-queries in parallel
   - Aggregate and join results at federation layer

3. **Data Virtualization**
   - Present virtual views of federated data
   - Real-time access to source systems
   - No data duplication or movement

#### Use Cases
- **Enterprise Integration**: Connecting legacy systems with modern applications
- **Microservices Architecture**: Each service maintains its own database
- **Regulatory Compliance**: Keep sensitive data in separate, compliant systems
- **Gradual Migration**: Transition from monolithic to distributed architecture

### Polyglot Persistence

Polyglot persistence uses different database technologies for different data storage needs within the same application.

```
┌─────────────────────────────────────────────────────────────┐
│                   POLYGLOT PERSISTENCE                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│                  ┌─────────────────┐                       │
│                  │   APPLICATION   │                       │
│                  │    SERVICES     │                       │
│                  └─────────┬───────┘                       │
│                            │                               │
│              ┌─────────────┼─────────────┐                 │
│              │             │             │                 │
│              ▼             ▼             ▼                 │
│        ┌──────────┐  ┌──────────┐  ┌──────────┐           │
│        │PostgreSQL│  │ MongoDB  │  │  Redis   │           │
│        │          │  │          │  │          │           │
│        │• Users   │  │• Products│  │• Sessions│           │
│        │• Orders  │  │• Catalog │  │• Cache   │           │
│        │• Payments│  │• Reviews │  │• Counters│           │
│        └──────────┘  └──────────┘  └──────────┘           │
│              │             │             │                 │
│              ▼             ▼             ▼                 │
│        ┌──────────┐  ┌──────────┐  ┌──────────┐           │
│        │Elasticsearch│ Neo4j    │  │   S3     │           │
│        │          │  │          │  │          │           │
│        │• Search  │  │• Social  │  │• Images  │           │
│        │• Logs    │  │• Recommendations│• Backups │       │
│        │• Analytics│ │• Fraud   │  │• Reports │           │
│        └──────────┘  └──────────┘  └──────────┘           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### Database Selection Criteria

1. **Data Structure**
   - Relational data → SQL databases
   - Document data → Document databases
   - Key-value data → Key-value stores
   - Graph data → Graph databases

2. **Access Patterns**
   - Complex queries → SQL databases
   - Simple lookups → Key-value stores
   - Full-text search → Search engines
   - Analytics → Column stores

3. **Scalability Requirements**
   - Vertical scaling → Traditional RDBMS
   - Horizontal scaling → NoSQL databases
   - Global distribution → Distributed databases

4. **Consistency Requirements**
   - Strong consistency → ACID databases
   - Eventual consistency → NoSQL databases
   - Real-time updates → In-memory databases

#### Implementation Strategy

```python
from abc import ABC, abstractmethod
from typing import Dict, Any, List

class DatabaseAdapter(ABC):
    @abstractmethod
    def save(self, data: Dict[str, Any]) -> str:
        pass
    
    @abstractmethod
    def find(self, query: Dict[str, Any]) -> List[Dict[str, Any]]:
        pass

class PostgreSQLAdapter(DatabaseAdapter):
    def save(self, data: Dict[str, Any]) -> str:
        # Implementation for PostgreSQL
        return "postgresql_id"
    
    def find(self, query: Dict[str, Any]) -> List[Dict[str, Any]]:
        # Implementation for PostgreSQL queries
        return []

class MongoDBAdapter(DatabaseAdapter):
    def save(self, data: Dict[str, Any]) -> str:
        # Implementation for MongoDB
        return "mongodb_id"
    
    def find(self, query: Dict[str, Any]) -> List[Dict[str, Any]]:
        # Implementation for MongoDB queries
        return []

class RedisAdapter(DatabaseAdapter):
    def save(self, data: Dict[str, Any]) -> str:
        # Implementation for Redis
        return "redis_key"
    
    def find(self, query: Dict[str, Any]) -> List[Dict[str, Any]]:
        # Implementation for Redis queries
        return []

class DataAccessLayer:
    def __init__(self):
        self.adapters = {
            'users': PostgreSQLAdapter(),
            'products': MongoDBAdapter(),
            'sessions': RedisAdapter()
        }
    
    def save_user(self, user_data: Dict[str, Any]) -> str:
        return self.adapters['users'].save(user_data)
    
    def save_product(self, product_data: Dict[str, Any]) -> str:
        return self.adapters['products'].save(product_data)
    
    def cache_session(self, session_data: Dict[str, Any]) -> str:
        return self.adapters['sessions'].save(session_data)
```

#### Benefits
- **Optimal Performance**: Each database optimized for specific use case
- **Technology Evolution**: Adopt new technologies incrementally
- **Risk Mitigation**: Reduce dependency on single database technology
- **Team Expertise**: Leverage different team skills and preferences

#### Challenges
- **Operational Complexity**: Managing multiple database technologies
- **Data Consistency**: Maintaining consistency across different systems
- **Transaction Management**: Handling distributed transactions
- **Monitoring and Debugging**: Unified observability across different systems

## Scaling Strategies

### Horizontal vs Vertical Scaling

Database scaling strategies address growing data volumes and increasing user loads through different approaches.

```
┌─────────────────────────────────────────────────────────────┐
│                    SCALING STRATEGIES                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  VERTICAL SCALING (Scale Up)                                │
│  ┌─────────────┐           ┌─────────────┐                 │
│  │   Server    │    ───▶   │   Server    │                 │
│  │             │           │             │                 │
│  │ 4 CPU       │           │ 16 CPU      │                 │
│  │ 8GB RAM     │           │ 64GB RAM    │                 │
│  │ 100GB SSD   │           │ 1TB SSD     │                 │
│  │ 1Gbps NIC   │           │ 10Gbps NIC  │                 │
│  └─────────────┘           └─────────────┘                 │
│                                                             │
│  HORIZONTAL SCALING (Scale Out)                             │
│  ┌─────────────┐           ┌─────────────┐                 │
│  │   Server    │    ───▶   │   Server    │                 │
│  │             │           │             │                 │
│  │ 4 CPU       │           │ 4 CPU       │                 │
│  │ 8GB RAM     │           │ 8GB RAM     │                 │
│  │ 100GB SSD   │           │ 100GB SSD   │                 │
│  └─────────────┘           └─────────────┘                 │
│                            ┌─────────────┐                 │
│                            │   Server    │                 │
│                            │             │                 │
│                            │ 4 CPU       │                 │
│                            │ 8GB RAM     │                 │
│                            │ 100GB SSD   │                 │
│                            └─────────────┘                 │
│                            ┌─────────────┐                 │
│                            │   Server    │                 │
│                            │             │                 │
│                            │ 4 CPU       │                 │
│                            │ 8GB RAM     │                 │
│                            │ 100GB SSD   │                 │
│                            └─────────────┘                 │
└─────────────────────────────────────────────────────────────┘
```

#### Vertical Scaling (Scale Up)

Vertical scaling increases the capacity of existing hardware by adding more powerful components.

**Characteristics:**
- **CPU Scaling**: Increase core count and clock speed
- **Memory Scaling**: Add more RAM for larger datasets and caching
- **Storage Scaling**: Faster SSDs, more storage capacity
- **Network Scaling**: Higher bandwidth network interfaces

**Advantages:**
- Simple to implement - no application changes required
- Maintains data consistency and ACID properties
- No complex distributed system challenges
- Familiar operational model for most teams
- Better performance for single-threaded operations

**Disadvantages:**
- Hardware limits - maximum capacity constraints
- Single point of failure - no redundancy
- Expensive - high-end hardware costs more per unit
- Downtime required for hardware upgrades
- Limited by the capabilities of a single machine

**Implementation Example:**

```yaml
# AWS RDS Instance Scaling
Resources:
  DatabaseInstance:
    Type: AWS::RDS::DBInstance
    Properties:
      DBInstanceClass: db.r5.24xlarge  # 96 vCPUs, 768 GB RAM
      AllocatedStorage: 16384          # 16 TB storage
      StorageType: io1
      Iops: 40000                      # High IOPS for performance
      MultiAZ: true
      StorageEncrypted: true
```

#### Horizontal Scaling (Scale Out)

Horizontal scaling distributes load across multiple machines, providing theoretically unlimited capacity.

**Characteristics:**
- **Node Addition**: Add more servers to handle increased load
- **Data Distribution**: Spread data across multiple nodes
- **Load Distribution**: Distribute queries across multiple instances
- **Fault Tolerance**: Multiple nodes provide redundancy

**Advantages:**
- Unlimited scaling potential - add more nodes as needed
- Cost-effective - use commodity hardware
- High availability - multiple nodes provide redundancy
- Fault tolerance - system continues if individual nodes fail
- Geographic distribution possible

**Disadvantages:**
- Complex application design required
- Eventual consistency challenges
- Distributed system complexity (CAP theorem)
- Cross-node queries are expensive
- Operational complexity increases

### Read Replicas

Read replicas provide horizontal scaling for read-heavy workloads by creating read-only copies of the primary database.

```
┌─────────────────────────────────────────────────────────────┐
│                      READ REPLICAS                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│                    ┌─────────────┐                         │
│                    │   PRIMARY   │                         │
│                    │  DATABASE   │                         │
│                    │             │                         │
│                    │ Writes ✓    │                         │
│                    │ Reads  ✓    │                         │
│                    └──────┬──────┘                         │
│                           │                                │
│                           │ Async Replication              │
│                           │                                │
│        ┌──────────────────┼──────────────────┐             │
│        │                  │                  │             │
│        ▼                  ▼                  ▼             │
│  ┌───────────┐      ┌───────────┐      ┌───────────┐      │
│  │READ REPLICA│     │READ REPLICA│     │READ REPLICA│     │
│  │    US-E    │     │   US-W     │     │   EU       │     │
│  │            │     │            │     │            │     │
│  │ Writes ✗   │     │ Writes ✗   │     │ Writes ✗   │     │
│  │ Reads  ✓   │     │ Reads  ✓   │     │ Reads  ✓   │     │
│  └───────────┘      └───────────┘      └───────────┘      │
│        ▲                  ▲                  ▲             │
│        │                  │                  │             │
│  ┌───────────┐      ┌───────────┐      ┌───────────┐      │
│  │Application│      │Application│      │Application│      │
│  │ Servers   │      │ Servers   │      │ Servers   │      │
│  │ (East)    │      │ (West)    │      │ (Europe)  │      │
│  └───────────┘      └───────────┘      └───────────┘      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### Read Replica Strategies

1. **Geographic Distribution**
   - Place replicas closer to users
   - Reduce latency for read operations
   - Comply with data residency requirements

2. **Workload Separation**
   - Dedicated replicas for analytics
   - Separate replicas for different applications
   - Isolate heavy queries from transactional workload

3. **Disaster Recovery**
   - Cross-region replicas for backup
   - Quick failover capabilities
   - Data protection against regional failures

#### Implementation Example (AWS RDS)

```yaml
# Primary Database
Resources:
  PrimaryDatabase:
    Type: AWS::RDS::DBInstance
    Properties:
      DBInstanceIdentifier: primary-db
      DBInstanceClass: db.r5.xlarge
      Engine: postgres
      BackupRetentionPeriod: 7
      MultiAZ: true

  # Read Replica in same region
  ReadReplicaSameRegion:
    Type: AWS::RDS::DBInstance
    Properties:
      SourceDBInstanceIdentifier: !Ref PrimaryDatabase
      DBInstanceClass: db.r5.large
      PubliclyAccessible: false

  # Cross-region read replica
  ReadReplicaCrossRegion:
    Type: AWS::RDS::DBInstance
    Properties:
      SourceDBInstanceIdentifier: !GetAtt PrimaryDatabase.DBInstanceArn
      DBInstanceClass: db.r5.large
      # This would be in a different region's template
```

### Connection Pooling

Connection pooling manages database connections efficiently to handle high concurrency and reduce connection overhead.

```
┌─────────────────────────────────────────────────────────────┐
│                    CONNECTION POOLING                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐│
│  │              APPLICATION LAYER                          ││
│  │                                                         ││
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐      ││
│  │  │Request 1│ │Request 2│ │Request 3│ │Request N│      ││
│  │  └─────────┘ └─────────┘ └─────────┘ └─────────┘      ││
│  └─────────────────────┬───────────────────────────────────┘│
│                        │                                   │
│                        ▼                                   │
│  ┌─────────────────────────────────────────────────────────┐│
│  │              CONNECTION POOL                            ││
│  │                                                         ││
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐      ││
│  │  │  Conn 1 │ │  Conn 2 │ │  Conn 3 │ │  Conn 4 │      ││
│  │  │ (Active)│ │ (Active)│ │ (Idle)  │ │ (Idle)  │      ││
│  │  └─────────┘ └─────────┘ └─────────┘ └─────────┘      ││
│  │                                                         ││
│  │  Pool Size: 20 | Active: 2 | Idle: 18                 ││
│  └─────────────────────┬───────────────────────────────────┘│
│                        │                                   │
│                        ▼                                   │
│  ┌─────────────────────────────────────────────────────────┐│
│  │                  DATABASE                               ││
│  │                                                         ││
│  │  Max Connections: 100                                   ││
│  │  Current Connections: 20 (from pool)                    ││
│  └─────────────────────────────────────────────────────────┘│
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### Connection Pool Configuration

```python
# SQLAlchemy Connection Pool Example
from sqlalchemy import create_engine
from sqlalchemy.pool import QueuePool, NullPool

# Production configuration with connection pooling
engine = create_engine(
    'postgresql://user:password@localhost:5432/database',
    
    # Pool configuration
    poolclass=QueuePool,
    pool_size=20,                    # Number of connections to maintain
    max_overflow=30,                 # Additional connections when needed
    pool_pre_ping=True,              # Validate connections before use
    pool_recycle=3600,               # Recycle connections after 1 hour
    
    # Connection timeout settings
    connect_args={
        "connect_timeout": 10,
        "application_name": "myapp",
    }
)

# Usage pattern
def get_user_data(user_id):
    with engine.connect() as connection:
        result = connection.execute(
            "SELECT * FROM users WHERE user_id = %s", 
            (user_id,)
        )
        return result.fetchone()
```

#### Pool Sizing Guidelines

1. **Pool Size Calculation**
   ```
   Pool Size = (Number of CPU cores × 2) + Number of disks
   
   For web applications:
   Pool Size = Expected concurrent requests / Average query time
   ```

2. **Monitoring Metrics**
   - Pool utilization percentage
   - Connection wait times
   - Connection creation/destruction rates
   - Query execution times

### Caching Strategies

Caching reduces database load by storing frequently accessed data in faster storage systems.

```
┌─────────────────────────────────────────────────────────────┐
│                    CACHING LAYERS                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐│
│  │                 APPLICATION                             ││
│  └─────────────────────┬───────────────────────────────────┘│
│                        │                                   │
│                        ▼                                   │
│  ┌─────────────────────────────────────────────────────────┐│
│  │              L1: APPLICATION CACHE                      ││
│  │              (In-Memory, Local)                         ││
│  │              Hit Rate: 60-80%                           ││
│  └─────────────────────┬───────────────────────────────────┘│
│                        │ Cache Miss                        │
│                        ▼                                   │
│  ┌─────────────────────────────────────────────────────────┐│
│  │              L2: DISTRIBUTED CACHE                      ││
│  │              (Redis, Memcached)                         ││
│  │              Hit Rate: 15-25%                           ││
│  └─────────────────────┬───────────────────────────────────┘│
│                        │ Cache Miss                        │
│                        ▼                                   │
│  ┌─────────────────────────────────────────────────────────┐│
│  │              L3: DATABASE                               ││
│  │              (Persistent Storage)                       ││
│  │              Hit Rate: 5-15%                            ││
│  └─────────────────────────────────────────────────────────┘│
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### Caching Patterns

1. **Cache-Aside (Lazy Loading)**
   ```python
   def get_user(user_id):
       # Check cache first
       user = cache.get(f"user:{user_id}")
       if user is None:
           # Cache miss - fetch from database
           user = database.get_user(user_id)
           # Store in cache for future requests
           cache.set(f"user:{user_id}", user, ttl=3600)
       return user
   ```

2. **Write-Through**
   ```python
   def update_user(user_id, user_data):
       # Update database first
       database.update_user(user_id, user_data)
       # Update cache
       cache.set(f"user:{user_id}", user_data, ttl=3600)
   ```

3. **Write-Behind (Write-Back)**
   ```python
   def update_user_async(user_id, user_data):
       # Update cache immediately
       cache.set(f"user:{user_id}", user_data, ttl=3600)
       # Queue database update for later
       queue.enqueue(database.update_user, user_id, user_data)
   ```

#### Cache Invalidation Strategies

1. **TTL-Based Expiration**
   - Set time-to-live for cached data
   - Automatic expiration after specified time
   - Simple but may serve stale data

2. **Event-Based Invalidation**
   - Invalidate cache when data changes
   - Requires coordination between systems
   - Ensures data freshness

3. **Version-Based Invalidation**
   - Include version numbers in cache keys
   - Increment version on data changes
   - Old versions automatically become invalid

### Database Partitioning

Partitioning divides large tables into smaller, more manageable pieces while maintaining logical unity.

#### Horizontal Partitioning (Sharding)

```sql
-- Range partitioning by date
CREATE TABLE orders_2025_q1 PARTITION OF orders
FOR VALUES FROM ('2025-01-01') TO ('2025-04-01');

CREATE TABLE orders_2025_q2 PARTITION OF orders
FOR VALUES FROM ('2025-04-01') TO ('2025-07-01');

-- Hash partitioning by user_id
CREATE TABLE users_partition_0 PARTITION OF users
FOR VALUES WITH (MODULUS 4, REMAINDER 0);

CREATE TABLE users_partition_1 PARTITION OF users
FOR VALUES WITH (MODULUS 4, REMAINDER 1);
```

#### Vertical Partitioning

```sql
-- Split large table into frequently and rarely accessed columns
CREATE TABLE users_core (
    user_id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE users_profile (
    user_id INTEGER PRIMARY KEY REFERENCES users_core(user_id),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    bio TEXT,
    avatar_url VARCHAR(500),
    preferences JSONB
);

CREATE TABLE users_activity (
    user_id INTEGER PRIMARY KEY REFERENCES users_core(user_id),
    last_login TIMESTAMP,
    login_count INTEGER DEFAULT 0,
    last_ip INET,
    session_data JSONB
);
```

#### Benefits of Partitioning

1. **Improved Performance**
   - Smaller indexes for faster queries
   - Parallel query execution across partitions
   - Partition elimination in query planning

2. **Easier Maintenance**
   - Backup and restore individual partitions
   - Drop old partitions for data retention
   - Rebuild indexes on smaller datasets

3. **Better Scalability**
   - Distribute partitions across different storage
   - Scale individual partitions independently
   - Improved concurrent access patterns

## Data Consistency and Availability

### CAP Theorem in Database Context

The CAP theorem fundamentally impacts database design decisions, especially in distributed systems.

```
┌─────────────────────────────────────────────────────────────┐
│                      CAP THEOREM                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│                    ┌─────────────┐                         │
│                    │CONSISTENCY  │                         │
│                    │             │                         │
│                    │All nodes see│                         │
│                    │same data at │                         │
│                    │same time    │                         │
│                    └──────┬──────┘                         │
│                           │                                │
│                           │                                │
│              ┌────────────┼────────────┐                   │
│              │            │            │                   │
│              │            │            │                   │
│    ┌─────────▼──┐      ┌──▼──┐      ┌──▼─────────┐        │
│    │    CP      │      │ ??? │      │     AP     │        │
│    │            │      │     │      │            │        │
│    │Traditional │      │ All │      │ NoSQL      │        │
│    │RDBMS       │      │Three│      │Systems     │        │
│    │            │      │     │      │            │        │
│    └────────────┘      └─────┘      └────────────┘        │
│              │                              │              │
│              │                              │              │
│    ┌─────────▼──────────┐        ┌─────────▼──────────┐   │
│    │    AVAILABILITY    │        │    PARTITION       │   │
│    │                   │        │    TOLERANCE       │   │
│    │System remains     │        │                   │   │
│    │operational        │        │System continues   │   │
│    │                   │        │despite network    │   │
│    │                   │        │failures           │   │
│    └───────────────────┘        └───────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### Consistency Models

1. **Strong Consistency (Linearizability)**
   - All reads receive the most recent write
   - System appears as if there's only one copy of data
   - Achieved through synchronous replication
   - Higher latency but guaranteed consistency

2. **Eventual Consistency**
   - System will become consistent over time
   - Temporary inconsistencies are acceptable
   - Lower latency but potential for stale reads
   - Common in distributed NoSQL systems

3. **Causal Consistency**
   - Preserves causal relationships between operations
   - If operation A causally precedes B, all nodes see A before B
   - Weaker than strong consistency, stronger than eventual

4. **Session Consistency**
   - Consistency guarantees within a user session
   - User sees their own writes immediately
   - Other users may see eventual consistency

### ACID vs BASE Properties Comparison

```
┌─────────────────────────────────────────────────────────────┐
│                    ACID vs BASE                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐│
│  │                     ACID                                ││
│  │  ┌─────────────────────────────────────────────────────┐││
│  │  │ Atomicity    │ All operations succeed or all fail   │││
│  │  │ Consistency  │ Database remains in valid state      │││
│  │  │ Isolation    │ Transactions don't interfere         │││
│  │  │ Durability   │ Committed changes persist            │││
│  │  └─────────────────────────────────────────────────────┘││
│  │                                                         ││
│  │  Use Cases: Banking, Financial Systems, Critical Data   ││
│  │  Examples: PostgreSQL, MySQL, Oracle                    ││
│  └─────────────────────────────────────────────────────────┘│
│                              │                             │
│                              ▼                             │
│  ┌─────────────────────────────────────────────────────────┐│
│  │                     BASE                                ││
│  │  ┌─────────────────────────────────────────────────────┐││
│  │  │ Basically Available │ System guarantees availability│││
│  │  │ Soft State         │ Data may be inconsistent      │││
│  │  │ Eventually Consistent│ System becomes consistent   │││
│  │  └─────────────────────────────────────────────────────┘││
│  │                                                         ││
│  │  Use Cases: Social Media, Analytics, Content Systems    ││
│  │  Examples: MongoDB, Cassandra, DynamoDB                 ││
│  └─────────────────────────────────────────────────────────┘│
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Isolation Levels

Database isolation levels control how transaction integrity is maintained when multiple transactions are executed concurrently.

```sql
-- Read Uncommitted: Can read uncommitted changes
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
BEGIN;
SELECT balance FROM accounts WHERE account_id = 'A';
-- May see uncommitted changes from other transactions
COMMIT;

-- Read Committed: Only reads committed data (Default in most databases)
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN;
SELECT balance FROM accounts WHERE account_id = 'A';
-- Will only see committed data, but may change between reads
SELECT balance FROM accounts WHERE account_id = 'A';
COMMIT;

-- Repeatable Read: Same reads return same results
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN;
SELECT balance FROM accounts WHERE account_id = 'A';
-- Subsequent reads will return the same value
SELECT balance FROM accounts WHERE account_id = 'A';
COMMIT;

-- Serializable: Full isolation, as if transactions run sequentially
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN;
SELECT COUNT(*) FROM accounts WHERE balance > 1000;
-- No other transaction can modify data that affects this query
INSERT INTO accounts (account_id, balance) VALUES ('C', 1500);
COMMIT;
```

### Distributed Consensus

Distributed consensus algorithms ensure agreement among distributed nodes even in the presence of failures.

```python
# Simplified Consensus Implementation
class ConsensusNode:
    def __init__(self, node_id, peers):
        self.node_id = node_id
        self.peers = peers
        self.state = 'follower'
        self.current_term = 0
        self.log = []
        
    def propose_value(self, value):
        """Propose a value for consensus"""
        if self.state != 'leader':
            return False
            
        # Phase 1: Prepare - get promises from majority
        promises = self.send_prepare_requests()
        if len(promises) <= len(self.peers) // 2:
            return False
            
        # Phase 2: Accept - send accept requests
        accepts = self.send_accept_requests(value)
        if len(accepts) > len(self.peers) // 2:
            self.commit_value(value)
            return True
            
        return False
```

## AWS Implementation

### RDS Multi-AZ Deployment

```yaml
# CloudFormation Template for RDS
Resources:
  DatabaseInstance:
    Type: AWS::RDS::DBInstance
    Properties:
      DBInstanceIdentifier: ecommerce-db
      DBInstanceClass: db.t3.medium
      Engine: postgres
      EngineVersion: '13.7'
      MasterUsername: dbadmin
      MasterUserPassword: !Ref DBPassword
      AllocatedStorage: 100
      StorageType: gp2
      MultiAZ: true
      VPCSecurityGroups:
        - !Ref DatabaseSecurityGroup
      DBSubnetGroupName: !Ref DBSubnetGroup
      BackupRetentionPeriod: 7
      DeletionProtection: true

  ReadReplica:
    Type: AWS::RDS::DBInstance
    Properties:
      SourceDBInstanceIdentifier: !Ref DatabaseInstance
      DBInstanceClass: db.t3.medium
      PubliclyAccessible: false
```

### DynamoDB Table Design

```yaml
# DynamoDB Table Configuration
Resources:
  UserTable:
    Type: AWS::DynamoDB::Table
    Properties:
      TableName: Users
      BillingMode: PAY_PER_REQUEST
      AttributeDefinitions:
        - AttributeName: user_id
          AttributeType: S
        - AttributeName: email
          AttributeType: S
      KeySchema:
        - AttributeName: user_id
          KeyType: HASH
      GlobalSecondaryIndexes:
        - IndexName: EmailIndex
          KeySchema:
            - AttributeName: email
              KeyType: HASH
          Projection:
            ProjectionType: ALL
```

```python
# DynamoDB Operations
import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('Users')

# Create user
table.put_item(
    Item={
        'user_id': 'usr_12345',
        'email': 'user@example.com',
        'name': 'John Doe',
        'created_at': '2025-09-10T14:30:00Z'
    }
)

# Query by email
response = table.query(
    IndexName='EmailIndex',
    KeyConditionExpression='email = :email',
    ExpressionAttributeValues={':email': 'user@example.com'}
)
```

## Decision Matrix

```
┌─────────────────────────────────────────────────────────────┐
│                DATABASE SELECTION MATRIX                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              CAPABILITY COMPARISON                      │ │
│  │                                                         │ │
│  │  Database    │ ACID │Scalability│Flexibility│Performance│ │
│  │  Type        │      │           │           │           │ │
│  │  ──────────  │ ──── │ ───────── │ ───────── │ ───────── │ │
│  │  Relational  │ ████ │ ██▒▒▒▒▒▒▒ │ ▒▒▒▒▒▒▒▒▒ │ ███▒▒▒▒▒▒ │ │
│  │              │ ✅   │ ⚠️ Vertical│ ❌ Rigid  │ ⚠️ Good   │ │
│  │              │      │           │           │           │ │
│  │  Document    │ ███▒ │ ████████▒ │ █████████ │ ████████▒ │ │
│  │              │ ⚠️   │ ✅ Horiz. │ ✅ Flexible│ ✅ Fast   │ │
│  │              │      │           │           │           │ │
│  │  Key-Value   │ ▒▒▒▒ │ █████████ │ ██████▒▒▒ │ █████████ │ │
│  │              │ ❌   │ ✅ Excellent│ ✅ Simple │ ✅ Fastest│ │
│  │              │      │           │           │           │ │
│  │  Graph       │ ██▒▒ │ ███▒▒▒▒▒▒ │ █████████ │ ████▒▒▒▒▒ │ │
│  │              │ ⚠️   │ ⚠️ Complex │ ✅ Relations│ ⚠️ Variable│ │
│  │              │      │           │           │           │ │
│  │  Column      │ ▒▒▒▒ │ █████████ │ █████▒▒▒▒ │ ████████▒ │ │
│  │              │ ❌   │ ✅ Excellent│ ⚠️ Column │ ✅ Fast   │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              DECISION FLOWCHART                         │ │
│  │                                                         │ │
│  │                    ┌─────────────┐                     │ │
│  │                    │ START: What │                     │ │
│  │                    │ type of data│                     │ │
│  │                    │ do you have?│                     │ │
│  │                    └──────┬──────┘                     │ │
│  │                           │                            │ │
│  │              ┌────────────┼────────────┐               │ │
│  │              │            │            │               │ │
│  │              ▼            ▼            ▼               │ │
│  │     ┌─────────────┐ ┌─────────────┐ ┌─────────────┐    │ │
│  │     │ Structured  │ │Semi-Struct  │ │Relationships│    │ │
│  │     │ Relational  │ │ Documents   │ │   Graphs    │    │ │
│  │     └──────┬──────┘ └──────┬──────┘ └──────┬──────┘    │ │
│  │            │               │               │           │ │
│  │            ▼               ▼               ▼           │ │
│  │     ┌─────────────┐ ┌─────────────┐ ┌─────────────┐    │ │
│  │     │Need ACID?   │ │Need Scale?  │ │Complex      │    │ │
│  │     │             │ │             │ │Queries?     │    │ │
│  │     │ Yes→SQL     │ │ Yes→NoSQL   │ │ Yes→Graph   │    │ │
│  │     │ No→NoSQL    │ │ No→SQL      │ │ No→Document │    │ │
│  │     └─────────────┘ └─────────────┘ └─────────────┘    │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                USE CASE MAPPING                         │ │
│  │                                                         │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │ │
│  │  │   E-COMMERCE│  │   SOCIAL    │  │   GAMING    │     │ │
│  │  │             │  │   MEDIA     │  │             │     │ │
│  │  │ Orders: SQL │  │ Posts: Doc  │  │ Players: KV │     │ │
│  │  │ Users: SQL  │  │ Friends:    │  │ Scores: KV  │     │ │
│  │  │ Products:   │  │ Graph       │  │ Sessions:   │     │ │
│  │  │ Document    │  │ Analytics:  │  │ Document    │     │ │
│  │  │ Sessions: KV│  │ Column      │  │ Leaderboard:│     │ │
│  │  │             │  │             │  │ Column      │     │ │
│  │  └─────────────┘  └─────────────┘  └─────────────┘     │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

| Database Type | ACID | Scalability | Flexibility | Performance | Consistency |
|---------------|------|-------------|-------------|-------------|-------------|
| **Relational** | ✅ Excellent | ⚠️ Vertical | ❌ Rigid Schema | ⚠️ Good | ✅ Strong |
| **Document** | ⚠️ Limited | ✅ Horizontal | ✅ Flexible | ✅ Fast | ⚠️ Eventual |
| **Key-Value** | ❌ Minimal | ✅ Excellent | ✅ Simple | ✅ Fastest | ⚠️ Eventual |
| **Graph** | ⚠️ Limited | ⚠️ Complex | ✅ Relationships | ⚠️ Variable | ⚠️ Eventual |
| **Column** | ❌ Minimal | ✅ Excellent | ⚠️ Column-based | ✅ Fast | ⚠️ Tunable |

### Selection Guidelines

**Choose Relational When:**
- Strong consistency required
- Complex queries and joins needed
- ACID transactions critical
- Well-defined schema

**Choose Document When:**
- Flexible schema needed
- Rapid development required
- Horizontal scaling important
- JSON-like data structure

**Choose Key-Value When:**
- Simple data model
- High performance critical
- Caching layer needed
- Session storage

## Use Cases

### E-commerce Platform Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                 E-COMMERCE DATA ARCHITECTURE                 │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
│  │   REDIS     │    │ POSTGRESQL  │    │  MONGODB    │     │
│  │             │    │             │    │             │     │
│  │ • Sessions  │    │ • Users     │    │ • Products  │     │
│  │ • Cart      │    │ • Orders    │    │ • Reviews   │     │
│  │ • Cache     │    │ • Payments  │    │ • Catalog   │     │
│  └─────────────┘    └─────────────┘    └─────────────┘     │
│                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
│  │ ELASTICSEARCH│    │   S3        │    │ DYNAMODB    │     │
│  │             │    │             │    │             │     │
│  │ • Search    │    │ • Images    │    │ • Analytics │     │
│  │ • Analytics │    │ • Backups   │    │ • Logs      │     │
│  │ • Logs      │    │ • Reports   │    │ • Events    │     │
│  └─────────────┘    └─────────────┘    └─────────────┘     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Best Practices

### Connection Pooling

```python
# Database Connection Pool
from sqlalchemy import create_engine
from sqlalchemy.pool import QueuePool

engine = create_engine(
    'postgresql://user:pass@localhost/db',
    poolclass=QueuePool,
    pool_size=20,
    max_overflow=30,
    pool_pre_ping=True,
    pool_recycle=3600
)

# Usage
with engine.connect() as conn:
    result = conn.execute("SELECT * FROM users WHERE active = true")
```

### Query Optimization

```sql
-- Bad: No index usage
SELECT * FROM orders WHERE created_at > '2025-01-01';

-- Good: Optimized with index
CREATE INDEX idx_orders_created_at ON orders(created_at);
SELECT order_id, user_id, total FROM orders 
WHERE created_at > '2025-01-01' 
ORDER BY created_at DESC 
LIMIT 100;

-- Good: Composite index for complex queries
CREATE INDEX idx_orders_user_status ON orders(user_id, status, created_at);
```

### Backup Strategy

```yaml
# Automated Backup Configuration
Resources:
  BackupVault:
    Type: AWS::Backup::BackupVault
    Properties:
      BackupVaultName: DatabaseBackups
      
  BackupPlan:
    Type: AWS::Backup::BackupPlan
    Properties:
      BackupPlan:
        BackupPlanName: DatabaseBackupPlan
        BackupPlanRule:
          - RuleName: DailyBackups
            TargetBackupVault: !Ref BackupVault
            ScheduleExpression: cron(0 2 * * ? *)
            Lifecycle:
              DeleteAfterDays: 30
```
