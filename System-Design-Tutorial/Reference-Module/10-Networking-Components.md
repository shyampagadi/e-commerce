# Networking Components in System Design

## Overview

Networking forms the backbone of distributed systems, enabling communication between services, users, and data centers. Understanding networking components is essential for designing scalable, reliable, and secure systems.

```
┌─────────────────────────────────────────────────────────────┐
│                 NETWORKING COMPONENTS OVERVIEW               │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                   OSI MODEL LAYERS                      │ │
│  │                                                         │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │ L7: APPLICATION │ HTTP, HTTPS, DNS, SMTP            │ │ │
│  │  ├─────────────────┼─────────────────────────────────────┤ │ │
│  │  │ L6: PRESENTATION│ SSL/TLS, Encryption, Compression   │ │ │
│  │  ├─────────────────┼─────────────────────────────────────┤ │ │
│  │  │ L5: SESSION     │ Session Management, Authentication  │ │ │
│  │  ├─────────────────┼─────────────────────────────────────┤ │ │
│  │  │ L4: TRANSPORT   │ TCP, UDP, Port Numbers             │ │ │
│  │  ├─────────────────┼─────────────────────────────────────┤ │ │
│  │  │ L3: NETWORK     │ IP, Routing, Subnets               │ │ │
│  │  ├─────────────────┼─────────────────────────────────────┤ │ │
│  │  │ L2: DATA LINK   │ Ethernet, MAC Addresses, Switches  │ │ │
│  │  ├─────────────────┼─────────────────────────────────────┤ │ │
│  │  │ L1: PHYSICAL    │ Cables, Fiber, Radio Waves         │ │ │
│  │  └─────────────────┴─────────────────────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                 TCP vs UDP COMPARISON                   │ │
│  │                                                         │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │                     TCP                             │ │ │
│  │  │                                                     │ │ │
│  │  │  Client ──── SYN ────▶ Server                      │ │ │
│  │  │  Client ◀─ SYN-ACK ─── Server                      │ │ │
│  │  │  Client ──── ACK ────▶ Server                      │ │ │
│  │  │  Client ◀──── Data ─── Server                      │ │ │
│  │  │  Client ──── ACK ────▶ Server                      │ │ │
│  │  │                                                     │ │ │
│  │  │  • Reliable delivery                                │ │ │
│  │  │  • Ordered packets                                  │ │ │
│  │  │  • Connection-oriented                              │ │ │
│  │  │  • Error detection & correction                     │ │ │
│  │  │  • Flow control                                     │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  │                                                         │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │                     UDP                             │ │ │
│  │  │                                                     │ │ │
│  │  │  Client ──── Data ────▶ Server                     │ │ │
│  │  │  Client ──── Data ────▶ Server                     │ │ │
│  │  │  Client ──── Data ────▶ Server                     │ │ │
│  │  │                                                     │ │ │
│  │  │  • Fast transmission                                │ │ │
│  │  │  • No connection setup                              │ │ │
│  │  │  • No delivery guarantee                            │ │ │
│  │  │  • Lower overhead                                   │ │ │
│  │  │  • Suitable for real-time                          │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                 NETWORK TOPOLOGY                        │ │
│  │                                                         │ │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐ │ │
│  │  │   CLIENT    │    │   INTERNET  │    │   SERVER    │ │ │
│  │  │             │    │             │    │             │ │ │
│  │  │ • Browser   │───▶│ • Routers   │───▶│ • Web App   │ │ │
│  │  │ • Mobile    │    │ • ISPs      │    │ • Database  │ │ │
│  │  │ • Desktop   │    │ • CDN       │    │ • Cache     │ │ │
│  │  └─────────────┘    └─────────────┘    └─────────────┘ │ │
│  │         │                   │                   │      │ │
│  │         ▼                   ▼                   ▼      │ │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐ │ │
│  │  │   LOCAL     │    │   WIDE      │    │   DATA      │ │ │
│  │  │  NETWORK    │    │  AREA       │    │  CENTER     │ │ │
│  │  │             │    │  NETWORK    │    │             │ │ │
│  │  │ • WiFi      │    │ • Fiber     │    │ • LAN       │ │ │
│  │  │ • Ethernet  │    │ • Satellite │    │ • Switches  │ │ │
│  │  │ • Cellular  │    │ • Cable     │    │ • Firewalls │ │ │
│  │  └─────────────┘    └─────────────┘    └─────────────┘ │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Table of Contents
- [Networking Fundamentals](#networking-fundamentals)
- [Load Balancing Strategies](#load-balancing-strategies)
- [Service Discovery Patterns](#service-discovery-patterns)
- [Network Security](#network-security)
- [AWS Networking Services](#aws-networking-services)
- [Performance Optimization](#performance-optimization)
- [Common Patterns and Use Cases](#common-patterns-and-use-cases)
- [Best Practices](#best-practices)

## Networking Fundamentals

### The OSI Model in Practice

Understanding how data flows through network layers helps in troubleshooting and optimizing system performance.

#### Layer 4 (Transport Layer) - TCP vs UDP
**TCP (Transmission Control Protocol):**
- **Characteristics**: Reliable, ordered, connection-oriented
- **Use Cases**: Web traffic (HTTP/HTTPS), database connections, file transfers
- **Trade-offs**: Higher overhead but guaranteed delivery
- **Example**: When a user loads a web page, TCP ensures all HTML, CSS, and JavaScript files arrive completely and in order

**UDP (User Datagram Protocol):**
- **Characteristics**: Fast, connectionless, no delivery guarantees
- **Use Cases**: Real-time gaming, video streaming, DNS queries
- **Trade-offs**: Lower latency but potential data loss
- **Example**: Online gaming where a missed packet is less important than low latency

#### Layer 7 (Application Layer) - HTTP/HTTPS
**HTTP/1.1 vs HTTP/2 vs HTTP/3:**
```
HTTP/1.1:
- One request per connection
- Head-of-line blocking issues
- Text-based protocol

