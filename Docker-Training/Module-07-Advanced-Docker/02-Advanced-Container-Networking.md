# Advanced Container Networking - From Basic Networks to Enterprise Architecture

## 📋 Learning Objectives
- **Understand** enterprise networking challenges and solutions for containerized applications
- **Master** advanced Docker networking patterns beyond basic bridge networks
- **Apply** enterprise networking concepts to secure your e-commerce platform
- **Build** scalable, secure network architectures for production environments

---

## 🤔 Why Advanced Container Networking Matters

### **The Problem: Basic Networking Limitations**

After Module 5, your e-commerce platform uses basic Docker Compose networking:
```yaml
# Basic networking (what you have now)
version: '3.8'
services:
  frontend:
    build: ./frontend
    ports:
      - "3000:3000"
  
  backend:
    build: ./backend
    ports:
      - "8000:8000"
  
  database:
    image: postgres:13
    ports:
      - "5432:5432"  # Exposed to the world!

# All services on the same network
# No security isolation
# No traffic control
# No advanced routing
```

### **Enterprise Networking Requirements**

Real-world e-commerce platforms need:
```
Enterprise Networking Challenges:
├── Security: "Isolate payment processing from public web traffic"
├── Compliance: "PCI DSS requires network segmentation"
├── Performance: "Route traffic efficiently across microservices"
├── Scalability: "Handle 10x traffic during Black Friday"
├── Multi-Environment: "Separate dev/staging/prod networks"
├── Service Mesh: "Secure service-to-service communication"
└── Observability: "Monitor and trace network traffic"
```

### **The Solution: Advanced Networking Patterns**

```yaml
# Enterprise networking (what you'll build)
version: '3.8'
services:
  frontend:
    networks:
      - web_tier
      - api_tier
  
  backend:
    networks:
      - api_tier
      - data_tier
  
  payment-service:
    networks:
      - payment_tier  # Isolated payment processing
  
  database:
    networks:
      - data_tier     # No external access

networks:
  web_tier:
    driver: bridge
  api_tier:
    driver: bridge
    internal: true
  data_tier:
    driver: bridge
    internal: true
  payment_tier:
    driver: bridge
    internal: true
    encrypted: true
```

---

## 🏗️ Docker Networking Architecture: Beyond the Basics

### **What You Already Know (Module 5 Review)**

```bash
# Basic Docker networking concepts
docker network ls                    # List networks
docker network create my-network     # Create custom network
docker run --network my-network nginx  # Connect container to network
```

### **Advanced Networking Components**

```
Docker Networking Stack:
├── Network Drivers
│   ├── bridge (default)
│   ├── host (performance)
│   ├── overlay (multi-host)
│   ├── macvlan (legacy integration)
│   └── none (isolation)
├── Network Plugins
│   ├── CNI (Container Network Interface)
│   ├── Libnetwork (Docker's networking)
│   └── Third-party (Calico, Weave, Flannel)
├── Service Discovery
│   ├── DNS resolution
│   ├── Service mesh
│   └── Load balancing
└── Security Features
    ├── Network policies
    ├── Encryption
    └── Firewall rules
```

---

## 🔧 Advanced Networking Patterns for E-Commerce

### **Pattern 1: Network Segmentation (Security Zones)**

#### **Theory: Why Network Segmentation?**
Network segmentation creates security boundaries:
- **DMZ**: Public-facing services (load balancer, CDN)
- **Web Tier**: Frontend applications
- **API Tier**: Backend services
- **Data Tier**: Databases and storage
- **Payment Tier**: PCI-compliant payment processing

#### **Implementation: Multi-Tier E-Commerce Network**

```yaml
version: '3.8'

services:
  # Load Balancer (DMZ)
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    networks:
      - dmz
      - web_tier
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf

  # Frontend (Web Tier)
  frontend:
    build: ./frontend
    networks:
      - web_tier
      - api_tier
    # No external ports - accessed through nginx

  # Backend API (API Tier)
  backend:
    build: ./backend
    networks:
      - api_tier
      - data_tier
    environment:
      DATABASE_URL: postgresql://user:pass@database:5432/ecommerce

  # Payment Service (Isolated Payment Tier)
  payment-service:
    build: ./payment-service
    networks:
      - payment_tier
      - api_tier
    environment:
      STRIPE_SECRET_KEY: ${STRIPE_SECRET_KEY}

  # Database (Data Tier)
  database:
    image: postgres:13
    networks:
      - data_tier
    # No external access - completely isolated

networks:
  dmz:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.1.0/24
  
  web_tier:
    driver: bridge
    internal: true  # No internet access
    ipam:
      config:
        - subnet: 172.20.2.0/24
  
  api_tier:
    driver: bridge
    internal: true
    ipam:
      config:
        - subnet: 172.20.3.0/24
  
  data_tier:
    driver: bridge
    internal: true
    ipam:
      config:
        - subnet: 172.20.4.0/24
  
  payment_tier:
    driver: bridge
    internal: true
    encrypted: true  # Encrypted traffic
    ipam:
      config:
        - subnet: 172.20.5.0/24
```

