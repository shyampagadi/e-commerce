# 🔧 Docker API & SDK Mastery

## 📋 Learning Objectives
By the end of this module, you will:
- **Understand** Docker API architecture and SDK capabilities
- **Master** programmatic container management and automation
- **Build** custom Docker tools and integrations
- **Implement** advanced API-driven e-commerce deployment automation
- **Create** production-ready Docker management applications

## 🎯 Real-World Context
Modern DevOps teams build custom automation tools using Docker APIs to manage complex deployments. This module teaches you to programmatically control Docker for advanced e-commerce platform management, automated scaling, and custom orchestration solutions.

---

## 📚 Part 1: Docker API Fundamentals

### Understanding Docker API Architecture

Docker provides multiple API interfaces for programmatic control:

**1. Docker Engine API**
- RESTful HTTP API for all Docker operations
- Used by Docker CLI and third-party tools
- Supports container, image, network, and volume management

**2. Docker SDK Libraries**
- Official SDKs for Python, Go, Java, and Node.js
- Simplified programming interfaces
- Built on top of the Docker Engine API

**3. API Versions and Compatibility**
- API versioning ensures backward compatibility
- Minimum API version requirements for features
- Version negotiation between client and daemon

### Docker API Endpoints Overview

**Core API Categories:**
```bash
# Container operations
GET    /containers/json          # List containers
POST   /containers/create        # Create container
POST   /containers/{id}/start    # Start container
POST   /containers/{id}/stop     # Stop container
DELETE /containers/{id}          # Remove container

# Image operations
GET    /images/json              # List images
POST   /images/create            # Pull/create image
DELETE /images/{name}            # Remove image

# Network operations
GET    /networks                 # List networks
POST   /networks/create          # Create network
DELETE /networks/{id}            # Remove network

# Volume operations
GET    /volumes                  # List volumes
POST   /volumes/create           # Create volume
DELETE /volumes/{name}           # Remove volume
```

type Node struct {
    ID       string            `json:"id"`
    Address  string            `json:"address"`
    Labels   map[string]string `json:"labels"`
    Status   string            `json:"status"`
    Capacity NodeCapacity      `json:"capacity"`
    Usage    NodeUsage         `json:"usage"`
}

type NodeCapacity struct {
    CPU    float64 `json:"cpu"`
    Memory int64   `json:"memory"`
    Disk   int64   `json:"disk"`
}

type NodeUsage struct {
    CPU    float64 `json:"cpu"`
    Memory int64   `json:"memory"`
    Disk   int64   `json:"disk"`
}

type Scheduler struct {
    strategy string
}

func NewOrchestrator() (*Orchestrator, error) {
    cli, err := client.NewClientWithOpts(client.FromEnv)
    if err != nil {
        return nil, err
    }

    return &Orchestrator{
        client:    cli,
        services:  make(map[string]*Service),
        nodes:     make(map[string]*Node),
        scheduler: &Scheduler{strategy: "spread"},
    }, nil
}

func (o *Orchestrator) CreateService(service *Service) error {
    o.mutex.Lock()
    defer o.mutex.Unlock()

    service.ID = generateID()
    service.Status = "pending"
    service.Containers = []string{}

    o.services[service.ID] = service

    // Schedule containers
    go o.scheduleService(service)

    return nil
}

func (o *Orchestrator) scheduleService(service *Service) {
    ctx := context.Background()

    for i := 0; i < service.Replicas; i++ {
        node := o.scheduler.selectNode(o.nodes, service.Constraints)
        if node == nil {
            log.Printf("No suitable node found for service %s", service.Name)
            continue
        }

        containerID, err := o.createContainer(ctx, service, node, i)
        if err != nil {
            log.Printf("Failed to create container for service %s: %v", service.Name, err)
            continue
        }

        service.Containers = append(service.Containers, containerID)
    }

    service.Status = "running"
}

func (o *Orchestrator) createContainer(ctx context.Context, service *Service, node *Node, replica int) (string, error) {
    containerName := fmt.Sprintf("%s-%d", service.Name, replica)

    // Create container configuration
    config := &container.Config{
        Image: service.Image,
        Env:   service.Env,
        Labels: map[string]string{
            "orchestrator.service": service.ID,
            "orchestrator.replica": fmt.Sprintf("%d", replica),
        },
    }

    hostConfig := &container.HostConfig{
        RestartPolicy: container.RestartPolicy{
            Name: "unless-stopped",
        },
    }

    networkConfig := &network.NetworkingConfig{}

    // Create container
    resp, err := o.client.ContainerCreate(ctx, config, hostConfig, networkConfig, nil, containerName)
    if err != nil {
        return "", err
    }

    // Start container
    if err := o.client.ContainerStart(ctx, resp.ID, types.ContainerStartOptions{}); err != nil {
        return "", err
    }

    return resp.ID, nil
}

