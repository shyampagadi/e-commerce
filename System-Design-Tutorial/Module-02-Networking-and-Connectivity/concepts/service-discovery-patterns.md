# Service Discovery Patterns

## Overview

Service discovery is a critical component of microservices architecture that enables services to find and communicate with each other dynamically. As systems scale and become more distributed, traditional static configuration becomes impractical, making service discovery essential for building resilient, scalable applications.

## Service Discovery Fundamentals

### What is Service Discovery?
```
┌─────────────────────────────────────────────────────────────┐
│                SERVICE DISCOVERY CONCEPT                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────┐  │
│  │   Service   │    │   Service   │    │   Service       │  │
│  │   A        │    │   B        │    │   C             │  │
│  │             │    │             │    │                 │  │
│  │ ┌─────────┐ │    │ ┌─────────┐ │    │ ┌─────────────┐ │  │
│  │ │Instance │ │    │ │Instance │ │    │ │Instance     │ │  │
│  │ │  1      │ │    │ │  1      │ │    │ │  1          │ │  │
│  │ └─────────┘ │    │ └─────────┘ │    │ └─────────────┘ │  │
│  │ ┌─────────┐ │    │ ┌─────────┐ │    │ ┌─────────────┐ │  │
│  │ │Instance │ │    │ │Instance │ │    │ │Instance     │ │  │
│  │ │  2      │ │    │ │  2      │ │    │ │  2          │ │  │
│  │ └─────────┘ │    │ └─────────┘ │    │ └─────────────┘ │  │
│  └─────────────┘    └─────────────┘    └─────────────────┘  │
│         │                   │                   │           │
│         └───────────────────┼───────────────────┘           │
│                             │                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │            Service Registry                         │    │
│  │                                                     │    │
│  │  - Service A: [Instance1, Instance2]               │    │
│  │  - Service B: [Instance1, Instance2]               │    │
│  │  - Service C: [Instance1, Instance2]               │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Service Discovery Benefits
- **Dynamic Scaling**: Services can scale up/down without configuration changes
- **Fault Tolerance**: Failed instances are automatically removed from discovery
- **Load Distribution**: Traffic can be distributed across healthy instances
- **Health Monitoring**: Unhealthy services are automatically excluded
- **Configuration Management**: Centralized service configuration

## Service Discovery Patterns

### 1. Client-Side Discovery

#### Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                CLIENT-SIDE DISCOVERY                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────┐  │
│  │   Client    │    │   Service   │    │   Service       │  │
│  │   Service   │    │  Registry   │    │   A             │  │
│  │             │    │             │    │                 │  │
│  │ ┌─────────┐ │    │ ┌─────────┐ │    │ ┌─────────────┐ │  │
│  │ │Discovery│ │    │ │Service  │ │    │ │Instance 1   │ │  │
│  │ │Client   │ │    │ │Catalog  │ │    │ └─────────────┘ │  │
│  │ └─────────┘ │    │ └─────────┘ │    │ ┌─────────────┐ │  │
│  │ ┌─────────┐ │    │ ┌─────────┐ │    │ │Instance 2   │ │  │
│  │ │Load     │ │    │ │Health   │ │    │ └─────────────┘ │  │
│  │ │Balancer │ │    │ │Checker  │ │    │ ┌─────────────┐ │  │
│  │ └─────────┘ │    │ └─────────┘ │    │ │Instance 3   │ │  │
│  └─────────────┘    └─────────────┘    │ └─────────────┘ │  │
│         │                   │          └─────────────────┘  │
│         │ 1. Query Services │                   │           │
│         ├──────────────────→│                   │           │
│         │ 2. Return List    │                   │           │
│         │←──────────────────┤                   │           │
│         │ 3. Load Balance   │                   │           │
│         ├──────────────────────────────────────→│           │
│         │ 4. Direct Request │                   │           │
│         ├──────────────────────────────────────→│           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### How It Works
1. **Service Registration**: Services register themselves with the registry
2. **Client Query**: Client queries the registry for available services
3. **Service List**: Registry returns list of healthy service instances
4. **Load Balancing**: Client performs load balancing locally
5. **Direct Communication**: Client communicates directly with selected instance

#### Advantages
- **Simple Architecture**: No additional infrastructure components
- **Low Latency**: Direct communication without proxy overhead
- **Client Control**: Client has full control over load balancing logic
- **Fault Tolerance**: Client can implement custom retry and circuit breaker logic

#### Disadvantages
- **Client Complexity**: Each client must implement discovery logic
- **Language Coupling**: Discovery logic must be implemented in each language
- **Registry Dependency**: All clients depend on registry availability
- **Configuration Drift**: Different clients may have different service lists

#### Use Cases
- **Microservices**: Service-to-service communication
- **Mobile Applications**: Mobile apps discovering backend services
- **Distributed Systems**: Systems with multiple service instances
- **Cloud-Native Applications**: Containerized applications

### 2. Server-Side Discovery

#### Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                SERVER-SIDE DISCOVERY                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────┐  │
│  │   Client    │    │   Load      │    │   Service       │  │
│  │   Service   │    │  Balancer   │    │   A             │  │
│  │             │    │             │    │                 │  │
│  │ ┌─────────┐ │    │ ┌─────────┐ │    │ ┌─────────────┐ │  │
│  │ │Simple   │ │    │ │Service  │ │    │ │Instance 1   │ │  │
│  │ │Request  │ │    │ │Registry │ │    │ └─────────────┘ │  │
│  │ └─────────┘ │    │ └─────────┘ │    │ ┌─────────────┐ │  │
│  │             │    │ ┌─────────┐ │    │ │Instance 2   │ │  │
│  │             │    │ │Load     │ │    │ └─────────────┘ │  │
│  │             │    │ │Balancer │ │    │ ┌─────────────┐ │  │
│  │             │    │ └─────────┘ │    │ │Instance 3   │ │  │
│  └─────────────┘    └─────────────┘    │ └─────────────┘ │  │
│         │                   │          └─────────────────┘  │
│         │ 1. Request        │                   │           │
│         ├──────────────────→│                   │           │
│         │ 2. Query Registry │                   │           │
│         │         ├─────────→│                   │           │
│         │ 3. Return List    │                   │           │
│         │         ←─────────┤                   │           │
│         │ 4. Load Balance   │                   │           │
│         │         ├─────────────────────────────→│           │
│         │ 5. Response       │                   │           │
│         │←──────────────────┤                   │           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### How It Works
1. **Service Registration**: Services register with the registry
2. **Client Request**: Client sends request to load balancer
3. **Service Discovery**: Load balancer queries registry for services
4. **Load Balancing**: Load balancer selects healthy instance
5. **Request Forwarding**: Load balancer forwards request to selected instance
6. **Response**: Response is returned through load balancer

#### Advantages
- **Client Simplicity**: Clients don't need discovery logic
- **Centralized Control**: Load balancing logic centralized
- **Language Agnostic**: Works with any client language
- **Consistent Behavior**: All clients get same load balancing

#### Disadvantages
- **Single Point of Failure**: Load balancer becomes bottleneck
- **Additional Infrastructure**: Requires load balancer components
- **Latency Overhead**: Additional hop through load balancer
- **Configuration Complexity**: Load balancer configuration required

#### Use Cases
- **Web Applications**: Web clients accessing backend services
- **API Gateways**: Centralized API management
- **Legacy Integration**: Integrating with existing systems
- **Multi-tenant Applications**: Shared infrastructure

### 3. Service Registry

#### Registry Types

##### In-Memory Registry
```
┌─────────────────────────────────────────────────────────────┐
│                IN-MEMORY REGISTRY                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │            Service Registry                         │    │
│  │                                                     │    │
│  │  Service A:                                        │    │
│  │  ┌─────────┬─────────┬─────────┬─────────┐          │    │
│  │  │Instance │Instance │Instance │Instance │          │    │
│  │  │   1     │   2     │   3     │   4     │          │    │
│  │  │10.0.1.1 │10.0.1.2 │10.0.1.3 │10.0.1.4 │          │    │
│  │  │:8080    │:8080    │:8080    │:8080    │          │    │
│  │  └─────────┴─────────┴─────────┴─────────┘          │    │
│  │                                                     │    │
│  │  Service B:                                        │    │
│  │  ┌─────────┬─────────┬─────────┐                    │    │
│  │  │Instance │Instance │Instance │                    │    │
│  │  │   1     │   2     │   3     │                    │    │
│  │  │10.0.2.1 │10.0.2.2 │10.0.2.3 │                    │    │
│  │  │:9090    │:9090    │:9090    │                    │    │
│  │  └─────────┴─────────┴─────────┘                    │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