#### **🛒 E-Commerce Application: Implement Network Segmentation**

```bash
# Create the segmented network architecture
docker-compose -f docker-compose.segmented.yml up -d

# Test network isolation
# Frontend can reach backend
docker-compose exec frontend curl http://backend:8000/health

# Frontend cannot reach database directly (should fail)
docker-compose exec frontend curl http://database:5432

# Backend can reach database
docker-compose exec backend pg_isready -h database -p 5432
```

### **Pattern 2: Service Mesh Architecture**

#### **Theory: What is a Service Mesh?**
A service mesh provides:
- **Service-to-service communication** with encryption
- **Traffic management** and load balancing
- **Observability** and monitoring
- **Security policies** and access control

#### **Implementation: Istio-like Service Mesh with Docker**

```yaml
version: '3.8'

services:
  # Service Mesh Proxy (Envoy-based)
  service-mesh-proxy:
    image: envoyproxy/envoy:v1.24-latest
    volumes:
      - ./envoy.yaml:/etc/envoy/envoy.yaml
    networks:
      - mesh_network
    ports:
      - "9901:9901"  # Admin interface

  # Frontend with sidecar proxy
  frontend:
    build: ./frontend
    networks:
      - mesh_network
    depends_on:
      - service-mesh-proxy

  # Backend with sidecar proxy
  backend:
    build: ./backend
    networks:
      - mesh_network
    depends_on:
      - service-mesh-proxy

  # Service mesh control plane
  mesh-control-plane:
    image: istio/pilot:1.16.0
    networks:
      - mesh_network
    environment:
      PILOT_ENABLE_WORKLOAD_ENTRY_AUTOREGISTRATION: true

networks:
  mesh_network:
    driver: bridge
    encrypted: true
```

#### **Envoy Configuration for Service Mesh**
```yaml
# envoy.yaml
static_resources:
  listeners:
  - name: listener_0
    address:
      socket_address:
        address: 0.0.0.0
        port_value: 10000
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          access_log:
          - name: envoy.access_loggers.stdout
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.access_loggers.stream.v3.StdoutAccessLog
          http_filters:
          - name: envoy.filters.http.router
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.filters.http.router.v3.Router
          route_config:
            name: local_route
            virtual_hosts:
            - name: local_service
              domains: ["*"]
              routes:
              - match:
                  prefix: "/api"
                route:
                  cluster: backend_service
              - match:
                  prefix: "/"
                route:
                  cluster: frontend_service

  clusters:
  - name: backend_service
    connect_timeout: 30s
    type: LOGICAL_DNS
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: backend_service
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: backend
                port_value: 8000
  
  - name: frontend_service
    connect_timeout: 30s
    type: LOGICAL_DNS
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: frontend_service
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: frontend
                port_value: 3000
```

### **Pattern 3: Network Policies and Security**

#### **Theory: Container Network Security**
Network security layers:
- **Network segmentation** (different networks)
- **Firewall rules** (iptables, ufw)
- **Encryption** (TLS, VPN)
- **Access control** (authentication, authorization)

#### **Implementation: Network Security Policies**

```bash
#!/bin/bash
# scripts/setup-network-security.sh

# Create custom iptables rules for container networks
iptables -N DOCKER-USER

# Allow traffic within web tier
iptables -I DOCKER-USER -s 172.20.2.0/24 -d 172.20.2.0/24 -j ACCEPT

# Allow web tier to API tier
iptables -I DOCKER-USER -s 172.20.2.0/24 -d 172.20.3.0/24 -j ACCEPT

# Block direct access to data tier from web tier
iptables -I DOCKER-USER -s 172.20.2.0/24 -d 172.20.4.0/24 -j DROP

# Allow API tier to data tier
iptables -I DOCKER-USER -s 172.20.3.0/24 -d 172.20.4.0/24 -j ACCEPT

# Block all other inter-network traffic
iptables -I DOCKER-USER -j DROP

echo "Network security policies applied"
```

---

## 🔍 Advanced Network Troubleshooting

