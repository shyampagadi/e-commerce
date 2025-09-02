# 🎯 Advanced Orchestration Patterns

## 📋 Learning Objectives
By the end of this module, you will:
- **Understand** advanced container orchestration concepts and patterns
- **Master** custom scheduling algorithms and placement strategies
- **Implement** intelligent workload distribution for e-commerce applications
- **Build** production-ready orchestration solutions
- **Deploy** enterprise-grade container management systems

## 🎯 Real-World Context
Modern e-commerce platforms require sophisticated orchestration to handle varying loads, ensure high availability, and optimize resource utilization. This module teaches you to build custom orchestration solutions that can intelligently manage containerized applications across multiple hosts and environments.

---

## 📚 Part 1: Orchestration Fundamentals

### Understanding Container Orchestration

**What is Container Orchestration?**
Container orchestration automates the deployment, management, scaling, and networking of containerized applications across multiple hosts.

**Key Orchestration Concepts:**

**1. Scheduling**
- Deciding where to place containers
- Resource allocation and constraints
- Affinity and anti-affinity rules
- Load balancing across nodes

**2. Service Discovery**
- Automatic service registration
- Dynamic endpoint resolution
- Health checking and failover
- Load balancer configuration

**3. Scaling**
- Horizontal scaling (more instances)
- Vertical scaling (more resources)
- Auto-scaling based on metrics
- Predictive scaling algorithms

**4. Health Management**
- Container health monitoring
- Automatic restart policies
- Rolling updates and rollbacks
- Disaster recovery procedures

### Orchestration Patterns

**1. Leader-Follower Pattern**
```yaml
# Leader-follower database setup
version: '3.8'
services:
  postgres-leader:
    image: postgres:15
    environment:
      POSTGRES_REPLICATION_MODE: master
      POSTGRES_REPLICATION_USER: replicator
      POSTGRES_REPLICATION_PASSWORD: secret
    labels:
      - "role=leader"
      - "service=database"

  postgres-follower-1:
    image: postgres:15
    environment:
      POSTGRES_REPLICATION_MODE: slave
      POSTGRES_MASTER_HOST: postgres-leader
      POSTGRES_REPLICATION_USER: replicator
      POSTGRES_REPLICATION_PASSWORD: secret
    labels:
      - "role=follower"
      - "service=database"
    depends_on:
      - postgres-leader
```

**2. Circuit Breaker Pattern**
```javascript
// circuit-breaker.js - Implement circuit breaker for service calls
class CircuitBreaker {
    constructor(service, options = {}) {
        this.service = service;
        this.failureThreshold = options.failureThreshold || 5;
        this.resetTimeout = options.resetTimeout || 60000;
        this.state = 'CLOSED'; // CLOSED, OPEN, HALF_OPEN
        this.failureCount = 0;
        this.nextAttempt = Date.now();
    }
    
    async call(...args) {
        if (this.state === 'OPEN') {
            if (Date.now() < this.nextAttempt) {
                throw new Error('Circuit breaker is OPEN');
            }
            this.state = 'HALF_OPEN';
        }
        
        try {
            const result = await this.service(...args);
            this.onSuccess();
            return result;
        } catch (error) {
            this.onFailure();
            throw error;
        }
    }
    
    onSuccess() {
        this.failureCount = 0;
        this.state = 'CLOSED';
    }
    
    onFailure() {
        this.failureCount++;
        if (this.failureCount >= this.failureThreshold) {
            this.state = 'OPEN';
            this.nextAttempt = Date.now() + this.resetTimeout;
        }
    }
}
```

---

## 🔧 Part 2: Custom Scheduling Strategies

### Intelligent Container Placement

**Resource-Based Scheduling:**
```python
# scheduler.py - Custom container scheduler
import docker
import psutil
from typing import Dict, List, Optional

class ECommerceScheduler:
    def __init__(self):
        self.client = docker.from_env()
        self.nodes = self.discover_nodes()
        
    def discover_nodes(self) -> Dict:
        """Discover available nodes and their resources"""
        nodes = {}
        
        # For single-node setup, use local resources
        nodes['local'] = {
            'cpu_cores': psutil.cpu_count(),
            'memory_gb': psutil.virtual_memory().total / (1024**3),
            'disk_gb': psutil.disk_usage('/').total / (1024**3),
            'running_containers': len(self.client.containers.list()),
            'load_average': psutil.getloadavg()[0] if hasattr(psutil, 'getloadavg') else 0
        }
        
        return nodes
    
    def calculate_node_score(self, node_info: Dict, requirements: Dict) -> float:
        """Calculate placement score for a node"""
        score = 100.0
        
        # CPU utilization penalty
        cpu_usage = node_info['load_average'] / node_info['cpu_cores']
        if cpu_usage > 0.8:
            score -= 30
        elif cpu_usage > 0.6:
            score -= 15
        
        # Memory availability bonus
        memory_available = node_info['memory_gb'] - (node_info['memory_gb'] * 0.1)  # Reserve 10%
        if requirements.get('memory_gb', 0) < memory_available * 0.5:
            score += 10
        
        # Container density penalty
        if node_info['running_containers'] > 20:
            score -= 20
        
        return max(0, score)
    
    def schedule_container(self, container_config: Dict) -> str:
        """Schedule container to best available node"""
        best_node = None
        best_score = -1
        
        requirements = container_config.get('requirements', {})
        
        for node_name, node_info in self.nodes.items():
            score = self.calculate_node_score(node_info, requirements)
            
            if score > best_score:
                best_score = score
                best_node = node_name
        
        return best_node
```

### Affinity and Anti-Affinity Rules