##### Distributed Registry
```
┌─────────────────────────────────────────────────────────────┐
│                DISTRIBUTED REGISTRY                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────┐  │
│  │   Registry  │    │   Registry  │    │   Registry      │  │
│  │   Node 1    │    │   Node 2    │    │   Node 3        │  │
│  │             │    │             │    │                 │  │
│  │ ┌─────────┐ │    │ ┌─────────┐ │    │ ┌─────────────┐ │  │
│  │ │Service  │ │    │ │Service  │ │    │ │Service      │ │  │
│  │ │Catalog  │ │    │ │Catalog  │ │    │ │Catalog      │ │  │
│  │ └─────────┘ │    │ └─────────┘ │    │ └─────────────┘ │  │
│  │ ┌─────────┐ │    │ ┌─────────┐ │    │ ┌─────────────┐ │  │
│  │ │Health   │ │    │ │Health   │ │    │ │Health       │ │  │
│  │ │Checker  │ │    │ │Checker  │ │    │ │Checker      │ │  │
│  │ └─────────┘ │    │ └─────────┘ │    │ └─────────────┘ │  │
│  └─────────────┘    └─────────────┘    └─────────────────┘  │
│         │                   │                   │           │
│         └───────────────────┼───────────────────┘           │
│                             │                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │            Replication & Consensus                  │    │
│  │                                                     │    │
│  │  - Data replication across nodes                    │    │
│  │  - Consensus protocol (Raft, Paxos)                 │    │
│  │  - Leader election                                  │    │
│  │  - Split-brain prevention                           │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 4. DNS-Based Discovery

#### Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                DNS-BASED DISCOVERY                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────┐  │
│  │   Client    │    │   DNS       │    │   Service       │  │
│  │   Service   │    │  Server     │    │   A             │  │
│  │             │    │             │    │                 │  │
│  │ ┌─────────┐ │    │ ┌─────────┐ │    │ ┌─────────────┐ │  │
│  │ │DNS      │ │    │ │Service  │ │    │ │Instance 1   │ │  │
│  │ │Client   │ │    │ │Records  │ │    │ │10.0.1.1:8080│ │  │
│  │ └─────────┘ │    │ └─────────┘ │    │ └─────────────┘ │  │
│  │ ┌─────────┐ │    │ ┌─────────┐ │    │ ┌─────────────┐ │  │
│  │ │Load     │ │    │ │Health   │ │    │ │Instance 2   │ │  │
│  │ │Balancer │ │    │ │Checker  │ │    │ │10.0.1.2:8080│ │  │
│  │ └─────────┘ │    │ └─────────┘ │    │ └─────────────┘ │  │
│  └─────────────┘    └─────────────┘    │ ┌─────────────┐ │  │
│         │                   │          │ │Instance 3   │ │  │
│         │ 1. DNS Query      │          │ │10.0.1.3:8080│ │  │
│         ├──────────────────→│          │ └─────────────┘ │  │
│         │ 2. Return Records │          └─────────────────┘  │
│         │←──────────────────┤                   │           │
│         │ 3. Load Balance   │                   │           │
│         ├──────────────────────────────────────→│           │
│         │ 4. Direct Request │                   │           │
│         ├──────────────────────────────────────→│           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### DNS Record Types
```
┌─────────────────────────────────────────────────────────────┐
│                DNS RECORD TYPES                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  A Records:                                                 │
│  service-a.example.com.    IN    A    10.0.1.1            │
│  service-a.example.com.    IN    A    10.0.1.2            │
│  service-a.example.com.    IN    A    10.0.1.3            │
│                                                             │
│  SRV Records:                                               │
│  _http._tcp.service-a.example.com. IN SRV 10 5 8080 10.0.1.1│
│  _http._tcp.service-a.example.com. IN SRV 10 5 8080 10.0.1.2│
│  _http._tcp.service-a.example.com. IN SRV 10 5 8080 10.0.1.3│
│                                                             │
│  CNAME Records:                                             │
│  api.example.com.          IN    CNAME service-a.example.com│
│  web.example.com.          IN    CNAME service-b.example.com│
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### Advantages
- **Standard Protocol**: Uses existing DNS infrastructure
- **Caching**: DNS caching reduces registry load
- **Load Distribution**: DNS round-robin provides basic load balancing
- **Language Agnostic**: Works with any DNS client