### **Network Debugging Tools**

#### **Container Network Inspection**
```bash
# Inspect network configuration
docker network inspect bridge
docker network inspect ecommerce_api_tier

# Check container network settings
docker inspect frontend --format='{{.NetworkSettings.Networks}}'

# View network interfaces inside container
docker exec frontend ip addr show
docker exec frontend ip route show

# Test connectivity between containers
docker exec frontend ping backend
docker exec frontend telnet backend 8000
docker exec frontend nslookup backend
```

#### **Advanced Network Monitoring**
```bash
# Monitor network traffic
docker exec frontend netstat -tulpn
docker exec frontend ss -tulpn

# Capture network packets
docker exec frontend tcpdump -i eth0 -n

# Monitor network performance
docker exec frontend iftop
docker exec frontend nethogs
```

### **Common Network Issues and Solutions**

#### **Issue 1: Service Discovery Problems**
```bash
# Problem: Container can't resolve service names
docker exec frontend nslookup backend
# nslookup: can't resolve 'backend'

# Solution: Check network connectivity
docker network ls
docker network inspect ecommerce_default

# Verify containers are on the same network
docker inspect frontend --format='{{.NetworkSettings.Networks}}'
docker inspect backend --format='{{.NetworkSettings.Networks}}'
```

#### **Issue 2: Port Conflicts**
```bash
# Problem: Port already in use
docker-compose up
# Error: bind: address already in use

# Solution: Find and resolve port conflicts
netstat -tulpn | grep :8000
lsof -i :8000

# Change port mapping
ports:
  - "8001:8000"  # Use different host port
```

#### **Issue 3: Network Performance Issues**
```bash
# Problem: Slow network communication
# Solution: Optimize network configuration

# Check MTU settings
docker exec frontend ip link show eth0

# Optimize network driver
networks:
  api_tier:
    driver: bridge
    driver_opts:
      com.docker.network.bridge.enable_icc: "true"
      com.docker.network.bridge.enable_ip_masquerade: "true"
      com.docker.network.driver.mtu: "1500"
```

---

## 🧪 Hands-On Practice: Advanced Networking

### **Exercise 1: Network Segmentation Implementation**

```bash
# Create multi-tier network architecture
cat > docker-compose.segmented.yml << 'EOF'
version: '3.8'

services:
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    networks:
      - dmz
      - web_tier

  frontend:
    image: node:16-alpine
    command: ["node", "-e", "require('http').createServer((req,res)=>res.end('Frontend')).listen(3000)"]
    networks:
      - web_tier
      - api_tier

  backend:
    image: node:16-alpine
    command: ["node", "-e", "require('http').createServer((req,res)=>res.end('Backend')).listen(8000)"]
    networks:
      - api_tier
      - data_tier

  database:
    image: postgres:13-alpine
    environment:
      POSTGRES_PASSWORD: password
    networks:
      - data_tier

networks:
  dmz:
    driver: bridge
  web_tier:
    driver: bridge
    internal: true
  api_tier:
    driver: bridge
    internal: true
  data_tier:
    driver: bridge
    internal: true
EOF

# Deploy segmented architecture
docker-compose -f docker-compose.segmented.yml up -d

# Test network isolation
docker-compose -f docker-compose.segmented.yml exec frontend ping backend  # Should work
docker-compose -f docker-compose.segmented.yml exec frontend ping database  # Should fail
```

### **Exercise 2: Network Performance Testing**

```bash
# Test network performance between containers
docker run -d --name server --network bridge nginx
docker run -it --name client --network bridge alpine

# Inside client container, test performance
apk add --no-cache curl iperf3
curl -o /dev/null -s -w "%{time_total}\n" http://server/

# Compare performance across different network drivers
docker network create --driver bridge test-bridge
docker network create --driver host test-host

# Test with different networks and compare results
```

### **Exercise 3: Service Mesh Implementation**

```bash
# Create simple service mesh with Envoy
mkdir service-mesh-demo
cd service-mesh-demo

# Create Envoy configuration
cat > envoy.yaml << 'EOF'
static_resources:
  listeners:
  - name: listener_0
    address:
      socket_address: { address: 0.0.0.0, port_value: 10000 }
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          route_config:
            name: local_route
            virtual_hosts:
            - name: local_service
              domains: ["*"]
              routes:
              - match: { prefix: "/" }
                route: { cluster: web_service }
          http_filters:
          - name: envoy.filters.http.router

  clusters:
  - name: web_service
    connect_timeout: 30s
    type: LOGICAL_DNS
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: web_service
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address: { address: web, port_value: 80 }
EOF

# Deploy service mesh
docker run -d --name envoy-proxy -p 10000:10000 -v $(pwd)/envoy.yaml:/etc/envoy/envoy.yaml envoyproxy/envoy:v1.24-latest
docker run -d --name web --link envoy-proxy nginx:alpine

# Test service mesh
curl http://localhost:10000
```