HTTP/2:
- Multiple requests per connection (multiplexing)
- Binary protocol for efficiency
- Server push capabilities

HTTP/3:
- Built on UDP (QUIC protocol)
- Eliminates head-of-line blocking
- Better performance on unreliable networks
```

### Network Topologies and Patterns

#### Hub and Spoke Architecture
**Traditional Enterprise Pattern:**
- Central hub connects to multiple spoke networks
- All traffic flows through the hub
- Simple routing but potential bottleneck at hub
- **Example**: Corporate headquarters (hub) connecting to branch offices (spokes)

#### Mesh Networking
**Modern Distributed Pattern:**
- Every node connects to multiple other nodes
- No single point of failure
- Complex routing but high resilience
- **Example**: Microservices architecture where services communicate directly

#### Content Delivery Networks (CDN)
**Global Distribution Pattern:**
- Content cached at edge locations worldwide
- Users served from nearest geographic location
- Reduces latency and origin server load
- **Example**: Netflix streaming movies from local edge servers

## Load Balancing Strategies

```
┌─────────────────────────────────────────────────────────────┐
│                 LOAD BALANCING ALGORITHMS                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                   ROUND ROBIN                           │ │
│  │                                                         │ │
│  │  ┌─────────────┐    ┌─────────────┐                    │ │
│  │  │   CLIENT    │    │LOAD BALANCER│                    │ │
│  │  │             │    │             │                    │ │
│  │  │ Request 1   │───▶│ Counter: 1  │───┐                │ │
│  │  │ Request 2   │───▶│ Counter: 2  │───┼─┐              │ │
│  │  │ Request 3   │───▶│ Counter: 3  │───┼─┼─┐            │ │
│  │  │ Request 4   │───▶│ Counter: 1  │───┼─┼─┼─┐          │ │
│  │  └─────────────┘    └─────────────┘   │ │ │ │          │ │
│  │                                       ▼ ▼ ▼ ▼          │ │
│  │                    ┌──────────┐ ┌──────────┐ ┌──────────┐│ │
│  │                    │SERVER 1  │ │SERVER 2  │ │SERVER 3  ││ │
│  │                    │          │ │          │ │          ││ │
│  │                    │Request 1 │ │Request 2 │ │Request 3 ││ │
│  │                    │Request 4 │ │          │ │          ││ │
│  │                    └──────────┘ └──────────┘ └──────────┘│ │
│  │                                                         │ │
│  │  Best For: Equal server capacity, uniform requests      │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                 WEIGHTED ROUND ROBIN                    │ │
│  │                                                         │ │
│  │  ┌─────────────┐    ┌─────────────┐                    │ │
│  │  │   CLIENT    │    │LOAD BALANCER│                    │ │
│  │  │             │    │             │                    │ │
│  │  │ Request 1   │───▶│Weight Logic │───┐                │ │
│  │  │ Request 2   │───▶│S1:3, S2:2   │───┼─┐              │ │
│  │  │ Request 3   │───▶│S3:1         │───┼─┼─┐            │ │
│  │  │ Request 4   │───▶│             │───┼─┼─┼─┐          │ │
│  │  │ Request 5   │───▶│             │───┼─┼─┼─┼─┐        │ │
│  │  └─────────────┘    └─────────────┘   │ │ │ │ │        │ │
│  │                                       ▼ ▼ ▼ ▼ ▼        │ │
│  │                    ┌──────────┐ ┌──────────┐ ┌──────────┐│ │
│  │                    │SERVER 1  │ │SERVER 2  │ │SERVER 3  ││ │
│  │                    │Weight: 3 │ │Weight: 2 │ │Weight: 1 ││ │
│  │                    │Req 1,2,4 │ │Req 3,5   │ │          ││ │
│  │                    │High Spec │ │Med Spec  │ │Low Spec  ││ │
│  │                    └──────────┘ └──────────┘ └──────────┘│ │
│  │                                                         │ │
│  │  Best For: Different server capacities                  │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                 LEAST CONNECTIONS                       │ │
│  │                                                         │ │
│  │  ┌─────────────┐    ┌─────────────┐                    │ │
│  │  │   CLIENT    │    │LOAD BALANCER│                    │ │
│  │  │             │    │             │                    │ │
│  │  │ New Request │───▶│ Check Active│                    │ │
│  │  │             │    │ Connections │                    │ │
│  │  │             │    │ Route to    │                    │ │
│  │  │             │    │ Least Busy  │                    │ │
│  │  └─────────────┘    └─────────────┘                    │ │
│  │                                                         │ │
│  │                    ┌──────────┐ ┌──────────┐ ┌──────────┐│ │
│  │                    │SERVER 1  │ │SERVER 2  │ │SERVER 3  ││ │
│  │                    │          │ │          │ │          ││ │
│  │                    │Active: 5 │ │Active: 2 │ │Active: 8 ││ │
│  │                    │          │ │   ◀──    │ │          ││ │
│  │                    │          │ │ Selected │ │          ││ │
│  │                    └──────────┘ └──────────┘ └──────────┘│ │
│  │                                                         │ │
│  │  Best For: Long-lived connections, varying request times│ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                    IP HASH                              │ │
│  │                                                         │ │
│  │  ┌─────────────┐    ┌─────────────┐                    │ │
│  │  │   CLIENT    │    │LOAD BALANCER│                    │ │
│  │  │             │    │             │                    │ │
│  │  │IP: 1.2.3.4  │───▶│Hash(1.2.3.4)│                   │ │
│  │  │             │    │   % 3 = 1   │                    │ │
│  │  │             │    │ Always      │                    │ │
│  │  │             │    │ Server 2    │                    │ │
│  │  └─────────────┘    └─────────────┘                    │ │
│  │                                       │                │ │
│  │                                       ▼                │ │
│  │                    ┌──────────┐ ┌──────────┐ ┌──────────┐│ │
│  │                    │SERVER 1  │ │SERVER 2  │ │SERVER 3  ││ │
│  │                    │          │ │    ◀──   │ │          ││ │
│  │                    │          │ │ Sticky   │ │          ││ │
│  │                    │          │ │ Session  │ │          ││ │
│  │                    └──────────┘ └──────────┘ └──────────┘│ │
│  │                                                         │ │
│  │  Best For: Session affinity, stateful applications     │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Load Balancing Algorithms