func (s *Scheduler) selectNode(nodes map[string]*Node, constraints map[string]string) *Node {
    var bestNode *Node
    var bestScore float64

    for _, node := range nodes {
        if node.Status != "ready" {
            continue
        }

        // Check constraints
        if !s.matchesConstraints(node, constraints) {
            continue
        }

        // Calculate node score
        score := s.calculateNodeScore(node)
        if bestNode == nil || score > bestScore {
            bestNode = node
            bestScore = score
        }
    }

    return bestNode
}

func (s *Scheduler) matchesConstraints(node *Node, constraints map[string]string) bool {
    for key, value := range constraints {
        if nodeValue, exists := node.Labels[key]; !exists || nodeValue != value {
            return false
        }
    }
    return true
}

func (s *Scheduler) calculateNodeScore(node *Node) float64 {
    // Simple scoring based on available resources
    cpuScore := (node.Capacity.CPU - node.Usage.CPU) / node.Capacity.CPU
    memoryScore := float64(node.Capacity.Memory-node.Usage.Memory) / float64(node.Capacity.Memory)
    
    return (cpuScore + memoryScore) / 2
}

// REST API endpoints
func (o *Orchestrator) setupAPI() {
    r := mux.NewRouter()

    r.HandleFunc("/services", o.handleCreateService).Methods("POST")
    r.HandleFunc("/services", o.handleListServices).Methods("GET")
    r.HandleFunc("/services/{id}", o.handleGetService).Methods("GET")
    r.HandleFunc("/services/{id}", o.handleDeleteService).Methods("DELETE")
    r.HandleFunc("/services/{id}/scale", o.handleScaleService).Methods("POST")

    log.Println("API server starting on :8080")
    log.Fatal(http.ListenAndServe(":8080", r))
}

func (o *Orchestrator) handleCreateService(w http.ResponseWriter, r *http.Request) {
    var service Service
    if err := json.NewDecoder(r.Body).Decode(&service); err != nil {
        http.Error(w, err.Error(), http.StatusBadRequest)
        return
    }

    if err := o.CreateService(&service); err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }

    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(service)
}

func (o *Orchestrator) handleListServices(w http.ResponseWriter, r *http.Request) {
    o.mutex.RLock()
    defer o.mutex.RUnlock()

    services := make([]*Service, 0, len(o.services))
    for _, service := range o.services {
        services = append(services, service)
    }

    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(services)
}

func generateID() string {
    return fmt.Sprintf("%d", time.Now().UnixNano())
}
```

### Advanced Container Management
```python
#!/usr/bin/env python3
# container-manager.py - Advanced container lifecycle management

import docker
import json
import time
import threading
from datetime import datetime, timedelta
from collections import defaultdict