---

## ✅ Knowledge Check: Advanced Networking Mastery

### **Conceptual Understanding**
- [ ] Understands network segmentation and security zones
- [ ] Knows service mesh architecture and benefits
- [ ] Comprehends advanced network drivers and their use cases
- [ ] Understands network policies and security implementation
- [ ] Knows network troubleshooting techniques and tools

### **Practical Skills**
- [ ] Can design and implement multi-tier network architectures
- [ ] Knows how to configure service mesh for microservices
- [ ] Can implement network security policies and firewall rules
- [ ] Understands network performance optimization techniques
- [ ] Can troubleshoot complex network issues

### **E-Commerce Application**
- [ ] Has implemented network segmentation for e-commerce platform
- [ ] Created secure network architecture with proper isolation
- [ ] Configured advanced networking for performance and security
- [ ] Implemented network monitoring and troubleshooting procedures
- [ ] Applied enterprise networking patterns to production deployment

---

## 🚀 Next Steps: Container Security Hardening

### **What You've Mastered**
- ✅ **Advanced networking patterns** for enterprise applications
- ✅ **Network segmentation** and security zone implementation
- ✅ **Service mesh architecture** for microservices communication
- ✅ **Network troubleshooting** and performance optimization
- ✅ **Enterprise networking** applied to e-commerce platform

### **Coming Next: Container Security Hardening**
In **03-Container-Security-Hardening.md**, you'll learn:
- **Enterprise security frameworks** and compliance requirements
- **Container security hardening** techniques and best practices
- **Runtime security monitoring** and threat detection
- **Security automation** and vulnerability management

### **E-Commerce Evolution Preview**
Your advanced networking knowledge will enable you to:
- **Secure sensitive data** with proper network isolation
- **Scale efficiently** with optimized network architectures
- **Meet compliance requirements** with enterprise networking patterns
- **Troubleshoot complex issues** with expert-level network debugging

**Continue to Container Security Hardening when you've successfully implemented advanced networking for your e-commerce platform and understand enterprise networking patterns.**
}

func cmdAdd(args *skel.CmdArgs) error {
    conf := NetConf{}
    if err := json.Unmarshal(args.StdinData, &conf); err != nil {
        return fmt.Errorf("failed to parse config: %v", err)
    }

    // Create or get bridge
    br, err := setupBridge(conf.Bridge, conf.Gateway, conf.Subnet, conf.MTU)
    if err != nil {
        return fmt.Errorf("failed to setup bridge: %v", err)
    }

    // Create veth pair
    hostVeth, containerVeth, err := setupVeth(args.IfName, conf.MTU)
    if err != nil {
        return fmt.Errorf("failed to setup veth: %v", err)
    }

    // Attach host veth to bridge
    if err := netlink.LinkSetMaster(hostVeth, br); err != nil {
        return fmt.Errorf("failed to attach veth to bridge: %v", err)
    }

    // Move container veth to container namespace
    netns, err := ns.GetNS(args.Netns)
    if err != nil {
        return fmt.Errorf("failed to open netns: %v", err)
    }
    defer netns.Close()

    if err := netlink.LinkSetNsFd(containerVeth, int(netns.Fd())); err != nil {
        return fmt.Errorf("failed to move veth to container: %v", err)
    }

    // Configure container interface
    err = netns.Do(func(hostNS ns.NetNS) error {
        return configureContainerInterface(containerVeth, args.IfName, conf.Subnet)
    })
    if err != nil {
        return fmt.Errorf("failed to configure container interface: %v", err)
    }

    // Allocate IP address
    ipAddr, err := allocateIP(conf.Subnet)
    if err != nil {
        return fmt.Errorf("failed to allocate IP: %v", err)
    }

    // Return result
    result := &types.Result{
        IP4: &types.IPConfig{
            IP:      *ipAddr,
            Gateway: net.ParseIP(conf.Gateway),
        },
    }

    return types.PrintResult(result, conf.CNIVersion)
}

