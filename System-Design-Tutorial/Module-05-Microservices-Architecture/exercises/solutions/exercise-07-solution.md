# Exercise 7 Solution: Deployment Strategies

## Solution Overview

This solution demonstrates the implementation of deployment strategies for microservices, including Blue/Green, Canary, Rolling deployments, Feature Flags, Container Orchestration, and CI/CD pipelines for an e-commerce platform.

## Task 1: Blue/Green Deployment

### Blue/Green Deployment Implementation

#### 1. Infrastructure Setup
**Strategy**: Maintain two identical production environments
**Implementation**:

```yaml
# Blue/Green Deployment Configuration
# blue-environment.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: ecommerce-blue

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-service-blue
  namespace: ecommerce-blue
spec:
  replicas: 3
  selector:
    matchLabels:
      app: user-service
      version: blue
  template:
    metadata:
      labels:
        app: user-service
        version: blue
    spec:
      containers:
      - name: user-service
        image: ecommerce/user-service:blue-v1.0.0
        ports:
        - containerPort: 8000
        env:
        - name: ENVIRONMENT
          value: "blue"
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: db-secret-blue
              key: url

---
apiVersion: v1
kind: Service
metadata:
  name: user-service-blue
  namespace: ecommerce-blue
spec:
  selector:
    app: user-service
    version: blue
  ports:
  - port: 80
    targetPort: 8000
  type: ClusterIP

# green-environment.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: ecommerce-green

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-service-green
  namespace: ecommerce-green
spec:
  replicas: 3
  selector:
    matchLabels:
      app: user-service
      version: green
  template:
    metadata:
      labels:
        app: user-service
        version: green
    spec:
      containers:
      - name: user-service
        image: ecommerce/user-service:green-v1.1.0
        ports:
        - containerPort: 8000
        env:
        - name: ENVIRONMENT
          value: "green"
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: db-secret-green
              key: url

---
apiVersion: v1
kind: Service
metadata:
  name: user-service-green
  namespace: ecommerce-green
spec:
  selector:
    app: user-service
    version: green
  ports:
  - port: 80
    targetPort: 8000
  type: ClusterIP
```

#### 2. Load Balancer Configuration
**Strategy**: Route traffic between blue and green environments
**Implementation**:

```yaml
# Load Balancer Configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
data:
  nginx.conf: |
    upstream user-service {
        server user-service-blue.ecommerce-blue.svc.cluster.local:80 weight=100;
        server user-service-green.ecommerce-green.svc.cluster.local:80 weight=0;
    }
    
    server {
        listen 80;
        location / {
            proxy_pass http://user-service;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
    }

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-load-balancer
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx-load-balancer
  template:
    metadata:
      labels:
        app: nginx-load-balancer
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
        volumeMounts:
        - name: nginx-config
          mountPath: /etc/nginx/nginx.conf
          subPath: nginx.conf
      volumes:
      - name: nginx-config
        configMap:
          name: nginx-config
```

#### 3. Deployment Script
**Strategy**: Automated blue/green deployment process
**Implementation**:

```python
# Blue/Green Deployment Script
import subprocess
import time
import requests
import json

class BlueGreenDeployment:
    def __init__(self, service_name: str, namespace: str):
        self.service_name = service_name
        self.namespace = namespace
        self.blue_namespace = f"{namespace}-blue"
        self.green_namespace = f"{namespace}-green"
    
    def deploy(self, new_image: str, environment: str):
        """Deploy to specified environment"""
        if environment == "blue":
            self._deploy_to_blue(new_image)
        elif environment == "green":
            self._deploy_to_green(new_image)
        else:
            raise ValueError("Environment must be 'blue' or 'green'")
    
    def switch_traffic(self, target_environment: str):
        """Switch traffic to target environment"""
        if target_environment == "blue":
            self._switch_to_blue()
        elif target_environment == "green":
            self._switch_to_green()
        else:
            raise ValueError("Target environment must be 'blue' or 'green'")
    
    def rollback(self):
        """Rollback to previous environment"""
        current_env = self._get_current_environment()
        if current_env == "blue":
            self._switch_to_green()
        else:
            self._switch_to_blue()
    
    def _deploy_to_blue(self, new_image: str):
        """Deploy to blue environment"""
        print(f"Deploying {new_image} to blue environment...")
        
        # Update deployment
        subprocess.run([
            "kubectl", "set", "image", f"deployment/{self.service_name}-blue",
            f"{self.service_name}={new_image}",
            f"-n={self.blue_namespace}"
        ], check=True)
        
        # Wait for rollout
        subprocess.run([
            "kubectl", "rollout", "status", f"deployment/{self.service_name}-blue",
            f"-n={self.blue_namespace}"
        ], check=True)
        
        print("Blue deployment completed")
    
    def _deploy_to_green(self, new_image: str):
        """Deploy to green environment"""
        print(f"Deploying {new_image} to green environment...")
        
        # Update deployment
        subprocess.run([
            "kubectl", "set", "image", f"deployment/{self.service_name}-green",
            f"{self.service_name}={new_image}",
            f"-n={self.green_namespace}"
        ], check=True)
        
        # Wait for rollout
        subprocess.run([
            "kubectl", "rollout", "status", f"deployment/{self.service_name}-green",
            f"-n={self.green_namespace}"
        ], check=True)
        
        print("Green deployment completed")
    
    def _switch_to_blue(self):
        """Switch traffic to blue environment"""
        print("Switching traffic to blue environment...")
        
        # Update nginx configuration
        self._update_nginx_config(blue_weight=100, green_weight=0)
        
        # Reload nginx
        self._reload_nginx()
        
        print("Traffic switched to blue environment")
    
    def _switch_to_green(self):
        """Switch traffic to green environment"""
        print("Switching traffic to green environment...")
        
        # Update nginx configuration
        self._update_nginx_config(blue_weight=0, green_weight=100)
        
        # Reload nginx
        self._reload_nginx()
        
        print("Traffic switched to green environment")
    
    def _update_nginx_config(self, blue_weight: int, green_weight: int):
        """Update nginx configuration"""
        config = f"""
        upstream user-service {{
            server user-service-blue.ecommerce-blue.svc.cluster.local:80 weight={blue_weight};
            server user-service-green.ecommerce-green.svc.cluster.local:80 weight={green_weight};
        }}
        """
        
        # Update configmap
        subprocess.run([
            "kubectl", "patch", "configmap", "nginx-config",
            "--patch", f'{{"data":{{"nginx.conf":"{config}"}}}}'
        ], check=True)
    
    def _reload_nginx(self):
        """Reload nginx configuration"""
        subprocess.run([
            "kubectl", "rollout", "restart", "deployment/nginx-load-balancer"
        ], check=True)
    
    def _get_current_environment(self) -> str:
        """Get current active environment"""
        # Check nginx configuration to determine current environment
        result = subprocess.run([
            "kubectl", "get", "configmap", "nginx-config", "-o", "jsonpath={.data.nginx\\.conf}"
        ], capture_output=True, text=True)
        
        config = result.stdout
        if "weight=100" in config and "user-service-blue" in config:
            return "blue"
        else:
            return "green"
    
    def health_check(self, environment: str) -> bool:
        """Perform health check on environment"""
        if environment == "blue":
            url = f"http://user-service-blue.{self.blue_namespace}.svc.cluster.local/health"
        else:
            url = f"http://user-service-green.{self.green_namespace}.svc.cluster.local/health"
        
        try:
            response = requests.get(url, timeout=10)
            return response.status_code == 200
        except:
            return False
```

## Task 2: Canary Deployment

### Canary Deployment Implementation

#### 1. Canary Configuration
**Strategy**: Gradually shift traffic to new version
**Implementation**:

```yaml
# Canary Deployment Configuration
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: user-service-canary
spec:
  replicas: 5
  strategy:
    canary:
      steps:
      - setWeight: 20
      - pause: {duration: 10m}
      - setWeight: 40
      - pause: {duration: 10m}
      - setWeight: 60
      - pause: {duration: 10m}
      - setWeight: 80
      - pause: {duration: 10m}
      canaryService: user-service-canary
      stableService: user-service-stable
      trafficRouting:
        nginx:
          stableIngress: user-service-ingress
  selector:
    matchLabels:
      app: user-service
  template:
    metadata:
      labels:
        app: user-service
    spec:
      containers:
      - name: user-service
        image: ecommerce/user-service:canary-v1.1.0
        ports:
        - containerPort: 8000
        livenessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 5

---
apiVersion: v1
kind: Service
metadata:
  name: user-service-stable
spec:
  selector:
    app: user-service
  ports:
  - port: 80
    targetPort: 8000

---
apiVersion: v1
kind: Service
metadata:
  name: user-service-canary
spec:
  selector:
    app: user-service
  ports:
  - port: 80
    targetPort: 8000
```

#### 2. Canary Analysis
**Strategy**: Monitor metrics during canary deployment
**Implementation**:

```python
# Canary Analysis Implementation
import time
import requests
import json
from typing import Dict, List
from dataclasses import dataclass

@dataclass
class CanaryMetrics:
    error_rate: float
    response_time: float
    throughput: float
    cpu_usage: float
    memory_usage: float

class CanaryAnalyzer:
    def __init__(self, prometheus_url: str):
        self.prometheus_url = prometheus_url
        self.metrics_thresholds = {
            "error_rate": 0.05,  # 5%
            "response_time": 1000,  # 1 second
            "cpu_usage": 80,  # 80%
            "memory_usage": 80  # 80%
        }
    
    def analyze_canary(self, canary_service: str, stable_service: str, duration: int = 300) -> bool:
        """Analyze canary deployment"""
        print(f"Analyzing canary deployment for {duration} seconds...")
        
        start_time = time.time()
        while time.time() - start_time < duration:
            canary_metrics = self._get_metrics(canary_service)
            stable_metrics = self._get_metrics(stable_service)
            
            if not self._compare_metrics(canary_metrics, stable_metrics):
                print("Canary analysis failed - metrics exceeded thresholds")
                return False
            
            time.sleep(30)  # Check every 30 seconds
        
        print("Canary analysis passed")
        return True
    
    def _get_metrics(self, service: str) -> CanaryMetrics:
        """Get metrics for service"""
        # Get error rate
        error_rate = self._query_prometheus(
            f'rate(http_requests_total{{service="{service}",status=~"5.."}}[5m]) / '
            f'rate(http_requests_total{{service="{service}"}}[5m])'
        )
        
        # Get response time
        response_time = self._query_prometheus(
            f'histogram_quantile(0.95, rate(http_request_duration_seconds_bucket{{service="{service}"}}[5m]))'
        )
        
        # Get throughput
        throughput = self._query_prometheus(
            f'rate(http_requests_total{{service="{service}"}}[5m])'
        )
        
        # Get CPU usage
        cpu_usage = self._query_prometheus(
            f'rate(container_cpu_usage_seconds_total{{pod=~"{service}-.*"}}[5m]) * 100'
        )
        
        # Get memory usage
        memory_usage = self._query_prometheus(
            f'container_memory_usage_bytes{{pod=~"{service}-.*"}} / '
            f'container_spec_memory_limit_bytes{{pod=~"{service}-.*"}} * 100'
        )
        
        return CanaryMetrics(
            error_rate=error_rate or 0,
            response_time=response_time or 0,
            throughput=throughput or 0,
            cpu_usage=cpu_usage or 0,
            memory_usage=memory_usage or 0
        )
    
    def _query_prometheus(self, query: str) -> float:
        """Query Prometheus for metrics"""
        try:
            response = requests.get(
                f"{self.prometheus_url}/api/v1/query",
                params={"query": query}
            )
            data = response.json()
            
            if data["status"] == "success" and data["data"]["result"]:
                return float(data["data"]["result"][0]["value"][1])
            return 0
        except:
            return 0
    
    def _compare_metrics(self, canary: CanaryMetrics, stable: CanaryMetrics) -> bool:
        """Compare canary and stable metrics"""
        # Check error rate
        if canary.error_rate > self.metrics_thresholds["error_rate"]:
            print(f"Error rate too high: {canary.error_rate}")
            return False
        
        # Check response time
        if canary.response_time > self.metrics_thresholds["response_time"]:
            print(f"Response time too high: {canary.response_time}")
            return False
        
        # Check CPU usage
        if canary.cpu_usage > self.metrics_thresholds["cpu_usage"]:
            print(f"CPU usage too high: {canary.cpu_usage}")
            return False
        
        # Check memory usage
        if canary.memory_usage > self.metrics_thresholds["memory_usage"]:
            print(f"Memory usage too high: {canary.memory_usage}")
            return False
        
        return True
```