class AdvancedContainerManager:
    def __init__(self):
        self.client = docker.from_env()
        self.policies = {}
        self.metrics = defaultdict(list)
        self.running = True
        
    def create_auto_scaling_policy(self, service_name, policy):
        """Create auto-scaling policy for service"""
        self.policies[service_name] = {
            'min_replicas': policy.get('min_replicas', 1),
            'max_replicas': policy.get('max_replicas', 10),
            'target_cpu': policy.get('target_cpu', 70),
            'target_memory': policy.get('target_memory', 80),
            'scale_up_threshold': policy.get('scale_up_threshold', 2),
            'scale_down_threshold': policy.get('scale_down_threshold', 5),
            'cooldown_period': policy.get('cooldown_period', 300)
        }
        
    def monitor_and_scale(self):
        """Monitor containers and auto-scale based on policies"""
        while self.running:
            for service_name, policy in self.policies.items():
                try:
                    containers = self.get_service_containers(service_name)
                    if not containers:
                        continue
                        
                    # Collect metrics
                    avg_cpu, avg_memory = self.collect_service_metrics(containers)
                    
                    # Make scaling decisions
                    current_replicas = len(containers)
                    desired_replicas = self.calculate_desired_replicas(
                        current_replicas, avg_cpu, avg_memory, policy
                    )
                    
                    if desired_replicas != current_replicas:
                        self.scale_service(service_name, desired_replicas, policy)
                        
                except Exception as e:
                    print(f"Error monitoring service {service_name}: {e}")
                    
            time.sleep(30)  # Check every 30 seconds
            
    def get_service_containers(self, service_name):
        """Get all containers for a service"""
        return self.client.containers.list(
            filters={'label': f'service={service_name}'}
        )
        
    def collect_service_metrics(self, containers):
        """Collect average CPU and memory metrics for service"""
        total_cpu = 0
        total_memory = 0
        valid_containers = 0
        
        for container in containers:
            try:
                stats = container.stats(stream=False)
                
                # Calculate CPU percentage
                cpu_delta = stats['cpu_stats']['cpu_usage']['total_usage'] - \
                           stats['precpu_stats']['cpu_usage']['total_usage']
                system_delta = stats['cpu_stats']['system_cpu_usage'] - \
                              stats['precpu_stats']['system_cpu_usage']
                
                if system_delta > 0:
                    cpu_percent = (cpu_delta / system_delta) * 100.0
                    total_cpu += cpu_percent
                    
                # Calculate memory percentage
                memory_usage = stats['memory_stats']['usage']
                memory_limit = stats['memory_stats']['limit']
                memory_percent = (memory_usage / memory_limit) * 100.0
                total_memory += memory_percent
                
                valid_containers += 1
                
            except Exception as e:
                print(f"Error collecting stats for container {container.id[:12]}: {e}")
                
        if valid_containers == 0:
            return 0, 0
            
        return total_cpu / valid_containers, total_memory / valid_containers
        
    def calculate_desired_replicas(self, current_replicas, avg_cpu, avg_memory, policy):
        """Calculate desired number of replicas based on metrics"""
        
        # Scale up if CPU or memory is high
        if (avg_cpu > policy['target_cpu'] or avg_memory > policy['target_memory']):
            if current_replicas < policy['max_replicas']:
                return min(current_replicas + 1, policy['max_replicas'])
                
        # Scale down if both CPU and memory are low
        elif (avg_cpu < policy['target_cpu'] * 0.5 and avg_memory < policy['target_memory'] * 0.5):
            if current_replicas > policy['min_replicas']:
                return max(current_replicas - 1, policy['min_replicas'])
                
        return current_replicas
        
    def scale_service(self, service_name, desired_replicas, policy):
        """Scale service to desired number of replicas"""
        containers = self.get_service_containers(service_name)
        current_replicas = len(containers)
        
        print(f"Scaling {service_name} from {current_replicas} to {desired_replicas} replicas")
        
        if desired_replicas > current_replicas:
            # Scale up
            for i in range(desired_replicas - current_replicas):
                self.create_service_container(service_name, current_replicas + i)
                
        elif desired_replicas < current_replicas:
            # Scale down
            containers_to_remove = containers[desired_replicas:]
            for container in containers_to_remove:
                try:
                    container.stop(timeout=10)
                    container.remove()
                    print(f"Removed container {container.id[:12]}")
                except Exception as e:
                    print(f"Error removing container {container.id[:12]}: {e}")
                    
    def create_service_container(self, service_name, replica_id):
        """Create a new container for the service"""
        try:
            container = self.client.containers.run(
                image=f"{service_name}:latest",
                name=f"{service_name}-{replica_id}",
                labels={'service': service_name, 'replica': str(replica_id)},
                detach=True,
                restart_policy={'Name': 'unless-stopped'}
            )
            print(f"Created container {container.id[:12]} for service {service_name}")
            return container
        except Exception as e:
            print(f"Error creating container for service {service_name}: {e}")
            return None
            
    def implement_circuit_breaker(self, service_name, failure_threshold=5, timeout=60):
        """Implement circuit breaker pattern for service"""
        
        class CircuitBreaker:
            def __init__(self, failure_threshold, timeout):
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
                    
        return CircuitBreaker(failure_threshold, timeout)
        
    def implement_health_checks(self, service_name, health_check_config):
        """Implement advanced health checking"""
        
        def health_check_worker():
            while self.running:
                containers = self.get_service_containers(service_name)
                
                for container in containers:
                    try:
                        # HTTP health check
                        if health_check_config.get('type') == 'http':
                            self.perform_http_health_check(container, health_check_config)
                            
                        # Command health check
                        elif health_check_config.get('type') == 'command':
                            self.perform_command_health_check(container, health_check_config)
                            
                        # TCP health check
                        elif health_check_config.get('type') == 'tcp':
                            self.perform_tcp_health_check(container, health_check_config)
                            
                    except Exception as e:
                        print(f"Health check failed for container {container.id[:12]}: {e}")
                        self.handle_unhealthy_container(container, service_name)
                        
                time.sleep(health_check_config.get('interval', 30))
                
        threading.Thread(target=health_check_worker, daemon=True).start()
        
    def perform_http_health_check(self, container, config):
        """Perform HTTP health check"""
        import requests
        
        # Get container IP
        container.reload()
        ip = container.attrs['NetworkSettings']['IPAddress']
        
        url = f"http://{ip}:{config['port']}{config['path']}"
        response = requests.get(url, timeout=config.get('timeout', 5))
        
        if response.status_code != config.get('expected_status', 200):
            raise Exception(f"HTTP health check failed: {response.status_code}")
            
    def perform_command_health_check(self, container, config):
        """Perform command-based health check"""
        result = container.exec_run(config['command'])
        
        if result.exit_code != 0:
            raise Exception(f"Command health check failed: {result.output.decode()}")
            
    def perform_tcp_health_check(self, container, config):
        """Perform TCP health check"""
        import socket
        
        container.reload()
        ip = container.attrs['NetworkSettings']['IPAddress']
        
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(config.get('timeout', 5))
        
        try:
            result = sock.connect_ex((ip, config['port']))
            if result != 0:
                raise Exception(f"TCP health check failed: cannot connect to {ip}:{config['port']}")
        finally:
            sock.close()
            
    def handle_unhealthy_container(self, container, service_name):
        """Handle unhealthy container"""
        print(f"Container {container.id[:12]} is unhealthy, restarting...")
        
        try:
            container.restart(timeout=10)
        except Exception as e:
            print(f"Failed to restart container {container.id[:12]}: {e}")
            # Create replacement container
            self.create_service_container(service_name, int(time.time()))
            
            # Remove unhealthy container
            try:
                container.stop(timeout=10)
                container.remove()
            except Exception as e:
                print(f"Failed to remove unhealthy container: {e}")

