# Exercise 10: Cache Cost Optimization

## Overview

**Duration**: 4-5 hours  
**Difficulty**: Advanced  
**Prerequisites**: Exercise 1-9 completion, understanding of cost analysis

## Learning Objectives

By completing this exercise, you will:
- Implement comprehensive cache cost analysis and optimization
- Design cost-effective caching strategies
- Create automated cost monitoring and alerting
- Optimize cache ROI and resource utilization

## Scenario

You are implementing cost optimization for a large-scale caching system with the following requirements:

### Cost Constraints
- **Monthly Budget**: $50,000 for caching infrastructure
- **Cost per Request**: < $0.001 per cache request
- **Storage Cost**: < $0.10 per GB per month
- **Bandwidth Cost**: < $0.05 per GB transferred

### Scale Requirements
- **Cache Nodes**: 100+ nodes across multiple regions
- **Data Volume**: 10TB+ cached data
- **Request Volume**: 100M+ requests per day
- **Global Distribution**: 20+ countries

### Performance Requirements
- **Cost Optimization**: 30% cost reduction target
- **Performance Impact**: < 5% performance degradation
- **ROI Target**: > 300% return on investment
- **Cost Visibility**: Real-time cost monitoring

## Exercise Tasks

### Task 1: Cache Cost Analysis Framework (90 minutes)

Implement comprehensive cache cost analysis:

1. **Cost Component Analysis**
   - Infrastructure costs (compute, storage, network)
   - Operational costs (monitoring, maintenance, support)
   - Data transfer costs (ingress, egress, cross-region)
   - Cache invalidation costs

2. **Cost Attribution System**
   - Per-service cost attribution
   - Per-user cost tracking
   - Per-region cost analysis
   - Per-data-type cost breakdown

**Implementation Requirements**:
```python
class CacheCostAnalyzer:
    def __init__(self, cost_config, metrics_collector):
        self.cost_config = cost_config
        self.metrics = metrics_collector
        self.cost_components = {}
        self.attribution_data = {}
        
    def analyze_infrastructure_costs(self) -> Dict[str, float]:
        """Analyze infrastructure costs"""
        pass
    
    def analyze_operational_costs(self) -> Dict[str, float]:
        """Analyze operational costs"""
        pass
    
    def analyze_data_transfer_costs(self) -> Dict[str, float]:
        """Analyze data transfer costs"""
        pass
    
    def calculate_total_cost(self) -> Dict[str, Any]:
        """Calculate total cache costs"""
        pass
    
    def attribute_costs_by_service(self, service_name: str) -> Dict[str, float]:
        """Attribute costs to specific service"""
        pass
```

### Task 2: Cost Optimization Strategies (75 minutes)

Implement various cost optimization strategies:

1. **Storage Optimization**
   - Data compression and deduplication
   - TTL optimization based on access patterns
   - Tiered storage strategies
   - Data lifecycle management

2. **Compute Optimization**
   - Right-sizing cache instances
   - Auto-scaling based on demand
   - Spot instance utilization
   - Reserved instance planning

**Implementation Requirements**:
```python
class CacheCostOptimizer:
    def __init__(self, cost_analyzer, cache_manager):
        self.cost_analyzer = cost_analyzer
        self.cache_manager = cache_manager
        self.optimization_strategies = {}
        self.cost_savings = {}
        
    def optimize_storage_costs(self) -> Dict[str, Any]:
        """Optimize storage costs"""
        pass
    
    def optimize_compute_costs(self) -> Dict[str, Any]:
        """Optimize compute costs"""
        pass
    
    def optimize_network_costs(self) -> Dict[str, Any]:
        """Optimize network costs"""
        pass
    
    def implement_tiered_storage(self) -> Dict[str, Any]:
        """Implement tiered storage strategy"""
        pass
    
    def optimize_ttl_policies(self) -> Dict[str, Any]:
        """Optimize TTL policies for cost efficiency"""
        pass
```

### Task 3: Automated Cost Monitoring (60 minutes)