**Service Placement Rules:**
```yaml
# docker-compose.affinity.yml
version: '3.8'

services:
  # Database should be on dedicated nodes
  ecommerce-database:
    image: postgres:15
    deploy:
      placement:
        constraints:
          - "node.labels.type==database"
        preferences:
          - spread: node.labels.zone
    labels:
      - "app=ecommerce"
      - "tier=database"

  # API services should be spread across zones
  ecommerce-api:
    image: ecommerce/api:latest
    deploy:
      replicas: 4
      placement:
        constraints:
          - "node.labels.type==compute"
        preferences:
          - spread: node.labels.zone
      update_config:
        parallelism: 1
        delay: 30s
        failure_action: rollback
    labels:
      - "app=ecommerce"
      - "tier=api"

  # Frontend should avoid database nodes
  ecommerce-frontend:
    image: ecommerce/frontend:latest
    deploy:
      replicas: 3
      placement:
        constraints:
          - "node.labels.type!=database"
    labels:
      - "app=ecommerce"
      - "tier=frontend"
```
    Memory int64   `json:"memory"`
    Disk   int64   `json:"disk"`
    GPU    int     `json:"gpu"`
}

type Workload struct {
    ID          string            `json:"id"`
    Name        string            `json:"name"`
    Image       string            `json:"image"`
    Resources   Resources         `json:"resources"`
    Constraints []Constraint      `json:"constraints"`
    Affinity    []AffinityRule    `json:"affinity"`
    Priority    int               `json:"priority"`
    Status      string            `json:"status"`
    NodeID      string            `json:"node_id"`
    CreatedAt   time.Time         `json:"created_at"`
}

type Constraint struct {
    Key      string `json:"key"`
    Operator string `json:"operator"`
    Values   []string `json:"values"`
}

type AffinityRule struct {
    Type     string            `json:"type"` // node, pod
    Weight   int               `json:"weight"`
    Selector map[string]string `json:"selector"`
}

type SchedulingPolicy interface {
    Name() string
    Score(node *Node, workload *Workload) float64
    Filter(node *Node, workload *Workload) bool
}

// Resource-based scheduling policy
type ResourcePolicy struct{}

func (p *ResourcePolicy) Name() string {
    return "resource-based"
}

func (p *ResourcePolicy) Filter(node *Node, workload *Workload) bool {
    return node.Available.CPU >= workload.Resources.CPU &&
           node.Available.Memory >= workload.Resources.Memory &&
           node.Available.Disk >= workload.Resources.Disk &&
           node.Available.GPU >= float64(workload.Resources.GPU)
}

func (p *ResourcePolicy) Score(node *Node, workload *Workload) float64 {
    // Score based on resource utilization balance
    cpuUtil := (node.Allocated.CPU + workload.Resources.CPU) / node.Capacity.CPU
    memUtil := float64(node.Allocated.Memory + workload.Resources.Memory) / float64(node.Capacity.Memory)
    
    // Prefer balanced utilization
    utilBalance := 1.0 - math.Abs(cpuUtil - memUtil)
    
    // Prefer nodes with more available resources
    resourceAvail := (node.Available.CPU / node.Capacity.CPU + 
                     float64(node.Available.Memory) / float64(node.Capacity.Memory)) / 2.0
    
    return (utilBalance * 0.6) + (resourceAvail * 0.4)
}

// Affinity-based scheduling policy
type AffinityPolicy struct{}

func (p *AffinityPolicy) Name() string {
    return "affinity-based"
}

func (p *AffinityPolicy) Filter(node *Node, workload *Workload) bool {
    // Check hard constraints
    for _, constraint := range workload.Constraints {
        if !p.evaluateConstraint(node, constraint) {
            return false
        }
    }
    return true
}

func (p *AffinityPolicy) evaluateConstraint(node *Node, constraint Constraint) bool {
    nodeValue, exists := node.Labels[constraint.Key]
    if !exists {
        return constraint.Operator == "NotIn"
    }
    
    switch constraint.Operator {
    case "In":
        for _, value := range constraint.Values {
            if nodeValue == value {
                return true
            }
        }
        return false
    case "NotIn":
        for _, value := range constraint.Values {
            if nodeValue == value {
                return false
            }
        }
        return true
    case "Exists":
        return exists
    case "DoesNotExist":
        return !exists
    }
    
    return false
}

func (p *AffinityPolicy) Score(node *Node, workload *Workload) float64 {
    score := 0.0
    totalWeight := 0
    
    for _, affinity := range workload.Affinity {
        if affinity.Type == "node" {
            matches := true
            for key, value := range affinity.Selector {
                if nodeValue, exists := node.Labels[key]; !exists || nodeValue != value {
                    matches = false
                    break
                }
            }
            
            if matches {
                score += float64(affinity.Weight)
            }
            totalWeight += affinity.Weight
        }
    }
    
    if totalWeight == 0 {
        return 0.5 // Neutral score
    }
    
    return score / float64(totalWeight)
}

// Performance-based scheduling policy
type PerformancePolicy struct {
    metrics *MetricsCollector
}

func (p *PerformancePolicy) Name() string {
    return "performance-based"
}

func (p *PerformancePolicy) Filter(node *Node, workload *Workload) bool {
    // Filter based on performance requirements
    if workload.Priority > 80 { // High priority workloads
        return node.Health == "healthy" && 
               p.metrics.GetNodePerformanceScore(node.ID) > 0.8
    }
    return node.Health == "healthy"
}

func (p *PerformancePolicy) Score(node *Node, workload *Workload) float64 {
    perfScore := p.metrics.GetNodePerformanceScore(node.ID)
    loadScore := 1.0 - p.metrics.GetNodeLoadScore(node.ID)
    
    // Weight performance higher for high-priority workloads
    if workload.Priority > 80 {
        return (perfScore * 0.7) + (loadScore * 0.3)
    }
    
    return (perfScore * 0.4) + (loadScore * 0.6)
}