func setupBridge(bridgeName, gateway, subnet string, mtu int) (netlink.Link, error) {
    // Check if bridge exists
    br, err := netlink.LinkByName(bridgeName)
    if err != nil {
        // Create bridge
        bridge := &netlink.Bridge{
            LinkAttrs: netlink.LinkAttrs{
                Name: bridgeName,
                MTU:  mtu,
            },
        }
        
        if err := netlink.LinkAdd(bridge); err != nil {
            return nil, err
        }
        
        br = bridge
    }

    // Set bridge up
    if err := netlink.LinkSetUp(br); err != nil {
        return nil, err
    }

    // Add gateway IP to bridge
    gwIP := net.ParseIP(gateway)
    _, ipNet, _ := net.ParseCIDR(subnet)
    addr := &netlink.Addr{
        IPNet: &net.IPNet{
            IP:   gwIP,
            Mask: ipNet.Mask,
        },
    }
    
    if err := netlink.AddrAdd(br, addr); err != nil && !os.IsExist(err) {
        return nil, err
    }

    return br, nil
}

func setupVeth(ifName string, mtu int) (netlink.Link, netlink.Link, error) {
    hostVethName := fmt.Sprintf("veth%s", ifName[:5])
    
    veth := &netlink.Veth{
        LinkAttrs: netlink.LinkAttrs{
            Name: hostVethName,
            MTU:  mtu,
        },
        PeerName: ifName,
    }

    if err := netlink.LinkAdd(veth); err != nil {
        return nil, nil, err
    }

    hostVeth, err := netlink.LinkByName(hostVethName)
    if err != nil {
        return nil, nil, err
    }

    containerVeth, err := netlink.LinkByName(ifName)
    if err != nil {
        return nil, nil, err
    }

    if err := netlink.LinkSetUp(hostVeth); err != nil {
        return nil, nil, err
    }

    return hostVeth, containerVeth, nil
}

func configureContainerInterface(link netlink.Link, ifName, subnet string) error {
    // Rename interface
    if err := netlink.LinkSetName(link, ifName); err != nil {
        return err
    }

    // Set interface up
    if err := netlink.LinkSetUp(link); err != nil {
        return err
    }

    return nil
}

func allocateIP(subnet string) (*net.IPNet, error) {
    _, ipNet, err := net.ParseCIDR(subnet)
    if err != nil {
        return nil, err
    }

    // Simple IP allocation (in production, use IPAM plugin)
    ip := make(net.IP, len(ipNet.IP))
    copy(ip, ipNet.IP)
    ip[len(ip)-1] = 10 // Assign .10

    return &net.IPNet{
        IP:   ip,
        Mask: ipNet.Mask,
    }, nil
}

func cmdDel(args *skel.CmdArgs) error {
    // Cleanup logic here
    return nil
}

func cmdCheck(args *skel.CmdArgs) error {
    // Validation logic here
    return nil
}
```

## 🔥 Advanced Multi-Host Networking

### VXLAN Overlay Network Implementation
```bash
#!/bin/bash
# vxlan-overlay.sh - Create multi-host overlay network

setup_vxlan_overlay() {
    local vni=$1
    local local_ip=$2
    local remote_ip=$3
    local bridge_name="br-overlay-$vni"
    local vxlan_name="vxlan-$vni"

    # Create VXLAN interface
    ip link add $vxlan_name type vxlan \
        id $vni \
        local $local_ip \
        dstport 4789 \
        nolearning

    # Create bridge for overlay
    ip link add name $bridge_name type bridge
    ip link set dev $bridge_name up

    # Attach VXLAN to bridge
    ip link set dev $vxlan_name master $bridge_name
    ip link set dev $vxlan_name up

    # Add remote VTEP
    bridge fdb append 00:00:00:00:00:00 dev $vxlan_name dst $remote_ip

    echo "VXLAN overlay network created: $bridge_name"
}

# Advanced VXLAN with multicast
setup_multicast_vxlan() {
    local vni=$1
    local mcast_group=$2
    local interface=$3

    ip link add vxlan-mc-$vni type vxlan \
        id $vni \
        group $mcast_group \
        dev $interface \
        dstport 4789

    ip link set vxlan-mc-$vni up
}

# Usage examples
setup_vxlan_overlay 100 192.168.1.10 192.168.1.20
setup_multicast_vxlan 200 239.1.1.1 eth0
```

### Custom Network Driver for Docker
```go
// network-driver.go - Custom Docker network driver
package main

import (
    "encoding/json"
    "fmt"
    "net/http"
    "log"

    "github.com/docker/go-plugins-helpers/network"
)

type Driver struct {
    networks map[string]*NetworkState
}

type NetworkState struct {
    ID        string
    Name      string
    Subnet    string
    Gateway   string
    Endpoints map[string]*EndpointState
}