def main():
    manager = AdvancedContainerManager()
    
    # Example: Create auto-scaling policy
    manager.create_auto_scaling_policy('web-service', {
        'min_replicas': 2,
        'max_replicas': 10,
        'target_cpu': 70,
        'target_memory': 80
    })
    
    # Example: Implement health checks
    manager.implement_health_checks('web-service', {
        'type': 'http',
        'port': 80,
        'path': '/health',
        'interval': 30,
        'timeout': 5
    })
    
    # Start monitoring
    monitor_thread = threading.Thread(target=manager.monitor_and_scale, daemon=True)
    monitor_thread.start()
    
    print("Advanced Container Manager started")
    
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        manager.running = False
        print("Shutting down...")

if __name__ == "__main__":
    main()
```

### Docker Events Processing
```go
// event-processor.go - Advanced Docker events processing
package main

import (
    "context"
    "encoding/json"
    "fmt"
    "log"
    "time"

    "github.com/docker/docker/api/types"
    "github.com/docker/docker/api/types/events"
    "github.com/docker/docker/client"
)

type EventProcessor struct {
    client   *client.Client
    handlers map[string][]EventHandler
    metrics  *EventMetrics
}

type EventHandler func(event events.Message) error

type EventMetrics struct {
    ContainerEvents map[string]int `json:"container_events"`
    ImageEvents     map[string]int `json:"image_events"`
    NetworkEvents   map[string]int `json:"network_events"`
    VolumeEvents    map[string]int `json:"volume_events"`
    TotalEvents     int            `json:"total_events"`
}

func NewEventProcessor() (*EventProcessor, error) {
    cli, err := client.NewClientWithOpts(client.FromEnv)
    if err != nil {
        return nil, err
    }

    return &EventProcessor{
        client:   cli,
        handlers: make(map[string][]EventHandler),
        metrics: &EventMetrics{
            ContainerEvents: make(map[string]int),
            ImageEvents:     make(map[string]int),
            NetworkEvents:   make(map[string]int),
            VolumeEvents:    make(map[string]int),
        },
    }, nil
}

func (ep *EventProcessor) RegisterHandler(eventType string, handler EventHandler) {
    ep.handlers[eventType] = append(ep.handlers[eventType], handler)
}

func (ep *EventProcessor) Start(ctx context.Context) error {
    eventsChan, errChan := ep.client.Events(ctx, types.EventsOptions{})

    for {
        select {
        case event := <-eventsChan:
            ep.processEvent(event)
        case err := <-errChan:
            if err != nil {
                log.Printf("Error receiving events: %v", err)
                return err
            }
        case <-ctx.Done():
            return ctx.Err()
        }
    }
}

func (ep *EventProcessor) processEvent(event events.Message) {
    // Update metrics
    ep.updateMetrics(event)

    // Process handlers
    eventKey := fmt.Sprintf("%s.%s", event.Type, event.Action)
    
    if handlers, exists := ep.handlers[eventKey]; exists {
        for _, handler := range handlers {
            go func(h EventHandler) {
                if err := h(event); err != nil {
                    log.Printf("Handler error for event %s: %v", eventKey, err)
                }
            }(handler)
        }
    }

    // Log event
    log.Printf("Event: %s %s %s", event.Type, event.Action, event.Actor.ID[:12])
}

func (ep *EventProcessor) updateMetrics(event events.Message) {
    ep.metrics.TotalEvents++

    switch event.Type {
    case "container":
        ep.metrics.ContainerEvents[event.Action]++
    case "image":
        ep.metrics.ImageEvents[event.Action]++
    case "network":
        ep.metrics.NetworkEvents[event.Action]++
    case "volume":
        ep.metrics.VolumeEvents[event.Action]++
    }
}