func NewScheduler() (*Scheduler, error) {
    cli, err := client.NewClientWithOpts(client.FromEnv)
    if err != nil {
        return nil, err
    }

    metrics := NewMetricsCollector()
    
    scheduler := &Scheduler{
        client:    cli,
        nodes:     make(map[string]*Node),
        workloads: make(map[string]*Workload),
        metrics:   metrics,
        policies: []SchedulingPolicy{
            &ResourcePolicy{},
            &AffinityPolicy{},
            &PerformancePolicy{metrics: metrics},
        },
    }

    return scheduler, nil
}

func (s *Scheduler) ScheduleWorkload(workload *Workload) error {
    s.mutex.Lock()
    defer s.mutex.Unlock()

    // Find suitable nodes
    candidates := s.findCandidateNodes(workload)
    if len(candidates) == 0 {
        return fmt.Errorf("no suitable nodes found for workload %s", workload.Name)
    }

    // Score and rank nodes
    scoredNodes := s.scoreNodes(candidates, workload)
    
    // Select best node
    bestNode := scoredNodes[0]
    
    // Schedule workload on selected node
    if err := s.deployWorkload(workload, bestNode); err != nil {
        return err
    }

    // Update state
    workload.NodeID = bestNode.ID
    workload.Status = "scheduled"
    s.workloads[workload.ID] = workload

    // Update node resources
    s.updateNodeResources(bestNode, workload, true)

    log.Printf("Scheduled workload %s on node %s (score: %.2f)", 
               workload.Name, bestNode.ID, bestNode.Score)

    return nil
}

func (s *Scheduler) findCandidateNodes(workload *Workload) []*Node {
    var candidates []*Node

    for _, node := range s.nodes {
        suitable := true
        
        // Apply all filtering policies
        for _, policy := range s.policies {
            if !policy.Filter(node, workload) {
                suitable = false
                break
            }
        }
        
        if suitable {
            candidates = append(candidates, node)
        }
    }

    return candidates
}

func (s *Scheduler) scoreNodes(nodes []*Node, workload *Workload) []*Node {
    type ScoredNode struct {
        node  *Node
        score float64
    }

    var scoredNodes []ScoredNode

    for _, node := range nodes {
        totalScore := 0.0
        
        // Apply all scoring policies
        for _, policy := range s.policies {
            score := policy.Score(node, workload)
            totalScore += score
        }
        
        avgScore := totalScore / float64(len(s.policies))
        
        scoredNodes = append(scoredNodes, ScoredNode{
            node:  node,
            score: avgScore,
        })
    }

    // Sort by score (highest first)
    sort.Slice(scoredNodes, func(i, j int) bool {
        return scoredNodes[i].score > scoredNodes[j].score
    })

    // Extract nodes
    var result []*Node
    for _, sn := range scoredNodes {
        sn.node.Score = sn.score
        result = append(result, sn.node)
    }

    return result
}

func (s *Scheduler) deployWorkload(workload *Workload, node *Node) error {
    ctx := context.Background()

    // Create container configuration
    config := &container.Config{
        Image: workload.Image,
        Labels: map[string]string{
            "scheduler.workload.id":   workload.ID,
            "scheduler.workload.name": workload.Name,
            "scheduler.node.id":       node.ID,
        },
    }

    hostConfig := &container.HostConfig{
        Resources: container.Resources{
            Memory:   workload.Resources.Memory,
            NanoCPUs: int64(workload.Resources.CPU * 1e9),
        },
    }

    // Create and start container
    resp, err := s.client.ContainerCreate(ctx, config, hostConfig, nil, nil, workload.Name)
    if err != nil {
        return err
    }

    if err := s.client.ContainerStart(ctx, resp.ID, types.ContainerStartOptions{}); err != nil {
        return err
    }

    workload.ID = resp.ID
    return nil
}

func (s *Scheduler) updateNodeResources(node *Node, workload *Workload, allocate bool) {
    multiplier := 1.0
    if !allocate {
        multiplier = -1.0
    }

    node.Allocated.CPU += workload.Resources.CPU * multiplier
    node.Allocated.Memory += int64(float64(workload.Resources.Memory) * multiplier)
    node.Allocated.Disk += int64(float64(workload.Resources.Disk) * multiplier)
    node.Allocated.GPU += float64(workload.Resources.GPU) * multiplier

    // Update available resources
    node.Available.CPU = node.Capacity.CPU - node.Allocated.CPU
    node.Available.Memory = node.Capacity.Memory - node.Allocated.Memory
    node.Available.Disk = node.Capacity.Disk - node.Allocated.Disk
    node.Available.GPU = node.Capacity.GPU - node.Allocated.GPU
}

// Metrics collector for performance-based scheduling
type MetricsCollector struct {
    nodeMetrics map[string]*NodeMetrics
    mutex       sync.RWMutex
}

type NodeMetrics struct {
    CPUUsage    float64   `json:"cpu_usage"`
    MemoryUsage float64   `json:"memory_usage"`
    DiskIO      float64   `json:"disk_io"`
    NetworkIO   float64   `json:"network_io"`
    ResponseTime float64  `json:"response_time"`
    Timestamp   time.Time `json:"timestamp"`
}

func NewMetricsCollector() *MetricsCollector {
    return &MetricsCollector{
        nodeMetrics: make(map[string]*NodeMetrics),
    }
}

func (mc *MetricsCollector) GetNodePerformanceScore(nodeID string) float64 {
    mc.mutex.RLock()
    defer mc.mutex.RUnlock()

    metrics, exists := mc.nodeMetrics[nodeID]
    if !exists {
        return 0.5 // Default score
    }

    // Calculate performance score based on various metrics
    cpuScore := 1.0 - (metrics.CPUUsage / 100.0)
    memScore := 1.0 - (metrics.MemoryUsage / 100.0)
    responseScore := math.Max(0, 1.0 - (metrics.ResponseTime / 1000.0)) // Normalize to 1s

    return (cpuScore + memScore + responseScore) / 3.0
}