Implement automated cost monitoring and alerting:

1. **Real-time Cost Tracking**
   - Real-time cost monitoring
   - Cost trend analysis
   - Budget tracking and alerting
   - Cost anomaly detection

2. **Cost Reporting System**
   - Daily, weekly, monthly cost reports
   - Cost breakdown by service and region
   - ROI analysis and reporting
   - Cost forecasting

**Implementation Requirements**:
```python
class CostMonitoringSystem:
    def __init__(self, cost_analyzer, alert_manager):
        self.cost_analyzer = cost_analyzer
        self.alerts = alert_manager
        self.cost_thresholds = {}
        self.budget_limits = {}
        
    def monitor_real_time_costs(self) -> Dict[str, Any]:
        """Monitor real-time costs"""
        pass
    
    def detect_cost_anomalies(self) -> List[Dict[str, Any]]:
        """Detect cost anomalies"""
        pass
    
    def generate_cost_reports(self, period: str) -> Dict[str, Any]:
        """Generate cost reports"""
        pass
    
    def forecast_costs(self, months: int) -> Dict[str, Any]:
        """Forecast future costs"""
        pass
    
    def setup_cost_alerts(self) -> None:
        """Setup cost monitoring alerts"""
        pass
```

### Task 4: ROI Analysis and Optimization (45 minutes)

Implement ROI analysis and optimization:

1. **ROI Calculation**
   - Calculate cache ROI based on performance gains
   - Measure cost savings from reduced database load
   - Analyze performance improvement value
   - Calculate break-even analysis

2. **Optimization Recommendations**
   - Generate cost optimization recommendations
   - Prioritize optimization opportunities
   - Implement A/B testing for cost optimizations
   - Track optimization effectiveness

**Implementation Requirements**:
```python
class ROIAnalyzer:
    def __init__(self, cost_analyzer, performance_monitor):
        self.cost_analyzer = cost_analyzer
        self.performance_monitor = performance_monitor
        self.roi_metrics = {}
        
    def calculate_cache_roi(self) -> Dict[str, float]:
        """Calculate cache ROI"""
        pass
    
    def measure_performance_value(self) -> Dict[str, float]:
        """Measure value of performance improvements"""
        pass
    
    def calculate_break_even(self) -> Dict[str, Any]:
        """Calculate break-even analysis"""
        pass
    
    def generate_optimization_recommendations(self) -> List[Dict[str, Any]]:
        """Generate optimization recommendations"""
        pass
    
    def track_optimization_effectiveness(self) -> Dict[str, Any]:
        """Track effectiveness of optimizations"""
        pass
```

## Performance Targets

### Cost Optimization
- **Cost Reduction**: 30% reduction in total cache costs
- **Cost per Request**: < $0.001 per cache request
- **Storage Efficiency**: > 80% storage utilization
- **ROI**: > 300% return on investment

### Cost Monitoring
- **Cost Visibility**: Real-time cost tracking
- **Alert Response**: < 5 minutes for cost threshold alerts
- **Report Generation**: < 1 minute for cost reports
- **Forecast Accuracy**: > 90% accuracy for 3-month forecasts

### Optimization Effectiveness
- **Optimization Implementation**: < 24 hours for automated optimizations
- **Performance Impact**: < 5% performance degradation
- **Cost Savings Tracking**: 100% of savings tracked
- **ROI Improvement**: > 20% ROI improvement

## Evaluation Criteria

### Technical Implementation (40%)
- **Cost Analysis**: Comprehensive cost analysis framework
- **Optimization Strategies**: Effective cost optimization strategies
- **Monitoring**: Real-time cost monitoring and alerting
- **ROI Analysis**: Accurate ROI calculation and analysis

### Cost Achievement (30%)
- **Cost Reduction**: Meets cost reduction targets
- **Cost Efficiency**: Achieves cost efficiency targets
- **ROI**: Meets ROI targets
- **Budget Management**: Stays within budget constraints