#### Disadvantages
- **Limited Load Balancing**: Basic round-robin only
- **Cache Issues**: DNS caching can cause stale data
- **Health Checking**: Limited health checking capabilities
- **Port Management**: Complex port management with SRV records

### 5. Service Mesh Discovery

#### Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                SERVICE MESH DISCOVERY                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────┐  │
│  │   Service   │    │   Service   │    │   Service       │  │
│  │   A        │    │   B        │    │   C             │  │
│  │             │    │             │    │                 │  │
│  │ ┌─────────┐ │    │ ┌─────────┐ │    │ ┌─────────────┐ │  │
│  │ │Sidecar  │ │    │ │Sidecar  │ │    │ │Sidecar      │ │  │
│  │ │Proxy    │ │    │ │Proxy    │ │    │ │Proxy        │ │  │
│  │ └─────────┘ │    │ └─────────┘ │    │ └─────────────┘ │  │
│  │ ┌─────────┐ │    │ ┌─────────┐ │    │ ┌─────────────┐ │  │
│  │ │Service  │ │    │ │Service  │ │    │ │Service      │ │  │
│  │ │Instance │ │    │ │Instance │ │    │ │Instance     │ │  │
│  │ └─────────┘ │    │ └─────────┘ │    │ └─────────────┘ │  │
│  └─────────────┘    └─────────────┘    └─────────────────┘  │
│         │                   │                   │           │
│         └───────────────────┼───────────────────┘           │
│                             │                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │            Control Plane                            │    │
│  │                                                     │    │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────┐  │    │
│  │  │Service      │    │Policy       │    │Security │  │    │
│  │  │Registry     │    │Engine       │    │Manager  │  │    │
│  │  └─────────────┘    └─────────────┘    └─────────┘  │    │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────┐  │    │
│  │  │Configuration│    │Telemetry    │    │Certificate│  │    │
│  │  │Manager      │    │Collector    │    │Manager  │  │    │
│  │  └─────────────┘    └─────────────┘    └─────────┘  │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### How It Works
1. **Sidecar Injection**: Sidecar proxy injected into each service pod
2. **Service Registration**: Sidecar registers service with control plane
3. **Configuration Distribution**: Control plane distributes service topology
4. **Traffic Management**: Sidecar handles service discovery and load balancing
5. **Health Monitoring**: Sidecar monitors service health and reports to control plane