func (mc *MetricsCollector) GetNodeLoadScore(nodeID string) float64 {
    mc.mutex.RLock()
    defer mc.mutex.RUnlock()

    metrics, exists := mc.nodeMetrics[nodeID]
    if !exists {
        return 0.5
    }

    // Calculate load score
    loadScore := (metrics.CPUUsage + metrics.MemoryUsage) / 200.0
    return math.Min(1.0, loadScore)
}

func (mc *MetricsCollector) UpdateNodeMetrics(nodeID string, metrics *NodeMetrics) {
    mc.mutex.Lock()
    defer mc.mutex.Unlock()

    mc.nodeMetrics[nodeID] = metrics
}
```

### Multi-Cluster Management
```python
#!/usr/bin/env python3
# multi-cluster-manager.py - Manage containers across multiple clusters

import asyncio
import json
import time
from dataclasses import dataclass, asdict
from typing import Dict, List, Optional
import aiohttp
import docker

@dataclass
class Cluster:
    id: str
    name: str
    endpoint: str
    region: str
    capacity: Dict[str, float]
    utilization: Dict[str, float]
    health: str
    latency: float = 0.0

@dataclass
class WorkloadRequest:
    id: str
    name: str
    image: str
    resources: Dict[str, float]
    constraints: Dict[str, str]
    priority: int
    region_preference: Optional[str] = None