#### Round Robin
**How it works:** Requests distributed sequentially across available servers
**Best for:** Servers with similar capacity and uniform request processing times
**Example Scenario:**
```
3 web servers handling user login requests:
Request 1 → Server A
Request 2 → Server B  
Request 3 → Server C
Request 4 → Server A (cycle repeats)
```

#### Weighted Round Robin
**How it works:** Servers assigned weights based on capacity, more requests go to higher-weighted servers
**Best for:** Servers with different capacities or performance characteristics
**Example Scenario:**
```
Mixed server environment:
- Server A (high-end): Weight 3
- Server B (medium): Weight 2  
- Server C (basic): Weight 1

Distribution pattern: A, A, A, B, B, C (repeats)
```

#### Least Connections
**How it works:** New requests sent to server with fewest active connections
**Best for:** Applications with varying request processing times
**Example Scenario:**
```
Database connection pooling:
- Server A: 5 active connections
- Server B: 8 active connections
- Server C: 3 active connections
→ Next request goes to Server C
```

#### IP Hash
**How it works:** Client IP address hashed to determine server assignment
**Best for:** Applications requiring session affinity (sticky sessions)
**Example Scenario:**
```
E-commerce shopping cart:
- User IP 192.168.1.100 always routes to Server A
- Maintains shopping cart state without shared storage
- Consistent user experience across requests
```

### Load Balancer Types

#### Layer 4 (Network) Load Balancers
**Characteristics:**
- Operates at transport layer (TCP/UDP)
- Routes based on IP address and port
- High performance, low latency
- Protocol agnostic

**Use Cases:**
- High-throughput applications
- Non-HTTP protocols (databases, gaming)
- Simple routing requirements
- **Example**: Distributing database connections across read replicas

#### Layer 7 (Application) Load Balancers
**Characteristics:**
- Operates at application layer (HTTP/HTTPS)
- Routes based on content (headers, URLs, cookies)
- Advanced features (SSL termination, compression)
- Higher latency but more intelligent routing

**Use Cases:**
- Web applications with complex routing
- Microservices architectures
- A/B testing and canary deployments
- **Example**: Routing /api/users to user service, /api/orders to order service

### Health Checks and Failover