### Monitoring and Analytics (20%)
- **Cost Visibility**: Comprehensive cost visibility
- **Alerting**: Effective cost alerting system
- **Reporting**: Detailed cost reporting
- **Forecasting**: Accurate cost forecasting

### Optimization and Innovation (10%)
- **Innovation**: Creative cost optimization approaches
- **Automation**: Automated optimization implementation
- **Effectiveness**: Measurable optimization effectiveness
- **Continuous Improvement**: Plans for ongoing optimization

## Sample Implementation

### Cache Cost Analyzer Implementation

```python
import time
import json
from typing import Dict, List, Any, Optional
from dataclasses import dataclass
from datetime import datetime, timedelta

@dataclass
class CostComponent:
    name: str
    cost_per_unit: float
    units: float
    total_cost: float
    category: str

class CacheCostAnalyzer:
    def __init__(self, cost_config: Dict[str, Any], metrics_collector):
        self.cost_config = cost_config
        self.metrics = metrics_collector
        self.cost_components = {}
        self.attribution_data = {}
        self.cost_history = []
        
    def analyze_infrastructure_costs(self) -> Dict[str, float]:
        """Analyze infrastructure costs"""
        infrastructure_costs = {}
        
        # Compute costs
        compute_costs = self._analyze_compute_costs()
        infrastructure_costs.update(compute_costs)
        
        # Storage costs
        storage_costs = self._analyze_storage_costs()
        infrastructure_costs.update(storage_costs)
        
        # Network costs
        network_costs = self._analyze_network_costs()
        infrastructure_costs.update(network_costs)
        
        return infrastructure_costs
    
    def _analyze_compute_costs(self) -> Dict[str, float]:
        """Analyze compute costs"""
        compute_costs = {}
        
        # Get cache node information
        nodes = self.metrics.get_cache_nodes()
        
        for node in nodes:
            node_type = node.get('instance_type', 'm5.large')
            hours_running = node.get('hours_running', 24)
            
            # Calculate compute cost
            hourly_rate = self.cost_config['compute_rates'].get(node_type, 0.1)
            daily_cost = hourly_rate * hours_running
            
            compute_costs[f"compute_{node['id']}"] = daily_cost
        
        return compute_costs
    
    def _analyze_storage_costs(self) -> Dict[str, float]:
        """Analyze storage costs"""
        storage_costs = {}
        
        # Get storage information
        storage_info = self.metrics.get_storage_info()
        
        for region, info in storage_info.items():
            storage_gb = info.get('storage_gb', 0)
            storage_type = info.get('storage_type', 'gp2')
            
            # Calculate storage cost
            gb_rate = self.cost_config['storage_rates'].get(storage_type, 0.10)
            daily_cost = (storage_gb * gb_rate) / 30  # Convert monthly to daily
            
            storage_costs[f"storage_{region}"] = daily_cost
        
        return storage_costs
    
    def _analyze_network_costs(self) -> Dict[str, float]:
        """Analyze network costs"""
        network_costs = {}
        
        # Get network usage
        network_usage = self.metrics.get_network_usage()
        
        for region, usage in network_usage.items():
            data_in = usage.get('data_in_gb', 0)
            data_out = usage.get('data_out_gb', 0)
            
            # Calculate network costs
            in_rate = self.cost_config['network_rates'].get('data_in', 0.01)
            out_rate = self.cost_config['network_rates'].get('data_out', 0.05)
            
            daily_cost = (data_in * in_rate) + (data_out * out_rate)
            network_costs[f"network_{region}"] = daily_cost
        
        return network_costs
    
    def analyze_operational_costs(self) -> Dict[str, float]:
        """Analyze operational costs"""
        operational_costs = {}
        
        # Monitoring costs
        monitoring_cost = self._calculate_monitoring_cost()
        operational_costs['monitoring'] = monitoring_cost
        
        # Maintenance costs
        maintenance_cost = self._calculate_maintenance_cost()
        operational_costs['maintenance'] = maintenance_cost
        
        # Support costs
        support_cost = self._calculate_support_cost()
        operational_costs['support'] = support_cost
        
        return operational_costs
    
    def _calculate_monitoring_cost(self) -> float:
        """Calculate monitoring costs"""
        # CloudWatch costs
        metrics_count = self.metrics.get_metrics_count()
        alarms_count = self.metrics.get_alarms_count()
        
        metrics_cost = metrics_count * 0.30  # $0.30 per metric per month
        alarms_cost = alarms_count * 0.10    # $0.10 per alarm per month
        
        return (metrics_cost + alarms_cost) / 30  # Convert to daily
    
    def _calculate_maintenance_cost(self) -> float:
        """Calculate maintenance costs"""
        # Based on team size and time spent
        team_size = self.cost_config.get('maintenance_team_size', 2)
        hours_per_day = self.cost_config.get('maintenance_hours_per_day', 4)
        hourly_rate = self.cost_config.get('maintenance_hourly_rate', 50)
        
        return team_size * hours_per_day * hourly_rate
    
    def _calculate_support_cost(self) -> float:
        """Calculate support costs"""
        # AWS support costs
        support_tier = self.cost_config.get('support_tier', 'business')
        support_rates = {
            'basic': 0,
            'developer': 29,
            'business': 100,
            'enterprise': 15000
        }
        
        monthly_cost = support_rates.get(support_tier, 0)
        return monthly_cost / 30  # Convert to daily
    
    def analyze_data_transfer_costs(self) -> Dict[str, float]:
        """Analyze data transfer costs"""
        transfer_costs = {}
        
        # Get data transfer information
        transfer_info = self.metrics.get_data_transfer_info()
        
        for region, info in transfer_info.items():
            # In-region transfer
            in_region_gb = info.get('in_region_gb', 0)
            in_region_rate = self.cost_config['transfer_rates'].get('in_region', 0.01)
            
            # Cross-region transfer
            cross_region_gb = info.get('cross_region_gb', 0)
            cross_region_rate = self.cost_config['transfer_rates'].get('cross_region', 0.02)
            
            # Internet transfer
            internet_gb = info.get('internet_gb', 0)
            internet_rate = self.cost_config['transfer_rates'].get('internet', 0.09)
            
            daily_cost = (in_region_gb * in_region_rate + 
                         cross_region_gb * cross_region_rate + 
                         internet_gb * internet_rate)
            
            transfer_costs[f"transfer_{region}"] = daily_cost
        
        return transfer_costs
    
    def calculate_total_cost(self) -> Dict[str, Any]:
        """Calculate total cache costs"""
        # Infrastructure costs
        infrastructure_costs = self.analyze_infrastructure_costs()
        infrastructure_total = sum(infrastructure_costs.values())
        
        # Operational costs
        operational_costs = self.analyze_operational_costs()
        operational_total = sum(operational_costs.values())
        
        # Data transfer costs
        transfer_costs = self.analyze_data_transfer_costs()
        transfer_total = sum(transfer_costs.values())
        
        # Total costs
        total_daily_cost = infrastructure_total + operational_total + transfer_total
        total_monthly_cost = total_daily_cost * 30
        
        # Store cost history
        cost_entry = {
            'timestamp': time.time(),
            'infrastructure': infrastructure_total,
            'operational': operational_total,
            'transfer': transfer_total,
            'total_daily': total_daily_cost,
            'total_monthly': total_monthly_cost
        }
        self.cost_history.append(cost_entry)
        
        return {
            'infrastructure_costs': infrastructure_costs,
            'operational_costs': operational_costs,
            'transfer_costs': transfer_costs,
            'total_daily': total_daily_cost,
            'total_monthly': total_monthly_cost,
            'breakdown': {
                'infrastructure_percent': (infrastructure_total / total_daily_cost) * 100,
                'operational_percent': (operational_total / total_daily_cost) * 100,
                'transfer_percent': (transfer_total / total_daily_cost) * 100
            }
        }
    
    def attribute_costs_by_service(self, service_name: str) -> Dict[str, float]:
        """Attribute costs to specific service"""
        service_costs = {}
        
        # Get service usage metrics
        service_metrics = self.metrics.get_service_metrics(service_name)
        
        # Calculate service's share of total costs
        total_requests = self.metrics.get_total_requests()
        service_requests = service_metrics.get('requests', 0)
        service_share = service_requests / max(total_requests, 1)
        
        # Get total costs
        total_costs = self.calculate_total_cost()
        
        # Attribute costs
        for category, cost in total_costs.items():
            if isinstance(cost, dict):
                service_costs[category] = {}
                for component, amount in cost.items():
                    service_costs[category][component] = amount * service_share
            else:
                service_costs[category] = cost * service_share
        
        return service_costs
    
    def get_cost_trends(self, days: int = 30) -> Dict[str, Any]:
        """Get cost trends over specified days"""
        if not self.cost_history:
            return {}
        
        # Get recent history
        recent_history = self.cost_history[-days:]
        
        # Calculate trends
        daily_costs = [entry['total_daily'] for entry in recent_history]
        
        if len(daily_costs) < 2:
            return {'trend': 'insufficient_data'}
        
        # Calculate trend
        first_cost = daily_costs[0]
        last_cost = daily_costs[-1]
        trend_percent = ((last_cost - first_cost) / first_cost) * 100
        
        # Calculate average
        avg_daily_cost = sum(daily_costs) / len(daily_costs)
        
        return {
            'trend_percent': trend_percent,
            'avg_daily_cost': avg_daily_cost,
            'first_cost': first_cost,
            'last_cost': last_cost,
            'data_points': len(daily_costs)
        }
```