// Advanced event handlers
func (ep *EventProcessor) setupAdvancedHandlers() {
    // Container lifecycle management
    ep.RegisterHandler("container.start", ep.handleContainerStart)
    ep.RegisterHandler("container.die", ep.handleContainerDie)
    ep.RegisterHandler("container.oom", ep.handleContainerOOM)

    // Security monitoring
    ep.RegisterHandler("container.exec_create", ep.handleExecCreate)
    ep.RegisterHandler("container.exec_start", ep.handleExecStart)

    // Resource monitoring
    ep.RegisterHandler("container.update", ep.handleContainerUpdate)

    // Network monitoring
    ep.RegisterHandler("network.create", ep.handleNetworkCreate)
    ep.RegisterHandler("network.destroy", ep.handleNetworkDestroy)
}

func (ep *EventProcessor) handleContainerStart(event events.Message) error {
    containerID := event.Actor.ID

    // Get container details
    container, err := ep.client.ContainerInspect(context.Background(), containerID)
    if err != nil {
        return err
    }

    log.Printf("Container started: %s (image: %s)", container.Name, container.Config.Image)

    // Implement auto-tagging
    if err := ep.autoTagContainer(containerID, container); err != nil {
        log.Printf("Failed to auto-tag container %s: %v", containerID[:12], err)
    }

    // Setup monitoring
    go ep.monitorContainer(containerID)

    return nil
}

func (ep *EventProcessor) handleContainerDie(event events.Message) error {
    containerID := event.Actor.ID
    exitCode := event.Actor.Attributes["exitCode"]

    log.Printf("Container died: %s (exit code: %s)", containerID[:12], exitCode)

    // Check if restart is needed
    if exitCode != "0" {
        return ep.handleContainerFailure(containerID, exitCode)
    }

    return nil
}

func (ep *EventProcessor) handleContainerOOM(event events.Message) error {
    containerID := event.Actor.ID

    log.Printf("Container OOM killed: %s", containerID[:12])

    // Implement OOM response
    return ep.handleOOMEvent(containerID)
}

func (ep *EventProcessor) handleExecCreate(event events.Message) error {
    containerID := event.Actor.ID
    execID := event.Actor.Attributes["execID"]

    log.Printf("Exec created in container %s: %s", containerID[:12], execID)

    // Security monitoring for exec commands
    return ep.monitorExecCommand(containerID, execID)
}

func (ep *EventProcessor) autoTagContainer(containerID string, container types.ContainerJSON) error {
    // Auto-tag based on image, environment, etc.
    labels := make(map[string]string)

    // Add timestamp
    labels["auto.created"] = time.Now().Format(time.RFC3339)

    // Add image info
    labels["auto.image"] = container.Config.Image

    // Add environment info
    if env := container.Config.Env; len(env) > 0 {
        labels["auto.has_env"] = "true"
    }

    // Update container labels
    updateConfig := container.Config
    if updateConfig.Labels == nil {
        updateConfig.Labels = make(map[string]string)
    }

    for k, v := range labels {
        updateConfig.Labels[k] = v
    }

    return nil // In real implementation, would update container
}

func (ep *EventProcessor) monitorContainer(containerID string) {
    // Implement container monitoring logic
    log.Printf("Starting monitoring for container %s", containerID[:12])
}

func (ep *EventProcessor) handleContainerFailure(containerID, exitCode string) error {
    log.Printf("Handling container failure: %s (exit code: %s)", containerID[:12], exitCode)

    // Implement failure handling logic
    // - Restart container
    // - Send alerts
    // - Update service status

    return nil
}

func (ep *EventProcessor) handleOOMEvent(containerID string) error {
    log.Printf("Handling OOM event for container %s", containerID[:12])

    // Implement OOM handling
    // - Increase memory limits
    // - Scale horizontally
    // - Send alerts

    return nil
}

func (ep *EventProcessor) monitorExecCommand(containerID, execID string) error {
    // Monitor exec commands for security
    log.Printf("Monitoring exec command %s in container %s", execID, containerID[:12])

    return nil
}

func main() {
    processor, err := NewEventProcessor()
    if err != nil {
        log.Fatal(err)
    }

    // Setup handlers
    processor.setupAdvancedHandlers()

    // Start processing
    ctx := context.Background()
    log.Println("Starting Docker event processor...")

    if err := processor.Start(ctx); err != nil {
        log.Fatal(err)
    }
}
```

---

## 🔧 Part 2: Docker SDK Implementation

### Python SDK for E-Commerce Automation

**Setting Up Docker SDK:**
```python
# requirements.txt
docker==6.1.3
requests==2.31.0
pyyaml==6.0

# ecommerce_docker_manager.py
import docker
import json
import time
from typing import List, Dict, Optional