#### Advantages
- **Transparent**: No changes required to application code
- **Language Agnostic**: Works with any programming language
- **Advanced Features**: Circuit breaking, retries, timeouts
- **Observability**: Built-in metrics, tracing, and logging
- **Security**: mTLS, authentication, authorization

#### Disadvantages
- **Complexity**: Additional infrastructure components
- **Resource Overhead**: Sidecar proxy consumes resources
- **Learning Curve**: Requires understanding of service mesh concepts
- **Vendor Lock-in**: Tied to specific service mesh implementation

## Service Discovery Implementation

### 1. Service Registration

#### Registration Process
```
┌─────────────────────────────────────────────────────────────┐
│                SERVICE REGISTRATION PROCESS                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Service Startup:                                        │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────┐  │
│  │   Service   │    │   Registry  │    │   Health        │  │
│  │   Instance  │    │   Client    │    │   Checker       │  │
│  │             │    │             │    │                 │  │
│  │ - Start     │    │ - Register  │    │ - Monitor       │  │
│  │ - Get IP    │    │ - Heartbeat │    │ - Report        │  │
│  │ - Get Port  │    │ - Update    │    │ - Deregister    │  │
│  └─────────────┘    └─────────────┘    └─────────────────┘  │
│         │                   │                   │           │
│         │ 1. Register       │                   │           │
│         ├──────────────────→│                   │           │
│         │ 2. Start Heartbeat│                   │           │
│         ├──────────────────→│                   │           │
│         │ 3. Health Check   │                   │           │
│         ├──────────────────────────────────────→│           │
│         │ 4. Periodic Update│                   │           │
│         ├──────────────────→│                   │           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### Registration Data
```
┌─────────────────────────────────────────────────────────────┐
│                SERVICE REGISTRATION DATA                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Service Instance:                                          │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ {                                                   │    │
│  │   "serviceId": "user-service",                      │    │
│  │   "instanceId": "user-service-1",                   │    │
│  │   "host": "10.0.1.1",                              │    │
│  │   "port": 8080,                                     │    │
│  │   "status": "UP",                                   │    │
│  │   "healthCheckUrl": "http://10.0.1.1:8080/health", │    │
│  │   "metadata": {                                      │    │
│  │     "version": "1.0.0",                             │    │
│  │     "region": "us-east-1",                          │    │
│  │     "zone": "us-east-1a"                            │    │
│  │   },                                                │    │
│  │   "leaseInfo": {                                    │    │
│  │     "duration": 30,                                 │    │
│  │     "renewalInterval": 10                           │    │
│  │   }                                                 │    │
│  │ }                                                   │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 2. Health Checking

