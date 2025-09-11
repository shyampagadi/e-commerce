# Interactive Labs - Module 01

## Lab 1: Auto Scaling Performance Simulator
**Duration**: 60 minutes | **Hands-on Experience**

### Setup
```bash
# Clone scaling simulator
git clone https://github.com/system-design-tutorial/scaling-simulator.git
cd scaling-simulator
docker-compose up -d
```

### Interactive Components
1. **Scaling Algorithm Comparison**: Test different scaling policies (target tracking, step, simple)
2. **Load Pattern Simulation**: Apply various traffic patterns (steady, spike, seasonal)
3. **Cost vs Performance Analysis**: Compare scaling strategies with cost implications
4. **Failure Scenario Testing**: Inject instance failures and observe scaling behavior

### Expected Outcomes
- Understand scaling algorithm trade-offs through real testing
- Optimize scaling policies for different workload patterns
- Calculate cost impact of different scaling strategies

## Lab 2: Compute Cost Optimizer
**Duration**: 45 minutes | **Real-world Application**

### Interactive Cost Calculator
```python
class ComputeCostOptimizer:
    def __init__(self):
        self.pricing = {
            'on_demand': {'m5.large': 0.096, 'm5.xlarge': 0.192},
            'reserved_1yr': {'m5.large': 0.062, 'm5.xlarge': 0.124},
            'spot': {'m5.large': 0.029, 'm5.xlarge': 0.058},
            'lambda': {'per_request': 0.0000002, 'per_gb_second': 0.0000166667}
        }
    
    def analyze_workload(self, workload_pattern):
        recommendations = []
        
        for compute_type, pricing in self.pricing.items():
            total_cost = self.calculate_cost(workload_pattern, pricing)
            recommendations.append({
                'type': compute_type,
                'monthly_cost': total_cost,
                'savings': self.calculate_savings(total_cost, self.pricing['on_demand']),
                'suitability': self.assess_suitability(compute_type, workload_pattern)
            })
        
        return sorted(recommendations, key=lambda x: x['monthly_cost'])
```

### Real-world Scenarios
- **E-commerce Platform**: Variable traffic with Black Friday spikes
- **Data Processing**: Batch jobs running 4 hours daily
- **API Backend**: Steady traffic with 30% growth annually

## Lab 3: Container Orchestration Simulator
**Duration**: 75 minutes | **Advanced Implementation**

### ECS vs EKS Comparison
```bash
# Deploy same application on both platforms
./deploy-to-ecs.sh --app web-service --replicas 3
./deploy-to-eks.sh --app web-service --replicas 3

# Compare resource utilization
kubectl top nodes  # EKS
aws ecs describe-services --cluster web-cluster  # ECS
```

### Performance Benchmarking
- **Startup Time**: Measure container startup across platforms
- **Resource Efficiency**: Compare CPU/memory utilization
- **Scaling Speed**: Test horizontal pod/service scaling
- **Cost Analysis**: Calculate operational costs for each platform

## Lab 4: Serverless vs Traditional Architecture
**Duration**: 50 minutes | **Architecture Comparison**

### Side-by-Side Implementation
```yaml
# Traditional Architecture
traditional:
  components:
    - ALB: $16/month
    - EC2 (2x m5.large): $139/month
    - RDS: $45/month
  total_cost: $200/month
  scaling: Manual/Auto Scaling Groups

# Serverless Architecture  
serverless:
  components:
    - API Gateway: $3.50/month
    - Lambda: $8.35/month
    - DynamoDB: $12.50/month
  total_cost: $24.35/month
  scaling: Automatic
```

### Performance Testing
- **Cold Start Impact**: Measure Lambda cold start times
- **Throughput Comparison**: Test requests per second
- **Cost at Scale**: Calculate costs at different traffic levels
- **Operational Overhead**: Compare management complexity

## Lab 5: Infrastructure as Code Workshop
**Duration**: 65 minutes | **Automation Focus**

### CloudFormation vs CDK vs Terraform
```bash
# Deploy same infrastructure with different tools
aws cloudformation deploy --template-file infrastructure.yaml --stack-name cf-stack
cdk deploy infrastructure-stack
terraform apply infrastructure.tf
```

### Comparison Metrics
- **Deployment Time**: Measure stack creation time
- **Code Complexity**: Lines of code and readability
- **Error Handling**: Rollback and error recovery
- **State Management**: Compare state handling approaches

### Advanced Features
- **Blue/Green Deployments**: Implement zero-downtime deployments
- **Multi-Environment**: Deploy to dev/staging/prod with parameter variations
- **Drift Detection**: Identify and resolve configuration drift

## Assessment Integration

### Lab Performance Tracking
```python
class LabAssessment:
    def __init__(self):
        self.scoring_criteria = {
            'scaling_simulator': {
                'algorithm_understanding': 25,
                'cost_optimization': 20,
                'performance_analysis': 15
            },
            'cost_optimizer': {
                'workload_analysis': 25,
                'savings_calculation': 20,
                'recommendation_quality': 15
            },
            'container_orchestration': {
                'platform_comparison': 30,
                'performance_benchmarking': 20,
                'cost_analysis': 10
            }
        }
    
    def evaluate_completion(self, student_id, lab_results):
        total_score = 0
        for lab, results in lab_results.items():
            lab_score = self.calculate_lab_score(lab, results)
            total_score += lab_score
        
        return {
            'total_score': total_score,
            'grade': self.calculate_grade(total_score),
            'recommendations': self.generate_recommendations(lab_results)
        }
```

### Real-time Progress Tracking
- **Completion Metrics**: Track lab progress and time spent
- **Performance Benchmarks**: Compare results against expected outcomes
- **Skill Gap Analysis**: Identify areas needing additional practice
- **Peer Comparison**: Anonymous benchmarking against cohort