class ECommerceDockerManager:
    def __init__(self):
        self.client = docker.from_env()
        self.services = {}
    
    def deploy_ecommerce_stack(self, config: Dict) -> Dict:
        """Deploy complete e-commerce stack programmatically"""
        results = {}
        
        # Create network first
        network = self.create_network(config['network'])
        results['network'] = network.id
        
        # Deploy database
        db_container = self.deploy_database(config['database'], network.name)
        results['database'] = db_container.id
        
        # Deploy API services
        api_containers = self.deploy_api_services(config['api'], network.name)
        results['api'] = [c.id for c in api_containers]
        
        # Deploy frontend
        frontend_container = self.deploy_frontend(config['frontend'], network.name)
        results['frontend'] = frontend_container.id
        
        return results
    
    def create_network(self, network_config: Dict) -> docker.models.networks.Network:
        """Create Docker network with custom configuration"""
        return self.client.networks.create(
            name=network_config['name'],
            driver=network_config.get('driver', 'bridge'),
            options=network_config.get('options', {}),
            ipam=docker.types.IPAMConfig(
                pool_configs=[
                    docker.types.IPAMPool(
                        subnet=network_config.get('subnet', '172.20.0.0/16')
                    )
                ]
            )
        )
```

### Node.js SDK for Real-Time Management

**Real-Time Container Monitoring:**
```javascript
// ecommerce-monitor.js
const Docker = require('dockerode');
const EventEmitter = require('events');

class ECommerceMonitor extends EventEmitter {
    constructor() {
        super();
        this.docker = new Docker();
        this.containers = new Map();
        this.monitoring = false;
    }
    
    async startMonitoring() {
        this.monitoring = true;
        console.log('🔍 Starting e-commerce container monitoring...');
        
        // Monitor container events
        const stream = await this.docker.getEvents({
            filters: { label: ['app=ecommerce'] }
        });
        
        stream.on('data', (chunk) => {
            const event = JSON.parse(chunk.toString());
            this.handleContainerEvent(event);
        });
        
        // Monitor resource usage
        setInterval(() => {
            this.checkResourceUsage();
        }, 10000);
    }
    
    handleContainerEvent(event) {
        const { Action, Actor } = event;
        const containerName = Actor.Attributes.name;
        
        switch (Action) {
            case 'start':
                console.log(`✅ Container started: ${containerName}`);
                this.emit('container:started', { name: containerName });
                break;
            case 'die':
                console.log(`❌ Container died: ${containerName}`);
                this.emit('container:died', { name: containerName });
                this.handleContainerFailure(containerName);
                break;
        }
    }
    
    async handleContainerFailure(containerName) {
        // Auto-restart failed containers
        try {
            const container = this.docker.getContainer(containerName);
            await container.restart();
            console.log(`🔄 Auto-restarted: ${containerName}`);
        } catch (error) {
            console.error(`Failed to restart ${containerName}:`, error.message);
        }
    }
}
```

---

## 🏗️ Part 3: E-Commerce API Integration

### Custom Deployment Automation

**Automated E-Commerce Deployment:**
```python
# ecommerce_deployer.py
import docker
import yaml
import time
from pathlib import Path

class ECommerceDeployer:
    def __init__(self, config_path: str):
        self.client = docker.from_env()
        self.config = self.load_config(config_path)
        
    def load_config(self, config_path: str) -> dict:
        """Load deployment configuration"""
        with open(config_path, 'r') as file:
            return yaml.safe_load(file)
    
    def deploy_production_stack(self):
        """Deploy production e-commerce stack"""
        print("🚀 Deploying production e-commerce stack...")
        
        # Phase 1: Infrastructure
        self.setup_networks()
        self.setup_volumes()
        
        # Phase 2: Data layer
        self.deploy_database()
        self.deploy_redis()
        
        # Phase 3: Application layer
        self.deploy_api_services()
        
        # Phase 4: Presentation layer
        self.deploy_frontend()
        self.deploy_nginx()
        
        # Phase 5: Monitoring
        self.deploy_monitoring()
        
        print("✅ Production deployment completed!")
    
    def setup_networks(self):
        """Create production networks"""
        networks = self.config['networks']
        
        for network_name, network_config in networks.items():
            try:
                network = self.client.networks.create(
                    name=network_name,
                    driver=network_config.get('driver', 'bridge'),
                    options=network_config.get('options', {}),
                    labels={'environment': 'production'}
                )
                print(f"📡 Created network: {network_name}")
            except docker.errors.APIError as e:
                if "already exists" in str(e):
                    print(f"📡 Network exists: {network_name}")
                else:
                    raise
    
    def deploy_database(self):
        """Deploy PostgreSQL database"""
        db_config = self.config['services']['database']
        
        container = self.client.containers.run(
            image=db_config['image'],
            name='ecommerce-database',
            environment=db_config['environment'],
            volumes=db_config['volumes'],
            networks=db_config['networks'],
            restart_policy={"Name": "unless-stopped"},
            detach=True,
            labels={'app': 'ecommerce', 'tier': 'database'}
        )
        
        # Wait for database to be ready
        self.wait_for_service('ecommerce-database', 'postgres')
        print("🗄️ Database deployed and ready")