#### Health Check Strategies
**Passive Health Checks:**
- Monitor actual request success/failure rates
- Mark servers unhealthy based on error responses
- No additional network overhead
- **Example**: Mark server unhealthy after 3 consecutive 500 errors

**Active Health Checks:**
- Periodic probes to dedicated health endpoints
- Proactive detection of server issues
- Additional network overhead but faster detection
- **Example**: HTTP GET /health every 30 seconds

#### Failover Patterns
**Immediate Failover:**
- Instantly remove unhealthy servers from rotation
- Fast response to failures
- Risk of false positives during temporary issues

**Graceful Failover:**
- Gradually reduce traffic to unhealthy servers
- Allow time for recovery
- Better for transient issues

## Service Discovery Patterns

### Service Discovery Fundamentals

Service discovery solves the problem of how services find and communicate with each other in dynamic environments where IP addresses and ports change frequently.

```
┌─────────────────────────────────────────────────────────────┐
│                 SERVICE DISCOVERY PATTERNS                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              CLIENT-SIDE DISCOVERY                      │ │
│  │                                                         │ │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐ │ │
│  │  │   CLIENT    │    │  SERVICE    │    │  SERVICE    │ │ │
│  │  │  SERVICE    │    │  REGISTRY   │    │ INSTANCES   │ │ │
│  │  │             │    │             │    │             │ │ │
│  │  │ 1. Query    │───▶│ 2. Return   │    │ ┌─────────┐ │ │ │
│  │  │ "user-svc"  │    │ Instance    │    │ │Instance │ │ │ │
│  │  │             │◀───│ List        │    │ │   A     │ │ │ │
│  │  │             │    │             │    │ │10.0.1.5 │ │ │ │
│  │  │ 3. Load     │    │ • Consul    │    │ └─────────┘ │ │ │
│  │  │ Balance &   │    │ • Eureka    │    │ ┌─────────┐ │ │ │
│  │  │ Call Direct │    │ • Zookeeper │    │ │Instance │ │ │ │
│  │  │             │    │             │    │ │   B     │ │ │ │
│  │  │ 4. Direct   │─────────────────────▶│ │10.0.1.6 │ │ │ │
│  │  │ Request     │    │             │    │ └─────────┘ │ │ │
│  │  └─────────────┘    └─────────────┘    └─────────────┘ │ │
│  │                                                         │ │
│  │  Pros: Simple, No proxy  │  Cons: Client complexity     │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              SERVER-SIDE DISCOVERY                      │ │
│  │                                                         │ │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐ │ │
│  │  │   CLIENT    │    │LOAD BALANCER│    │  SERVICE    │ │ │
│  │  │  SERVICE    │    │   + ROUTER  │    │ INSTANCES   │ │ │
│  │  │             │    │             │    │             │ │ │
│  │  │ 1. Request  │───▶│ 2. Query    │───▶│ ┌─────────┐ │ │ │
│  │  │ "user-svc"  │    │ Registry    │    │ │Instance │ │ │ │
│  │  │             │    │             │    │ │   A     │ │ │ │
│  │  │             │    │ 3. Route    │    │ │10.0.1.5 │ │ │ │
│  │  │             │    │ Request     │    │ └─────────┘ │ │ │
│  │  │             │◀───│             │    │ ┌─────────┐ │ │ │
│  │  │ 4. Response │    │ • AWS ALB   │    │ │Instance │ │ │ │
│  │  │             │    │ • Nginx     │    │ │   B     │ │ │ │
│  │  │             │    │ • HAProxy   │    │ │10.0.1.6 │ │ │ │
│  │  │             │    │ • Envoy     │    │ └─────────┘ │ │ │
│  │  └─────────────┘    └─────────────┘    └─────────────┘ │ │
│  │                            │                           │ │
│  │                            ▼                           │ │
│  │                    ┌─────────────┐                     │ │
│  │                    │  SERVICE    │                     │ │
│  │                    │  REGISTRY   │                     │ │
│  │                    │             │                     │ │
│  │                    │ • Consul    │                     │ │
│  │                    │ • Eureka    │                     │ │
│  │                    │ • Kubernetes│                     │ │
│  │                    └─────────────┘                     │ │
│  │                                                         │ │
│  │  Pros: Simple clients  │  Cons: Additional network hop  │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                SERVICE MESH DISCOVERY                   │ │
│  │                                                         │ │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐ │ │
│  │  │  SERVICE A  │    │   SERVICE   │    │  SERVICE B  │ │ │
│  │  │             │    │    MESH     │    │             │ │ │
│  │  │ ┌─────────┐ │    │             │    │ ┌─────────┐ │ │ │
│  │  │ │ Sidecar │ │    │ ┌─────────┐ │    │ │ Sidecar │ │ │ │
│  │  │ │ Proxy   │ │───▶│ │Control  │ │◀───│ │ Proxy   │ │ │ │
│  │  │ │ (Envoy) │ │    │ │ Plane   │ │    │ │ (Envoy) │ │ │ │
│  │  │ └─────────┘ │    │ │         │ │    │ └─────────┘ │ │ │
│  │  │     │       │    │ │• Istio  │ │    │     │       │ │ │
│  │  │     ▼       │    │ │• Linkerd│ │    │     ▼       │ │ │
│  │  │ App Logic   │    │ │• Consul │ │    │ App Logic   │ │ │
│  │  └─────────────┘    │ └─────────┘ │    └─────────────┘ │ │
│  │                     └─────────────┘                    │ │
│  │                                                         │ │
│  │  Features:                                              │ │
│  │  • Automatic service discovery                          │ │
│  │  • Load balancing                                       │ │
│  │  • Circuit breaking                                     │ │
│  │  • Observability                                        │ │
│  │  • Security (mTLS)                                      │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### The Service Discovery Problem
**Traditional Static Environment:**
```
Web App connects to Database:
- Database IP: 192.168.1.100 (never changes)
- Database Port: 5432 (fixed)
- Configuration: Hard-coded in application
```

**Modern Dynamic Environment:**
```
Microservices in containers:
- User Service: IP changes on each deployment
- Order Service: Multiple instances with different IPs
- Payment Service: Auto-scales, instances come and go
- Problem: How do services find each other?
```

### Service Discovery Patterns

#### Client-Side Discovery
**How it works:**
1. Service instances register with service registry
2. Clients query registry to find available instances
3. Clients implement load balancing logic
4. Clients make direct requests to service instances

**Example: Netflix Eureka Pattern**
```
Order Service startup:
1. Registers itself with Eureka: "order-service" at 10.0.1.15:8080
2. User Service needs to call Order Service
3. Queries Eureka: "Where is order-service?"
4. Receives list: [10.0.1.15:8080, 10.0.1.16:8080]
5. Implements client-side load balancing
6. Makes direct call to chosen instance
```

**Advantages:**
- Simple architecture
- Clients have full control over load balancing
- No additional network hops

**Disadvantages:**
- Clients must implement discovery logic
- Tight coupling between clients and registry
- Language-specific client libraries needed

#### Server-Side Discovery
**How it works:**
1. Clients make requests to load balancer
2. Load balancer queries service registry
3. Load balancer routes requests to available instances
4. Service instances register/deregister with registry

**Example: AWS Application Load Balancer Pattern**
```
API Gateway pattern:
1. Services register with internal registry
2. Load balancer maintains current service locations
3. Clients call load balancer endpoint
4. Load balancer routes to healthy service instances
5. Clients unaware of individual service locations
```

**Advantages:**
- Clients simplified (no discovery logic needed)
- Centralized load balancing and routing
- Language agnostic

**Disadvantages:**
- Additional network hop
- Load balancer becomes potential bottleneck
- More complex infrastructure

### Service Registry Patterns

#### Self-Registration Pattern
**How it works:** Services register themselves with the registry on startup and deregister on shutdown

**Example Implementation:**
```
Service Startup Process:
1. Application starts on port 8080
2. Performs health check on itself
3. Registers with registry: POST /registry/services
   {
     "name": "user-service",
     "address": "10.0.1.20",
     "port": 8080,
     "health_check": "/health"
   }