#### Health Check Types
```
┌─────────────────────────────────────────────────────────────┐
│                HEALTH CHECK TYPES                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  HTTP Health Check:                                         │
│  - URL: /health                                             │
│  - Method: GET                                              │
│  - Expected Status: 200                                     │
│  - Timeout: 5 seconds                                       │
│  - Interval: 30 seconds                                     │
│                                                             │
│  TCP Health Check:                                          │
│  - Port: 8080                                               │
│  - Timeout: 3 seconds                                       │
│  - Interval: 30 seconds                                     │
│                                                             │
│  Custom Health Check:                                       │
│  - Script: /usr/local/bin/health-check.sh                  │
│  - Timeout: 10 seconds                                      │
│  - Interval: 60 seconds                                     │
│                                                             │
│  Application Health Check:                                  │
│  - Database connectivity                                    │
│  - External service availability                            │
│  - Resource utilization                                     │
│  - Business logic validation                                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### Health Check Implementation
```
┌─────────────────────────────────────────────────────────────┐
│                HEALTH CHECK IMPLEMENTATION                 │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Service Health Endpoint:                                  │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ GET /health                                         │    │
│  │                                                     │    │
│  │ Response:                                           │    │
│  │ {                                                   │    │
│  │   "status": "UP",                                   │    │
│  │   "checks": {                                       │    │
│  │     "database": "UP",                               │    │
│  │     "redis": "UP",                                  │    │
│  │     "disk": "UP",                                   │    │
│  │     "memory": "UP"                                  │    │
│  │   },                                                │    │
│  │   "timestamp": "2024-01-15T10:30:00Z"               │    │
│  │ }                                                   │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 3. Load Balancing