```

### Health Check and Auto-Recovery

**Intelligent Health Monitoring:**
```python
# health_monitor.py
import docker
import requests
import time
import logging
from typing import Dict, List

class HealthMonitor:
    def __init__(self):
        self.client = docker.from_env()
        self.services = self.discover_services()
        self.logger = self.setup_logging()
    
    def discover_services(self) -> Dict:
        """Discover all e-commerce services"""
        containers = self.client.containers.list(
            filters={'label': 'app=ecommerce'}
        )
        
        services = {}
        for container in containers:
            service_name = container.labels.get('service', container.name)
            services[service_name] = {
                'container': container,
                'health_endpoint': container.labels.get('health.endpoint'),
                'restart_count': 0,
                'last_check': None
            }
        
        return services
    
    def check_service_health(self, service_name: str) -> bool:
        """Check individual service health"""
        service = self.services[service_name]
        container = service['container']
        
        # Check container status
        container.reload()
        if container.status != 'running':
            self.logger.warning(f"Container {service_name} is not running")
            return False
        
        # Check health endpoint if available
        health_endpoint = service.get('health_endpoint')
        if health_endpoint:
            try:
                response = requests.get(health_endpoint, timeout=5)
                if response.status_code == 200:
                    return True
                else:
                    self.logger.warning(f"Health check failed for {service_name}: {response.status_code}")
                    return False
            except requests.RequestException as e:
                self.logger.error(f"Health check error for {service_name}: {e}")
                return False
        
        return True
    
    def auto_recover_service(self, service_name: str):
        """Automatically recover failed service"""
        service = self.services[service_name]
        container = service['container']
        
        try:
            # Try restart first
            container.restart()
            service['restart_count'] += 1
            self.logger.info(f"Restarted {service_name} (attempt {service['restart_count']})")
            
            # If too many restarts, recreate container
            if service['restart_count'] > 3:
                self.recreate_service(service_name)
                
        except Exception as e:
            self.logger.error(f"Failed to recover {service_name}: {e}")
```

---

## 🧪 Part 4: Hands-On API Labs

### Lab 1: Custom Container Manager

**Build a simple container management tool:**
```python
# container_manager.py
import docker
import argparse
import json

class SimpleContainerManager:
    def __init__(self):
        self.client = docker.from_env()
    
    def list_containers(self, all_containers=False):
        """List running or all containers"""
        containers = self.client.containers.list(all=all_containers)
        
        for container in containers:
            print(f"ID: {container.short_id}")
            print(f"Name: {container.name}")
            print(f"Status: {container.status}")
            print(f"Image: {container.image.tags[0] if container.image.tags else 'N/A'}")
            print("-" * 40)
    
    def create_ecommerce_container(self, service_type):
        """Create e-commerce service container"""
        configs = {
            'api': {
                'image': 'ecommerce/api:latest',
                'ports': {'3000/tcp': 3000},
                'environment': ['NODE_ENV=production']
            },
            'frontend': {
                'image': 'ecommerce/frontend:latest',
                'ports': {'80/tcp': 8080},
                'environment': ['REACT_APP_API_URL=http://localhost:3000']
            }
        }
        
        config = configs.get(service_type)
        if not config:
            print(f"Unknown service type: {service_type}")
            return
        
        container = self.client.containers.run(
            **config,
            name=f"ecommerce-{service_type}",
            detach=True,
            labels={'app': 'ecommerce', 'service': service_type}
        )
        
        print(f"Created container: {container.name} ({container.short_id})")

if __name__ == "__main__":
    manager = SimpleContainerManager()
    
    parser = argparse.ArgumentParser(description='Simple Container Manager')
    parser.add_argument('action', choices=['list', 'create'])
    parser.add_argument('--service', help='Service type for create action')
    parser.add_argument('--all', action='store_true', help='List all containers')
    
    args = parser.parse_args()
    
    if args.action == 'list':
        manager.list_containers(args.all)
    elif args.action == 'create':
        if not args.service:
            print("Service type required for create action")
        else:
            manager.create_ecommerce_container(args.service)
```

### Lab 2: Automated Scaling System

**Build auto-scaling based on metrics:**
```python
# auto_scaler.py
import docker
import time
import psutil
from typing import Dict