type EndpointState struct {
    ID        string
    Interface *network.InterfaceInfo
}

func NewDriver() *Driver {
    return &Driver{
        networks: make(map[string]*NetworkState),
    }
}

func (d *Driver) GetCapabilities() (*network.CapabilitiesResponse, error) {
    return &network.CapabilitiesResponse{
        Scope:             network.LocalScope,
        ConnectivityScope: network.LocalScope,
    }, nil
}

func (d *Driver) CreateNetwork(req *network.CreateNetworkRequest) error {
    log.Printf("Creating network: %s", req.NetworkID)

    // Parse network options
    subnet := req.Options["subnet"]
    gateway := req.Options["gateway"]

    if subnet == "" {
        subnet = "172.20.0.0/16"
    }
    if gateway == "" {
        gateway = "172.20.0.1"
    }

    // Create network state
    d.networks[req.NetworkID] = &NetworkState{
        ID:        req.NetworkID,
        Name:      req.NetworkID[:12],
        Subnet:    subnet,
        Gateway:   gateway,
        Endpoints: make(map[string]*EndpointState),
    }

    // Create actual network infrastructure
    if err := d.createNetworkInfrastructure(req.NetworkID, subnet, gateway); err != nil {
        return fmt.Errorf("failed to create network infrastructure: %v", err)
    }

    return nil
}

func (d *Driver) createNetworkInfrastructure(networkID, subnet, gateway string) error {
    // Implementation would create bridges, configure routing, etc.
    log.Printf("Creating network infrastructure for %s", networkID)
    return nil
}

func (d *Driver) DeleteNetwork(req *network.DeleteNetworkRequest) error {
    log.Printf("Deleting network: %s", req.NetworkID)
    
    if _, exists := d.networks[req.NetworkID]; !exists {
        return fmt.Errorf("network %s not found", req.NetworkID)
    }

    // Cleanup network infrastructure
    if err := d.deleteNetworkInfrastructure(req.NetworkID); err != nil {
        return fmt.Errorf("failed to delete network infrastructure: %v", err)
    }

    delete(d.networks, req.NetworkID)
    return nil
}

func (d *Driver) deleteNetworkInfrastructure(networkID string) error {
    log.Printf("Deleting network infrastructure for %s", networkID)
    return nil
}

func (d *Driver) CreateEndpoint(req *network.CreateEndpointRequest) (*network.CreateEndpointResponse, error) {
    log.Printf("Creating endpoint: %s", req.EndpointID)

    netState, exists := d.networks[req.NetworkID]
    if !exists {
        return nil, fmt.Errorf("network %s not found", req.NetworkID)
    }

    // Create endpoint
    endpoint := &EndpointState{
        ID: req.EndpointID,
        Interface: &network.InterfaceInfo{
            Address:    "172.20.0.10/16", // Dynamic allocation in production
            MacAddress: "02:42:ac:14:00:0a",
        },
    }

    netState.Endpoints[req.EndpointID] = endpoint

    return &network.CreateEndpointResponse{
        Interface: endpoint.Interface,
    }, nil
}

func (d *Driver) DeleteEndpoint(req *network.DeleteEndpointRequest) error {
    log.Printf("Deleting endpoint: %s", req.EndpointID)

    netState, exists := d.networks[req.NetworkID]
    if !exists {
        return fmt.Errorf("network %s not found", req.NetworkID)
    }

    delete(netState.Endpoints, req.EndpointID)
    return nil
}

func (d *Driver) Join(req *network.JoinRequest) (*network.JoinResponse, error) {
    log.Printf("Joining endpoint %s to network %s", req.EndpointID, req.NetworkID)

    return &network.JoinResponse{
        InterfaceName: network.InterfaceName{
            SrcName:   fmt.Sprintf("veth%s", req.EndpointID[:7]),
            DstPrefix: "eth",
        },
        Gateway: "172.20.0.1",
    }, nil
}

func (d *Driver) Leave(req *network.LeaveRequest) error {
    log.Printf("Leaving endpoint %s from network %s", req.EndpointID, req.NetworkID)
    return nil
}

func (d *Driver) DiscoverNew(req *network.DiscoveryNotification) error {
    return nil
}

func (d *Driver) DiscoverDelete(req *network.DiscoveryNotification) error {
    return nil
}

func (d *Driver) ProgramExternalConnectivity(req *network.ProgramExternalConnectivityRequest) error {
    return nil
}

func (d *Driver) RevokeExternalConnectivity(req *network.RevokeExternalConnectivityRequest) error {
    return nil
}