class MultiClusterManager:
    def __init__(self):
        self.clusters: Dict[str, Cluster] = {}
        self.workloads: Dict[str, dict] = {}
        self.placement_policies = []
        
    def register_cluster(self, cluster: Cluster):
        """Register a new cluster"""
        self.clusters[cluster.id] = cluster
        print(f"Registered cluster: {cluster.name} ({cluster.region})")
        
    def add_placement_policy(self, policy):
        """Add a workload placement policy"""
        self.placement_policies.append(policy)
        
    async def schedule_workload(self, workload: WorkloadRequest) -> str:
        """Schedule workload across clusters"""
        
        # Find suitable clusters
        suitable_clusters = await self.find_suitable_clusters(workload)
        
        if not suitable_clusters:
            raise Exception(f"No suitable clusters found for workload {workload.name}")
            
        # Score clusters
        scored_clusters = await self.score_clusters(suitable_clusters, workload)
        
        # Select best cluster
        best_cluster = scored_clusters[0]
        
        # Deploy workload
        deployment_result = await self.deploy_to_cluster(workload, best_cluster)
        
        # Track workload
        self.workloads[workload.id] = {
            'workload': asdict(workload),
            'cluster_id': best_cluster.id,
            'deployment_id': deployment_result['id'],
            'status': 'running',
            'scheduled_at': time.time()
        }
        
        print(f"Scheduled workload {workload.name} on cluster {best_cluster.name}")
        return deployment_result['id']
        
    async def find_suitable_clusters(self, workload: WorkloadRequest) -> List[Cluster]:
        """Find clusters that can accommodate the workload"""
        suitable = []
        
        for cluster in self.clusters.values():
            if await self.can_accommodate(cluster, workload):
                suitable.append(cluster)
                
        return suitable
        
    async def can_accommodate(self, cluster: Cluster, workload: WorkloadRequest) -> bool:
        """Check if cluster can accommodate workload"""
        
        # Check resource availability
        required_cpu = workload.resources.get('cpu', 0)
        required_memory = workload.resources.get('memory', 0)
        
        available_cpu = cluster.capacity['cpu'] - cluster.utilization['cpu']
        available_memory = cluster.capacity['memory'] - cluster.utilization['memory']
        
        if required_cpu > available_cpu or required_memory > available_memory:
            return False
            
        # Check health
        if cluster.health != 'healthy':
            return False
            
        # Check constraints
        for key, value in workload.constraints.items():
            if key == 'region' and cluster.region != value:
                return False
                
        return True
        
    async def score_clusters(self, clusters: List[Cluster], workload: WorkloadRequest) -> List[Cluster]:
        """Score and rank clusters for workload placement"""
        
        scored_clusters = []
        
        for cluster in clusters:
            score = await self.calculate_cluster_score(cluster, workload)
            scored_clusters.append((cluster, score))
            
        # Sort by score (highest first)
        scored_clusters.sort(key=lambda x: x[1], reverse=True)
        
        return [cluster for cluster, score in scored_clusters]
        
    async def calculate_cluster_score(self, cluster: Cluster, workload: WorkloadRequest) -> float:
        """Calculate placement score for cluster"""
        
        score = 0.0
        
        # Resource availability score (40%)
        cpu_avail = (cluster.capacity['cpu'] - cluster.utilization['cpu']) / cluster.capacity['cpu']
        mem_avail = (cluster.capacity['memory'] - cluster.utilization['memory']) / cluster.capacity['memory']
        resource_score = (cpu_avail + mem_avail) / 2.0
        score += resource_score * 0.4
        
        # Latency score (30%)
        latency_score = max(0, 1.0 - (cluster.latency / 1000.0))  # Normalize to 1s
        score += latency_score * 0.3
        
        # Region preference score (20%)
        region_score = 1.0 if workload.region_preference == cluster.region else 0.5
        score += region_score * 0.2
        
        # Load balancing score (10%)
        total_util = (cluster.utilization['cpu'] + cluster.utilization['memory']) / 2.0
        load_score = 1.0 - (total_util / 100.0)
        score += load_score * 0.1
        
        return score
        
    async def deploy_to_cluster(self, workload: WorkloadRequest, cluster: Cluster) -> dict:
        """Deploy workload to selected cluster"""
        
        deployment_config = {
            'name': workload.name,
            'image': workload.image,
            'resources': workload.resources,
            'priority': workload.priority
        }
        
        async with aiohttp.ClientSession() as session:
            async with session.post(
                f"{cluster.endpoint}/api/v1/workloads",
                json=deployment_config
            ) as response:
                if response.status == 201:
                    result = await response.json()
                    return result
                else:
                    raise Exception(f"Failed to deploy to cluster {cluster.name}: {response.status}")
                    
    async def monitor_clusters(self):
        """Monitor cluster health and metrics"""
        
        while True:
            tasks = []
            for cluster in self.clusters.values():
                tasks.append(self.update_cluster_metrics(cluster))
                
            await asyncio.gather(*tasks, return_exceptions=True)
            await asyncio.sleep(30)  # Update every 30 seconds
            
    async def update_cluster_metrics(self, cluster: Cluster):
        """Update cluster metrics"""
        
        try:
            async with aiohttp.ClientSession() as session:
                # Get cluster metrics
                async with session.get(f"{cluster.endpoint}/api/v1/metrics") as response:
                    if response.status == 200:
                        metrics = await response.json()
                        
                        cluster.utilization = metrics.get('utilization', {})
                        cluster.health = metrics.get('health', 'unknown')
                        cluster.latency = metrics.get('latency', 1000.0)
                        
                # Measure actual latency
                start_time = time.time()
                async with session.get(f"{cluster.endpoint}/api/v1/health") as response:
                    cluster.latency = (time.time() - start_time) * 1000
                    
        except Exception as e:
            print(f"Failed to update metrics for cluster {cluster.name}: {e}")
            cluster.health = 'unhealthy'
            
    async def rebalance_workloads(self):
        """Rebalance workloads across clusters"""
        
        while True:
            try:
                # Check for imbalanced clusters
                overloaded_clusters = []
                underutilized_clusters = []
                
                for cluster in self.clusters.values():
                    avg_util = (cluster.utilization.get('cpu', 0) + 
                              cluster.utilization.get('memory', 0)) / 2.0
                              
                    if avg_util > 80:  # Overloaded
                        overloaded_clusters.append(cluster)
                    elif avg_util < 30:  # Underutilized
                        underutilized_clusters.append(cluster)
                        
                # Migrate workloads from overloaded to underutilized clusters
                if overloaded_clusters and underutilized_clusters:
                    await self.migrate_workloads(overloaded_clusters, underutilized_clusters)
                    
            except Exception as e:
                print(f"Error during rebalancing: {e}")
                
            await asyncio.sleep(300)  # Rebalance every 5 minutes
            
    async def migrate_workloads(self, source_clusters: List[Cluster], target_clusters: List[Cluster]):
        """Migrate workloads between clusters"""
        
        for source_cluster in source_clusters:
            # Find workloads to migrate
            workloads_to_migrate = await self.find_migratable_workloads(source_cluster)
            
            for workload_info in workloads_to_migrate:
                # Find best target cluster
                best_target = await self.find_best_migration_target(
                    workload_info, target_clusters
                )
                
                if best_target:
                    await self.perform_migration(workload_info, source_cluster, best_target)
                    
    async def find_migratable_workloads(self, cluster: Cluster) -> List[dict]:
        """Find workloads that can be migrated from cluster"""
        
        migratable = []
        
        for workload_id, workload_info in self.workloads.items():
            if (workload_info['cluster_id'] == cluster.id and 
                workload_info['workload']['priority'] < 80):  # Don't migrate high priority
                migratable.append(workload_info)
                
        # Sort by priority (migrate lowest priority first)
        migratable.sort(key=lambda x: x['workload']['priority'])
        
        return migratable[:5]  # Limit migrations
        
    async def find_best_migration_target(self, workload_info: dict, target_clusters: List[Cluster]) -> Optional[Cluster]:
        """Find best target cluster for migration"""
        
        workload = WorkloadRequest(**workload_info['workload'])
        
        suitable_targets = []
        for cluster in target_clusters:
            if await self.can_accommodate(cluster, workload):
                suitable_targets.append(cluster)
                
        if not suitable_targets:
            return None
            
        # Score and select best target
        scored_targets = await self.score_clusters(suitable_targets, workload)
        return scored_targets[0] if scored_targets else None
        
    async def perform_migration(self, workload_info: dict, source_cluster: Cluster, target_cluster: Cluster):
        """Perform workload migration"""
        
        print(f"Migrating workload {workload_info['workload']['name']} from {source_cluster.name} to {target_cluster.name}")
        
        try:
            # Deploy to target cluster
            workload = WorkloadRequest(**workload_info['workload'])
            new_deployment = await self.deploy_to_cluster(workload, target_cluster)
            
            # Wait for new deployment to be ready
            await asyncio.sleep(10)
            
            # Remove from source cluster
            await self.remove_from_cluster(workload_info['deployment_id'], source_cluster)
            
            # Update tracking
            workload_info['cluster_id'] = target_cluster.id
            workload_info['deployment_id'] = new_deployment['id']
            
            print(f"Successfully migrated workload {workload_info['workload']['name']}")
            
        except Exception as e:
            print(f"Failed to migrate workload: {e}")
            
    async def remove_from_cluster(self, deployment_id: str, cluster: Cluster):
        """Remove workload from cluster"""
        
        async with aiohttp.ClientSession() as session:
            async with session.delete(f"{cluster.endpoint}/api/v1/workloads/{deployment_id}") as response:
                if response.status not in [200, 204, 404]:
                    raise Exception(f"Failed to remove workload from {cluster.name}")