#### Load Balancing Strategies
```
┌─────────────────────────────────────────────────────────────┐
│                LOAD BALANCING STRATEGIES                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Round Robin:                                               │
│  - Distribute requests evenly across instances             │
│  - Simple and predictable                                  │
│  - Good for equal capacity instances                       │
│                                                             │
│  Weighted Round Robin:                                      │
│  - Assign weights based on instance capacity               │
│  - More powerful instances get more requests                │
│  - Good for heterogeneous instances                        │
│                                                             │
│  Least Connections:                                         │
│  - Route to instance with fewest active connections        │
│  - Good for long-lived connections                         │
│  - Adapts to real-time load                                │
│                                                             │
│  Random:                                                    │
│  - Randomly select instance                                │
│  - Simple implementation                                   │
│  - Good for basic load distribution                        │
│                                                             │
│  Consistent Hashing:                                        │
│  - Hash-based instance selection                           │
│  - Good for session affinity                               │
│  - Minimal remapping on instance changes                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Service Discovery Tools

### 1. Consul

#### Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                    CONSUL ARCHITECTURE                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────┐  │
│  │   Consul    │    │   Consul    │    │   Consul        │  │
│  │   Server 1  │    │   Server 2  │    │   Server 3      │  │
│  │             │    │             │    │                 │  │
│  │ ┌─────────┐ │    │ ┌─────────┐ │    │ ┌─────────────┐ │  │
│  │ │Raft     │ │    │ │Raft     │ │    │ │Raft         │ │  │
│  │ │Leader   │ │    │ │Follower │ │    │ │Follower     │ │  │
│  │ └─────────┘ │    │ └─────────┘ │    │ └─────────────┘ │  │
│  │ ┌─────────┐ │    │ ┌─────────┐ │    │ ┌─────────────┐ │  │
│  │ │Service  │ │    │ │Service  │ │    │ │Service      │ │  │
│  │ │Catalog  │ │    │ │Catalog  │ │    │ │Catalog      │ │  │
│  │ └─────────┘ │    │ └─────────┘ │    │ └─────────────┘ │  │
│  └─────────────┘    └─────────────┘    └─────────────────┘  │
│         │                   │                   │           │
│         └───────────────────┼───────────────────┘           │
│                             │                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │            Consul Agents                            │    │
│  │                                                     │    │
│  │  - Service registration                             │    │
│  │  - Health checking                                  │    │
│  │  - DNS interface                                    │    │
│  │  - HTTP API                                         │    │
│  │  - Service discovery                                │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### Features
- **Service Discovery**: DNS and HTTP interfaces
- **Health Checking**: Multiple health check types
- **Key-Value Store**: Distributed configuration
- **Multi-Datacenter**: Cross-datacenter replication
- **ACL System**: Access control and security
- **Web UI**: Management interface

### 2. Eureka

#### Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                    EUREKA ARCHITECTURE                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────┐  │
│  │   Eureka    │    │   Eureka    │    │   Eureka        │  │
│  │   Server 1  │    │   Server 2  │    │   Server 3      │  │
│  │             │    │             │    │                 │  │
│  │ ┌─────────┐ │    │ ┌─────────┐ │    │ ┌─────────────┐ │  │
│  │ │Registry │ │    │ │Registry │ │    │ │Registry     │ │  │
│  │ │         │ │    │ │         │ │    │ │             │ │  │
│  │ │Service A│ │    │ │Service A│ │    │ │Service A    │ │  │
│  │ │Service B│ │    │ │Service B│ │    │ │Service B    │ │  │
│  │ │Service C│ │    │ │Service C│ │    │ │Service C    │ │  │
│  │ └─────────┘ │    │ └─────────┘ │    │ └─────────────┘ │  │
│  └─────────────┘    └─────────────┘    └─────────────────┘  │
│         │                   │                   │           │
│         └───────────────────┼───────────────────┘           │
│                             │                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │            Eureka Clients                          │    │
│  │                                                     │    │
│  │  - Service registration                             │    │
│  │  - Service discovery                                │    │
│  │  - Heartbeat                                        │    │
│  │  - Load balancing                                   │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### Features
- **Self-Preservation**: Handles network partitions
- **Client-Side Caching**: Reduces registry load
- **REST API**: Simple HTTP interface
- **Spring Integration**: Native Spring Boot support
- **Zone Awareness**: Multi-zone deployment support

### 3. etcd

#### Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                    ETCD ARCHITECTURE                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────┐  │
│  │   etcd      │    │   etcd      │    │   etcd          │  │
│  │   Node 1    │    │   Node 2    │    │   Node 3        │  │
│  │             │    │             │    │                 │  │
│  │ ┌─────────┐ │    │ ┌─────────┐ │    │ ┌─────────────┐ │  │
│  │ │Raft     │ │    │ │Raft     │ │    │ │Raft         │ │  │
│  │ │Leader   │ │    │ │Follower │ │    │ │Follower     │ │  │
│  │ └─────────┘ │    │ └─────────┘ │    │ └─────────────┘ │  │
│  │ ┌─────────┐ │    │ ┌─────────┐ │    │ ┌─────────────┐ │  │
│  │ │Key-Value│ │    │ │Key-Value│ │    │ │Key-Value    │ │  │
│  │ │Store    │ │    │ │Store    │ │    │ │Store        │ │  │
│  │ └─────────┘ │    │ └─────────┘ │    │ └─────────────┘ │  │
│  └─────────────┘    └─────────────┘    └─────────────────┘  │
│         │                   │                   │           │
│         └───────────────────┼───────────────────┘           │
│                             │                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │            etcd Clients                            │    │
│  │                                                     │    │
│  │  - Service registration                             │    │
│  │  - Service discovery                                │    │
│  │  - Configuration management                         │    │
│  │  - Distributed locking                              │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### Features
- **Distributed Key-Value Store**: Reliable data storage
- **Raft Consensus**: Strong consistency guarantees
- **Watch API**: Real-time change notifications
- **TTL Support**: Automatic key expiration
- **Authentication**: Built-in security features

## Best Practices

### Service Discovery Best Practices
```
┌─────────────────────────────────────────────────────────────┐
│                SERVICE DISCOVERY BEST PRACTICES            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Health Checking:                                        │
│  - Implement comprehensive health checks                    │
│  - Use multiple health check types                          │
│  - Set appropriate timeouts and intervals                   │
│  - Monitor health check metrics                             │
│                                                             │
│  2. Service Registration:                                   │
│  - Register services on startup                             │
│  - Implement graceful shutdown                              │
│  - Use unique instance identifiers                          │
│  - Include metadata for service identification              │
│                                                             │
│  3. Load Balancing:                                         │
│  - Choose appropriate load balancing algorithm              │
│  - Implement circuit breakers                              │
│  - Use retry logic with exponential backoff                 │
│  - Monitor load balancing metrics                           │
│                                                             │
│  4. Security:                                               │
│  - Use TLS for service communication                        │
│  - Implement authentication and authorization               │
│  - Use service mesh for advanced security                   │
│  - Monitor for security threats                             │
│                                                             │
│  5. Monitoring:                                             │
│  - Monitor service discovery metrics                        │
│  - Track service availability                               │
│  - Monitor registry performance                             │
│  - Set up alerts for failures                               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Implementation Guidelines
```
┌─────────────────────────────────────────────────────────────┐
│                IMPLEMENTATION GUIDELINES                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Start Simple:                                           │
│  - Begin with client-side discovery                         │
│  - Use DNS-based discovery for simple cases                 │
│  - Implement basic health checking                          │
│  - Add complexity gradually                                 │
│                                                             │
│  2. Choose the Right Tool:                                  │
│  - Consul for complex service mesh                          │
│  - Eureka for Spring Boot applications                      │
│  - etcd for Kubernetes environments                         │
│  - DNS for simple service discovery                         │
│                                                             │
│  3. Plan for Scale:                                         │
│  - Design for high availability                             │
│  - Implement caching strategies                             │
│  - Use multiple registry instances                          │
│  - Plan for cross-region deployment                        │
│                                                             │
│  4. Monitor and Alert:                                      │
│  - Set up comprehensive monitoring                          │
│  - Create alerts for critical failures                      │
│  - Track service discovery metrics                          │
│  - Monitor registry health                                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Conclusion

Service discovery is a fundamental component of modern distributed systems that enables dynamic, resilient communication between services. By understanding different discovery patterns and implementing appropriate solutions, you can build systems that scale effectively and handle failures gracefully. The key is to choose the right pattern for your specific use case and implement it with proper health checking, load balancing, and monitoring.