func main() {
    driver := NewDriver()
    handler := network.NewHandler(driver)
    
    log.Println("Starting custom network driver on /run/docker/plugins/mynetwork.sock")
    if err := handler.ServeUnix("mynetwork", 0); err != nil {
        log.Fatal(err)
    }
}
```

## ⚡ High-Performance Networking Optimizations

### SR-IOV and DPDK Integration
```bash
#!/bin/bash
# sriov-setup.sh - Setup SR-IOV for high-performance networking

setup_sriov() {
    local pf_interface=$1
    local num_vfs=$2

    echo "Setting up SR-IOV on $pf_interface with $num_vfs VFs"

    # Enable SR-IOV
    echo $num_vfs > /sys/class/net/$pf_interface/device/sriov_numvfs

    # Configure VFs
    for i in $(seq 0 $((num_vfs-1))); do
        # Set VF MAC address
        ip link set $pf_interface vf $i mac 02:00:00:00:00:$(printf "%02x" $i)
        
        # Set VF VLAN
        ip link set $pf_interface vf $i vlan $((100 + i))
        
        # Enable VF trust
        ip link set $pf_interface vf $i trust on
        
        # Set VF rate limit (Mbps)
        ip link set $pf_interface vf $i rate 1000
    done

    echo "SR-IOV setup completed"
}

# DPDK container setup
setup_dpdk_container() {
    local container_name=$1
    local vf_pci_addr=$2

    # Bind VF to DPDK driver
    dpdk-devbind.py --bind=vfio-pci $vf_pci_addr

    # Run container with DPDK support
    docker run -d \
        --name $container_name \
        --privileged \
        --device=/dev/vfio/vfio \
        --device=/dev/vfio/$(ls /dev/vfio/ | grep -v vfio) \
        -v /sys/bus/pci/devices:/sys/bus/pci/devices \
        -v /sys/kernel/mm/hugepages:/sys/kernel/mm/hugepages \
        -v /dev/hugepages:/dev/hugepages \
        --env PCI_ADDR=$vf_pci_addr \
        dpdk-app:latest
}

# Usage
setup_sriov eth0 4
setup_dpdk_container dpdk-app1 0000:03:10.0
```

### Network Performance Monitoring
```python
#!/usr/bin/env python3
# network-monitor.py - Advanced network performance monitoring

import time
import json
import subprocess
import psutil
from collections import defaultdict