async def main():
    manager = MultiClusterManager()
    
    # Register clusters
    clusters = [
        Cluster("us-east-1", "US East", "http://cluster1:8080", "us-east-1", 
                {"cpu": 1000, "memory": 2048}, {"cpu": 300, "memory": 512}, "healthy"),
        Cluster("us-west-2", "US West", "http://cluster2:8080", "us-west-2", 
                {"cpu": 800, "memory": 1536}, {"cpu": 200, "memory": 384}, "healthy"),
        Cluster("eu-west-1", "EU West", "http://cluster3:8080", "eu-west-1", 
                {"cpu": 600, "memory": 1024}, {"cpu": 150, "memory": 256}, "healthy"),
    ]
    
    for cluster in clusters:
        manager.register_cluster(cluster)
    
    # Start monitoring
    monitor_task = asyncio.create_task(manager.monitor_clusters())
    rebalance_task = asyncio.create_task(manager.rebalance_workloads())
    
    # Example workload scheduling
    workload = WorkloadRequest(
        id="web-app-1",
        name="web-application",
        image="nginx:latest",
        resources={"cpu": 100, "memory": 256},
        constraints={"region": "us-east-1"},
        priority=50
    )
    
    try:
        deployment_id = await manager.schedule_workload(workload)
        print(f"Workload scheduled with ID: {deployment_id}")
    except Exception as e:
        print(f"Failed to schedule workload: {e}")
    
    # Keep running
    await asyncio.gather(monitor_task, rebalance_task)

if __name__ == "__main__":
    asyncio.run(main())
```
---

## 🏗️ Part 3: E-Commerce Orchestration Implementation

### Multi-Environment Orchestration

**Production E-Commerce Orchestration:**
```yaml
# docker-compose.production.yml
version: '3.8'

services:
  # Load balancer with health checks
  nginx-lb:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./nginx/ssl:/etc/nginx/ssl
    deploy:
      replicas: 2
      placement:
        constraints:
          - "node.labels.type==edge"
      update_config:
        parallelism: 1
        delay: 10s
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # API tier with intelligent scaling
  ecommerce-api:
    image: ecommerce/api:latest
    deploy:
      replicas: 6
      placement:
        constraints:
          - "node.labels.type==compute"
        preferences:
          - spread: node.labels.zone
      resources:
        limits:
          cpus: '1.0'
          memory: 1G
        reservations:
          cpus: '0.25'
          memory: 512M
      update_config:
        parallelism: 2
        delay: 30s
        failure_action: rollback
        monitor: 60s
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
    environment:
      NODE_ENV: production
      DATABASE_URL: postgresql://postgres:password@postgres-leader:5432/ecommerce
      REDIS_URL: redis://redis-cluster:6379
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 15s
      timeout: 5s
      retries: 3
      start_period: 30s

  # Database cluster with leader-follower
  postgres-leader:
    image: postgres:15
    environment:
      POSTGRES_REPLICATION_MODE: master
      POSTGRES_REPLICATION_USER: replicator
      POSTGRES_REPLICATION_PASSWORD: replicator_password
      POSTGRES_DB: ecommerce
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_leader_data:/var/lib/postgresql/data
    deploy:
      placement:
        constraints:
          - "node.labels.type==database"
          - "node.labels.role==primary"
      resources:
        limits:
          cpus: '4.0'
          memory: 8G
        reservations:
          cpus: '2.0'
          memory: 4G

  postgres-follower:
    image: postgres:15
    environment:
      POSTGRES_REPLICATION_MODE: slave
      POSTGRES_MASTER_HOST: postgres-leader
      POSTGRES_REPLICATION_USER: replicator
      POSTGRES_REPLICATION_PASSWORD: replicator_password
    volumes:
      - postgres_follower_data:/var/lib/postgresql/data
    deploy:
      replicas: 2
      placement:
        constraints:
          - "node.labels.type==database"
          - "node.labels.role==secondary"
    depends_on:
      - postgres-leader

  # Redis cluster for caching
  redis-cluster:
    image: redis:7-alpine
    command: redis-server --cluster-enabled yes --cluster-config-file nodes.conf
    deploy:
      replicas: 6
      placement:
        constraints:
          - "node.labels.type==cache"
        preferences:
          - spread: node.labels.zone
    volumes:
      - redis_data:/data

volumes:
  postgres_leader_data:
    driver: local
  postgres_follower_data:
    driver: local
  redis_data:
    driver: local

networks:
  default:
    driver: overlay
    attachable: true
```

### Auto-Scaling Implementation

**Intelligent Auto-Scaling System:**
```python
# auto_scaler.py - Advanced auto-scaling for e-commerce
import docker
import time
import requests
import statistics
from typing import Dict, List