### Cache Cost Optimizer Implementation

```python
class CacheCostOptimizer:
    def __init__(self, cost_analyzer: CacheCostAnalyzer, cache_manager):
        self.cost_analyzer = cost_analyzer
        self.cache_manager = cache_manager
        self.optimization_strategies = {}
        self.cost_savings = {}
        
    def optimize_storage_costs(self) -> Dict[str, Any]:
        """Optimize storage costs"""
        optimization_results = {}
        
        # Analyze current storage usage
        storage_info = self.cost_analyzer.metrics.get_storage_info()
        
        for region, info in storage_info.items():
            current_gb = info.get('storage_gb', 0)
            storage_type = info.get('storage_type', 'gp2')
            
            # Calculate potential savings from compression
            compression_ratio = self._calculate_compression_ratio(region)
            compressed_gb = current_gb * (1 - compression_ratio)
            
            # Calculate cost savings
            gb_rate = self.cost_analyzer.cost_config['storage_rates'].get(storage_type, 0.10)
            daily_savings = (current_gb - compressed_gb) * gb_rate / 30
            
            optimization_results[f"compression_{region}"] = {
                'current_gb': current_gb,
                'compressed_gb': compressed_gb,
                'savings_gb': current_gb - compressed_gb,
                'daily_savings': daily_savings,
                'monthly_savings': daily_savings * 30
            }
        
        return optimization_results
    
    def _calculate_compression_ratio(self, region: str) -> float:
        """Calculate compression ratio for region"""
        # Analyze data types in region
        data_types = self.cost_analyzer.metrics.get_data_types(region)
        
        compression_ratios = {
            'json': 0.3,      # 30% compression
            'text': 0.5,      # 50% compression
            'binary': 0.1,    # 10% compression
            'images': 0.2     # 20% compression
        }
        
        total_data = sum(data_types.values())
        weighted_compression = 0
        
        for data_type, amount in data_types.items():
            ratio = compression_ratios.get(data_type, 0.2)
            weighted_compression += (amount / total_data) * ratio
        
        return weighted_compression
    
    def optimize_compute_costs(self) -> Dict[str, Any]:
        """Optimize compute costs"""
        optimization_results = {}
        
        # Analyze current compute usage
        nodes = self.cost_analyzer.metrics.get_cache_nodes()
        
        for node in nodes:
            node_id = node['id']
            current_type = node.get('instance_type', 'm5.large')
            cpu_utilization = node.get('cpu_utilization', 0)
            memory_utilization = node.get('memory_utilization', 0)
            
            # Recommend instance type based on utilization
            recommended_type = self._recommend_instance_type(cpu_utilization, memory_utilization)
            
            if recommended_type != current_type:
                # Calculate cost savings
                current_rate = self.cost_analyzer.cost_config['compute_rates'].get(current_type, 0.1)
                recommended_rate = self.cost_analyzer.cost_config['compute_rates'].get(recommended_type, 0.1)
                
                daily_savings = (current_rate - recommended_rate) * 24
                
                optimization_results[f"rightsize_{node_id}"] = {
                    'current_type': current_type,
                    'recommended_type': recommended_type,
                    'current_rate': current_rate,
                    'recommended_rate': recommended_rate,
                    'daily_savings': daily_savings,
                    'monthly_savings': daily_savings * 30
                }
        
        return optimization_results
    
    def _recommend_instance_type(self, cpu_util: float, memory_util: float) -> str:
        """Recommend instance type based on utilization"""
        if cpu_util < 20 and memory_util < 30:
            return 't3.micro'
        elif cpu_util < 40 and memory_util < 50:
            return 't3.small'
        elif cpu_util < 60 and memory_util < 70:
            return 't3.medium'
        elif cpu_util < 80 and memory_util < 80:
            return 'm5.large'
        else:
            return 'm5.xlarge'
    
    def optimize_network_costs(self) -> Dict[str, Any]:
        """Optimize network costs"""
        optimization_results = {}
        
        # Analyze network usage patterns
        network_usage = self.cost_analyzer.metrics.get_network_usage()
        
        for region, usage in network_usage.items():
            data_out = usage.get('data_out_gb', 0)
            
            # Check if we can optimize with CloudFront
            if data_out > 100:  # More than 100GB per day
                # Calculate CloudFront savings
                current_rate = self.cost_analyzer.cost_config['network_rates'].get('data_out', 0.05)
                cloudfront_rate = 0.085  # CloudFront rate per GB
                
                # CloudFront is more expensive for small amounts but cheaper for large amounts
                if data_out > 1000:  # More than 1TB per day
                    daily_savings = data_out * (current_rate - cloudfront_rate)
                    
                    optimization_results[f"cloudfront_{region}"] = {
                        'current_rate': current_rate,
                        'cloudfront_rate': cloudfront_rate,
                        'data_out_gb': data_out,
                        'daily_savings': daily_savings,
                        'monthly_savings': daily_savings * 30
                    }
        
        return optimization_results
    
    def implement_tiered_storage(self) -> Dict[str, Any]:
        """Implement tiered storage strategy"""
        optimization_results = {}
        
        # Analyze data access patterns
        access_patterns = self.cost_analyzer.metrics.get_access_patterns()
        
        for region, patterns in access_patterns.items():
            hot_data_gb = patterns.get('hot_data_gb', 0)
            warm_data_gb = patterns.get('warm_data_gb', 0)
            cold_data_gb = patterns.get('cold_data_gb', 0)
            
            # Calculate tiered storage costs
            hot_rate = 0.10    # gp2 rate
            warm_rate = 0.05   # gp3 rate
            cold_rate = 0.01   # S3 IA rate
            
            current_cost = (hot_data_gb + warm_data_gb + cold_data_gb) * hot_rate / 30
            tiered_cost = (hot_data_gb * hot_rate + 
                          warm_data_gb * warm_rate + 
                          cold_data_gb * cold_rate) / 30
            
            daily_savings = current_cost - tiered_cost
            
            optimization_results[f"tiered_storage_{region}"] = {
                'hot_data_gb': hot_data_gb,
                'warm_data_gb': warm_data_gb,
                'cold_data_gb': cold_data_gb,
                'current_cost': current_cost,
                'tiered_cost': tiered_cost,
                'daily_savings': daily_savings,
                'monthly_savings': daily_savings * 30
            }
        
        return optimization_results
    
    def optimize_ttl_policies(self) -> Dict[str, Any]:
        """Optimize TTL policies for cost efficiency"""
        optimization_results = {}
        
        # Analyze TTL usage patterns
        ttl_patterns = self.cost_analyzer.metrics.get_ttl_patterns()
        
        for data_type, patterns in ttl_patterns.items():
            current_ttl = patterns.get('current_ttl', 3600)
            access_frequency = patterns.get('access_frequency', 0)
            miss_rate = patterns.get('miss_rate', 0)
            
            # Calculate optimal TTL
            optimal_ttl = self._calculate_optimal_ttl(access_frequency, miss_rate)
            
            if optimal_ttl != current_ttl:
                # Calculate cost impact
                cost_impact = self._calculate_ttl_cost_impact(data_type, current_ttl, optimal_ttl)
                
                optimization_results[f"ttl_{data_type}"] = {
                    'current_ttl': current_ttl,
                    'optimal_ttl': optimal_ttl,
                    'access_frequency': access_frequency,
                    'miss_rate': miss_rate,
                    'cost_impact': cost_impact
                }
        
        return optimization_results
    
    def _calculate_optimal_ttl(self, access_frequency: float, miss_rate: float) -> int:
        """Calculate optimal TTL based on access patterns"""
        # Simple heuristic: higher access frequency = longer TTL
        # Higher miss rate = shorter TTL
        
        base_ttl = 3600  # 1 hour base
        
        # Adjust based on access frequency
        frequency_factor = min(access_frequency / 100, 2.0)  # Cap at 2x
        
        # Adjust based on miss rate
        miss_factor = max(1 - miss_rate, 0.5)  # Lower miss rate = longer TTL
        
        optimal_ttl = int(base_ttl * frequency_factor * miss_factor)
        
        # Clamp between 300 seconds and 86400 seconds
        return max(300, min(optimal_ttl, 86400))
    
    def _calculate_ttl_cost_impact(self, data_type: str, current_ttl: int, optimal_ttl: int) -> float:
        """Calculate cost impact of TTL change"""
        # Longer TTL = less database load = cost savings
        # Shorter TTL = more cache misses = cost increase
        
        ttl_ratio = optimal_ttl / current_ttl
        
        # Estimate cost impact based on TTL ratio
        if ttl_ratio > 1:
            # Longer TTL - cost savings
            return 0.1 * (ttl_ratio - 1)  # 10% savings per TTL doubling
        else:
            # Shorter TTL - cost increase
            return -0.05 * (1 - ttl_ratio)  # 5% increase per TTL halving
```

## Additional Resources

### Cost Optimization
- [AWS Cost Optimization](https://aws.amazon.com/pricing/cost-optimization/)
- [Cloud Cost Management](https://en.wikipedia.org/wiki/Cloud_computing#Cost)
- [ROI Analysis](https://en.wikipedia.org/wiki/Return_on_investment)

### Cost Analysis Tools
- **AWS Cost Explorer**: AWS cost analysis
- **CloudHealth**: Multi-cloud cost management
- **Cloudability**: Cloud cost optimization
- **Kubernetes Cost Analysis**: Container cost optimization

### Best Practices
- Monitor costs continuously
- Implement automated cost optimization
- Use reserved instances for predictable workloads
- Optimize data transfer and storage costs
- Regular cost reviews and optimization

## Next Steps

After completing this exercise:
1. **Deploy**: Deploy cost optimization system
2. **Monitor**: Set up comprehensive cost monitoring
3. **Optimize**: Implement automated optimizations
4. **Review**: Regular cost review and optimization
5. **Improve**: Continuously improve cost efficiency

---

**Last Updated**: 2024-01-15  
**Version**: 1.0  
**Next Review**: 2024-02-15