class AutoScaler:
    def __init__(self):
        self.client = docker.from_env()
        self.scaling_rules = {
            'ecommerce-api': {
                'min_replicas': 2,
                'max_replicas': 10,
                'cpu_threshold': 80,
                'memory_threshold': 85
            }
        }
    
    def get_container_metrics(self, container_name: str) -> Dict:
        """Get container resource metrics"""
        try:
            container = self.client.containers.get(container_name)
            stats = container.stats(stream=False)
            
            # Calculate CPU percentage
            cpu_delta = stats['cpu_stats']['cpu_usage']['total_usage'] - \
                       stats['precpu_stats']['cpu_usage']['total_usage']
            system_delta = stats['cpu_stats']['system_cpu_usage'] - \
                          stats['precpu_stats']['system_cpu_usage']
            cpu_percent = (cpu_delta / system_delta) * 100.0
            
            # Calculate memory percentage
            memory_usage = stats['memory_stats']['usage']
            memory_limit = stats['memory_stats']['limit']
            memory_percent = (memory_usage / memory_limit) * 100.0
            
            return {
                'cpu_percent': cpu_percent,
                'memory_percent': memory_percent,
                'memory_usage': memory_usage,
                'memory_limit': memory_limit
            }
        except Exception as e:
            print(f"Error getting metrics for {container_name}: {e}")
            return {}
    
    def scale_service(self, service_name: str, target_replicas: int):
        """Scale service to target replica count"""
        current_containers = self.client.containers.list(
            filters={'label': f'service={service_name}'}
        )
        current_count = len(current_containers)
        
        if target_replicas > current_count:
            # Scale up
            for i in range(target_replicas - current_count):
                self.create_replica(service_name, current_count + i + 1)
        elif target_replicas < current_count:
            # Scale down
            containers_to_remove = current_containers[target_replicas:]
            for container in containers_to_remove:
                container.stop()
                container.remove()
        
        print(f"Scaled {service_name} from {current_count} to {target_replicas} replicas")
    
    def create_replica(self, service_name: str, replica_number: int):
        """Create new service replica"""
        container = self.client.containers.run(
            image=f'ecommerce/{service_name}:latest',
            name=f'{service_name}-{replica_number}',
            detach=True,
            labels={
                'app': 'ecommerce',
                'service': service_name,
                'replica': str(replica_number)
            }
        )
        print(f"Created replica: {container.name}")
```

---

## 📊 Part 5: Production API Patterns

### Enterprise Docker Management

**Production-Ready Management System:**
```python
# enterprise_docker_manager.py
import docker
import logging
import json
import time
from datetime import datetime
from typing import Dict, List, Optional

class EnterpriseDockerManager:
    def __init__(self, config_file: str):
        self.client = docker.from_env()
        self.config = self.load_config(config_file)
        self.logger = self.setup_logging()
        
    def setup_logging(self):
        """Configure enterprise logging"""
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler('/var/log/docker-manager.log'),
                logging.StreamHandler()
            ]
        )
        return logging.getLogger(__name__)
    
    def deploy_with_rollback(self, service_config: Dict) -> bool:
        """Deploy with automatic rollback capability"""
        service_name = service_config['name']
        new_image = service_config['image']
        
        # Get current deployment
        current_containers = self.get_service_containers(service_name)
        
        try:
            # Deploy new version
            self.logger.info(f"Deploying {service_name} with image {new_image}")
            new_containers = self.deploy_service(service_config)
            
            # Health check new deployment
            if self.verify_deployment_health(new_containers):
                # Remove old containers
                self.cleanup_old_containers(current_containers)
                self.logger.info(f"Successfully deployed {service_name}")
                return True
            else:
                # Rollback
                self.logger.warning(f"Health check failed, rolling back {service_name}")
                self.cleanup_old_containers(new_containers)
                return False
                
        except Exception as e:
            self.logger.error(f"Deployment failed for {service_name}: {e}")
            return False
    
    def verify_deployment_health(self, containers: List) -> bool:
        """Verify deployment health"""
        for container in containers:
            # Wait for container to be ready
            time.sleep(10)
            
            # Check container status
            container.reload()
            if container.status != 'running':
                return False
            
            # Check health endpoint if configured
            health_endpoint = container.labels.get('health.endpoint')
            if health_endpoint:
                if not self.check_health_endpoint(health_endpoint):
                    return False
        
        return True
```

---

## 🎓 Module Summary

You've mastered Docker API & SDK programming by learning:

**Core Concepts:**
- Docker API architecture and endpoint structure
- SDK implementation in Python and Node.js
- Programmatic container lifecycle management

**Practical Skills:**
- Building custom Docker management tools
- Implementing automated deployment systems
- Creating health monitoring and auto-recovery solutions

**Enterprise Techniques:**
- Production-ready deployment automation
- Advanced scaling and orchestration patterns
- Enterprise logging and monitoring integration

**Next Steps:**
- Build custom tools for your e-commerce platform
- Implement automated deployment pipelines
- Prepare for Module 6: Enterprise Storage Solutions

---

## 📚 Additional Resources

- [Docker Engine API Documentation](https://docs.docker.com/engine/api/)
- [Docker SDK for Python](https://docker-py.readthedocs.io/)
- [Docker SDK for Node.js](https://github.com/apocas/dockerode)
- [Docker API Best Practices](https://docs.docker.com/develop/sdk/)