class ECommerceAutoScaler:
    def __init__(self):
        self.client = docker.from_env()
        self.scaling_policies = {
            'ecommerce-api': {
                'min_replicas': 3,
                'max_replicas': 20,
                'target_cpu': 70,
                'target_memory': 80,
                'scale_up_threshold': 80,
                'scale_down_threshold': 30,
                'cooldown_period': 300  # 5 minutes
            },
            'ecommerce-frontend': {
                'min_replicas': 2,
                'max_replicas': 10,
                'target_cpu': 60,
                'target_memory': 70,
                'scale_up_threshold': 75,
                'scale_down_threshold': 25,
                'cooldown_period': 180  # 3 minutes
            }
        }
        self.last_scale_time = {}
        
    def get_service_metrics(self, service_name: str) -> Dict:
        """Get current metrics for a service"""
        containers = self.client.containers.list(
            filters={'label': f'com.docker.compose.service={service_name}'}
        )
        
        if not containers:
            return {}
        
        cpu_percentages = []
        memory_percentages = []
        
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
                    cpu_percentages.append(cpu_percent)
                
                # Calculate memory percentage
                memory_usage = stats['memory_stats']['usage']
                memory_limit = stats['memory_stats']['limit']
                memory_percent = (memory_usage / memory_limit) * 100.0
                memory_percentages.append(memory_percent)
                
            except Exception as e:
                print(f"Error getting stats for {container.name}: {e}")
                continue
        
        return {
            'replica_count': len(containers),
            'avg_cpu': statistics.mean(cpu_percentages) if cpu_percentages else 0,
            'avg_memory': statistics.mean(memory_percentages) if memory_percentages else 0,
            'max_cpu': max(cpu_percentages) if cpu_percentages else 0,
            'max_memory': max(memory_percentages) if memory_percentages else 0
        }
    
    def should_scale(self, service_name: str, metrics: Dict) -> str:
        """Determine if service should scale up, down, or stay the same"""
        policy = self.scaling_policies.get(service_name)
        if not policy:
            return 'none'
        
        # Check cooldown period
        last_scale = self.last_scale_time.get(service_name, 0)
        if time.time() - last_scale < policy['cooldown_period']:
            return 'none'
        
        current_replicas = metrics['replica_count']
        avg_cpu = metrics['avg_cpu']
        avg_memory = metrics['avg_memory']
        
        # Scale up conditions
        if (avg_cpu > policy['scale_up_threshold'] or 
            avg_memory > policy['scale_up_threshold']) and \
           current_replicas < policy['max_replicas']:
            return 'up'
        
        # Scale down conditions
        if (avg_cpu < policy['scale_down_threshold'] and 
            avg_memory < policy['scale_down_threshold']) and \
           current_replicas > policy['min_replicas']:
            return 'down'
        
        return 'none'
    
    def scale_service(self, service_name: str, direction: str):
        """Scale service up or down"""
        try:
            # This would integrate with Docker Swarm or Compose
            # For demonstration, we'll show the concept
            current_replicas = len(self.client.containers.list(
                filters={'label': f'com.docker.compose.service={service_name}'}
            ))
            
            if direction == 'up':
                new_replicas = min(
                    current_replicas + 1,
                    self.scaling_policies[service_name]['max_replicas']
                )
            else:  # direction == 'down'
                new_replicas = max(
                    current_replicas - 1,
                    self.scaling_policies[service_name]['min_replicas']
                )
            
            print(f"Scaling {service_name} from {current_replicas} to {new_replicas}")
            
            # Update last scale time
            self.last_scale_time[service_name] = time.time()
            
            # In production, this would call Docker Swarm API:
            # docker service update --replicas {new_replicas} {service_name}
            
        except Exception as e:
            print(f"Error scaling {service_name}: {e}")
    
    def run_scaling_loop(self):
        """Main scaling loop"""
        print("🚀 Starting auto-scaling monitor...")
        
        while True:
            try:
                for service_name in self.scaling_policies.keys():
                    metrics = self.get_service_metrics(service_name)
                    
                    if metrics:
                        print(f"📊 {service_name}: {metrics['replica_count']} replicas, "
                              f"CPU: {metrics['avg_cpu']:.1f}%, "
                              f"Memory: {metrics['avg_memory']:.1f}%")
                        
                        scale_decision = self.should_scale(service_name, metrics)
                        
                        if scale_decision != 'none':
                            self.scale_service(service_name, scale_decision)
                
                time.sleep(30)  # Check every 30 seconds
                
            except KeyboardInterrupt:
                print("Stopping auto-scaler...")
                break
            except Exception as e:
                print(f"Error in scaling loop: {e}")
                time.sleep(60)

if __name__ == "__main__":
    scaler = ECommerceAutoScaler()
    scaler.run_scaling_loop()
```

---

## 🔄 Part 4: Service Discovery and Load Balancing

### Dynamic Service Discovery

**Service Registry Implementation:**
```python
# service_registry.py - Dynamic service discovery
import docker
import json
import time
from typing import Dict, List

class ServiceRegistry:
    def __init__(self):
        self.client = docker.from_env()
        self.services = {}
        self.health_checks = {}
        
    def discover_services(self) -> Dict:
        """Discover all running services"""
        containers = self.client.containers.list()
        services = {}
        
        for container in containers:
            labels = container.labels
            service_name = labels.get('com.docker.compose.service')
            
            if service_name:
                if service_name not in services:
                    services[service_name] = []
                
                # Get container network information
                networks = container.attrs['NetworkSettings']['Networks']
                for network_name, network_info in networks.items():
                    ip_address = network_info['IPAddress']
                    if ip_address:
                        services[service_name].append({
                            'container_id': container.short_id,
                            'container_name': container.name,
                            'ip_address': ip_address,
                            'status': container.status,
                            'labels': labels,
                            'ports': self.get_exposed_ports(container)
                        })
        
        return services
    
    def get_exposed_ports(self, container) -> List[int]:
        """Get exposed ports for a container"""
        ports = []
        port_bindings = container.attrs['NetworkSettings']['Ports']
        
        for port_spec, bindings in port_bindings.items():
            if bindings:
                port = int(port_spec.split('/')[0])
                ports.append(port)
        
        return ports
    
    def generate_nginx_config(self, services: Dict) -> str:
        """Generate nginx configuration for load balancing"""
        config = """
events {
    worker_connections 1024;
}

http {
    upstream api_backend {
"""
        
        # Add API service instances
        api_services = services.get('ecommerce-api', [])
        for service in api_services:
            if service['status'] == 'running':
                config += f"        server {service['ip_address']}:3000;\n"
        
        config += """    }
    
    upstream frontend_backend {
"""
        
        # Add frontend service instances
        frontend_services = services.get('ecommerce-frontend', [])
        for service in frontend_services:
            if service['status'] == 'running':
                config += f"        server {service['ip_address']}:80;\n"
        
        config += """    }
    
    server {
        listen 80;
        
        location /api/ {
            proxy_pass http://api_backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
        
        location / {
            proxy_pass http://frontend_backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
    }
}
"""
        return config
    
    def update_load_balancer(self):
        """Update load balancer configuration"""
        services = self.discover_services()
        nginx_config = self.generate_nginx_config(services)
        
        # Write configuration to file
        with open('/tmp/nginx.conf', 'w') as f:
            f.write(nginx_config)
        
        # Reload nginx configuration
        try:
            nginx_containers = self.client.containers.list(
                filters={'label': 'service=nginx'}
            )
            
            for container in nginx_containers:
                # Copy new config and reload
                container.exec_run('nginx -s reload')
                print("✅ Nginx configuration reloaded")
                
        except Exception as e:
            print(f"Error updating load balancer: {e}")