4. Sends periodic heartbeats to maintain registration
5. Deregisters on graceful shutdown
```

#### Third-Party Registration Pattern
**How it works:** External registrar monitors services and manages registry entries

**Example: Kubernetes Pattern**
```
Kubernetes Service Discovery:
1. Deploy service with Kubernetes manifest
2. Kubernetes creates service endpoints automatically
3. Kubernetes DNS provides service name resolution
4. Services discover each other via DNS names
5. Kubernetes handles registration/deregistration automatically
```

## Network Security

### Security Layers

#### Network Segmentation
**Virtual Private Clouds (VPCs):**
- Isolated network environments in cloud
- Control traffic flow between subnets
- Separate production, staging, and development environments
- **Example**: E-commerce VPC with separate subnets for web tier, application tier, and database tier

#### Security Groups and NACLs
**Security Groups (Stateful):**
- Instance-level firewalls
- Allow rules only (default deny)
- Stateful (return traffic automatically allowed)
- **Example**: Web server security group allows HTTP (80) and HTTPS (443) inbound

**Network ACLs (Stateless):**
- Subnet-level firewalls
- Both allow and deny rules
- Stateless (must explicitly allow return traffic)
- **Example**: Database subnet NACL denies all internet traffic

### Zero Trust Networking

#### Principles of Zero Trust
1. **Never Trust, Always Verify**: Authenticate and authorize every connection
2. **Least Privilege Access**: Grant minimum necessary permissions
3. **Assume Breach**: Design assuming network is already compromised
4. **Verify Explicitly**: Use multiple factors for authentication

#### Implementation Example
**Microservices Zero Trust:**
```
Service-to-Service Communication:
1. Each service has unique identity (certificate)
2. All communication encrypted (mTLS)
3. Authorization policies enforce access rules
4. Network traffic monitored and logged
5. No implicit trust based on network location
```

## AWS Networking Services

### Amazon VPC (Virtual Private Cloud)

#### VPC Design Patterns

**Single-Tier Architecture:**
- All resources in public subnets
- Direct internet access for all components
- Simple but less secure
- **Use Case**: Simple web applications, development environments

**Multi-Tier Architecture:**
- Web tier: Public subnets (internet-facing)
- Application tier: Private subnets (internal only)
- Database tier: Private subnets (most restricted)
- **Use Case**: Production web applications, enterprise systems

**Hub and Spoke VPC:**
- Central hub VPC for shared services
- Spoke VPCs for individual applications/teams
- VPC peering or Transit Gateway for connectivity
- **Use Case**: Large organizations with multiple teams/applications

### Elastic Load Balancing (ELB)

#### Application Load Balancer (ALB)
**Key Features:**
- Layer 7 load balancing (HTTP/HTTPS)
- Content-based routing (path, host, headers)
- WebSocket and HTTP/2 support
- Integration with AWS services (ECS, Lambda)

**Routing Examples:**
```
Path-based routing:
- /api/users/* → User Service Target Group
- /api/orders/* → Order Service Target Group
- /static/* → S3 Static Content

Host-based routing:
- api.example.com → API Target Group
- admin.example.com → Admin Target Group
- www.example.com → Web Target Group
```

#### Network Load Balancer (NLB)
**Key Features:**
- Layer 4 load balancing (TCP/UDP)
- Ultra-high performance (millions of requests/second)
- Static IP addresses
- Preserve source IP addresses

**Use Cases:**
- High-performance applications
- Non-HTTP protocols
- Gaming applications
- IoT device communication

### Amazon Route 53

#### DNS Routing Policies

**Simple Routing:**
- Single resource record
- No health checks
- **Example**: www.example.com → 203.0.113.12

**Weighted Routing:**
- Distribute traffic across multiple resources
- Useful for A/B testing and gradual rollouts
- **Example**: 80% traffic to new version, 20% to old version

**Latency-Based Routing:**
- Route to lowest latency endpoint
- Improves user experience globally
- **Example**: US users → US-East region, EU users → EU-West region

**Geolocation Routing:**
- Route based on user's geographic location
- Compliance and content localization
- **Example**: EU users → EU data center (GDPR compliance)

**Failover Routing:**
- Active-passive failover configuration
- Automatic failover to backup resources
- **Example**: Primary site fails → Route to disaster recovery site

## Performance Optimization

### Network Performance Factors

#### Latency Optimization
**Geographic Distribution:**
- Place resources close to users
- Use CDNs for static content
- Multi-region deployments for global applications

**Connection Optimization:**
- HTTP/2 for multiplexing
- Connection pooling and keep-alive
- Reduce DNS lookup times

#### Bandwidth Optimization
**Content Optimization:**
- Compress responses (gzip, brotli)
- Optimize images and media
- Minify CSS and JavaScript

**Caching Strategies:**
- Browser caching for static assets
- CDN caching for global distribution
- Application-level caching for dynamic content

### Monitoring and Troubleshooting

#### Key Network Metrics
**Latency Metrics:**
- Round-trip time (RTT)
- Time to first byte (TTFB)
- DNS resolution time
- SSL handshake time

**Throughput Metrics:**
- Requests per second
- Bytes transferred per second
- Connection establishment rate
- Error rates and timeouts

#### Common Network Issues
**High Latency:**
- **Causes**: Geographic distance, network congestion, DNS issues
- **Solutions**: CDN deployment, DNS optimization, route optimization

**Packet Loss:**
- **Causes**: Network congestion, hardware issues, misconfigurations
- **Solutions**: Quality of Service (QoS), redundant paths, monitoring

**Connection Timeouts:**
- **Causes**: Overloaded servers, network partitions, firewall issues
- **Solutions**: Connection pooling, retry logic, health checks

## Common Patterns and Use Cases

### Microservices Networking

#### Service Mesh Architecture
**What is a Service Mesh:**
- Infrastructure layer for service-to-service communication
- Handles routing, load balancing, security, observability
- Decouples networking concerns from application code

**Service Mesh Benefits:**
```
Without Service Mesh:
- Each service implements networking logic
- Inconsistent security and monitoring
- Difficult to manage at scale

With Service Mesh:
- Centralized networking policies
- Consistent security (mTLS everywhere)
- Unified observability and monitoring
- Language-agnostic implementation
```

#### API Gateway Pattern
**Centralized Entry Point:**
- Single entry point for all client requests
- Handles authentication, rate limiting, routing
- Protocol translation and request/response transformation

**API Gateway Responsibilities:**
```
Client Request Flow:
1. Client → API Gateway (authentication)
2. API Gateway → Rate Limiting Check
3. API Gateway → Request Routing
4. API Gateway → Backend Service
5. Backend Service → API Gateway (response)
6. API Gateway → Response Transformation
7. API Gateway → Client (final response)
```

### Global Distribution Patterns

#### Multi-Region Architecture
**Active-Active Configuration:**
- Multiple regions serve traffic simultaneously
- Load distributed geographically
- Complex data synchronization requirements
- **Example**: Global e-commerce platform serving all regions

**Active-Passive Configuration:**
- Primary region serves all traffic
- Secondary region for disaster recovery
- Simpler data consistency
- **Example**: Financial system with strict consistency requirements

#### Edge Computing
**Edge Deployment Benefits:**
- Reduced latency for end users
- Decreased bandwidth usage
- Improved reliability and availability
- Local data processing capabilities

**Edge Use Cases:**
- IoT data processing
- Real-time gaming
- Augmented/Virtual Reality
- Content personalization

## Best Practices

```
┌─────────────────────────────────────────────────────────────┐
│              NETWORKING BEST PRACTICES FRAMEWORK            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                 DESIGN PRINCIPLES                       │ │
│  │                                                         │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │ │
│  │  │PLAN FOR     │  │ SECURITY    │  │PERFORMANCE  │     │ │
│  │  │FAILURE      │  │ BY DESIGN   │  │OPTIMIZATION │     │ │
│  │  │             │  │             │  │             │     │ │
│  │  │ ┌─────────┐ │  │ ┌─────────┐ │  │ ┌─────────┐ │     │ │
│  │  │ │Multi-AZ │ │  │ │Defense  │ │  │ │Caching  │ │     │ │
│  │  │ │Redundancy│ │  │ │in Depth │ │  │ │Strategy │ │     │ │
│  │  │ └─────────┘ │  │ └─────────┘ │  │ └─────────┘ │     │ │
│  │  │ ┌─────────┐ │  │ ┌─────────┐ │  │ ┌─────────┐ │     │ │
│  │  │ │Circuit  │ │  │ │Network  │ │  │ │CDN      │ │     │ │
│  │  │ │Breakers │ │  │ │Segmentaion│ │ │ │Global   │ │     │ │
│  │  │ └─────────┘ │  │ └─────────┘ │  │ └─────────┘ │     │ │
│  │  │ ┌─────────┐ │  │ ┌─────────┐ │  │ ┌─────────┐ │     │ │
│  │  │ │Graceful │ │  │ │Least    │ │  │ │Connection│ │     │ │
│  │  │ │Degradation│ │ │ │Privilege│ │  │ │Pooling  │ │     │ │
│  │  │ └─────────┘ │  │ └─────────┘ │  │ └─────────┘ │     │ │
│  │  └─────────────┘  └─────────────┘  └─────────────┘     │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              IMPLEMENTATION MATURITY MODEL               │ │
│  │                                                         │ │
│  │  Level 1: Basic                                         │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │ • Single Load Balancer                              │ │ │
│  │  │ • Basic Security Groups                             │ │ │
│  │  │ • Manual Configuration                              │ │ │
│  │  │ • Simple Monitoring                                 │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  │                           │                             │ │
│  │                           ▼                             │ │
│  │  Level 2: Intermediate                                  │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │ • Multi-AZ Load Balancing                           │ │ │
│  │  │ • VPC with Subnets                                  │ │ │
│  │  │ • Infrastructure as Code                            │ │ │
│  │  │ • Automated Deployments                             │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  │                           │                             │ │
│  │                           ▼                             │ │
│  │  Level 3: Advanced                                      │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │ • Global Load Balancing                             │ │ │
│  │  │ • Service Mesh                                      │ │ │
│  │  │ • Zero-Trust Networking                             │ │ │
│  │  │ • AI-Powered Optimization                           │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              NETWORKING ARCHITECTURE STACK              │ │
│  │                                                         │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │                APPLICATION LAYER                    │ │ │
│  │  │                                                     │ │ │
│  │  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │ │ │
│  │  │  │   API       │  │ SERVICE     │  │   MICRO     │ │ │ │
│  │  │  │ GATEWAY     │  │ MESH        │  │ SERVICES    │ │ │ │
│  │  │  └─────────────┘  └─────────────┘  └─────────────┘ │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  │                           │                             │ │
│  │                           ▼                             │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │                LOAD BALANCING LAYER                 │ │ │
│  │  │                                                     │ │ │
│  │  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │ │ │
│  │  │  │APPLICATION  │  │  NETWORK    │  │   GLOBAL    │ │ │ │
│  │  │  │LOAD BALANCER│  │LOAD BALANCER│  │LOAD BALANCER│ │ │ │
│  │  │  └─────────────┘  └─────────────┘  └─────────────┘ │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  │                           │                             │ │
│  │                           ▼                             │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │                NETWORK LAYER                        │ │ │
│  │  │                                                     │ │ │
│  │  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │ │ │
│  │  │  │    VPC      │  │   SUBNETS   │  │   ROUTING   │ │ │ │
│  │  │  │ ISOLATION   │  │  PUBLIC/    │  │   TABLES    │ │ │ │
│  │  │  │             │  │  PRIVATE    │  │             │ │ │ │
│  │  │  └─────────────┘  └─────────────┘  └─────────────┘ │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  │                           │                             │ │
│  │                           ▼                             │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │                SECURITY LAYER                       │ │ │
│  │  │                                                     │ │ │
│  │  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │ │ │
│  │  │  │ SECURITY    │  │   NACLs     │  │    WAF      │ │ │ │
│  │  │  │  GROUPS     │  │ NETWORK     │  │ WEB APP     │ │ │ │
│  │  │  │             │  │ ACCESS      │  │ FIREWALL    │ │ │ │
│  │  │  └─────────────┘  └─────────────┘  └─────────────┘ │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Design Principles

#### 1. Plan for Failure
- **Redundancy**: Multiple availability zones and regions
- **Graceful Degradation**: System continues operating with reduced functionality
- **Circuit Breakers**: Prevent cascade failures
- **Timeout and Retry Logic**: Handle transient failures

#### 2. Security by Design
- **Defense in Depth**: Multiple security layers
- **Principle of Least Privilege**: Minimum necessary access
- **Network Segmentation**: Isolate critical components
- **Encryption Everywhere**: Data in transit and at rest

#### 3. Performance Optimization
- **Caching Strategy**: Multiple levels of caching
- **Content Delivery**: Global distribution of content
- **Connection Management**: Pooling and reuse
- **Monitoring and Alerting**: Proactive issue detection

### Implementation Guidelines

#### 1. Start Simple, Scale Complexity
- Begin with basic load balancing
- Add advanced features as needed
- Monitor performance and adjust
- Document architectural decisions

#### 2. Automate Operations
- Infrastructure as Code (IaC)
- Automated deployment pipelines
- Self-healing systems
- Comprehensive monitoring

#### 3. Plan for Growth
- Scalable architecture patterns
- Capacity planning and forecasting
- Performance testing under load
- Cost optimization strategies

This comprehensive guide provides the foundation for understanding and implementing networking components in modern distributed systems. The key is to start with solid fundamentals and evolve your networking architecture as your system grows and requirements change.
## Decision Matrix

```
┌─────────────────────────────────────────────────────────────┐
│             NETWORKING COMPONENTS DECISION MATRIX           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              LOAD BALANCER TYPES                        │ │
│  │                                                         │ │
│  │  Type        │Layer    │Features  │Performance│Use Case │ │
│  │  ──────────  │────────│─────────│──────────│────────  │ │
│  │  ALB         │ Layer 7 │ ✅ Rich  │ ✅ High   │HTTP/S   │ │
│  │  NLB         │ Layer 4 │ ⚠️ Basic │ ✅ Ultra  │TCP/UDP  │ │
│  │  CLB         │ Layer 4/7│⚠️ Legacy│ ⚠️ Medium │Legacy   │ │
│  │  GLB         │ Layer 3 │ ⚠️ Special│✅ High   │Gateway  │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              CONTENT DELIVERY                           │ │
│  │                                                         │ │
│  │  Solution    │Latency   │Cost     │Features  │Use Case │ │
│  │  ──────────  │─────────│────────│─────────│────────  │ │
│  │  CloudFront  │ ✅ Low   │ ⚠️ Med  │ ✅ Rich  │Global   │ │
│  │  S3 Transfer │ ⚠️ Medium│ ✅ Low  │ ⚠️ Basic │Simple   │ │
│  │  Direct      │ ❌ High  │ ✅ Low  │ ❌ None  │Internal │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              DNS ROUTING                                │ │
│  │                                                         │ │
│  │  Strategy    │Complexity│Reliability│Performance│Use Case│ │
│  │  ──────────  │─────────│──────────│──────────│───────│ │
│  │  Simple      │ ✅ Low   │ ⚠️ Basic  │ ✅ Fast   │Basic  │ │
│  │  Weighted    │ ⚠️ Medium│ ✅ Good   │ ✅ Fast   │A/B Test│ │
│  │  Geolocation │ ❌ High  │ ✅ Good   │ ✅ Fast   │Global │ │
│  │  Health Check│ ❌ High  │ ✅ High   │ ⚠️ Medium │HA     │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Selection Guidelines

**Choose ALB When:**
- HTTP/HTTPS applications
- Advanced routing needed
- SSL termination required
- Microservices architecture

**Choose NLB When:**
- Ultra-high performance needed
- TCP/UDP protocols
- Static IP addresses required
- Extreme low latency critical

**Choose CloudFront When:**
- Global content delivery
- Static asset optimization
- API acceleration needed
- Edge computing requirements