class NetworkMonitor:
    def __init__(self):
        self.baseline = {}
        self.metrics = defaultdict(list)
    
    def get_interface_stats(self, interface):
        """Get detailed interface statistics"""
        stats = {}
        
        # Basic stats from psutil
        net_io = psutil.net_io_counters(pernic=True).get(interface)
        if net_io:
            stats.update({
                'bytes_sent': net_io.bytes_sent,
                'bytes_recv': net_io.bytes_recv,
                'packets_sent': net_io.packets_sent,
                'packets_recv': net_io.packets_recv,
                'errin': net_io.errin,
                'errout': net_io.errout,
                'dropin': net_io.dropin,
                'dropout': net_io.dropout
            })
        
        # Advanced stats from /proc/net/dev
        try:
            with open('/proc/net/dev', 'r') as f:
                for line in f:
                    if interface in line:
                        fields = line.split()
                        stats.update({
                            'rx_compressed': int(fields[7]),
                            'rx_multicast': int(fields[8]),
                            'tx_compressed': int(fields[15]),
                            'tx_collisions': int(fields[14])
                        })
                        break
        except:
            pass
        
        return stats
    
    def get_container_network_stats(self, container_id):
        """Get network stats for specific container"""
        try:
            # Get container PID
            result = subprocess.run(['docker', 'inspect', '-f', '{{.State.Pid}}', container_id],
                                  capture_output=True, text=True)
            pid = result.stdout.strip()
            
            if pid and pid != '0':
                # Read network stats from container's network namespace
                netdev_path = f'/proc/{pid}/net/dev'
                stats = {}
                
                with open(netdev_path, 'r') as f:
                    for line in f:
                        if 'eth0' in line:  # Assuming eth0 is the main interface
                            fields = line.split()
                            stats = {
                                'rx_bytes': int(fields[1]),
                                'rx_packets': int(fields[2]),
                                'rx_errors': int(fields[3]),
                                'rx_dropped': int(fields[4]),
                                'tx_bytes': int(fields[9]),
                                'tx_packets': int(fields[10]),
                                'tx_errors': int(fields[11]),
                                'tx_dropped': int(fields[12])
                            }
                            break
                
                return stats
        except:
            pass
        
        return {}
    
    def measure_latency(self, target_ip, count=10):
        """Measure network latency"""
        try:
            result = subprocess.run(['ping', '-c', str(count), target_ip],
                                  capture_output=True, text=True)
            
            # Parse ping output for latency stats
            lines = result.stdout.split('\n')
            for line in lines:
                if 'min/avg/max' in line:
                    stats = line.split('=')[1].strip().split('/')
                    return {
                        'min_latency': float(stats[0]),
                        'avg_latency': float(stats[1]),
                        'max_latency': float(stats[2]),
                        'stddev': float(stats[3].split()[0])
                    }
        except:
            pass
        
        return {}
    
    def measure_bandwidth(self, interface, duration=10):
        """Measure interface bandwidth"""
        initial_stats = self.get_interface_stats(interface)
        time.sleep(duration)
        final_stats = self.get_interface_stats(interface)
        
        if initial_stats and final_stats:
            rx_bps = (final_stats['bytes_recv'] - initial_stats['bytes_recv']) / duration
            tx_bps = (final_stats['bytes_sent'] - initial_stats['bytes_sent']) / duration
            
            return {
                'rx_bandwidth_mbps': rx_bps * 8 / 1000000,
                'tx_bandwidth_mbps': tx_bps * 8 / 1000000,
                'rx_pps': (final_stats['packets_recv'] - initial_stats['packets_recv']) / duration,
                'tx_pps': (final_stats['packets_sent'] - initial_stats['packets_sent']) / duration
            }
        
        return {}
    
    def analyze_network_performance(self, containers=None, duration=60):
        """Comprehensive network performance analysis"""
        print(f"Starting network performance analysis for {duration} seconds...")
        
        start_time = time.time()
        
        while time.time() - start_time < duration:
            timestamp = time.time()
            
            # Monitor host interfaces
            for interface in psutil.net_if_addrs().keys():
                if interface != 'lo':  # Skip loopback
                    stats = self.get_interface_stats(interface)
                    if stats:
                        self.metrics[f'host_{interface}'].append({
                            'timestamp': timestamp,
                            **stats
                        })
            
            # Monitor container networks
            if containers:
                for container_id in containers:
                    stats = self.get_container_network_stats(container_id)
                    if stats:
                        self.metrics[f'container_{container_id[:12]}'].append({
                            'timestamp': timestamp,
                            **stats
                        })
            
            time.sleep(1)
        
        return self.generate_report()
    
    def generate_report(self):
        """Generate performance analysis report"""
        report = {
            'summary': {},
            'detailed_metrics': self.metrics,
            'recommendations': []
        }
        
        for entity, metrics in self.metrics.items():
            if len(metrics) > 1:
                # Calculate rates and trends
                first = metrics[0]
                last = metrics[-1]
                duration = last['timestamp'] - first['timestamp']
                
                if 'bytes_recv' in first and 'bytes_recv' in last:
                    rx_rate = (last['bytes_recv'] - first['bytes_recv']) / duration
                    tx_rate = (last['bytes_sent'] - first['bytes_sent']) / duration
                    
                    report['summary'][entity] = {
                        'avg_rx_mbps': rx_rate * 8 / 1000000,
                        'avg_tx_mbps': tx_rate * 8 / 1000000,
                        'total_errors': last.get('errin', 0) + last.get('errout', 0),
                        'total_drops': last.get('dropin', 0) + last.get('dropout', 0)
                    }
                    
                    # Generate recommendations
                    if rx_rate > 100000000:  # > 100 Mbps
                        report['recommendations'].append(
                            f"{entity}: High network utilization detected. Consider SR-IOV or DPDK."
                        )
                    
                    if last.get('errin', 0) > 0 or last.get('errout', 0) > 0:
                        report['recommendations'].append(
                            f"{entity}: Network errors detected. Check interface configuration."
                        )
        
        return report

def main():
    monitor = NetworkMonitor()
    
    # Example usage
    containers = ['nginx-container', 'app-container']  # Replace with actual container IDs
    
    # Run analysis
    report = monitor.analyze_network_performance(containers=containers, duration=30)
    
    # Print results
    print(json.dumps(report, indent=2))
    
    # Save to file
    with open('network_performance_report.json', 'w') as f:
        json.dump(report, f, indent=2)

if __name__ == "__main__":
    main()
```

This continues the game-changing Module 7 with advanced networking topics that are rarely covered elsewhere. The module maintains the same depth and practical implementation focus that sets it apart from typical Docker training.