```

---

## 🧪 Part 5: Hands-On Orchestration Labs

### Lab 1: Custom Scheduler Implementation

**Build a simple container scheduler:**
```python
# simple_scheduler.py
import docker
import random
from typing import Dict, List

class SimpleScheduler:
    def __init__(self):
        self.client = docker.from_env()
        
    def get_node_resources(self) -> Dict:
        """Get current node resource usage"""
        import psutil
        
        return {
            'cpu_percent': psutil.cpu_percent(interval=1),
            'memory_percent': psutil.virtual_memory().percent,
            'disk_percent': psutil.disk_usage('/').percent,
            'load_average': psutil.getloadavg()[0] if hasattr(psutil, 'getloadavg') else 0
        }
    
    def schedule_container(self, image: str, **kwargs) -> str:
        """Schedule container based on resource availability"""
        resources = self.get_node_resources()
        
        # Simple scheduling logic
        if resources['cpu_percent'] > 80:
            print("⚠️ High CPU usage, delaying container start")
            return None
        
        if resources['memory_percent'] > 90:
            print("⚠️ High memory usage, cannot start container")
            return None
        
        # Start container
        container = self.client.containers.run(
            image=image,
            detach=True,
            **kwargs
        )
        
        print(f"✅ Scheduled container {container.short_id} on node")
        return container.id

# Test the scheduler
scheduler = SimpleScheduler()
container_id = scheduler.schedule_container(
    'nginx:alpine',
    name='test-nginx',
    ports={'80/tcp': 8080}
)
```

### Lab 2: Health Check and Auto-Recovery

**Implement service health monitoring:**
```python
# health_monitor.py
import docker
import time
import requests
from typing import Dict

class HealthMonitor:
    def __init__(self):
        self.client = docker.from_env()
        self.unhealthy_containers = {}
        
    def check_container_health(self, container) -> bool:
        """Check if container is healthy"""
        try:
            # Check container status
            container.reload()
            if container.status != 'running':
                return False
            
            # Check health endpoint if available
            health_endpoint = container.labels.get('health.endpoint')
            if health_endpoint:
                response = requests.get(health_endpoint, timeout=5)
                return response.status_code == 200
            
            return True
            
        except Exception as e:
            print(f"Health check failed for {container.name}: {e}")
            return False
    
    def recover_container(self, container):
        """Attempt to recover unhealthy container"""
        try:
            print(f"🔄 Attempting to recover {container.name}")
            
            # Try restart first
            container.restart()
            time.sleep(10)
            
            # Check if recovery was successful
            if self.check_container_health(container):
                print(f"✅ Successfully recovered {container.name}")
                if container.id in self.unhealthy_containers:
                    del self.unhealthy_containers[container.id]
            else:
                print(f"❌ Recovery failed for {container.name}")
                
        except Exception as e:
            print(f"Error recovering {container.name}: {e}")
    
    def monitor_services(self):
        """Main monitoring loop"""
        print("🔍 Starting health monitoring...")
        
        while True:
            try:
                containers = self.client.containers.list(
                    filters={'label': 'app=ecommerce'}
                )
                
                for container in containers:
                    is_healthy = self.check_container_health(container)
                    
                    if not is_healthy:
                        if container.id not in self.unhealthy_containers:
                            self.unhealthy_containers[container.id] = time.time()
                            print(f"⚠️ Container {container.name} is unhealthy")
                        else:
                            # If unhealthy for more than 60 seconds, attempt recovery
                            unhealthy_duration = time.time() - self.unhealthy_containers[container.id]
                            if unhealthy_duration > 60:
                                self.recover_container(container)
                    else:
                        # Remove from unhealthy list if recovered
                        if container.id in self.unhealthy_containers:
                            del self.unhealthy_containers[container.id]
                            print(f"✅ Container {container.name} is healthy again")
                
                time.sleep(30)  # Check every 30 seconds
                
            except KeyboardInterrupt:
                print("Stopping health monitor...")
                break
            except Exception as e:
                print(f"Error in monitoring loop: {e}")
                time.sleep(60)

if __name__ == "__main__":
    monitor = HealthMonitor()
    monitor.monitor_services()
```

---

## 🎓 Module Summary

You've mastered advanced orchestration patterns by learning:

**Core Concepts:**
- Container orchestration fundamentals and patterns
- Custom scheduling algorithms and placement strategies
- Service discovery and load balancing techniques

**Practical Skills:**
- Implementing intelligent workload distribution
- Building auto-scaling systems for e-commerce applications
- Creating health monitoring and auto-recovery solutions

**Enterprise Techniques:**
- Production-ready orchestration configurations
- Advanced placement constraints and preferences
- Dynamic service discovery and configuration management

**Next Steps:**
- Implement orchestration solutions for your e-commerce platform
- Build custom scheduling and monitoring tools
- Prepare for Module 8: Container Image Optimization

---

## 📚 Additional Resources

- [Docker Swarm Documentation](https://docs.docker.com/engine/swarm/)
- [Container Orchestration Patterns](https://kubernetes.io/docs/concepts/overview/working-with-objects/)
- [Service Discovery Best Practices](https://microservices.io/patterns/service-registry.html)
- [Load Balancing Strategies](https://nginx.org/en/docs/http/load_balancing.html)