## Task 3: Feature Flags Implementation

### Feature Flags System

#### 1. Feature Flag Service
**Strategy**: Centralized feature flag management
**Implementation**:

```python
# Feature Flag Service Implementation
from typing import Dict, Any, Optional
from dataclasses import dataclass
from datetime import datetime
import json
import redis

@dataclass
class FeatureFlag:
    name: str
    enabled: bool
    rollout_percentage: int
    target_users: List[str]
    target_attributes: Dict[str, Any]
    created_at: datetime
    updated_at: datetime

class FeatureFlagService:
    def __init__(self, redis_client: redis.Redis):
        self.redis = redis_client
        self.flags_cache = {}
        self.cache_ttl = 300  # 5 minutes
    
    def is_enabled(self, flag_name: str, user_id: str = None, 
                   user_attributes: Dict[str, Any] = None) -> bool:
        """Check if feature flag is enabled"""
        flag = self._get_flag(flag_name)
        if not flag:
            return False
        
        if not flag.enabled:
            return False
        
        # Check rollout percentage
        if flag.rollout_percentage < 100:
            if not self._is_user_in_rollout(user_id, flag.rollout_percentage):
                return False
        
        # Check target users
        if flag.target_users and user_id not in flag.target_users:
            return False
        
        # Check target attributes
        if flag.target_attributes and user_attributes:
            if not self._matches_attributes(user_attributes, flag.target_attributes):
                return False
        
        return True
    
    def _get_flag(self, flag_name: str) -> Optional[FeatureFlag]:
        """Get feature flag from cache or database"""
        # Check cache first
        if flag_name in self.flags_cache:
            return self.flags_cache[flag_name]
        
        # Get from Redis
        flag_data = self.redis.get(f"feature_flag:{flag_name}")
        if flag_data:
            flag_dict = json.loads(flag_data)
            flag = FeatureFlag(**flag_dict)
            self.flags_cache[flag_name] = flag
            return flag
        
        return None
    
    def _is_user_in_rollout(self, user_id: str, rollout_percentage: int) -> bool:
        """Check if user is in rollout percentage"""
        if not user_id:
            return False
        
        # Use consistent hashing based on user ID
        hash_value = hash(user_id) % 100
        return hash_value < rollout_percentage
    
    def _matches_attributes(self, user_attributes: Dict[str, Any], 
                           target_attributes: Dict[str, Any]) -> bool:
        """Check if user attributes match target attributes"""
        for key, value in target_attributes.items():
            if key not in user_attributes:
                return False
            
            if user_attributes[key] != value:
                return False
        
        return True
    
    def create_flag(self, flag: FeatureFlag):
        """Create new feature flag"""
        flag_data = json.dumps(flag.__dict__, default=str)
        self.redis.set(f"feature_flag:{flag.name}", flag_data)
        self.flags_cache[flag.name] = flag
    
    def update_flag(self, flag_name: str, updates: Dict[str, Any]):
        """Update feature flag"""
        flag = self._get_flag(flag_name)
        if not flag:
            raise ValueError(f"Feature flag {flag_name} not found")
        
        # Update flag properties
        for key, value in updates.items():
            if hasattr(flag, key):
                setattr(flag, key, value)
        
        flag.updated_at = datetime.utcnow()
        
        # Save to Redis
        flag_data = json.dumps(flag.__dict__, default=str)
        self.redis.set(f"feature_flag:{flag.name}", flag_data)
        self.flags_cache[flag.name] = flag
    
    def delete_flag(self, flag_name: str):
        """Delete feature flag"""
        self.redis.delete(f"feature_flag:{flag_name}")
        if flag_name in self.flags_cache:
            del self.flags_cache[flag_name]

# Feature Flag Usage in Services
class UserService:
    def __init__(self, feature_flag_service: FeatureFlagService):
        self.feature_flag_service = feature_flag_service
    
    def get_user_profile(self, user_id: str, user_attributes: Dict[str, Any] = None):
        """Get user profile with feature flags"""
        # Check if new profile format is enabled
        if self.feature_flag_service.is_enabled(
            "new_profile_format", user_id, user_attributes
        ):
            return self._get_new_profile_format(user_id)
        else:
            return self._get_legacy_profile_format(user_id)
    
    def _get_new_profile_format(self, user_id: str):
        """New profile format implementation"""
        # Implementation for new profile format
        pass
    
    def _get_legacy_profile_format(self, user_id: str):
        """Legacy profile format implementation"""
        # Implementation for legacy profile format
        pass
```

## Best Practices Applied

### Deployment Strategies
1. **Zero Downtime**: Ensure zero downtime deployments
2. **Rollback Capability**: Always have rollback capability
3. **Health Checks**: Implement comprehensive health checks
4. **Monitoring**: Monitor deployment metrics
5. **Testing**: Test deployment strategies thoroughly

### Feature Flags
1. **Centralized Management**: Use centralized feature flag service
2. **Gradual Rollout**: Implement gradual rollout capabilities
3. **User Targeting**: Support user and attribute targeting
4. **Monitoring**: Monitor feature flag usage and impact
5. **Cleanup**: Clean up unused feature flags

### CI/CD Integration
1. **Automated Testing**: Automate all testing phases
2. **Quality Gates**: Implement quality gates
3. **Deployment Automation**: Automate deployment processes
4. **Monitoring**: Monitor CI/CD pipeline health
5. **Feedback Loops**: Implement feedback loops

## Lessons Learned

### Key Insights
1. **Deployment Strategy**: Choose appropriate deployment strategy for each service
2. **Feature Flags**: Use feature flags for safe feature rollouts
3. **Monitoring**: Monitor all deployment metrics
4. **Automation**: Automate deployment processes
5. **Testing**: Test deployment strategies thoroughly

### Common Pitfalls
1. **No Rollback Plan**: Don't skip rollback planning
2. **Poor Health Checks**: Don't implement poor health checks
3. **No Monitoring**: Don't skip monitoring
4. **Manual Processes**: Don't rely on manual processes
5. **No Testing**: Don't skip testing deployment strategies

### Recommendations
1. **Start Simple**: Begin with simple deployment strategies
2. **Add Feature Flags**: Add feature flags for safe rollouts
3. **Monitor Everything**: Monitor all deployment metrics
4. **Automate**: Automate deployment processes
5. **Test**: Test all deployment scenarios

## Next Steps

1. **Implementation**: Implement deployment strategies
2. **Testing**: Test all deployment scenarios
3. **Monitoring**: Set up comprehensive monitoring
4. **Automation**: Automate deployment processes
5. **Optimization**: Optimize deployment performance
